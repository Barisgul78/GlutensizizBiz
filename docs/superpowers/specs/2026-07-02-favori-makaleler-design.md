# Favoriler — Makaleler Sekmesi (Bookmark İpuçları)

## Amaç

Kullanıcı, "Günün İpucu" makale detay ekranındaki bookmark ikonuyla bir
makaleyi kaydedebilsin; Favoriler sayfasına eklenen üçüncü "Makaleler"
sekmesinde kaydettiği makaleleri listeleyip oradan tekrar açabilsin.
Şu an bookmark ikonu sadece local `setState` — hiçbir yere yazılmıyor,
uygulama yeniden açıldığında kayboluyor. Bu, mevcut ürün favorileme akışıyla
aynı desene (Firestore `favoriler/{userId}` dokümanı) bağlanacak.

## Veri Modeli

`favoriler/{userId}` dokümanına mevcut `urun_idleri`/`mekan_idleri`
alanlarıyla aynı desende üçüncü bir alan eklenir:

```
favoriler/{userId}: {
  urun_idleri: [],
  mekan_idleri: [],
  makale_idleri: [],   // YENİ — Tip.id değerleri, örn. "tip_colyak"
}
```

Tip'ler Firestore'da değil `lib/features/tips/data/services/tips_service.dart`
içindeki `TipsService._tips` sabit listesinde tutuluyor. Bu yüzden makale
favorileri için ayrı bir Firestore sorgusu gerekmiyor — ID listesi
`TipsService.getAll()` üzerinden lokal filtrelenecek.

## Servis Katmanı — `FavoritesService`

`lib/features/favorites/data/services/favorites_service.dart`'a, mevcut
`isProductFavorite`/`toggleProductFavorite` ile birebir aynı desende iki yeni
statik metod eklenir (farkı sadece Firestore alan adı: `makale_idleri`):

- `static Future<bool> isArticleFavorite(String tipId)`
- `static Future<void> toggleArticleFavorite(String tipId, {required bool isFavorite})`

Mevcut `favoritesStream(userId)` zaten tüm dokümanı döndürüyor — `makale_idleri`
alanı da aynı stream'den okunacak, yeni bir stream metoduna gerek yok.

## Makale Detay Ekranı — `tip_detail_screen.dart`

- `_TipDetailScreenState`'e `initState` eklenir; `FavoritesService.isArticleFavorite(tip.id)`
  ile başlangıç `_saved` durumu çekilir (mevcut `detail_screen.dart`'taki
  `_checkIfFavorite()` deseniyle aynı: tek seferlik Future, `mounted` kontrolü).
- Bookmark `GestureDetector.onTap`: `FavoritesService.toggleArticleFavorite(tip.id, isFavorite: _saved)`
  çağrılır, `setState(() => _saved = !_saved)` ile ikon (`bookmark_rounded` /
  `bookmark_border_rounded`) anında güncellenir — optimistic update, mevcut
  ürün favori toggle akışıyla aynı yaklaşım.

## Favoriler Ekranı — `favorites_screen.dart`

**Sekme ekleme:** `_buildTabSwitcher()`'daki `Row` içine üçüncü
`Expanded(child: _tabButton('Makaleler'))` eklenir. Mevcut `_tabButton` zaten
generic (title parametresi alıyor) — değişiklik gerekmiyor. Üç sekme eşit
genişlikte bölünecek, stil/hizalama otomatik korunur.

**State:** `selectedTab` üç değerden birini tutar (`'Ürünler'`, `'Mekanlar'`,
`'Makaleler'`). `build()`'deki `Expanded` içeriği üç yönlü koşula çıkarılır.

**`_buildArticlesList()`** — `_buildProductsList()` ile aynı iskelet:
- `userId == null` → aynı "Favorilerinizi görmek için giriş yapmanız
  gerekiyor." uyarısı (mevcut metin, aynen tekrar kullanılır).
- `StreamBuilder(stream: FavoritesService.favoritesStream(userId))` ile
  doküman izlenir, `makale_idleri` alanı okunur.
- Liste boşsa: ortalanmış tek satır **"Kayıtlı makale bulunamadı."** (Ürünler
  sekmesindeki boş durumla aynı stil: `GoogleFonts.sourceSans3`,
  `kOnSurfaceVariant`, 14px — ikon/alt metin yok, talimatla birebir).
- Doluysa: `TipsService.getAll().where((t) => ids.contains(t.id)).toList()`
  ile filtrelenip `ListView.builder` içinde `_buildArticleCard(tip)` render
  edilir.

**`_buildArticleCard(Tip tip)`** — `search_screen.dart`'taki
`_buildSearchResultCard` ile birebir aynı kart iskeleti (kullanıcının
paylaştığı Ürün Ara ekranı görseliyle eşleşecek şekilde):
- `Container` (margin/padding/border/radius aynı: `kSurface`, `radius 16`,
  `border: kOutlineVariant`).
- Sol: `Stack` içinde 72×72 görsel kutusu — `TipImage(asset: tip.imageAsset)`
  (mevcut widget, `tips/presentation/widgets/tip_image.dart`), üzerinde
  `Positioned(top:4, left:4)` ile `CategoryBadge(label: tip.category)` (mevcut
  widget — `ProductStatusBadge`'in bu ekrandaki karşılığı).
- Orta (`Expanded` + `Column`): yazar adı (10px, uppercase, `sourceSans3`,
  `kOnSurfaceVariant` — brand satırının karşılığı), başlık (`tip.title`,
  bold 15px, `maxLines:1, ellipsis`), tarih (`du.formatDate(tip.date)`, 12px,
  `kOnSurfaceVariant` — kategori satırının karşılığı; kategori zaten badge
  olarak görselde var, tekrar yazılmayacak).
- Sağ: `GestureDetector` ile bookmark ikonu (`bookmark_rounded`, `kSecondary`,
  20px) — dokununca `FavoritesService.toggleArticleFavorite(tip.id,
  isFavorite: true)` çağrılıp local state güncellenerek karttan kaldırılır
  (listeden anında çıkma — `StreamBuilder` zaten Firestore güncellemesini
  yakalayıp yeniden render edecek, ekstra local state gerekmez).
- `onTap` (kart geneli): `Navigator.push(MaterialPageRoute(builder: (_) =>
  TipDetailScreen(tip: tip)))`.

## Kapsam Dışı

- Diğer sekmelerin (Ürünler/Mekanlar) tasarımı veya davranışı değişmiyor.
- Like/dislike (`_Reaction`) mantığı dokunulmuyor.
- Routing (`go_router`) / Riverpod mimarisine geçiş bu işin kapsamında değil —
  mevcut `StatefulWidget`/`setState` + `Navigator.push` deseni korunuyor.
- Tips'in Firestore'a taşınması bu işin kapsamında değil; ID listesi mevcut
  hardcoded `TipsService.getAll()` üzerinden filtreleniyor.

## Doğrulama

- `flutter analyze` temiz.
- Manuel smoke test: Makale detayında bookmark'a bas → Favoriler > Makaleler
  sekmesinde görünsün. Sekmeyi aç/kapa, kalıcılığı doğrula (state yeniden
  build edilse de Firestore'dan okunuyor). Karttaki bookmark ikonuna basarak
  listeden kaldır. Hiç kayıt yokken "Kayıtlı makale bulunamadı." görünsün.
  Kart dokununca doğru `TipDetailScreen`'e gitsin. Giriş yapılmamış durumda
  Ürünler sekmesindeki gibi uyarı görünsün.
