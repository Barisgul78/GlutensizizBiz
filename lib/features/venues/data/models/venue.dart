class Venue {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String rating;
  final String distance;
  final String location;
  final String badgeText;
  final List<String> tags;

  const Venue({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.distance,
    required this.location,
    required this.badgeText,
    required this.tags,
  });

  factory Venue.fromFirestore(String id, Map<String, dynamic> data) {
    return Venue(
      id: id,
      imageUrl: data['resim'] ?? '',
      title: data['ad'] ?? '',
      description: data['aciklama'] ?? '',
      rating: (data['puan'] ?? 0).toString(),
      distance: data['mesafe'] ?? '',
      location: data['adres'] ?? '',
      badgeText: data['rozet'] ?? 'Glutensiz',
      tags: List<String>.from(data['etiketler'] ?? []),
    );
  }
}
