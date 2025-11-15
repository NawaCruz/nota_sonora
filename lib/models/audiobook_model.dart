class AudioBookModel {
  final String id;
  final String title;
  final String author;
  final String color;
  final double progress;
  final bool isNew;
  final String aiSummary;

  AudioBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.color,
    required this.progress,
    required this.isNew,
    required this.aiSummary,
  });
}
