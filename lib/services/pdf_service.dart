import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class PDFService {
  static const String apiKey = 'TU_API_KEY_GEMINI'; // Reemplazar con tu key

  static Future<String> processPDF(File pdfFile, String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      
      final pdfBytes = await pdfFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', pdfBytes),
        ])
      ];
      
      final response = await model.generateContent(content);
      return response.text ?? 'No se pudo procesar el PDF';
    } catch (e) {
      return 'Error: $e';
    }
  }
}