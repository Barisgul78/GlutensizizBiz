import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  String selectedFilter = 'Tüm Mekanlar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            const SliverPadding(padding: EdgeInsets.only(top: 8)),
            SliverToBoxAdapter(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('mekanlar').get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator(color: kPrimary)),
                    );
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                      child: Column(
                        children: [
                          const Icon(Icons.location_off_outlined,
                              color: kOutlineVariant, size: 52),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz mekan eklenmemiş',
                            style: GoogleFonts.plusJakartaSans(
                              color: kOnSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yakında glutensiz dostu mekanlar burada görünecek.',
                            style: GoogleFonts.sourceSans3(
                              color: kOnSurfaceVariant,
                              fontSize: 13,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildVenueCard(
                            imageUrl: data['resim'] ?? '',
                            title: data['ad'] ?? '',
                            description: data['aciklama'] ?? '',
                            rating: (data['puan'] ?? 0).toString(),
                            distance: data['mesafe'] ?? '',
                            location: data['adres'] ?? '',
                            badgeText: data['rozet'] ?? 'Glutensiz',
                            badgeColor: kPrimary,
                            tags: List<String>.from(data['etiketler'] ?? []),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Glutensiz Mekanları\nKeşfet',
                  style: GoogleFonts.plusJakartaSans(
                    color: kOnSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bütünsel yaşam tarzınıza hitap eden güvenilir yerel mekanları keşfedin.',
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kSurfaceContainerHigh,
            ),
            child: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kOutlineVariant),
        ),
        child: TextField(
          style: const TextStyle(color: kOnSurface),
          decoration: InputDecoration(
            icon: const Icon(Icons.search, color: kOnSurfaceVariant, size: 20),
            hintText: 'Kafe, fırın veya bölge ara...',
            hintStyle: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 14),
            suffixIcon: const Icon(Icons.tune_rounded, color: kOnSurfaceVariant, size: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tüm Mekanlar', 'Kafeler & Fırınlar', 'Restoranlar', 'Büfeler'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kPrimary : kSurfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? kPrimary : kOutlineVariant),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? kOnPrimary : kOnSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueCard({
    required String imageUrl,
    required String title,
    required String description,
    required String rating,
    required String distance,
    required String location,
    required String badgeText,
    required Color badgeColor,
    required List<String> tags,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görsel + overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: kSurfaceContainerHighest,
                    child: const Icon(Icons.restaurant, color: kOnSurfaceVariant, size: 40),
                  ),
                ),
              ),
              // Favori butonu
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kSurface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: kSecondary, size: 18),
                ),
              ),
              // Badge
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          // İçerik
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: kOnSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: GoogleFonts.plusJakartaSans(
                            color: kOnSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.sourceSans3(
                    color: kOnSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimaryFixed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(color: kPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: kOnSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$distance • $location',
                      style: GoogleFonts.sourceSans3(color: kOnSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: kOnPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Detayları Gör',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kOutlineVariant),
                        color: kSurfaceContainerHigh,
                      ),
                      child: const Icon(Icons.map_outlined, color: kPrimary, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
