import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFraudAccessibilityBridge platform = MethodChannelFraudAccessibilityBridge();
  const MethodChannel channel = MethodChannel('fraud_accessibility_bridge');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'isAccessibilityServiceEnabled':
              return true;
            case 'openAccessibilitySettings':
              return null;
            case 'checkAndCopyProductLink':
              return <String, dynamic>{'status': 'success', 'copiedText': 'https://example.com'};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isAccessibilityServiceEnabled', () async {
    expect(await platform.isAccessibilityServiceEnabled(), true);
  });
}
