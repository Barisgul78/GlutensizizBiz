import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/paginated.dart';
import '../models/product.dart';

class SearchService {
  SearchService._();

  // Urun adi/marka uzerinde case-insensitive client-side arama.
  // Firestore'da urun_adi karisik/buyuk harfle kayitli oldugundan
  // (ornek: "NUSTIL Besin Mayasi 100g"), server-side prefix range
  // sorgusu calismiyor - veri kucuk oldugu icin (33 urun) tumunu
  // cekip Dart tarafinda filtrelemek yeterli.
  static Future<Paginated<Product>> searchByName(
    String query, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const Paginated(items: [], lastDocument: null, hasMore: false);
    }
    final snap =
        await FirebaseFirestore.instance.collectionGroup('marka_urunleri').get();
    final items = snap.docs
        .map((d) => Product.fromFirestore(d.data()))
        .where((p) =>
            p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q))
        .toList();
    return Paginated(items: items, lastDocument: null, hasMore: false);
  }

  // Arama boskeen gosterilen sinirli urun listesi (or. Populer Urunler).
  static Future<List<Product>> fetchFeatured({int limit = 5}) async {
    final snap = await FirebaseFirestore.instance
        .collectionGroup('marka_urunleri')
        .limit(limit)
        .get();
    return snap.docs.map((d) => Product.fromFirestore(d.data())).toList();
  }
}
