# GluFree - Claude Code Geliştirme Rehberi

Bu dosya Claude Code için ana proje rehberidir. Her yeni istek, refactor ve revize bu kurallar okunmuş kabul edilerek yapılmalıdır.

## 1. Proje Özeti

- **Uygulama:** GluFree — glutensiz ürün ve mekan keşif uygulaması.
- **Hedef kitle:** Çölyak hastalığı ve gluten hassasiyeti olan kullanıcılar.
- **Platform:** Flutter ile iOS ve Android.
- **Mevcut stack:** Flutter, Dart, Firebase Auth, Cloud Firestore, google_fonts, shared_preferences, flutter_map, latlong2, geolocator (mekan haritası), flutter_typeahead.
- **Mevcut akış:** `MainShell` (`NavigationBar`, 5 sekme — `lib/core/routing/main_shell.dart`):
  - **Anasayfa** — hero banner, popüler glutensiz mekanlar carousel (şu an mock veri, bkz. Bölüm 15), yeni eklenen ürünler grid, glutensiz ipuçları/blog bento kartları. "Tümünü gör" ile Mekanlar ekranına (`VenuesScreen`) `Navigator.push` ile gidilir — Mekanlar bağımsız bir sekme değildir.
  - **Ara** — ürün adı/marka/kategori filtresiyle Firestore canlı arama; barkod tarayıcı entegrasyonu henüz planlanma aşamasında (kod içinde sadece placeholder yorum var, paket seçilmedi).
  - **Rehber** — glutensiz ipuçları/makaleler listesi ve detay ekranı (`lib/features/tips/`), Firestore favori entegrasyonlu.
  - **Favoriler** — 3 sekmeli (Ürünler / Mekanlar / Makaleler) favori listesi; Firestore + local storage ile senkron.
  - **Profil** — kullanıcı bilgisi, ayarlar, çıkış.
  - **Mekanlar** — glutensiz restoran/kafe/belediye listesi, puan, mesafe, filtre; harita görünümü (`VenueMapScreen`, `flutter_map`) dahil. Anasayfa üzerinden erişilir.
  - Ayrıca: **Auth akışı** (`lib/features/auth/` — giriş/kayıt/sign ekranları) ve **Onboarding** (`lib/features/onboarding/`) mevcut; `main.dart` bunlar arasında `SharedPreferences` flag'ine göre geçiş yapar.
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

Feature-first mimariye geçiş **tamamlandı** — eski düz `lib/components/` yapısı artık yok. Güncel ağaç:

```text
lib/
  core/
    routing/        (app_routes.dart — tanımlı ama henüz aktif kullanılmıyor, main_shell.dart, splash_screen.dart)
    theme/          (app_colors.dart, app_theme.dart)
    widgets/        (custom_button.dart, custom_text_field.dart, bubble_background.dart)
    utils/          (validators.dart, string_utils.dart, date_utils.dart, snackbars.dart, firebase_error_mapper.dart)
    constants/      (app_sizes.dart, app_constants.dart)
    providers/      (theme_provider.dart, locale_provider.dart — ChangeNotifier tabanlı, henüz Riverpod değil)
    localization/   (app_strings.dart)
    services/       (location_service.dart)
  features/
    auth/
      data/services/     (auth_service.dart)
      presentation/screens/ (login_screen.dart, register_screen.dart, sign_screen.dart)
    onboarding/
      presentation/screens/ (onboarding_screen.dart)
    home/
      presentation/screens/ (home_screen.dart — mock mekan verisi + doğrudan Firestore erişimi içeriyor, data/ katmanı yok)
    search/
      data/models/        (product.dart)
      data/services/      (search_service.dart)
      presentation/screens/ (search_screen.dart)
    venues/
      presentation/screens/ (venues_screen.dart, venue_map_screen.dart)
      -- data/ katmanı yok: venue.dart modeli / venue_service.dart henüz eklenmedi (bkz. Bölüm 15)
    tips/
      data/models/         (tip.dart)
      data/services/       (tips_service.dart)
      presentation/screens/ (tips_list_screen.dart, rehber_screen.dart, tip_detail_screen.dart)
    favorites/
      data/services/       (favorites_service.dart)
      presentation/screens/ (favorites_screen.dart)
    profile/
      presentation/screens/ (profile_screen.dart)
    product_detail/
      presentation/screens/ (detail_screen.dart)
  main.dart
  firebase_options.dart
```

Yeni geliştirmelerde bu yapı korunmalı. Bilinen eksik: `venues` ve `home` feature'larında `data/` katmanı yok — clean architecture hedefiyle çelişiyor (bkz. Bölüm 4, Bölüm 15 madde 8).

## 4. Clean Architecture Standardı

- **Presentation:** ekranlar, widget'lar, form state'i, UI event'leri.
- **Domain:** entity, use case, repository sözleşmeleri, iş kuralları.
- **Data:** Firestore datasource, model, repository implementasyonu.
- UI katmanı Firestore veya Firebase SDK'yı doğrudan bilmemeli.
- Service/repository metotları anlamlı exception veya result yapısı döndürmeli.
- Yeni özelliklerde önce feature sınırı belirlenmeli, sonra dosyalar ilgili feature altına eklenmeli.
- Şu an `search`, `tips`, `favorites`, `auth` feature'ları bu katmanlara uyuyor. `venues` ve `home` uymuyor — `data/` katmanı eksik, Firestore erişimi doğrudan UI'da yapılıyor (bkz. Bölüm 15 madde 8).

## 5. Riverpod Kuralları

- Global state ve dependency injection Riverpod ile yönetilecek (henüz eklenmemiş, hedef).
- UI, provider'ları `ConsumerWidget` veya `ConsumerStatefulWidget` ile kullanacak.
- Async işlerde `AsyncValue`, `FutureProvider`, `StreamProvider` veya controller/notifier tercih edilmeli.
- Form içindeki geçici UI state için `setState` kullanılabilir; iş mantığı ve veri state'i provider'a taşınmalı.
- Provider'lar tek sorumluluk taşımalı ve testte override edilebilir olmalı.
- Gereksiz rebuild engellemek için `.select()` ve küçük provider'lar tercih edilmeli.
- Güncel durum: `riverpod`/`flutter_riverpod` paketi `pubspec.yaml`'da yok. State şu an `core/providers/theme_provider.dart` ve `locale_provider.dart` içinde düz `ChangeNotifier` sınıflarıyla yönetiliyor.

## 6. Routing Kuralları

- Uygulama navigasyonu `go_router` veya merkezi bir navigator yapısıyla yönetilecek.
- UI içinde `Navigator.push` kullanılmaz; lokal işlemlerde `context.pop()` kullanılabilir.
- Route path ve name değerleri merkezi `AppRoute`/`RouteNames` yapısında toplanmalı.
- Auth redirect mantığı router seviyesinde yönetilmeli.
- Güncel durum: `go_router` pubspec'te yok, henüz eklenmedi. Navigasyon şu an `Navigator.push` ve `MaterialApp.home` ile yapılıyor; `core/routing/app_routes.dart` tanımlı ama aktif kullanılmıyor. Bu bölümdeki kurallar hedef durumdur, henüz uygulanmadı.

## 7. Responsive Tasarım

Uygulama iOS/Android telefonlar için tasarlanmıştır.

- Her ekran `SafeArea`, keyboard davranışı ve notch/padding değerlerini hesaba katmalı.
- Layout'larda `LayoutBuilder`, `MediaQuery`, `Flexible`, `Expanded`, `SingleChildScrollView` bilinçli kullanılmalı.
- Sabit genişlik/yükseklik sadece ikon, avatar, buton gibi kontrollü elemanlarda kullanılmalı.
- Text overflow, keyboard overflow, scroll bozulması ve buton erişilebilirliği kontrol edilmeli.

## 8. Tema Sistemi

Uygulamanın renk ve tipografi sistemi — **değiştirilmeden korunacak.** (Aşağıdaki değerler `lib/core/theme/app_colors.dart` dosyasının gerçek içeriğidir.)

**Renkler (Material 3, açık "Earthy" palet):**
- `kBackground:` `#FFF8F4`
- `kPrimary:` `#4F6145` · `kPrimaryContainer:` `#677A5C` · `kOnPrimary:` `#FFFFFF` · `kOnPrimaryContainer:` `#F8FFEE` · `kPrimaryFixed:` `#D4E9C5`
- `kSurface:` `#FFF8F4` · `kSurfaceContainer:` `#FAEBE0` · `kSurfaceContainerHigh:` `#F4E6DA` · `kSurfaceContainerHighest:` `#EEE0D4` · `kSurfaceContainerLow:` `#FFF1E6`
- `kOnSurface:` `#211A13` · `kOnSurfaceVariant:` `#444840`
- `kSecondary:` `#964824` · `kSecondaryFixed:` `#FFDBCD`
- `kOutline:` `#75786F` · `kOutlineVariant:` `#C4C8BD`
- `kError:` `#BA1A1A` · `kErrorContainer:` `#FFDAD6` · `kOnErrorContainer:` `#93000A`
- Pastel ikon arka planları: `kPastelGreen/Blue/Red/Yellow/Orange/Pink/Gray`, `kMapBackground`
- Rozet renkleri: `kBadgeSuccess`, `kBadgeDanger`, `kBadgeInfo`
- Onboarding koyu yeşil: `kOnboardingDarkGreen` `#2D4A2D` (sadece onboarding sayfası arka planı, genel tema değil)

**Tipografi:**
- `google_fonts` paketi kullanılıyor — bundle edilmiş "Manrope" font asset'i UI'da kullanılmıyor (dead asset).
- Başlıklar: **Plus Jakarta Sans** (`GoogleFonts.plusJakartaSans`)
- Gövde metni: **Source Sans 3** (`GoogleFonts.sourceSans3`)

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
- Not: `core/localization/app_strings.dart` ve `core/providers/locale_provider.dart` mevcut — dil değiştirme altyapısı için ilk adımlar atılmış (UI'da tam kullanım oranı doğrulanmadı).

## 11. Firebase ve Veri Kuralları

- Firebase Auth ve Firestore işlemleri UI içinde yapılmaz; service katmanında kalır.
- **Firestore `urunler/{id}` dokümanı:** `id` (String), `urun_adi` (String), `marka` (String), `resim` (String — URL veya asset adı), `icindekiler` (String), `barkod` (String), `durum` (`"GUVENLI"` | `"RISKLI"` | `"BILINMIYOR"`).
- **Firestore `markalar/{marka}/marka_urunleri/{id}`:** marka bazlı alt koleksiyon, aynı ürün alanları.
- **Firestore `mekanlar/{id}`:** mekan bilgileri (ad, adres, puan, konum, çalışma saatleri, glutensiz sertifikası).
- **Firestore `favoriler/{userId}`:** `urun_idleri: []`, `mekan_idleri: []`, `makale_idleri: []`.
- **Security rules mevcut** (`firestore.rules`, repo kökünde). `favoriler/{userId}` ve `users/{userId}` için `auth.uid == userId` şartı uygulanıyor; `urunler`, `markalar/{marka}/marka_urunleri` (+ collectionGroup), `mekanlar` herkese açık okuma/yazma-kapalı kuralına sahip.
- Tarih alanları Firestore `Timestamp` olarak saklanmalı.
- Firebase sorguları filtreli, index uyumlu ve minimum veri çekecek şekilde yazılmalı.
- Hardcoded `"test_user_123"` kaldırıldı — `AuthService.currentUserId` üzerinden gerçek Firebase Auth UID kullanılıyor.

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

1. ~~Mimari yeniden yapılandırma~~ — **tamamlandı**, `lib/components/` artık yok.
2. ~~Firebase Auth entegrasyonu~~ — **tamamlandı**, hardcoded `"test_user_123"` kaldırıldı.
3. ~~Firestore security rules~~ — **tamamlandı**, `firestore.rules` mevcut.
4. **Barkod tarayıcı:** `mobile_scanner` veya `flutter_barcode_scanner` paketi ile Ara ekranına entegre et. (Hâlâ geçerli — pubspec'te yok, sadece placeholder yorum var.)
5. **Riverpod:** State yönetimini provider yapısına taşı; `setState` ve `ChangeNotifier` kullanımını azalt. (Hâlâ geçerli.)
6. **Merkezi tema:** Renkler zaten `core/theme/app_colors.dart` altında merkezi (bu revizeyle CLAUDE.md'deki palet gerçeğe uyduruldu). Font kullanımı hâlâ her çağrı noktasında ad-hoc (`GoogleFonts.plusJakartaSans(...)`) — tek bir `AppTypography`/token sınıfına taşınması önerilir.
7. **Mock data temizliği:** `home_screen.dart` içindeki `_mockVenues` hâlâ hardcoded, gerçek Firestore verisine bağlanmalı. `profile_screen.dart` sağlık profili/rozetler bölümü bilinçli olarak statik placeholder (henüz veri modeli yok, onaylı karar) — Favoriler ekranı zaten tamamen Firestore-driven.
8. **Venues/Home data katmanı:** `venues` ve `home` feature'larına `data/` katmanı (venue modeli + servis) ekle; Firestore çağrılarını UI'dan servis katmanına taşı.

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
