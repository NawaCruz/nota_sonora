import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiPDFService {
  static const String apiKey = 'TU_API_KEY_GEMINI'; // Obtener de Google AI Studio
  
  static Future<String> procesarPDF(File pdfFile, String prompt) async {
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
  
  static Future<Map<String, String>> procesamientoCompleto(File pdfFile) async {
    return {
      'resumenCorto': await procesarPDF(pdfFile, 'Haz un resumen ejecutivo de 1 párrafo'),
      'resumenLargo': await procesarPDF(pdfFile, 'Haz un resumen extenso de 3-4 párrafos'),
      'puntosClave': await procesarPDF(pdfFile, 'Extrae los 5 puntos clave más importantes en bullet points'),
    };
  }
}