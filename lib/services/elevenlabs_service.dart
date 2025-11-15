import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  static const String apiKey = 'TU_API_KEY_ELEVENLABS'; // Reemplazar con tu key real
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  
  // Voice ID por defecto - puedes cambiarlo por uno en español
  static const String defaultVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Voz en inglés
  // Para español busca: 'MF3mGyEYCl7XYWbV9V6O' o 'ErXwobaYiN019PkySvjV'
  
  static Future<String> textoAVoz(String texto, {String voiceId = defaultVoiceId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text-to-speech/$voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': texto,
          'model_id': 'eleven_multilingual_v2', // Modelo multilingüe
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.8,
            'style': 0.2,
            'use_speaker_boost': true,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        // Guardar audio temporalmente
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception('Error ElevenLabs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en ElevenLabs: $e');
    }
  }
}