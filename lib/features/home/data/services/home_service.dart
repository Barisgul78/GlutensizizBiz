import '../../../venues/data/models/venue.dart';
import '../../../venues/data/services/venues_service.dart';

class HomeService {
  HomeService._();

  static Future<List<Venue>> fetchNearbyVenues({int limit = 3}) async {
    final page = await VenuesService.fetchPage(limit: limit);
    return page.items;
  }
}
