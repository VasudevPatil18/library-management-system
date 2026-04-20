import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  // Real-time Books Fetch (Stream)
  void startFetchingBooks() {
    _isLoading = true;
    _db.collection('books').snapshots().listen((snapshot) {
      _books = snapshot.docs.map((doc) {
        return Book(
          id: doc.id, // Firebase Document ID
          title: doc['title'],
          author: doc['author'],
          isbn: doc['isbn'],
          quantity: doc['quantity'],
          isIssued: doc['isIssued'] ?? false,
        );
      }).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Create Book
  Future<void> addBook(Book book) async {
    await _db.collection('books').add({
      'title': book.title,
      'author': book.author,
      'isbn': book.isbn,
      'quantity': book.quantity,
      'isIssued': false,
    });
  }

  // Delete Book
  Future<void> deleteBook(String id) async {
    await _db.collection('books').doc(id).delete();
  }

  // Toggle Issued Status
  Future<void> toggleStatus(String id, bool currentStatus) async {
    await _db.collection('books').doc(id).update({'isIssued': !currentStatus});
  }
}