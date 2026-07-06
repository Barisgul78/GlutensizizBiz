import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore sayfalama sonucu — sonraki sayfa icin son dokuman ve daha
// fazla veri olup olmadigi bilgisini tasir.
class Paginated<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const Paginated({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });
}
