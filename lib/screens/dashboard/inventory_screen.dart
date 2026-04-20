import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../models/book_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Firebase se realtime data fetch karna shuru karein
    Future.microtask(() {
      Provider.of<BookProvider>(context, listen: false).startFetchingBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Books Inventory", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (bookProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (bookProvider.books.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No books in Firebase. Add your first book!", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: bookProvider.books.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = bookProvider.books[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          child: const Icon(Icons.book, color: Colors.indigo),
                        ),
                        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("By ${book.author}"),
                            Text("ISBN: ${book.isbn}  |  Qty: ${book.quantity}", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Interactive Status Chip (Click to toggle)
                            GestureDetector(
                              onTap: () => bookProvider.toggleStatus(book.id, book.isIssued),
                              child: _statusChip(book.isIssued),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => bookProvider.deleteBook(book.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookDialog(context),
        label: const Text("Add New Book"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Book Entry"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(_titleController, "Book Title", Icons.title),
                _buildField(_authorController, "Author Name", Icons.person),
                _buildField(_isbnController, "ISBN Number", Icons.numbers),
                _buildField(_qtyController, "Quantity", Icons.format_list_numbered, isNumeric: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newBook = Book(
                  id: '', // Firebase auto-generate karega
                  title: _titleController.text,
                  author: _authorController.text,
                  isbn: _isbnController.text,
                  quantity: int.parse(_qtyController.text),
                );
                
                await Provider.of<BookProvider>(context, listen: false).addBook(newBook);
                
                _titleController.clear();
                _authorController.clear();
                _isbnController.clear();
                _qtyController.clear();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Book added to Firebase Cloud!")),
                );
              }
            },
            child: const Text("Save Book"),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value!.isEmpty ? "Required field" : null,
      ),
    );
  }

  Widget _statusChip(bool isIssued) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isIssued ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isIssued ? Colors.orange : Colors.green, width: 0.5),
      ),
      child: Text(
        isIssued ? "Issued" : "Available",
        style: TextStyle(color: isIssued ? Colors.orange : Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}