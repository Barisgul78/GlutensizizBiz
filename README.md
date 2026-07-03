[README.md](https://github.com/user-attachments/files/29626382/README.md)
# 🌾 GlutensizizBiz

<p align="center">
  <img src="assets/images/logo.png" alt="GlutensizizBiz Logo" width="120"/>
</p>

<p align="center">
  Türkiye'nin çölyak hastaları ve gluten hassasiyeti olan bireyler için geliştirilmiş kapsamlı mobil rehber uygulaması.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat" />
  <img src="https://img.shields.io/badge/Durum-Geliştirme%20Aşamasında-orange?style=flat" />
</p>

---

## 📱 Uygulama Hakkında

**GlutensizizBiz**, Türkiye'deki çölyak hastaları ve gluten hassasiyeti olan bireylerin günlük hayatını kolaylaştırmak amacıyla geliştirilmiş bir Flutter mobil uygulamasıdır. Glutensiz ürün rehberinden belediye yardımlarına, yakındaki glutensiz mekânlardan sağlık içeriklerine kadar her şey tek uygulamada toplanmıştır.

---

## ✨ Özellikler

### 🏠 Anasayfa
- Kişiselleştirilmiş kullanıcı karşılama
- Günün glutensiz ipucu (kaydırılabilir)
- Yakındaki glutensiz mekânlar (mini harita)
- Popüler rehber kategorileri
- Haftanın markası

### 🔍 Ürün Arama
- Ürün adıyla arama
- Barkod tarama ile anında sorgulama
- Glutensiz ürün ve marka veritabanı
- Ürün değişiklik bildirimi

### 📚 Rehber
Kategorilere ayrılmış bilgi içerikleri:
- 🏥 Çölyak Hastalığı
- 👨‍🍳 Glutensiz Tarifler
- 🏛️ Belediye Destekleri (konuma göre)
- 💊 Sağlık İpuçları
- 📰 Güncel Haberler
- 🧒 Çocuklarda Çölyak
- 🛒 Alışveriş Rehberi
- 📋 Diyet Listeleri

### 📍 Mekânlar
- Konuma göre glutensiz kafe, restoran, fırın
- Harita üzerinde görüntüleme (flutter_map)
- Telefon harita uygulamasına yönlendirme
- Kullanıcı yorumları ve puanlama

### 👤 Profil
- Sağlık profili (Çölyak / Gluten Hassasiyeti / Ebeveyn)
- Tanı yılı ve şehir bilgisi
- Rozet sistemi (gamification)
- Sağlık kartı (QR ile doktora göster)
- Bildirim ayarları

---

## 🛠️ Teknoloji Altyapısı

| Teknoloji | Kullanım Amacı |
|---|---|
| Flutter | Cross-platform mobil geliştirme |
| Dart | Programlama dili |
| Firebase | Veritabanı, kimlik doğrulama |
| flutter_map | Harita görüntüleme (OpenStreetMap) |
| go_router | Sayfa yönlendirme |
| Provider | State management |
| google_fonts | Montserrat yazı tipi |
| url_launcher | Harici uygulama yönlendirme |

---

## 📁 Proje Yapısı

```
lib/
├── constants/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_constants.dart
├── models/
│   ├── product_model.dart
│   ├── place_model.dart
│   └── article_model.dart
├── screens/
│   ├── home/
│   ├── search/
│   ├── guide/
│   ├── places/
│   ├── favorites/
│   └── profile/
├── widgets/
│   ├── common/
│   └── cards/
├── services/
│   ├── firebase_service.dart
│   └── location_service.dart
├── router/
│   └── app_router.dart
└── main.dart
```

---

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio veya VS Code
- Firebase hesabı

### Adımlar

```bash
# Repoyu klonla
git clone https://github.com/kullaniciadi/glutensiziz-biz.git

# Proje dizinine gir
cd glutensiziz-biz

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

### Firebase Kurulumu
1. [Firebase Console](https://console.firebase.google.com)'dan yeni proje oluştur
2. Android ve iOS uygulamalarını ekle
3. `google-services.json` dosyasını `android/app/` klasörüne koy
4. `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne koy

---

## 📸 Ekran Görüntüleri

| Anasayfa | Rehber | Profil |
|---|---|---|
| _yakında_ | _yakında_ | _yakında_ |

---

## 🗺️ Yol Haritası

- [x] UI/UX tasarımı
- [x] Proje mimarisi
- [ ] Kimlik doğrulama (giriş/kayıt)
- [ ] Ürün veritabanı
- [ ] Barkod tarama
- [ ] Harita entegrasyonu
- [ ] Rehber içerikleri
- [ ] Bildirim sistemi
- [ ] Rozet sistemi
- [ ] App Store & Google Play yayını

---

## 🤝 Katkıda Bulunanlar

| İsim | Rol |
|---|---|
| Barış Can Gül | Geliştirici |

---

## 📬 İletişim

Proje hakkında iş birliği veya öneri için:

- GitHub: https://github.com/Barisgul78
- E-posta: gulbariscan502@gmail.com

---

<p align="center">
  Türkiye'deki tüm çölyak hastaları için ❤️ ile geliştirildi
</p>
