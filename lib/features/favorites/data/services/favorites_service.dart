import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../search/data/models/product.dart';

class FavoritesService {
  FavoritesService._();

  static const _col = 'favoriler';
  static const _field = 'urun_idleri';
  static const _articleField = 'makale_idleri';

  static Future<bool> isProductFavorite(String productId) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return false;
    final doc = await FirebaseFirestore.instance.collection(_col).doc(userId).get();
    if (!doc.exists) return false;
    final List ids = doc.data()?[_field] ?? [];
    return ids.contains(productId);
  }

  static Future<void> toggleProductFavorite(String productId, {required bool isFavorite}) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    final docRef = FirebaseFirestore.instance.collection(_col).doc(userId);
    if (isFavorite) {
      await docRef.update({_field: FieldValue.arrayRemove([productId])});
    } else {
      await docRef.set({_field: FieldValue.arrayUnion([productId])}, SetOptions(merge: true));
    }
  }

  static Future<void> addProductFavorite(String productId) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    await FirebaseFirestore.instance.collection(_col).doc(userId).set(
      {_field: FieldValue.arrayUnion([productId])},
      SetOptions(merge: true),
    );
  }

  static Stream<DocumentSnapshot> favoritesStream(String userId) =>
      FirebaseFirestore.instance.collection(_col).doc(userId).snapshots();

  static Future<bool> isArticleFavorite(String tipId) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return false;
    final doc = await FirebaseFirestore.instance.collection(_col).doc(userId).get();
    if (!doc.exists) return false;
    final List ids = doc.data()?[_articleField] ?? [];
    return ids.contains(tipId);
  }

  static Future<void> toggleArticleFavorite(String tipId, {required bool isFavorite}) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    final docRef = FirebaseFirestore.instance.collection(_col).doc(userId);
    if (isFavorite) {
      await docRef.update({_articleField: FieldValue.arrayRemove([tipId])});
    } else {
      await docRef.set({_articleField: FieldValue.arrayUnion([tipId])}, SetOptions(merge: true));
    }
  }

  // Firestore whereIn sorgusu tek seferde en fazla 30 eleman kabul eder,
  // bu yuzden liste 30'luk parcalara bolunup paralel sorgulanir.
  static const _whereInLimit = 30;

  static Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = _chunk(ids, _whereInLimit);
    final results = await Future.wait(chunks.map((chunk) =>
        FirebaseFirestore.instance
            .collectionGroup('marka_urunleri')
            .where('id', whereIn: chunk)
            .get()));
    return results
        .expand((snap) => snap.docs)
        .map((d) => Product.fromFirestore(d.data()))
        .toList();
  }

  static List<List<T>> _chunk<T>(List<T> list, int size) => [
        for (var i = 0; i < list.length; i += size)
          list.sublist(i, i + size > list.length ? list.length : i + size),
      ];
}
