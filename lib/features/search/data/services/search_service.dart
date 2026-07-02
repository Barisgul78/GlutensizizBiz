import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class SearchService {
  SearchService._();

  static Future<List<Product>> fetchAll() async {
    final snap = await FirebaseFirestore.instance
        .collectionGroup('marka_urunleri')
        .get();
    return snap.docs
        .map((d) => Product.fromFirestore(d.data()))
        .toList();
  }
}
