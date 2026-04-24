import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:duka_book/main.dart';
import 'package:duka_book/store.dart';

void main() {
  testWidgets('App loads and shows Dashboard tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStore(),
        child: const DukaBookApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
  });
}
