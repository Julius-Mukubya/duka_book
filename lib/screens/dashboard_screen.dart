import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Duka Book', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  'UGX ${store.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                ),
                const Text('Total Revenue', style: TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats grid
          const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatCard('Books', '${store.books.length}', Icons.menu_book_rounded, const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
              _StatCard('Sales', '${store.sales.length}', Icons.receipt_long_rounded, const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
              _StatCard('Customers', '${store.customers.length}', Icons.people_rounded, const Color(0xFF6A1B9A), const Color(0xFFF3E5F5)),
              _StatCard('Low Stock', '${store.lowStockBooks.length}', Icons.warning_rounded, const Color(0xFFE65100), const Color(0xFFFFF3E0)),
            ],
          ),
          const SizedBox(height: 24),

          // Low stock section
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 20),
              const SizedBox(width: 8),
              const Text('Low Stock Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '≤ 5 units',
                  style: TextStyle(fontSize: 11, color: const Color(0xFFE65100), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          store.lowStockBooks.isEmpty
              ? _EmptyState(icon: Icons.check_circle_rounded, message: 'All books are well stocked', color: Colors.green)
              : Column(
                  children: store.lowStockBooks.map((b) => _LowStockTile(b)).toList(),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _StatCard(this.label, this.value, this.icon, this.iconColor, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const Expanded(child: SizedBox()),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final dynamic book;
  const _LowStockTile(this.book);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCBC), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.menu_book_rounded, color: Color(0xFFE65100), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(book.author, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: book.stock == 0 ? Colors.red.shade50 : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: book.stock == 0 ? Colors.red.shade200 : const Color(0xFFFFCCBC)),
            ),
            child: Text(
              '${book.stock} left',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: book.stock == 0 ? Colors.red.shade700 : const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _EmptyState({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
