class TipSection {
  final String heading;
  final String body;

  const TipSection({required this.heading, required this.body});
}

class Tip {
  final String id;
  final String category;
  final String imageAsset;
  final String title;
  final String summary;
  final List<TipSection> sections;
  final String author;
  final DateTime date;
  final int likes;
  final int dislikes;
  final int commentCount;

  const Tip({
    required this.id,
    required this.category,
    required this.imageAsset,
    required this.title,
    required this.summary,
    required this.sections,
    required this.author,
    required this.date,
    required this.likes,
    required this.dislikes,
    required this.commentCount,
  });
}
