import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

// Profil "İstatistiklerim" bölümü için sayaç/streak yazma işlemleri.
// users/{userId}.istatistikler map'ini transaction ile günceller.
class StatsService {
  static final _users = FirebaseFirestore.instance.collection(kUsersCollection);

  static String _monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static Future<void> incrementSearchCount(String userId) =>
      _bumpCounter(userId, prefix: 'aranan_urun');

  static Future<void> registerVenueDiscovered(String userId, String venueId) =>
      _registerUnique(userId, prefix: 'kesfedilen_mekan', itemId: venueId);

  static Future<void> registerProductClicked(String userId, String productId) =>
      _registerUnique(userId, prefix: 'tiklanan_urun', itemId: productId);

  static Future<void> registerArticleRead(String userId, String articleId) =>
      _registerUnique(userId, prefix: 'okunan_makale', itemId: articleId);

  // Basit eylem sayacı: her çağrıda toplam +1, ay değiştiyse "bu ay" sıfırlanıp +1
  static Future<void> _bumpCounter(String userId, {required String prefix}) {
    final docRef = _users.doc(userId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final stats = (snap.data()?['istatistikler'] as Map<String, dynamic>?) ?? {};

      final currentMonthKey = _monthKey(DateTime.now());
      final storedMonthKey = stats['${prefix}_ay_anahtari'] as String?;
      final total = (stats['${prefix}_toplam'] as int?) ?? 0;
      final monthCount =
          storedMonthKey == currentMonthKey ? (stats['${prefix}_bu_ay'] as int?) ?? 0 : 0;

      tx.set(
        docRef,
        {
          'istatistikler': {
            '${prefix}_toplam': total + 1,
            '${prefix}_bu_ay': monthCount + 1,
            '${prefix}_ay_anahtari': currentMonthKey,
          },
        },
        SetOptions(merge: true),
      );
    });
  }

  // Benzersizlik sayacı: itemId daha önce görülmediyse array'e eklenir ve sayaçlar artar
  static Future<void> _registerUnique(
    String userId, {
    required String prefix,
    required String itemId,
  }) {
    final docRef = _users.doc(userId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final stats = (snap.data()?['istatistikler'] as Map<String, dynamic>?) ?? {};

      final ids = List<String>.from(stats['${prefix}_idleri'] as List? ?? const []);
      if (ids.contains(itemId)) return; // zaten sayılmış, tekrar sayma

      final currentMonthKey = _monthKey(DateTime.now());
      final storedMonthKey = stats['${prefix}_ay_anahtari'] as String?;
      final monthCount =
          storedMonthKey == currentMonthKey ? (stats['${prefix}_bu_ay'] as int?) ?? 0 : 0;

      ids.add(itemId);
      tx.set(
        docRef,
        {
          'istatistikler': {
            '${prefix}_idleri': ids,
            '${prefix}_bu_ay': monthCount + 1,
            '${prefix}_ay_anahtari': currentMonthKey,
          },
        },
        SetOptions(merge: true),
      );
    });
  }

  // Günlük giriş serisi: takvim günü bazında ardışıklık kontrolü
  static Future<void> registerDailyVisit(String userId) {
    final docRef = _users.doc(userId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final stats = (snap.data()?['istatistikler'] as Map<String, dynamic>?) ?? {};

      final lastTimestamp = stats['son_giris_tarihi'] as Timestamp?;
      final currentStreak = (stats['giris_serisi'] as int?) ?? 0;
      final record = (stats['giris_serisi_rekor'] as int?) ?? 0;

      final today = _dateOnly(DateTime.now());
      final lastDay = lastTimestamp != null ? _dateOnly(lastTimestamp.toDate()) : null;
      final dayDiff = lastDay != null ? today.difference(lastDay).inDays : null;

      if (dayDiff == 0) return; // bugün zaten kaydedilmiş

      final newStreak = dayDiff == 1 ? currentStreak + 1 : 1;

      tx.set(
        docRef,
        {
          'istatistikler': {
            'giris_serisi': newStreak,
            'giris_serisi_rekor': newStreak > record ? newStreak : record,
            'son_giris_tarihi': Timestamp.fromDate(today),
          },
        },
        SetOptions(merge: true),
      );
    });
  }
}
