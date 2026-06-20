enum ProductStatus { safe, risky, unknown }

class Product {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String? ingredients;
  final String? barkod;
  final ProductStatus status;
  final String category;
  final Map<String, String>? nutrition;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    this.ingredients,
    this.barkod,
    required this.status,
    required this.category,
    this.nutrition,
  });

  factory Product.fromFirestore(Map<String, dynamic> data) {
    ProductStatus parseStatus(String? st) {
      if (st == 'GUVENLI') return ProductStatus.safe;
      if (st == 'RISKLI') return ProductStatus.risky;
      return ProductStatus.unknown;
    }

    return Product(
      id: data['id'] ?? '',
      name: data['urun_adi'] ?? '',
      brand: data['marka'] ?? '',
      imageUrl: data['resim'] ?? '',
      ingredients: data['icindekiler'],
      barkod: data['barkod'],
      status: parseStatus(data['durum']),
      category: data['kategori'] ?? 'Genel',
      nutrition: {
        'calories': data['kalori'] ?? 'N/A',
        'protein': data['protein'] ?? 'N/A',
        'carbs': data['karbonhidrat'] ?? 'N/A',
      },
    );
  }
}
