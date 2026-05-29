import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Sale.fromJson(Map<String, dynamic> json, String docId) {
    return Sale(
      id: docId,
      bookId: json['bookId'] as String? ?? '',
      bookTitle: json['bookTitle'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': Timestamp.fromDate(date),
    };
  }
}