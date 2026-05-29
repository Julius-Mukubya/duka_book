class Book {
  String id;
  String title;
  String author;
  String category;
  double price;
  int stock;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory Book.fromJson(Map<String, dynamic> json, String docId) {
    return Book(
      id: docId,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'category': category,
      'price': price,
      'stock': stock,
    };
  }
}