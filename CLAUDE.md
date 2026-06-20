# GluFree - Claude Code Geliştirme Rehberi

Bu dosya Claude Code için ana proje rehberidir. Her yeni istek, refactor ve revize bu kurallar okunmuş kabul edilerek yapılmalıdır.

## 1. Proje Özeti

- **Uygulama:** GluFree — glutensiz ürün ve mekan keşif uygulaması.
- **Hedef kitle:** Çölyak hastalığı ve gluten hassasiyeti olan kullanıcılar.
- **Platform:** Flutter ile iOS ve Android.
- **Mevcut stack:** Flutter, Dart, Firebase Auth, Cloud Firestore, google_fonts, shared_preferences.
- **Mevcut akış:** MainView (BottomNavigationBar, 5 sekme):
  - **Anasayfa** — hero banner, popüler glutensiz mekanlar carousel, yeni eklenen ürünler grid, glutensiz ipuçları/blog bento kartları.
  - **Ara** — ürün adı/marka/kategori filtresiyle Firestore canlı arama; barkod tarayıcı entegrasyonu planlanıyor.
  - **Mekanlar** — glutensiz restoran/kafe/belediye listesi, puan, mesafe, filtre.
  - **Favoriler** — sekmeli (Mekanlar / Ürünler) favori listesi; Firestore + local storage ile senkron.
  - **Profil** — kullanıcı bilgisi, ayarlar, çıkış.
- **UI dili:** Türkçe.
- **Backend:** Firebase (Firestore). Firebase çağrıları UI içinde değil service katmanında kalmalıdır.

## 2. AI Çalışma Kuralları

- Kod yazmadan önce ilgili dosyaları oku, mevcut paterni anla ve gereksiz geniş refactor yapma.
- Mevcut çalışan akış korunacak; davranış değişikliği gerekiyorsa bilinçli ve açık olmalı.
- Her yeni ekran veya özellik responsive, tema uyumlu ve test edilebilir tasarlanacak.
- Firebase config, paket sürümleri, native Android/iOS ayarları ve routing akışı gereksiz değiştirilmemeli.
- Revize sonunda mümkünse `flutter test` ve `flutter analyze` çalıştırılmalı.
- Türkçe yorum yaz (kısa ve net!).

## 3. Mevcut Mimari

**Mevcut yapı (düzeltilmesi gerekiyor):**

```text
lib/
  components/              ← tüm ekranlar tek klasörde, dağınık
    main_view.dart         (HomeView + BottomNavigationBar)
    search_view.dart       (ürün arama)
    detail_view.dart       (ürün detay + favori)
    venue_view.dart        (mekanlar)
    favorites_view.dart    (favoriler)
    profile_view.dart      (profil)
    nav_bar.dart
  models/
    product.dart
  main.dart
  firebase_options.dart
```

**Hedef yapı (feature-first, clean architecture):**

```text
lib/
  core/
    routing/        (app_routes.dart, main_shell.dart)
    theme/          (app_colors.dart, app_theme.dart)
    widgets/        (ortak buton, card, loading, empty state)
    utils/
  features/
    home/
      presentation/
        screens/    (home_screen.dart)
        widgets/    (venue_card.dart, product_card.dart, tips_card.dart)
    search/
      data/
        models/     (product.dart → buraya taşınacak)
        services/   (search_service.dart)
      presentation/
        screens/    (search_screen.dart)
        widgets/    (product_list_tile.dart)
    venues/
      data/
        models/     (venue.dart)
        services/   (venue_service.dart)
      presentation/
        screens/    (venues_screen.dart)
        widgets/    (venue_list_card.dart)
    favorites/
      data/
        services/   (favorites_service.dart)
      presentation/
        screens/    (favorites_screen.dart)
    profile/
      presentation/
        screens/    (profile_screen.dart)
    product_detail/
      presentation/
        screens/    (detail_screen.dart)
  main.dart
  firebase_options.dart
```

Uygulama şu an erken aşamada düz bir `components/` yapısına sahip. Yeni geliştirmelerde hedef clean architecture olmalıdır; mevcut dosyalar kademeli olarak bu yapıya taşınabilir.

## 4. Clean Architecture Standardı

- **Presentation:** ekranlar, widget'lar, form state'i, UI event'leri.
- **Domain:** entity, use case, repository sözleşmeleri, iş kuralları.
- **Data:** Firestore datasource, model, repository implementasyonu.
- UI katmanı Firestore veya Firebase SDK'yı doğrudan bilmemeli.
- Service/repository metotları anlamlı exception veya result yapısı döndürmeli.
- Yeni özelliklerde önce feature sınırı belirlenmeli, sonra dosyalar ilgili feature altına eklenmeli.

## 5. Riverpod Kuralları

- Global state ve dependency injection Riverpod ile yönetilecek (henüz eklenmemiş, hedef).
- UI, provider'ları `ConsumerWidget` veya `ConsumerStatefulWidget` ile kullanacak.
- Async işlerde `AsyncValue`, `FutureProvider`, `StreamProvider` veya controller/notifier tercih edilmeli.
- Form içindeki geçici UI state için `setState` kullanılabilir; iş mantığı ve veri state'i provider'a taşınmalı.
- Provider'lar tek sorumluluk taşımalı ve testte override edilebilir olmalı.
- Gereksiz rebuild engellemek için `.select()` ve küçük provider'lar tercih edilmeli.

## 6. Routing Kuralları

- Uygulama navigasyonu `go_router` veya merkezi bir navigator yapısıyla yönetilecek.
- UI içinde `Navigator.push` kullanılmaz; lokal işlemlerde `context.pop()` kullanılabilir.
- Route path ve name değerleri merkezi `AppRoute`/`RouteNames` yapısında toplanmalı.
- Auth redirect mantığı router seviyesinde yönetilmeli.

## 7. Responsive Tasarım

Uygulama iOS/Android telefonlar için tasarlanmıştır.

- Her ekran `SafeArea`, keyboard davranışı ve notch/padding değerlerini hesaba katmalı.
- Layout'larda `LayoutBuilder`, `MediaQuery`, `Flexible`, `Expanded`, `SingleChildScrollView` bilinçli kullanılmalı.
- Sabit genişlik/yükseklik sadece ikon, avatar, buton gibi kontrollü elemanlarda kullanılmalı.
- Text overflow, keyboard overflow, scroll bozulması ve buton erişilebilirliği kontrol edilmeli.

## 8. Tema Sistemi

Uygulamanın renk ve tipografi sistemi — **değiştirilmeden korunacak.**

**Renkler:**
- `background:` `#0D1A0D` (koyu yeşil)
- `primaryGreen:` `#13EC13` (neon yeşil)
- `surfaceLow:` `#193319`
- `surfaceHigh:` `#234823`
- `border:` `rgba(255,255,255,0.05)`

**Tipografi:**
- Font ailesi: **Manrope** (Regular, Medium, SemiBold, Bold, ExtraBold)

Renk ve tipografi token'ları `core/theme` altında toplanmalı. UI içinde direkt `Color(...)` ve `Colors.*` kullanımı minimuma indirilmeli.

## 9. UI ve UX Standartları

- Ortak buton, card, dialog, snackbar, loading ve empty state component'leri `core/widgets` altından gelmeli.
- Butonlar loading, disabled ve error durumlarını desteklemeli.
- Hata mesajları teknik değil, kullanıcıya anlamlı olmalıdır.
- Her async işlemde loading state ve hata state'i görünür olmalı.
- Barkod tarayıcı entegrasyonu için kamera izni akışı ve hata yönetimi planlanmalıdır.

## 10. Lokalizasyon

- UI dili şu an Türkçe. Hardcoded metinler kabul edilebilir; ancak ileride arb/gen-l10n sistemine geçiş hedeflenmeli.
- Yeni eklenen her metin TR karşılığıyla eklenmeli.

## 11. Firebase ve Veri Kuralları

- Firebase Auth ve Firestore işlemleri UI içinde yapılmaz; service katmanında kalır.
- **Firestore `urunler/{id}` dokümanı:** `id` (String), `urun_adi` (String), `marka` (String), `resim` (String — URL veya asset adı), `icindekiler` (String), `barkod` (String), `durum` (`"GUVENLI"` | `"RISKLI"` | `"BILINMIYOR"`).
- **Firestore `markalar/{marka}/marka_urunleri/{id}`:** marka bazlı alt koleksiyon, aynı ürün alanları.
- **Firestore `mekanlar/{id}`:** mekan bilgileri (ad, adres, puan, konum, çalışma saatleri, glutensiz sertifikası).
- **Firestore `favoriler/{userId}`:** `urun_idleri: []`, `mekan_idleri: []`.
- Security rules yazılmamış — **kritik eksik.** `favoriler/{userId}` için yalnızca `uid == request.auth.uid` erişimine izin verilmeli.
- Tarih alanları Firestore `Timestamp` olarak saklanmalı.
- Firebase sorguları filtreli, index uyumlu ve minimum veri çekecek şekilde yazılmalı.
- **Şu an hardcoded `"test_user_123"` user ID kullanılıyor — Firebase Auth entegrasyonuyla kaldırılmalı.**

## 12. Kod Kalitesi

- `flutter_lints` kuralları korunacak; `flutter analyze` temiz kalmalı.
- `print()` kullanılmaz; gerekiyorsa `debugPrint()` kullanılır.
- Boş `catch` bloğu yasak. Hata yutulmaz.
- Async sonrası UI kullanılıyorsa `mounted` kontrol edilir.
- Controller, FocusNode, PageController dispose edilir.
- `const` constructor ve immutable modeller tercih edilir.
- Dosya adları `snake_case.dart`, class adları `PascalCase`, değişken/metotlar `camelCase`.
- Fonksiyonlar küçük ve tek sorumluluklu olmalı.
- Yorumlar kısa ve gerekli olduğunda Türkçe olabilir; kodun zaten söylediğini tekrar eden yorum yazılmaz.

## 13. Test ve Doğrulama

Her anlamlı revizede şu kontroller düşünülmeli:

- `flutter analyze`
- `flutter test`
- Service ve model için unit test
- Kritik ekranlar için widget test
- Arama, favori ekleme/çıkarma, barkod tarama için manuel smoke test
- Responsive kontrol: küçük/büyük telefon, portre

## 14. Performans

- Gereksiz rebuild, büyük widget build metotları ve kontrolsüz stream dinlemeleri engellenmeli.
- Ürün ve mekan listelerinde pagination ve lazy loading planlanmalı.
- Görsellerde network cache ve placeholder kullanılmalı.
- Firebase sorguları filtreli ve index uyumlu yazılmalı.

## 15. Yakın Revize Öncelikleri

1. **Mimari yeniden yapılandırma:** `lib/components/` içindeki dosyaları feature-first yapıya taşı.
2. **Firebase Auth entegrasyonu:** Hardcoded `"test_user_123"` kaldır, gerçek UID kullan.
3. **Firestore security rules:** `favoriler/{userId}` için auth-based erişim kuralı ekle.
4. **Barkod tarayıcı:** `mobile_scanner` veya `flutter_barcode_scanner` paketi ile Ara ekranına entegre et.
5. **Riverpod:** State yönetimini provider yapısına taşı; `setState` kullanımını azalt.
6. **Merkezi tema:** Renk ve font token'larını `core/theme/app_colors.dart` altında topla.
7. **Mock data temizliği:** Favoriler ve Profil ekranlarındaki hardcoded örnek verileri kaldır.

## 16. Son Kontrol Listesi

Yeni bir iş tamamlanmadan önce:

- Mimariye uygun mu?
- UI responsive mi?
- Tema renkleri ve tipografi merkezi token'lardan mı geliyor?
- Firebase/UI ayrımı korunuyor mu?
- Loading, error, empty state var mı?
- Controller ve async lifecycle güvenli mi? (`mounted` kontrolü)
- `flutter analyze` temiz mi?
- Gereksiz dosya, paket veya refactor eklendi mi?
