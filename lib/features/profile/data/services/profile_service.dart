import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

// Kullanıcı profil verisi (users/{userId}) okuma/yazma
class ProfileService {
  static final _users = FirebaseFirestore.instance.collection(kUsersCollection);

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String userId) =>
      _users.doc(userId).snapshots();

  static Future<void> setDiagnosisDate(String userId, DateTime date) =>
      _users.doc(userId).set(
        {'tani_tarihi': Timestamp.fromDate(date)},
        SetOptions(merge: true),
      );
}
