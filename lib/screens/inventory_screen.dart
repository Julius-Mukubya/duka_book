import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import '../models/book.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showDialog(BuildContext context, [Book? existing]) {
    final store = context.read<AppStore>();
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final authorCtrl = TextEditingController(text: existing?.author ?? '');
    final priceCtrl = TextEditingController(text: existing?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: existing?.stock.toString() ?? '');
    String category = existing?.category ?? 'Fiction';
    final categories = ['Fiction', 'Non-Fiction', 'Science', 'History', 'Children'];
    String? error;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          existing == null ? Icons.add_rounded : Icons.edit_rounded,
                          color: const Color(0xFF1A237E),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        existing == null ? 'Add Book' : 'Edit Book',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title_rounded))),
                  const SizedBox(height: 12),
                  TextField(controller: authorCtrl, decoration: const InputDecoration(labelText: 'Author', prefixIcon: Icon(Icons.person_rounded))),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => category = v!),
                    decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Price (UGX)', prefixIcon: Icon(Icons.attach_money_rounded)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stockCtrl,
                    decoration: const InputDecoration(labelText: 'Stock', prefixIcon: Icon(Icons.inventory_2_rounded)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final price = double.tryParse(priceCtrl.text) ?? 0;
                            final stock = int.tryParse(stockCtrl.text) ?? 0;
                            if (titleCtrl.text.trim().isEmpty) {
                              setState(() => error = 'Title is required.');
                              return;
                            }
                            if (price <= 0) {
                              setState(() => error = 'Price must be a positive number.');
                              return;
                            }
                            if (existing == null) {
                              store.addBook(Book(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleCtrl.text.trim(),
                                author: authorCtrl.text.trim(),
                                category: category,
                                price: price,
                                stock: stock,
                              ));
                            } else {
                              store.updateBook(Book(
                                id: existing.id,
                                title: titleCtrl.text.trim(),
                                author: authorCtrl.text.trim(),
                                category: category,
                                price: price,
                                stock: stock,
                              ));
                            }
                            Navigator.pop(ctx);
                          },
                          child: Text(existing == null ? 'Add Book' : 'Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Fiction': return const Color(0xFF1565C0);
      case 'Non-Fiction': return const Color(0xFF2E7D32);
      case 'Science': return const Color(0xFF00838F);
      case 'History': return const Color(0xFF6A1B9A);
      case 'Children': return const Color(0xFFE65100);
      default: return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: store.books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No books yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Tap + to add your first book', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.books.length,
              itemBuilder: (_, i) {
                final b = store.books[i];
                final catColor = _categoryColor(b.category);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.menu_book_rounded, color: catColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(b.author, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _Tag(b.category, catColor),
                                  _Tag('UGX ${b.price.toStringAsFixed(0)}', const Color(0xFF2E7D32)),
                                  _Tag(
                                    '${b.stock} in stock',
                                    b.stock <= 5 ? const Color(0xFFE65100) : Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            _ActionBtn(Icons.edit_rounded, const Color(0xFF1A237E), () => _showDialog(context, b)),
                            const SizedBox(height: 4),
                            _ActionBtn(Icons.delete_rounded, Colors.red.shade400, () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                          child: Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 32),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Remove Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Remove "${b.title}" and its sales history?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.pop(context),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  side: BorderSide(color: Colors.grey.shade300),
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red.shade600,
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                onPressed: () {
                                                  store.removeBook(b.id);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Remove'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
