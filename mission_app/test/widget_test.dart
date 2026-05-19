import 'package:go4me/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Go4MeApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Go4MeApp());

    // Verify that our app starts
    expect(find.byType(Go4MeApp), findsOneWidget);
  });
}
