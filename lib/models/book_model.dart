class Book {
  String id;
  String title;
  String author;
  String isbn;
  int quantity;
  bool isIssued;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.quantity,
    this.isIssued = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'isbn': isbn,
    'quantity': quantity,
    'isIssued': isIssued,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    author: json['author'] ?? '',
    isbn: json['isbn'] ?? '',
    quantity: json['quantity'] ?? 0,
    isIssued: json['isIssued'] ?? false,
  );
}
