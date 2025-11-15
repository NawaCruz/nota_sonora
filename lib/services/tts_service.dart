import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = 1.0;
  double _currentProgress = 0.0;
  String _currentText = '';
  int _currentPosition = 0;
  
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<Duration> currentTimeNotifier = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration> totalDurationNotifier = ValueNotifier<Duration>(Duration.zero);

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  double get progress => _currentProgress;

  Future<void> initialize() async {
    try {
      // Configurar idioma por defecto a español
      await _flutterTts.setLanguage("es-ES");
      
      // Configurar velocidad inicial
      await _flutterTts.setSpeechRate(_speechRate);
      
      // Configurar volumen y tono
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Configurar callbacks
      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        _isPaused = false;
        isPlayingNotifier.value = true;
        debugPrint('TTS: Iniciado');
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _isPaused = false;
        _currentProgress = 1.0;
        isPlayingNotifier.value = false;
        progressNotifier.value = 1.0;
        debugPrint('TTS: Completado');
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        _isPaused = false;
        isPlayingNotifier.value = false;
        debugPrint('TTS: Cancelado');
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isPlaying = false;
        _isPaused = false;
        isPlayingNotifier.value = false;
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        if (_currentText.isNotEmpty) {
          _currentPosition = start;
          _currentProgress = start / _currentText.length;
          progressNotifier.value = _currentProgress;
          
          // Calcular tiempo actual basado en progreso
          final totalDuration = totalDurationNotifier.value;
          final currentSeconds = (totalDuration.inSeconds * _currentProgress).round();
          currentTimeNotifier.value = Duration(seconds: currentSeconds);
        }
      });

      debugPrint('TTS Service inicializado correctamente');
    } catch (e) {
      debugPrint('Error al inicializar TTS: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      if (text.isEmpty) {
        debugPrint('TTS: Texto vacío, no se puede reproducir');
        return;
      }

      _currentText = text;
      _currentPosition = 0;
      _currentProgress = 0.0;
      
      // Calcular duración total estimada
      final duration = _calculateDuration(text, _speechRate);
      totalDurationNotifier.value = duration;
      currentTimeNotifier.value = Duration.zero;
      progressNotifier.value = 0.0;

      await _flutterTts.speak(text);
      debugPrint('TTS: Reproduciendo texto de ${text.length} caracteres');
    } catch (e) {
      debugPrint('Error al reproducir texto: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isPaused = true;
      _isPlaying = false;
      isPlayingNotifier.value = false;
      debugPrint('TTS: Pausado');
    } catch (e) {
      debugPrint('Error al pausar: $e');
    }
  }

  Future<void> resume() async {
    try {
      // En Android/iOS, después de pause() necesitamos continuar desde donde paramos
      // Pero flutter_tts no tiene resume nativo, así que debemos usar speak con el texto restante
      if (_currentText.isNotEmpty && _currentPosition < _currentText.length) {
        final remainingText = _currentText.substring(_currentPosition);
        await _flutterTts.speak(remainingText);
      }
      _isPaused = false;
      _isPlaying = true;
      isPlayingNotifier.value = true;
      debugPrint('TTS: Reanudado');
    } catch (e) {
      debugPrint('Error al reanudar: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      _isPaused = false;
      _currentProgress = 0.0;
      _currentPosition = 0;
      isPlayingNotifier.value = false;
      progressNotifier.value = 0.0;
      currentTimeNotifier.value = Duration.zero;
      debugPrint('TTS: Detenido');
    } catch (e) {
      debugPrint('Error al detener: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      // Validar rango (0.5x - 2.0x)
      final validRate = rate.clamp(0.5, 2.0);
      _speechRate = validRate;
      await _flutterTts.setSpeechRate(validRate);
      
      // Recalcular duración si hay texto cargado
      if (_currentText.isNotEmpty) {
        final duration = _calculateDuration(_currentText, _speechRate);
        totalDurationNotifier.value = duration;
      }
      
      debugPrint('TTS: Velocidad cambiada a ${validRate}x');
    } catch (e) {
      debugPrint('Error al cambiar velocidad: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      debugPrint('TTS: Idioma cambiado a $language');
    } catch (e) {
      debugPrint('Error al cambiar idioma: $e');
    }
  }

  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
      debugPrint('TTS: Voz cambiada a ${voice["name"]}');
    } catch (e) {
      debugPrint('Error al cambiar voz: $e');
    }
  }

  Future<List<dynamic>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices ?? [];
    } catch (e) {
      debugPrint('Error al obtener voces: $e');
      return [];
    }
  }

  // Calcular duración estimada basada en palabras y velocidad
  Duration _calculateDuration(String text, double speechRate) {
    // Promedio de lectura: 150 palabras por minuto a velocidad normal (1.0x)
    const baseWordsPerMinute = 150.0;
    
    // Contar palabras
    final words = text.trim().split(RegExp(r'\s+')).length;
    
    // Ajustar por velocidad
    final effectiveWordsPerMinute = baseWordsPerMinute * speechRate;
    
    // Calcular minutos
    final minutes = words / effectiveWordsPerMinute;
    
    // Convertir a segundos
    final seconds = (minutes * 60).round();
    
    return Duration(seconds: seconds);
  }

  // Adelantar X segundos
  Future<void> seekForward(int seconds) async {
    if (_currentText.isEmpty) return;
    
    final totalDuration = totalDurationNotifier.value;
    final newTime = currentTimeNotifier.value + Duration(seconds: seconds);
    
    if (newTime >= totalDuration) {
      // Si se pasa del final, ir al final
      await seekToPosition(1.0);
    } else {
      final newProgress = newTime.inSeconds / totalDuration.inSeconds;
      await seekToPosition(newProgress);
    }
  }

  // Retroceder X segundos
  Future<void> seekBackward(int seconds) async {
    if (_currentText.isEmpty) return;
    
    final totalDuration = totalDurationNotifier.value;
    final newTime = currentTimeNotifier.value - Duration(seconds: seconds);
    
    if (newTime.isNegative) {
      // Si se pasa del inicio, ir al inicio
      await seekToPosition(0.0);
    } else {
      final newProgress = newTime.inSeconds / totalDuration.inSeconds;
      await seekToPosition(newProgress);
    }
  }

  // Buscar a una posición específica (0.0 a 1.0)
  Future<void> seekToPosition(double position) async {
    if (_currentText.isEmpty) return;
    
    try {
      final wasPlaying = _isPlaying;
      
      // Detener reproducción actual
      await _flutterTts.stop();
      
      // Calcular nueva posición en el texto
      final newPosition = (_currentText.length * position).round().clamp(0, _currentText.length);
      _currentPosition = newPosition;
      _currentProgress = position;
      
      // Actualizar progreso visual
      progressNotifier.value = position;
      
      // Actualizar tiempo actual
      final totalDuration = totalDurationNotifier.value;
      final currentSeconds = (totalDuration.inSeconds * position).round();
      currentTimeNotifier.value = Duration(seconds: currentSeconds);
      
      // Si estaba reproduciendo, continuar desde la nueva posición
      if (wasPlaying && newPosition < _currentText.length) {
        final remainingText = _currentText.substring(newPosition);
        await _flutterTts.speak(remainingText);
      }
      
      debugPrint('TTS: Buscando a posición ${(position * 100).toStringAsFixed(1)}%');
    } catch (e) {
      debugPrint('Error al buscar posición: $e');
    }
  }

  void dispose() {
    isPlayingNotifier.dispose();
    progressNotifier.dispose();
    currentTimeNotifier.dispose();
    totalDurationNotifier.dispose();
  }
}
