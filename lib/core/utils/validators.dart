// Form doğrulama fonksiyonları — TextFormField validator parametresine uygun
class Validators {
  Validators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-posta gerekli.';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Geçersiz e-posta adresi.';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Şifre gerekli.';
    if (v.length < 6) return 'Şifre en az 6 karakter olmalı.';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ad soyad gerekli.';
    if (v.trim().length < 2) return 'Ad soyad en az 2 karakter olmalı.';
    return null;
  }

  // Şifre tekrar kontrolü: diğer şifre alanının değeri `other` olarak geçirilir
  static String? Function(String?) passwordMatch(String other) {
    return (String? v) {
      if (v == null || v.isEmpty) return 'Şifre tekrar gerekli.';
      if (v != other) return 'Şifreler eşleşmiyor.';
      return null;
    };
  }

  static String? required(String? v, {String label = 'Bu alan'}) {
    if (v == null || v.trim().isEmpty) return '$label gerekli.';
    return null;
  }
}
