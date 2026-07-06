import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/firebase_error_mapper.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // ── Mevcut kullanıcı ────────────────────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;
  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  // Auth durum stream'i — uygulama genelinde dinlenebilir
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Kullanıcı adı müsaitlik kontrolü ────────────────────────────────────────
  // where sorgusu kullanılmaz — sadece doküman ID'si ile tekil get() yapılır.
  static Future<bool> isUsernameTaken(String username) async {
    final doc = await _db.collection(kUsernamesCollection).doc(username).get();
    return doc.exists;
  }

  // ── Kayıt ──────────────────────────────────────────────────────────────────
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
    required DateTime birthDate,
    required String username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);
    // Firestore profil belgesi ve kullanıcı adı rezervasyonu — başarısız olursa
    // yarım kalmış Auth hesabını geri al (rollback), hatayı yutma.
    try {
      await _db.collection(kUsersCollection).doc(cred.user!.uid).set({
        'ad': displayName,
        'email': email,
        'fotoURL': null,
        'dogumTarihi': Timestamp.fromDate(birthDate),
        'kullaniciAdi': username,
        'olusturmaTarihi': FieldValue.serverTimestamp(),
        'anonim': false,
      });
      await _db.collection(kUsernamesCollection).doc(username).set({
        'uid': cred.user!.uid,
      });
    } catch (e) {
      debugPrint('Firestore kullanıcı belgesi oluşturulamadı, hesap geri alınıyor: $e');
      try {
        await cred.user!.delete();
      } catch (rollbackError) {
        debugPrint('Rollback sırasında hesap silinemedi: $rollbackError');
      }
      rethrow;
    }
    return cred;
  }

  // ── Giriş ──────────────────────────────────────────────────────────────────
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── Misafir girişi ─────────────────────────────────────────────────────────
  static Future<UserCredential> signInAnonymously() async {
    return _auth.signInAnonymously();
  }

  // ── Çıkış ──────────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Hesap silme ──────────────────────────────────────────────────────────
  // Kullanıcı adı rezervasyonu, favoriler ve profil dokümanını, ardından
  // Auth hesabını siler. Firestore rules gereği bu sıra korunmalı — Auth
  // hesabı önce silinirse users/{uid} silme kuralı (auth.uid == userId) geçersiz kalır.
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final userDoc = await _db.collection(kUsersCollection).doc(uid).get();
    final username = userDoc.data()?['kullaniciAdi'] as String?;

    if (username != null) {
      await _db.collection(kUsernamesCollection).doc(username).delete();
    }
    await _db.collection(kFavorilerCollection).doc(uid).delete();
    await _db.collection(kUsersCollection).doc(uid).delete();

    await user.delete();
  }

  // ── Hesap bilgileri güncelleme ─────────────────────────────────────────────
  // Kullanıcı adı değiştiyse eski rezervasyon silinip yenisi alınır (signUp'taki
  // rezervasyon deseniyle tutarlı). Aynıysa sadece ad güncellenir.
  static Future<void> updateProfileBasics({
    required String ad,
    required String soyad,
    required String currentUsername,
    required String newUsername,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    if (newUsername != currentUsername) {
      if (await isUsernameTaken(newUsername)) {
        throw Exception('kullanici-adi-alinmis');
      }
      final batch = _db.batch();
      batch.delete(_db.collection(kUsernamesCollection).doc(currentUsername));
      batch.set(_db.collection(kUsernamesCollection).doc(newUsername), {'uid': uid});
      batch.update(_db.collection(kUsersCollection).doc(uid), {
        'ad': ad,
        'soyad': soyad,
        'kullaniciAdi': newUsername,
      });
      await batch.commit();
    } else {
      await _db.collection(kUsersCollection).doc(uid).update({'ad': ad, 'soyad': soyad});
    }
    await user.updateDisplayName('$ad $soyad'.trim());
  }

  // ── E-posta doğrulama ──────────────────────────────────────────────────────
  static Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Auth'un yerel önbelleğini sunucudan tazeler, güncel emailVerified değerini döner.
  static Future<bool> reloadAndCheckEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Firebase hata kodunu Türkçeye çevir — FirebaseErrorMapper'a delege edildi
  static String errorMessage(String code) => FirebaseErrorMapper.map(code);
}
