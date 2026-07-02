import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

// Yakınındaki Mekanlar haritasının tam ekran hâli
class VenueMapScreen extends StatelessWidget {
  const VenueMapScreen({super.key, required this.center, this.hasUserLocation = false});

  final LatLng center;
  final bool hasUserLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kOnSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Yakınındaki Mekanlar',
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: FlutterMap(
        key: ValueKey(center),
        options: MapOptions(
          initialCenter: center,
          initialZoom: hasUserLocation ? 15 : 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.glufree.app',
          ),
          if (hasUserLocation)
            MarkerLayer(markers: [
              Marker(
                point: center,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location, color: kPrimary, size: 30),
              ),
            ]),
        ],
      ),
    );
  }
}
