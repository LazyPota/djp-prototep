// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isAccessibilityServiceEnabled returns a bool', (WidgetTester tester) async {
    const FraudAccessibilityBridge plugin = FraudAccessibilityBridge();
    final bool enabled = await plugin.isAccessibilityServiceEnabled();
    expect(enabled, anyOf(isTrue, isFalse));
  });
}
