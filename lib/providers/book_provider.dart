import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  static const _booksKey = 'local_books';

  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> startFetchingBooks() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_booksKey);

    if (raw == null) {
      await _seedBooks(prefs);
    } else {
      final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
      _books = list.map((e) => Book.fromJson(e)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_booksKey, jsonEncode(_books.map((b) => b.toJson()).toList()));
  }

  Future<void> _seedBooks(SharedPreferences prefs) async {
    final seedData = [
      Book(id: '1', title: 'Clean Code', author: 'Robert C. Martin', isbn: '978-0132350884', quantity: 5),
      Book(id: '2', title: 'The Pragmatic Programmer', author: 'Andrew Hunt', isbn: '978-0135957059', quantity: 3),
      Book(id: '3', title: 'Design Patterns', author: 'Gang of Four', isbn: '978-0201633610', quantity: 4),
      Book(id: '4', title: 'Introduction to Algorithms', author: 'Thomas H. Cormen', isbn: '978-0262033848', quantity: 6),
      Book(id: '5', title: 'The Mythical Man-Month', author: 'Frederick P. Brooks', isbn: '978-0201835953', quantity: 2),
      Book(id: '6', title: 'Code Complete', author: 'Steve McConnell', isbn: '978-0735619678', quantity: 4),
      Book(id: '7', title: 'Refactoring', author: 'Martin Fowler', isbn: '978-0134757599', quantity: 3),
      Book(id: '8', title: "You Don't Know JS", author: 'Kyle Simpson', isbn: '978-1491924464', quantity: 5),
      Book(id: '9', title: 'SICP', author: 'Harold Abelson', isbn: '978-0262510875', quantity: 2),
      Book(id: '10', title: 'The Art of Computer Programming', author: 'Donald E. Knuth', isbn: '978-0201896831', quantity: 1),
    ];
    _books = seedData;
    await prefs.setString(_booksKey, jsonEncode(_books.map((b) => b.toJson()).toList()));
  }

  Future<void> addBook(Book book) async {
    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: book.title,
      author: book.author,
      isbn: book.isbn,
      quantity: book.quantity,
    );
    _books.add(newBook);
    await _saveBooks();
    notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
    await _saveBooks();
    notifyListeners();
  }

  Future<void> toggleStatus(String id, bool currentStatus) async {
    final index = _books.indexWhere((b) => b.id == id);
    if (index != -1) {
      _books[index].isIssued = !currentStatus;
      await _saveBooks();
      notifyListeners();
    }
  }
}
