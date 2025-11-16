import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TtsService _ttsService = TtsService();
  String _selectedVoice = 'Voz del Sistema';
  String _selectedVoiceId = '';
  List<Map<dynamic, dynamic>> _availableVoices = [];
  List<Map<String, String>> _simplifiedVoices = [];
  double _speechRate = 1.0;
  bool _aiPreview = true;
  bool _autoSummary = true;
  bool _chatEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _ttsService.initialize();
    
    // Cargar voces disponibles
    final voices = await _ttsService.getAvailableVoices();
    if (voices.isNotEmpty) {
      setState(() {
        _availableVoices = voices.cast<Map<dynamic, dynamic>>();
        
        // Crear lista simplificada de voces en español
        _simplifiedVoices = [];
        int femaleCount = 0;
        int maleCount = 0;
        
        for (var voice in _availableVoices) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          final name = voice['name']?.toString() ?? '';
          
          if (locale.startsWith('es')) {
            String displayName;
            String country = '';
            
            // Determinar el país
            if (locale.contains('us')) {
              country = 'Estados Unidos';
            } else if (locale.contains('es')) {
              country = 'España';
            } else if (locale.contains('mx')) {
              country = 'México';
            } else if (locale.contains('ar')) {
              country = 'Argentina';
            } else {
              country = 'Internacional';
            }
            
            // Simplificar el nombre
            if (name.toLowerCase().contains('female') || name.toLowerCase().contains('woman')) {
              femaleCount++;
              displayName = 'Voz Femenina ${femaleCount > 1 ? femaleCount : ''} ($country)'.trim();
            } else if (name.toLowerCase().contains('male') || name.toLowerCase().contains('man')) {
              maleCount++;
              displayName = 'Voz Masculina ${maleCount > 1 ? maleCount : ''} ($country)'.trim();
            } else {
              displayName = 'Voz $country';
            }
            
            _simplifiedVoices.add({
              'displayName': displayName,
              'country': country,
              'actualName': name,
              'locale': locale,
            });
          }
        }
        
        // Si hay voces, seleccionar la primera
        if (_simplifiedVoices.isNotEmpty) {
          _selectedVoice = _simplifiedVoices[0]['displayName']!;
          _selectedVoiceId = _simplifiedVoices[0]['actualName']!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B66EA), Color(0xFF4DD0E1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'Ajustes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildVoiceSettings(),
                      const SizedBox(height: 24),
                      _buildSpeedSettings(),
                      const SizedBox(height: 24),
                      _buildAISettings(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo (2).png',
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AudiFy',
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Configuración',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.grey[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Voz de Narración',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showVoiceSelector,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _selectedVoice,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.grey[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Velocidad de Reproducción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('0.5x', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _speechRate,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  activeColor: const Color(0xFF5B66EA),
                  onChanged: (value) {
                    setState(() => _speechRate = value);
                    _ttsService.setSpeechRate(value);
                  },
                ),
              ),
              const Text('2.0x', style: TextStyle(fontSize: 12)),
            ],
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B66EA).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_speechRate.toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B66EA),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.grey[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Características de IA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Vista Previa de IA',
            'Muestra resúmenes generados automáticamente',
            _aiPreview,
            (value) => setState(() => _aiPreview = value),
          ),
          const Divider(),
          _buildSwitchTile(
            'Resumen Automático',
            'Genera resúmenes al cargar libros',
            _autoSummary,
            (value) => setState(() => _autoSummary = value),
          ),
          const Divider(),
          _buildSwitchTile(
            'Chat con IA',
            'Habilita conversaciones sobre el contenido',
            _chatEnabled,
            (value) => setState(() => _chatEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFF5B66EA),
            activeThumbColor: const Color(0xFF5B66EA),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showVoiceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar Voz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_simplifiedVoices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Cargando voces disponibles...'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _simplifiedVoices.length,
                  itemBuilder: (context, index) {
                    final voice = _simplifiedVoices[index];
                    final displayName = voice['displayName']!;
                    final country = voice['country']!;
                    final actualName = voice['actualName']!;
                    final isSelected = _selectedVoiceId == actualName;
                    
                    return ListTile(
                      title: Text(displayName),
                      subtitle: Text(country, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF5B66EA)) : null,
                      onTap: () async {
                        setState(() {
                          _selectedVoice = displayName;
                          _selectedVoiceId = actualName;
                        });
                        
                        // Aplicar la voz seleccionada al TTS
                        await _ttsService.setVoice({
                          'name': actualName,
                          'locale': voice['locale']!,
                        });
                        
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
