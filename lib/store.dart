import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/book.dart';
import 'models/customer.dart';
import 'models/sale.dart';

class AppStore extends ChangeNotifier {
  AppStore._();
  static final instance = AppStore._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Book> _books = [];
  List<Customer> _customers = [];
  List<Sale> _sales = [];
  bool _loading = true;
  String? _error;
  bool _initialized = false;

  // Stream subscriptions
  StreamSubscription? _booksSub;
  StreamSubscription? _customersSub;
  StreamSubscription? _salesSub;

  List<Book> get books => _books;
  List<Customer> get customers => _customers;
  List<Sale> get sales => _sales;
  bool get loading => _loading;
  String? get error => _error;

  List<Book> get lowStockBooks => _books.where((b) => b.stock <= 5).toList();
  double get totalRevenue => _sales.fold(0.0, (prev, s) => prev + s.totalPrice);

  /// Call after auth state is confirmed to begin listening to Firestore data.
  /// All authenticated staff share the same top-level collections.
  void init() {
    if (_initialized) return;
    _initialized = true;
    _loading = true;
    notifyListeners();

    // Listen to books collection (top-level, shared by all staff)
    _booksSub = _firestore
        .collection('books')
        .orderBy('title')
        .snapshots()
        .listen(
      (snapshot) {
        _books = snapshot.docs
            .map((doc) => Book.fromJson(doc.data(), doc.id))
            .toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load books: $e';
        _loading = false;
        notifyListeners();
      },
    );

    // Listen to customers collection (top-level, shared by all staff)
    _customersSub = _firestore
        .collection('customers')
        .orderBy('name')
        .snapshots()
        .listen(
      (snapshot) {
        _customers = snapshot.docs
            .map((doc) => Customer.fromJson(doc.data(), doc.id))
            .toList();
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load customers: $e';
        notifyListeners();
      },
    );

    // Listen to sales collection (top-level, shared by all staff)
    _salesSub = _firestore
        .collection('sales')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _sales = snapshot.docs
            .map((doc) => Sale.fromJson(doc.data(), doc.id))
            .toList();
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load sales: $e';
        notifyListeners();
      },
    );
  }

  void disposeStore() {
    _booksSub?.cancel();
    _customersSub?.cancel();
    _salesSub?.cancel();
    _initialized = false;
  }

  // ── Inventory ──────────────────────────────────────────────

  Future<String?> addBook(Book book) async {
    try {
      await _firestore.collection('books').add(book.toJson());
      return null;
    } catch (e) {
      return 'Failed to add book: $e';
    }
  }

  Future<String?> updateBook(Book updated) async {
    try {
      await _firestore
          .collection('books')
          .doc(updated.id)
          .update(updated.toJson());
      return null;
    } catch (e) {
      return 'Failed to update book: $e';
    }
  }

  Future<String?> removeBook(String id) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('books').doc(id));
      // Also remove related sales
      final salesSnap = await _firestore
          .collection('sales')
          .where('bookId', isEqualTo: id)
          .get();
      for (var doc in salesSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return null;
    } catch (e) {
      return 'Failed to remove book: $e';
    }
  }

  // ── Sales ───────────────────────────────────────────────────

  Future<String?> recordSale(String bookId, int quantity) async {
    if (quantity <= 0) return 'Quantity must be at least 1.';
    try {
      final bookRef = _firestore.collection('books').doc(bookId);

      // Use a transaction to decrement stock and record sale atomically
      await _firestore.runTransaction((transaction) async {
        final bookSnapshot = await transaction.get(bookRef);
        if (!bookSnapshot.exists) return 'Book not found.';

        final book = Book.fromJson(
          bookSnapshot.data()!,
          bookSnapshot.id,
        );
        if (book.stock < quantity) return 'Insufficient stock.';

        // Decrement stock
        transaction.update(bookRef, {'stock': book.stock - quantity});

        // Record sale
        final saleRef = _firestore.collection('sales').doc();
        transaction.set(saleRef, Sale(
          id: saleRef.id,
          bookId: bookId,
          bookTitle: book.title,
          quantity: quantity,
          totalPrice: book.price * quantity,
          date: DateTime.now(),
        ).toJson());

        return null;
      });
      return null;
    } catch (e) {
      return 'Failed to record sale: $e';
    }
  }

  // ── Customers ───────────────────────────────────────────────

  Future<String?> addCustomer(Customer customer) async {
    if (!RegExp(r'^\d+$').hasMatch(customer.phone)) {
      return 'Phone number must contain digits only.';
    }
    try {
      await _firestore.collection('customers').add(customer.toJson());
      return null;
    } catch (e) {
      return 'Failed to add customer: $e';
    }
  }

  Future<String?> removeCustomer(String id) async {
    try {
      await _firestore.collection('customers').doc(id).delete();
      return null;
    } catch (e) {
      return 'Failed to remove customer: $e';
    }
  }
}