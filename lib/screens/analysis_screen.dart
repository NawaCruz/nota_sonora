import 'package:flutter/material.dart';
import '../main.dart';
import '../models/audiobook_model.dart';
import '../services/ai_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final AiService _aiService = AiService();
  AudioBookModel? _selectedBook;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedBook == null) {
      return;
    }

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'message': userMessage,
      });
      _isProcessing = true;
    });

    try {
      final response = await _aiService.chatAboutBook(
        _selectedBook!.title,
        _selectedBook!.fullText,
        userMessage,
      );

      setState(() {
        _messages.add({
          'role': 'assistant',
          'message': response,
        });
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'message': 'Error al procesar tu mensaje: $e',
        });
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleToolTap(String tool, Color color) async {
    if (tool == 'Resumir') {
      // Solo Resumir funciona, los demás en desarrollo
      if (_selectedBook == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Selecciona un libro primero'),
            backgroundColor: Color(0xFFFFA726),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (_selectedBook!.fullText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Este libro no tiene texto cargado'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      await _generateSummary();
    } else {
      // Otras herramientas en desarrollo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚧 $tool - En desarrollo'),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isProcessing = true;
      _messages.add({
        'role': 'system',
        'message': '📝 Generando resumen de "${_selectedBook!.title}"...',
      });
    });

    try {
      final summary = await _aiService.generateSummary(
        _selectedBook!.title,
        _selectedBook!.fullText,
      );

      setState(() {
        _messages.removeLast(); // Remover mensaje de "Generando..."
        _messages.add({
          'role': 'assistant',
          'message': summary,
        });
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'role': 'assistant',
          'message': '❌ Error al generar resumen: $e',
        });
        _isProcessing = false;
      });
    }
  }

  void _showBookSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Selecciona un libro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<List<AudioBookModel>>(
              stream: audiobookService.booksStream,
              initialData: audiobookService.currentBooks,
              builder: (context, snapshot) {
                final books = snapshot.data ?? [];
                if (books.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_outlined, 
                          size: 60, 
                          color: Colors.grey[300]
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay libros subidos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ve a "Subir" para agregar un libro',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: books.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final isSelected = _selectedBook?.id == book.id;
                    
                    return Card(
                      elevation: isSelected ? 2 : 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected 
                              ? const Color(0xFF5B66EA) 
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(int.parse('0xFF${book.color}')),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          book.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? const Color(0xFF5B66EA) 
                                : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (book.fullText.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${book.fullText.length} caracteres',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5B66EA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                        onTap: () {
                          setState(() {
                            _selectedBook = book;
                          });
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📚 Libro seleccionado: ${book.title}'),
                              backgroundColor: const Color(0xFF4CAF50),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Herramientas de Análisis',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBookSelector(),
                            const SizedBox(height: 20),
                            _buildAnalysisTools(),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _buildChatArea(),
                      ),
                      _buildInputArea(),
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
                'Análisis inteligente',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBookSelector() {
    return StreamBuilder<List<AudioBookModel>>(
      stream: audiobookService.booksStream,
      initialData: audiobookService.currentBooks,
      builder: (context, snapshot) {
        final books = snapshot.data ?? [];
        final hasBooks = books.isNotEmpty;
        
        return InkWell(
          onTap: hasBooks ? _showBookSelector : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _selectedBook != null
                  ? LinearGradient(
                      colors: [
                        Color(int.parse('0xFF${_selectedBook!.color}')).withOpacity(0.1),
                        Color(int.parse('0xFF${_selectedBook!.color}')).withOpacity(0.05),
                      ],
                    )
                  : null,
              color: _selectedBook == null 
                  ? const Color(0xFF5B66EA).withAlpha(26)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedBook != null
                    ? Color(int.parse('0xFF${_selectedBook!.color}')).withOpacity(0.3)
                    : const Color(0xFF5B66EA).withAlpha(51),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                if (_selectedBook != null)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${_selectedBook!.color}')),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: Color(0xFF5B66EA),
                      size: 24,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBook != null
                            ? _selectedBook!.title
                            : hasBooks
                                ? 'Selecciona un libro'
                                : 'No hay libros disponibles',
                        style: TextStyle(
                          color: _selectedBook != null
                              ? Color(int.parse('0xFF${_selectedBook!.color}'))
                              : const Color(0xFF5B66EA),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedBook != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _selectedBook!.fullText.isNotEmpty
                                    ? 'Listo para análisis (${_selectedBook!.fullText.length} caracteres)'
                                    : 'Sin contenido extraído',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _selectedBook!.fullText.isNotEmpty
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasBooks)
                  Icon(
                    Icons.arrow_drop_down_circle,
                    color: _selectedBook != null
                        ? Color(int.parse('0xFF${_selectedBook!.color}'))
                        : const Color(0xFF5B66EA),
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTools() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildToolCard(Icons.summarize, 'Resumir', const Color(0xFF5B66EA)),
        _buildToolCard(Icons.lightbulb_outline, 'Explicar', const Color(0xFFFF6B9D)),
        _buildToolCard(Icons.quiz, 'Preguntas', const Color(0xFF4DD0E1)),
        _buildToolCard(Icons.account_tree, 'Mapa Mental', const Color(0xFFFFA726)),
      ],
    );
  }

  Widget _buildToolCard(IconData icon, String label, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleToolTap(label, color),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(51)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Inicia una conversación',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: false,
      itemCount: _messages.length + (_isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        // Mostrar indicador de carga al final
        if (_isProcessing && index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pensando...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        final message = _messages[index];
        final isUser = message['role'] == 'user';
        final isSystem = message['role'] == 'system';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: isUser 
                  ? const Color(0xFF5B66EA) 
                  : isSystem
                      ? Colors.amber[100]
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message['message']!,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    final hasBookSelected = _selectedBook != null;
    final hasContent = _selectedBook?.fullText.isNotEmpty ?? false;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!hasBookSelected || !hasContent)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      !hasBookSelected 
                          ? 'Selecciona un libro para comenzar'
                          : 'Este libro no tiene contenido para analizar',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: hasBookSelected && hasContent && !_isProcessing,
                  decoration: InputDecoration(
                    hintText: hasBookSelected && hasContent
                        ? 'Escribe tu mensaje...'
                        : 'Selecciona un libro primero',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: hasBookSelected && hasContent
                        ? Colors.grey[100]
                        : Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: hasBookSelected && hasContent && !_isProcessing
                      ? const Color(0xFF5B66EA)
                      : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: hasBookSelected && hasContent && !_isProcessing
                      ? _sendMessage
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
