# GluFree - Claude Code Geliştirme Rehberi

Bu dosya Claude Code için ana proje rehberidir. Her yeni istek, refactor ve revize bu kurallar okunmuş kabul edilerek yapılmalıdır.

## 1. Proje Özeti

- **Uygulama:** GluFree — glutensiz ürün ve mekan keşif uygulaması.
- **Hedef kitle:** Çölyak hastalığı ve gluten hassasiyeti olan kullanıcılar.
- **Platform:** Flutter ile iOS ve Android.
- **Mevcut stack:** Flutter, Dart, Firebase Auth, Cloud Firestore, go_router, flutter_riverpod, google_fonts, shared_preferences, flutter_map, latlong2, geolocator, flutter_typeahead.
- **Mevcut akış:** `MainShell` (`NavigationBar`, 5 sekme — `lib/core/routing/main_shell.dart`):
  - **Anasayfa** — hero banner, yakınındaki glutensiz mekanlar listesi (Firestore `mekanlar` koleksiyonundan, `home/data/services/home_service.dart` üzerinden), yeni eklenen ürünler grid, ipuçları/blog bento kartları. "Tümü" ile Mekanlar ekranına (`VenuesScreen`) `go_router` ile gidilir — Mekanlar bağımsız bir sekme değildir.
  - **Ara** — ürün adı/marka/kategori filtresiyle Firestore canlı arama. Barkod tarayıcı **desteklenmeyecek** — bilinçli karar, entegre edilmeyecek.
  - **Rehber** — glutensiz ipuçları/makaleler listesi ve detay ekranı (`lib/features/tips/`), Firestore favori entegrasyonlu.
  - **Favoriler** — 3 sekmeli (Ürünler / Mekanlar / Makaleler) favori listesi; Firestore + local storage ile senkron.
  - **Profil** — kullanıcı bilgisi, ayarlar, çıkış.
  - **Mekanlar** — glutensiz restoran/kafe/belediye listesi, puan, mesafe, filtre; harita görünümü (`VenueMapScreen`, `flutter_map`) dahil. Anasayfa üzerinden erişilir.
  - Ayrıca: **Auth akışı** (`lib/features/auth/`) ve **Onboarding** (`lib/features/onboarding/`) mevcut; router seviyesinde auth durumuna göre yönlendirme yapılır.
- **UI dili:** Türkçe.
- **Backend:** Firebase (Firestore). Firebase çağrıları UI içinde değil service katmanında kalmalıdır.

## 2. AI Çalışma Kuralları

- Kod yazmadan önce ilgili dosyaları oku, mevcut paterni anla ve gereksiz geniş refactor yapma.
- Mevcut çalışan akış korunacak; davranış değişikliği gerekiyorsa bilinçli ve açık olmalı.
- Her yeni ekran veya özellik responsive, tema uyumlu ve test edilebilir tasarlanacak.
- Firebase config, paket sürümleri, native Android/iOS ayarları ve routing akışı gereksiz değiştirilmemeli.
- Büyük veya birden fazla dosyayı etkileyen revizeler için önce plan mode ile plan sunulmalı, onay alınmadan kod yazılmamalı (bkz. Bölüm 3).
- Revize sonunda mümkünse `flutter test` ve `flutter analyze` çalıştırılmalı.
- Türkçe yorum yaz (kısa ve net!).

## 3. Plan Mode Kullanımı

- Yeni bir özellik, mimari değişiklik veya birden fazla dosyayı etkileyen revizeler önce plan mode'da ele alınmalı.
- Plan mode çıktısı şunları içermeli:
  - Değişikliğin kapsamı ve etkilenecek dosya/klasörler.
  - Alınan mimari/teknik kararlar ve gerekçesi.
  - Mevcut davranışta değişecek noktalar (breaking change'ler açıkça işaretlenmeli).
  - Sırasıyla yapılacak adımlar (kod yazmadan önce net bir checklist).
- Plan onaylanmadan implementasyon adımına geçilmemeli.
- Plandan sapılıyorsa bu açıkça belirtilmeli.

## 4. Mevcut Mimari

Feature-first mimariye geçiş **tamamlandı** — eski düz `lib/components/` yapısı artık yok. Güncel ağaç:

```text
lib/
  core/
    routing/        (app_router.dart — go_router kurulumu, MainShell + StatefulShellRoute; main_shell.dart, splash_screen.dart)
    theme/          (app_colors.dart, app_theme.dart)
    widgets/        (custom_button.dart, custom_text_field.dart, bubble_background.dart)
    utils/          (validators.dart, string_utils.dart, date_utils.dart, snackbars.dart, firebase_error_mapper.dart)
    constants/      (app_sizes.dart, app_constants.dart)
    providers/      (theme_provider.dart, locale_provider.dart — Riverpod StateNotifierProvider'lar)
    localization/   (app_strings.dart)
    services/       (location_service.dart)
  features/
    auth/
      data/services/     (auth_service.dart)
      presentation/screens/ (login_screen.dart, register_screen.dart, sign_screen.dart)
    onboarding/
      presentation/screens/ (onboarding_screen.dart)
    home/
      data/services/      (home_service.dart — mekanlar için venues servisini sarar)
      presentation/screens/ (home_screen.dart)
    search/
      data/models/        (product.dart)
      data/services/      (search_service.dart)
      presentation/screens/ (search_screen.dart)
    venues/
      data/models/         (venue.dart)
      data/services/       (venues_service.dart)
      presentation/screens/ (venues_screen.dart, venue_map_screen.dart)
    tips/
      data/models/         (tip.dart)
      data/services/       (tips_service.dart)
      presentation/screens/ (tips_list_screen.dart, rehber_screen.dart, tip_detail_screen.dart)
    favorites/
      data/services/       (favorites_service.dart)
      presentation/screens/ (favorites_screen.dart)
    profile/
      presentation/screens/ (profile_screen.dart, edit_profile_screen.dart, settings_screen.dart)
    product_detail/
      presentation/screens/ (detail_screen.dart)
  main.dart
  firebase_options.dart
```

Yeni geliştirmelerde bu yapı korunmalı.

## 5. Clean Architecture Standardı

- **Presentation:** ekranlar, widget'lar, form state'i, UI event'leri.
- **Domain:** entity, use case, repository sözleşmeleri, iş kuralları.
- **Data:** Firestore datasource, model, repository implementasyonu.
- UI katmanı Firestore veya Firebase SDK'yı doğrudan bilmemeli.
- Service/repository metotları anlamlı exception veya result yapısı döndürmeli.
- Yeni özelliklerde önce feature sınırı belirlenmeli, sonra dosyalar ilgili feature altına eklenmeli.
- `search`, `tips`, `favorites`, `auth`, `venues`, `home` feature'ları bu katmanlara uyuyor.

## 6. State Management (Riverpod)

- Global state ve dependency injection **Riverpod ile yönetiliyor** (`flutter_riverpod` pubspec'te mevcut).
- `main.dart`'ta `runApp` çağrısı `ProviderScope` ile sarılı; `MyApp` `ConsumerStatefulWidget`.
- `core/providers/theme_provider.dart` → `themeModeProvider` (`StateNotifierProvider<ThemeModeNotifier, ThemeMode>`), `core/providers/locale_provider.dart` → `localeProvider` (`StateNotifierProvider<LocaleNotifier, Locale>`).
- UI, provider'ları `ConsumerWidget` veya `ConsumerStatefulWidget` ile kullanacak.
- Async işlerde `AsyncValue`, `FutureProvider`, `StreamProvider` veya `StateNotifier`/`Notifier` tercih edilmeli.
- Form içindeki geçici UI state için `setState` kullanılabilir; iş mantığı ve veri state'i provider'a taşınmalı.
- Provider'lar tek sorumluluk taşımalı ve testte override edilebilir olmalı.
- Gereksiz rebuild engellemek için `.select()` ve küçük provider'lar tercih edilmeli.
- İstisna: `lib/core/routing/app_router.dart` içindeki `GoRouterRefreshStream` hâlâ `ChangeNotifier` — bu, go_router'ın `refreshListenable` mekanizmasına özel, kasıtlı bir tasarım; Riverpod'a taşınmaz.

## 7. Routing Kuralları

- Uygulama navigasyonu **go_router ile yönetiliyor** (`go_router: ^14.6.2`, `lib/core/routing/app_router.dart`, `createAppRouter()`), `main.dart`'ta `MaterialApp.router` kullanılıyor.
- UI içinde `Navigator.push` kullanılmaz; `context.go`/`context.push` ve lokal işlemlerde `context.pop()` kullanılır.
- Route path değerleri `app_router.dart` içinde merkezi tanımlanır (`_branchPaths`, `GoRoute` path'leri).
- Auth redirect mantığı router seviyesinde yönetiliyor (`redirect` callback, `GoRouterRefreshStream` ile Firebase Auth durumu dinlenip yeniden değerlendiriliyor).
- 5 sekmeli ana gezinme `StatefulShellRoute.indexedStack` ile yapılıyor; sekme dışı ekranlar (`/urun`, `/settings`, `/profile/edit`, `/tips/detay`, `/venues/map`) `rootNavigatorKey` ile üstte açılıyor.

## 8. Responsive Tasarım

Uygulama iOS/Android telefonlar için tasarlanmıştır.

- Her ekran `SafeArea`, keyboard davranışı ve notch/padding değerlerini hesaba katmalı.
- Layout'larda `LayoutBuilder`, `MediaQuery`, `Flexible`, `Expanded`, `SingleChildScrollView` bilinçli kullanılmalı.
- Sabit genişlik/yükseklik sadece ikon, avatar, buton gibi kontrollü elemanlarda kullanılmalı.
- Text overflow, keyboard overflow, scroll bozulması ve buton erişilebilirliği kontrol edilmeli.

## 9. Tema Sistemi

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

Ayrı bir koyu tema paleti henüz tanımlı değil; `MaterialApp.router`'da `darkTheme` şimdilik `AppTheme.light`'a eşit — `themeModeProvider` mekanizması hazır, koyu palet eklendiğinde sadece `darkTheme` değeri değişecek.

**Tipografi:**
- `google_fonts` paketi kullanılıyor — bundle edilmiş "Manrope" font asset'i UI'da kullanılmıyor (dead asset).
- Başlıklar: **Plus Jakarta Sans** (`GoogleFonts.plusJakartaSans`)
- Gövde metni: **Source Sans 3** (`GoogleFonts.sourceSans3`)

Renk ve tipografi token'ları `core/theme` altında toplanmalı. UI içinde direkt `Color(...)` ve `Colors.*` kullanımı minimuma indirilmeli.

## 10. UI ve UX Standartları

- Ortak buton, card, dialog, snackbar, loading ve empty state component'leri `core/widgets` altından gelmeli.
- Butonlar loading, disabled ve error durumlarını desteklemeli.
- Hata mesajları teknik değil, kullanıcıya anlamlı olmalıdır.
- Her async işlemde loading state ve hata state'i görünür olmalı.
- Barkod tarayıcı **desteklenmeyecek** — kamera izni/entegrasyon akışı planlanmıyor.

## 11. Lokalizasyon

- UI dili şu an Türkçe. Hardcoded metinler kabul edilebilir; ancak ileride arb/gen-l10n sistemine geçiş hedeflenmeli.
- Yeni eklenen her metin TR karşılığıyla eklenmeli.
- Not: `core/localization/app_strings.dart` ve `core/providers/locale_provider.dart` (Riverpod `localeProvider`) mevcut — dil değiştirme altyapısı için ilk adımlar atılmış (UI'da tam kullanım oranı doğrulanmadı).

## 12. Firebase ve Veri Kuralları

- Firebase Auth ve Firestore işlemleri UI içinde yapılmaz; service katmanında kalır.
- **Firestore `urunler/{id}` dokümanı:** `id` (String), `urun_adi` (String), `marka` (String), `resim` (String — URL veya asset adı), `icindekiler` (String), `barkod` (String), `durum` (`"GUVENLI"` | `"RISKLI"` | `"BILINMIYOR"`).
- **Firestore `markalar/{marka}/marka_urunleri/{id}`:** marka bazlı alt koleksiyon, aynı ürün alanları.
- **Firestore `mekanlar/{id}`:** mekan bilgileri (`ad`, `aciklama`, `resim`, `puan`, `mesafe`, `adres`, `rozet`, `etiketler`). `venues_service.dart` ve `home_service.dart` bu koleksiyonu okur.
- **Firestore `favoriler/{userId}`:** `urun_idleri: []`, `mekan_idleri: []`, `makale_idleri: []`.
- **Security rules mevcut** (`firestore.rules`, repo kökünde). `favoriler/{userId}` ve `users/{userId}` için `auth.uid == userId` şartı uygulanıyor; `urunler`, `markalar/{marka}/marka_urunleri` (+ collectionGroup), `mekanlar` herkese açık okuma/yazma-kapalı kuralına sahip.
- Tarih alanları Firestore `Timestamp` olarak saklanmalı.
- Firebase sorguları filtreli, index uyumlu ve minimum veri çekecek şekilde yazılmalı.
- Hardcoded `"test_user_123"` kaldırıldı — `AuthService.currentUserId` üzerinden gerçek Firebase Auth UID kullanılıyor.

## 13. Kod Kalitesi

- `flutter_lints` kuralları korunacak; `flutter analyze` temiz kalmalı.
- `print()` kullanılmaz; gerekiyorsa `debugPrint()` kullanılır.
- Boş `catch` bloğu yasak. Hata yutulmaz.
- Async sonrası UI kullanılıyorsa `mounted` kontrol edilir.
- Controller, FocusNode, PageController dispose edilir.
- `const` constructor ve immutable modeller tercih edilir.
- Dosya adları `snake_case.dart`, class adları `PascalCase`, değişken/metotlar `camelCase`.
- Fonksiyonlar küçük ve tek sorumluluklu olmalı.
- Yorumlar kısa ve gerekli olduğunda Türkçe olabilir; kodun zaten söylediğini tekrar eden yorum yazılmaz.

## 14. Test ve Doğrulama

Her anlamlı revizede şu kontroller düşünülmeli:

- `flutter analyze`
- `flutter test`
- Service ve model için unit test
- Kritik ekranlar için widget test
- Arama, favori ekleme/çıkarma için manuel smoke test
- Responsive kontrol: küçük/büyük telefon, portre

## 15. Performans

- Gereksiz rebuild, büyük widget build metotları ve kontrolsüz stream dinlemeleri engellenmeli.
- Ürün ve mekan listelerinde pagination ve lazy loading planlanmalı (venues zaten `startAfterDocument` ile sayfalanıyor).
- Görsellerde network cache ve placeholder kullanılmalı.
- Firebase sorguları filtreli ve index uyumlu yazılmalı.

## 16. Yakın Revize Öncelikleri

1. ~~Mimari yeniden yapılandırma~~ — **tamamlandı**, `lib/components/` artık yok.
2. ~~Firebase Auth entegrasyonu~~ — **tamamlandı**, hardcoded `"test_user_123"` kaldırıldı.
3. ~~Firestore security rules~~ — **tamamlandı**, `firestore.rules` mevcut.
4. ~~go_router entegrasyonu~~ — **tamamlandı**, tüm navigasyon `context.go`/`context.push` ile yapılıyor.
5. ~~Riverpod~~ — **tamamlandı**, `theme_provider.dart`/`locale_provider.dart` `StateNotifierProvider`'a taşındı, `main.dart` `ProviderScope` ile sarılı.
6. ~~Home mock veri temizliği~~ — **tamamlandı**, `home_screen.dart` artık `home_service.dart` üzerinden Firestore `mekanlar` koleksiyonunu okuyor, veri yoksa empty-state gösteriyor.
7. ~~Venues/Home data katmanı~~ — **tamamlandı**, `venues/data/` ve `home/data/services/home_service.dart` mevcut.
8. **Barkod tarayıcı:** desteklenmeyecek, kapsam dışı bırakıldı — ilgili placeholder UI kaldırıldı.
9. **Merkezi tema:** Renkler zaten `core/theme/app_colors.dart` altında merkezi. Font kullanımı hâlâ her çağrı noktasında ad-hoc (`GoogleFonts.plusJakartaSans(...)`) — tek bir `AppTypography`/token sınıfına taşınması önerilir.
10. **Profil sağlık profili/rozetler:** bilinçli olarak statik placeholder (henüz veri modeli yok, onaylı karar).

## 17. Son Kontrol Listesi

Yeni bir iş tamamlanmadan önce:

- Mimariye uygun mu?
- UI responsive mi?
- Tema renkleri ve tipografi merkezi token'lardan mı geliyor?
- Firebase/UI ayrımı korunuyor mu?
- Loading, error, empty state var mı?
- Controller ve async lifecycle güvenli mi? (`mounted` kontrolü)
- `flutter analyze` temiz mi?
- Gereksiz dosya, paket veya refactor eklendi mi?
- Kapsamlı bir değişiklikse önce plan mode'dan geçti mi?
