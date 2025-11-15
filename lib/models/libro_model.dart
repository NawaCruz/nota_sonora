import 'dart:io';

class LibroProcesado {
  final File archivoPDF;
  final Map<String, String> analisis;
  final String? rutaAudio;

  LibroProcesado({
    required this.archivoPDF,
    required this.analisis,
    this.rutaAudio,
  });

  String get nombre => archivoPDF.path.split('/').last;
  String get resumenCorto => analisis['resumenCorto'] ?? '';
  String get resumenLargo => analisis['resumenLargo'] ?? '';
  String get puntosClave => analisis['puntosClave'] ?? '';
}