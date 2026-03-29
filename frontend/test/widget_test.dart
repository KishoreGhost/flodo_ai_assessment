import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flodo/main.dart';

void main() {
  testWidgets('App smoke test - FlodoApp renders', (WidgetTester tester) async {
    // Note: This test will fail if backend is not running (expected in CI)
    // Run integration tests with a running backend for full coverage
    await tester.pumpWidget(const ProviderScope(child: FlodoApp()));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
