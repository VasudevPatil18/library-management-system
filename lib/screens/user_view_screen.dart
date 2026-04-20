import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lib/providers/book_provider.dart'; // Sirf ye ek line kafi hai
class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});

  @override
  State<UserViewScreen> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  @override
  void initState() {
    super.initState();
    // Firebase se books load karna
    // UserViewScreen mein ye line change karein:
Future.microtask(() => 
  Provider.of<BookProvider>(context, listen: false).startFetchingBooks() // fetchBooks ki jagah ye likhein
);
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Books"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: bookProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : bookProvider.books.isEmpty
          ? const Center(child: Text("No books available in library."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.indigo),
                    title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Author: ${book.author}\nISBN: ${book.isbn}"),
                    trailing: Chip(
                      label: Text(book.isIssued ? "Issued" : "Available"),
                      backgroundColor: book.isIssued ? Colors.orange.shade100 : Colors.green.shade100,
                    ),
                  ),
                );
              },
            ),
    );
  }
}