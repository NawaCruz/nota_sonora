import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/audiobook_model.dart';

class PlayerScreen extends StatefulWidget {
  final AudioBookModel book;

  const PlayerScreen({super.key, required this.book});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  final double _progress = 0.0;
  String? _pdfError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(int.parse('0xFF${widget.book.color}')),
              Color(int.parse('0xFF${widget.book.color}')).withAlpha(179),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Visor de PDF en la parte superior
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPdfViewer(),
            ),
          ),
          // Información del libro y controles
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.author,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  _buildProgressBar(),
                  const SizedBox(height: 24),
                  _buildControls(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    // Debug: Verificar si hay PDF disponible
    print('PDF Path: ${widget.book.pdfPath}');
    print('PDF URL: ${widget.book.pdfUrl}');
    print('PDF Bytes: ${widget.book.pdfBytes != null ? "Disponible (${widget.book.pdfBytes!.length} bytes)" : "null"}');
    
    // Si hay bytes del PDF disponible (web), mostrarlo
  if (widget.book.pdfBytes != null) {
      // En Web algunos navegadores presentan problemas con memory().
      // Usamos un data URL como alternativa cuando es Web.
      if (kIsWeb) {
        final dataUrl =
            'data:application/pdf;base64,${base64Encode(widget.book.pdfBytes!)}';
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SfPdfViewer.network(
            dataUrl,
            initialZoomLevel: 1.0,
            enableDoubleTapZooming: true,
            pageSpacing: 4,
            onDocumentLoaded: (_) => setState(() => _pdfError = null),
            onDocumentLoadFailed: (details) {
              setState(() => _pdfError = details.description);
            },
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SfPdfViewer.memory(
          widget.book.pdfBytes!,
          initialZoomLevel: 1.0,
          enableDoubleTapZooming: true,
          pageSpacing: 4,
          onDocumentLoaded: (_) => setState(() => _pdfError = null),
          onDocumentLoadFailed: (details) {
            setState(() => _pdfError = details.description);
          },
        ),
      );
    }
    // Si hay un PDF path disponible (móvil/desktop), mostrarlo
    else if (widget.book.pdfPath != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SfPdfViewer.file(
          File(widget.book.pdfPath!),
          initialZoomLevel: 1.0,
          enableDoubleTapZooming: true,
          pageSpacing: 4,
          onDocumentLoaded: (_) => setState(() => _pdfError = null),
          onDocumentLoadFailed: (details) {
            setState(() => _pdfError = details.description);
          },
        ),
      );
    } else if (widget.book.pdfUrl != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SfPdfViewer.network(
          widget.book.pdfUrl!,
          initialZoomLevel: 1.0,
          enableDoubleTapZooming: true,
          pageSpacing: 4,
          onDocumentLoaded: (_) => setState(() => _pdfError = null),
          onDocumentLoadFailed: (details) {
            setState(() => _pdfError = details.description);
          },
        ),
      );
    }
    
    // Si no hay PDF o hay error, mostrar placeholder
    return _buildPdfPlaceholder();
  }

  Widget _buildPdfPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 48, color: Colors.deepPurple),
          const SizedBox(height: 12),
          Text(
            _pdfError == null
                ? 'No hay PDF disponible para mostrar'
                : 'No se pudo cargar el PDF',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (_pdfError != null) ...[
            const SizedBox(height: 8),
            Text(
              _pdfError!,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Consejos: vuelve a subir el archivo, prueba con otro PDF o usa móvil/desktop para archivos grandes.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  // Book cover eliminado al priorizar el visor de PDF y placeholder.

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(
            Color(int.parse('0xFF${widget.book.color}')),
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0:00',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '45:30',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 36,
          onPressed: () {},
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${widget.book.color}')),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(int.parse('0xFF${widget.book.color}')).withAlpha(102),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 48,
            onPressed: () {
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 36,
          onPressed: () {},
        ),
      ],
    );
  }
}