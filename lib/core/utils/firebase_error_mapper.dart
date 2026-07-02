// Firebase Auth hata kodlarını Türkçe mesajlara çevirir
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String map(String code) {
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
        return 'Bu giriş yöntemi etkin değil.';
      case 'network-request-failed':
        return 'İnternet bağlantısını kontrol edin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'requires-recent-login':
        return 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
