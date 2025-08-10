import 'package:flutter_test/flutter_test.dart';
import 'package:test1/main.dart'; // Ensure this path is correct

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // This is a very basic test. We are just making sure the app doesn't crash on start.
    // Since the app requires Firebase, providers, etc., a real test would be more complex.
    // For now, we'll just build the root widget.

    // ✅ FIX: Changed MyApp() to MicroBookApp()
    await tester.pumpWidget(const MicroBookApp());

    // You can add more specific tests here if you want.
    // For example, expect(find.text('Micro-Book App'), findsOneWidget);
  });
}