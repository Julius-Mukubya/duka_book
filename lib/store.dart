import 'package:flutter/foundation.dart';
import 'models/book.dart';
import 'models/customer.dart';
import 'models/sale.dart';

class AppStore extends ChangeNotifier {
  final List<Book> books = [
    Book(id: '1', title: 'Things Fall Apart', author: 'Chinua Achebe', category: 'Fiction', price: 25000, stock: 20),
    Book(id: '2', title: 'The River and the Source', author: 'Margaret Ogola', category: 'Fiction', price: 18000, stock: 3),
    Book(id: '3', title: 'Weep Not Child', author: 'Ngugi wa Thiong\'o', category: 'Fiction', price: 20000, stock: 8),
  ];

  final List<Customer> customers = [
    Customer(id: '1', name: 'Alice Nakato', phone: '0701234567', location: 'Kampala'),
  ];

  final List<Sale> sales = [];

  // ── Inventory ──────────────────────────────────────────────
  void addBook(Book book) {
    books.add(book);
    notifyListeners();
  }

  void updateBook(Book updated) {
    final i = books.indexWhere((b) => b.id == updated.id);
    if (i != -1) {
      books[i] = updated;
      notifyListeners();
    }
  }

  void removeBook(String id) {
    books.removeWhere((b) => b.id == id);
    sales.removeWhere((s) => s.bookId == id);
    notifyListeners();
  }

  // ── Sales ───────────────────────────────────────────────────
  String? recordSale(String bookId, int quantity) {
    if (quantity <= 0) return 'Quantity must be at least 1.';
    final book = books.firstWhere((b) => b.id == bookId);
    if (book.stock < quantity) return 'Insufficient stock.';
    book.stock -= quantity;
    sales.add(Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      bookTitle: book.title,
      quantity: quantity,
      totalPrice: book.price * quantity,
      date: DateTime.now(),
    ));
    notifyListeners();
    return null;
  }

  // ── Customers ───────────────────────────────────────────────
  String? addCustomer(Customer customer) {
    if (!RegExp(r'^\d+$').hasMatch(customer.phone)) {
      return 'Phone number must contain digits only.';
    }
    customers.add(customer);
    notifyListeners();
    return null;
  }

  void removeCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Dashboard helpers ───────────────────────────────────────
  List<Book> get lowStockBooks => books.where((b) => b.stock <= 5).toList();
  double get totalRevenue => sales.fold(0, (sum, s) => sum + s.totalPrice);
}
