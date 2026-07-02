import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Konum servisi kapalı.');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Konum izni reddedildi: $permission');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('Anlık konum alınamadı, son bilinen konuma düşülüyor: $e');
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) {
        debugPrint('Son bilinen konum da yok.');
      }
      return lastKnown;
    }
  }
}
