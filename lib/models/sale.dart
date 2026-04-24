class Sale {
  final String id;
  final String bookId;
  final String bookTitle;
  final int quantity;
  final double totalPrice;
  final DateTime date;

  Sale({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });
}
