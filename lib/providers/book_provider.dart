import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = _books.map((b) => b.toJson()).toList();
    await prefs.setString('books', jsonEncode(booksJson));
  }

  void startFetchingBooks() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getString('books');
    if (booksJson != null) {
      final List<dynamic> decoded = jsonDecode(booksJson);
      _books = decoded.map((e) => Book.fromJson(e)).toList();
    } else {
      // Default books on first launch
      _books = [
        Book(id: '1', title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', isbn: '978-0743273565', quantity: 3),
        Book(id: '2', title: 'To Kill a Mockingbird', author: 'Harper Lee', isbn: '978-0061935466', quantity: 5),
        Book(id: '3', title: 'Clean Code', author: 'Robert C. Martin', isbn: '978-0132350884', quantity: 2),
        Book(id: '4', title: '1984', author: 'George Orwell', isbn: '978-0451524935', quantity: 4),
        Book(id: '5', title: 'The Alchemist', author: 'Paulo Coelho', isbn: '978-0062315007', quantity: 6),
        Book(id: '6', title: 'Harry Potter and the Sorcerer\'s Stone', author: 'J.K. Rowling', isbn: '978-0439708180', quantity: 3),
        Book(id: '7', title: 'The Pragmatic Programmer', author: 'Andrew Hunt', isbn: '978-0135957059', quantity: 2),
        Book(id: '8', title: 'Atomic Habits', author: 'James Clear', isbn: '978-0735211292', quantity: 5),
        Book(id: '9', title: 'Rich Dad Poor Dad', author: 'Robert Kiyosaki', isbn: '978-1612680194', quantity: 4),
        Book(id: '10', title: 'The Lean Startup', author: 'Eric Ries', isbn: '978-0307887894', quantity: 2),
      ];
      await _saveBooks();
    }

    _isLoading = false;
    notifyListeners();
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
