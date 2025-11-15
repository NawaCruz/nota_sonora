import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReaderPage extends StatelessWidget {
  final String title;
  final String pdfUrl; // o ruta local

  const PdfReaderPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SfPdfViewer.network(pdfUrl), // si usas URL de Firebase Storage
      // body: SfPdfViewer.asset('assets/tu_pdf.pdf'),  // si es asset
      // body: SfPdfViewer.file(File(rutaLocal)),       // si lo descargas al dispositivo
    );
  }
}
