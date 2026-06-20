import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../search/data/models/product.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../../../core/theme/app_colors.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  final VoidCallback onBack;

  const DetailScreen({super.key, required this.product, required this.onBack});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('favoriler').doc(userId).get();
    if (doc.exists && mounted) {
      final List urunler = doc.data()?['urun_idleri'] ?? [];
      setState(() => isFavorite = urunler.contains(widget.product.id));
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorilere eklemek için giriş yapmanız gerekiyor.')),
        );
      }
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('favoriler').doc(userId);
    if (isFavorite) {
      await docRef.update({'urun_idleri': FieldValue.arrayRemove([widget.product.id])});
    } else {
      await docRef.set(
        {'urun_idleri': FieldValue.arrayUnion([widget.product.id])},
        SetOptions(merge: true),
      );
    }
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _productHeroCard(),
                  const SizedBox(height: 18),
                  _glutenStatusCard(),
                  const SizedBox(height: 28),
                  const Text(
                    'Besin Değerleri (100g)',
                    style: TextStyle(color: kOnSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _nutCard('Kalori', widget.product.nutrition?['calories'] ?? '140', Icons.local_fire_department, Colors.orange),
                      const SizedBox(width: 12),
                      _nutCard('Protein', widget.product.nutrition?['protein'] ?? '2g', Icons.fitness_center, Colors.blue),
                      const SizedBox(width: 12),
                      _nutCard('Karb.', widget.product.nutrition?['carbs'] ?? '18g', Icons.grain, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _ingredientsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kOnSurface, size: 20),
        onPressed: widget.onBack,
      ),
      title: const Text(
        'Ürün Detayları',
        style: TextStyle(color: kOnSurface, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
    );
  }

  Widget _productHeroCard() {
    final userId = AuthService.currentUserId;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kSurfaceContainerHighest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Image.network(
              widget.product.imageUrl,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: kPrimary, size: 64),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.brand,
                        style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.name,
                        style: const TextStyle(color: kOnSurface, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: userId != null ? _toggleFavorite : null,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: userId != null ? kSecondaryFixed : kSurfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: userId != null ? kSecondary : kOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glutenStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: kPrimaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gluten Durumu',
                style: TextStyle(color: kOnSurface, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 6),
              Text('GÜVENLİ', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutCard(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(val, style: const TextStyle(color: kOnSurface, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _ingredientsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant_menu, color: kPrimary, size: 18),
              SizedBox(width: 8),
              Text(
                'İçindekiler',
                style: TextStyle(color: kOnSurface, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.ingredients ?? 'İçerik bilgisi bulunamadı.',
            style: const TextStyle(color: kOnSurfaceVariant, height: 1.6, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
