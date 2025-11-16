import 'dart:async';
import '../models/audiobook_model.dart';

class AudiobookService {
  final _booksController = StreamController<List<AudioBookModel>>.broadcast();
  final List<AudioBookModel> _books = [];

  Stream<List<AudioBookModel>> get booksStream => _booksController.stream;
  List<AudioBookModel> get books => List.unmodifiable(_books);
  
  // Obtener snapshot inicial
  List<AudioBookModel> get currentBooks => _books;

  void addBook(AudioBookModel book) {
    _books.add(book);
    _booksController.add(_books);
  }

  void removeBook(String id) {
    _books.removeWhere((book) => book.id == id);
    _booksController.add(_books);
  }

  void updateBook(AudioBookModel updatedBook) {
    final index = _books.indexWhere((book) => book.id == updatedBook.id);
    if (index != -1) {
      _books[index] = updatedBook;
      _booksController.add(_books);
    }
  }

  void dispose() {
    _booksController.close();
  }
}
