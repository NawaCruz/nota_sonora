import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../models/audiobook_model.dart';
import 'dart:math';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isProcessing = false;
  String? _currentFileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub', 'txt', 'docx'],
    );

    if (result != null) {
      setState(() {
        _isProcessing = true;
        _currentFileName = result.files.single.name;
      });

      await Future.delayed(const Duration(seconds: 2));

      final fileName = result.files.single.name;
      final extension = result.files.single.extension ?? '';
      
      final newBook = AudioBookModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: fileName.replaceAll('.$extension', ''),
        author: 'Documento subido',
        color: _getRandomColor(),
        progress: 0.0,
        isNew: true,
        aiSummary: 'Procesando documento...',
      );

      audiobookService.addBook(newBook);

      setState(() {
        _isProcessing = false;
        _currentFileName = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Archivo convertido a audiolibro'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getRandomColor() {
    final colors = ['5B66EA', 'FF6B9D', '4DD0E1', 'FFA726', '66BB6A'];
    return colors[Random().nextInt(colors.length)];
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (_isProcessing) ...[
                          const SizedBox(height: 80),
                          _buildProcessingIndicator(),
                          const SizedBox(height: 80),
                        ] else ...[
                          _buildUploadIcon(),
                          const SizedBox(height: 24),
                          const Text(
                            'Sube tus documentos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Convierte PDFs, EPUB y documentos de texto\nen audiolibros inteligentes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFileTypeButtons(),
                          const SizedBox(height: 32),
                          _buildFeatureCards(),
                          const SizedBox(height: 32),
                          _buildSelectButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B66EA)),
        ),
        const SizedBox(height: 24),
        Text(
          'Procesando: $_currentFileName',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Convirtiendo a audiolibro...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AudioBook AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sube documentos',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildUploadIcon() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF5B66EA).withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.upload_file,
        size: 80,
        color: Color(0xFF5B66EA),
      ),
    );
  }

  Widget _buildFileTypeButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildFileTypeChip(Icons.picture_as_pdf, 'PDF'),
        _buildFileTypeChip(Icons.menu_book, 'EPUB'),
        _buildFileTypeChip(Icons.description, 'TXT'),
        _buildFileTypeChip(Icons.article, 'DOCX'),
      ],
    );
  }

  Widget _buildFileTypeChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildFeatureCard(
          Icons.voice_chat,
          'Narración Natural',
        ),
        _buildFeatureCard(
          Icons.auto_awesome,
          'Resumen IA',
        ),
        _buildFeatureCard(
          Icons.translate,
          'Multi-Idioma',
        ),
        _buildFeatureCard(
          Icons.speed,
          'Velocidad',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF5B66EA).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF5B66EA), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _pickFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B66EA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open),
            SizedBox(width: 12),
            Text(
              'Seleccionar Archivo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
