import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // ── Mevcut kullanıcı ────────────────────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;
  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  // Auth durum stream'i — uygulama genelinde dinlenebilir
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Kayıt ──────────────────────────────────────────────────────────────────
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);
    // Firestore profil belgesi — başarısız olsa bile auth geçerli
    try {
      await _db.collection('users').doc(cred.user!.uid).set({
        'ad': displayName,
        'email': email,
        'fotoURL': null,
        'olusturmaTarihi': FieldValue.serverTimestamp(),
        'anonim': false,
      });
    } catch (e) {
      debugPrint('Firestore kullanıcı belgesi oluşturulamadı: $e');
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

  // ── Firebase hata kodunu Türkçeye çevir ────────────────────────────────────
  static String errorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen biraz bekleyin.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi etkin değil. Firebase Console\'dan aktif edin.';
      case 'network-request-failed':
        return 'İnternet bağlantısını kontrol edin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
