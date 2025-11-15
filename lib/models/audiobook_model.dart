import 'dart:typed_data';

class AudioBookModel {
  final String id;
  final String title;
  final String author;
  final String color;
  final double progress;
  final bool isNew;
  final String aiSummary;
  final String fullText; // Texto extraído del documento
  final String? pdfPath; // Ruta local del PDF (móvil/desktop)
  final String? pdfUrl; // URL del PDF (Firebase Storage, etc.)
  final Uint8List? pdfBytes; // Bytes del PDF (para web)

  AudioBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.color,
    required this.progress,
    required this.isNew,
    required this.aiSummary,
    this.fullText = '',
    this.pdfPath,
    this.pdfUrl,
    this.pdfBytes,
  });
}
