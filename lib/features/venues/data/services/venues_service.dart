import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/paginated.dart';
import '../models/venue.dart';

class VenuesService {
  VenuesService._();

  static Future<Paginated<Venue>> fetchPage({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('mekanlar').limit(limit);
    if (startAfter != null) {
      ref = ref.startAfterDocument(startAfter);
    }
    final snap = await ref.get();
    final items = snap.docs.map((d) => Venue.fromFirestore(d.id, d.data())).toList();
    return Paginated(
      items: items,
      lastDocument: snap.docs.isNotEmpty ? snap.docs.last : null,
      hasMore: snap.docs.length == limit,
    );
  }
}
