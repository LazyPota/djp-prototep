import 'package:flutter_test/flutter_test.dart';
import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';
import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge_platform_interface.dart';
import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFraudAccessibilityBridgePlatform
    with MockPlatformInterfaceMixin
    implements FraudAccessibilityBridgePlatform {
  @override
  Future<String?> getCurrentForegroundApp() => Future.value('com.example.shop');

  @override
  Future<bool> isAccessibilityServiceEnabled() => Future.value(true);

  @override
  Future<void> openAccessibilitySettings() async {}

  @override
  Future<Map<String, dynamic>> checkAndCopyProductLink({required Duration timeout}) async {
    return <String, dynamic>{'status': 'success', 'copiedText': 'https://example.com'};
  }
}

void main() {
  final FraudAccessibilityBridgePlatform initialPlatform = FraudAccessibilityBridgePlatform.instance;

  test('$MethodChannelFraudAccessibilityBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFraudAccessibilityBridge>());
  });

  test('isAccessibilityServiceEnabled', () async {
    const FraudAccessibilityBridge fraudAccessibilityBridgePlugin = FraudAccessibilityBridge();
    MockFraudAccessibilityBridgePlatform fakePlatform = MockFraudAccessibilityBridgePlatform();
    FraudAccessibilityBridgePlatform.instance = fakePlatform;

    expect(await fraudAccessibilityBridgePlugin.isAccessibilityServiceEnabled(), true);
  });
}
