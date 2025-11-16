/// Centraliza la lectura de variables de entorno inyectadas con --dart-define
/// Nunca subas tus API keys en el código fuente.
class Env {
  // Google AI Studio - Gemini
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDXxQFNNqw-NroNebQ1jvo64AIAq9NJZmk',
  );

  // ElevenLabs (para futuras implementaciones de TTS premium)
  static const elevenLabsApiKey = String.fromEnvironment(
    'ELEVENLABS_API_KEY',
    defaultValue: 'sk_63158b65bcaef7e2f8af90e49ab1cbff97b2c59845c75c52',
  );
}
