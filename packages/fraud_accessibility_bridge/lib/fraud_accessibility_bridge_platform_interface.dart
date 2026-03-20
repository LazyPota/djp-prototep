import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fraud_accessibility_bridge_method_channel.dart';

abstract class FraudAccessibilityBridgePlatform extends PlatformInterface {
  /// Constructs a FraudAccessibilityBridgePlatform.
  FraudAccessibilityBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static FraudAccessibilityBridgePlatform _instance = MethodChannelFraudAccessibilityBridge();

  /// The default instance of [FraudAccessibilityBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelFraudAccessibilityBridge].
  static FraudAccessibilityBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FraudAccessibilityBridgePlatform] when
  /// they register themselves.
  static set instance(FraudAccessibilityBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getCurrentForegroundApp() {
    throw UnimplementedError('getCurrentForegroundApp() has not been implemented.');
  }

  Future<bool> isAccessibilityServiceEnabled() {
    throw UnimplementedError('isAccessibilityServiceEnabled() has not been implemented.');
  }

  Future<void> openAccessibilitySettings() {
    throw UnimplementedError('openAccessibilitySettings() has not been implemented.');
  }

  Future<Map<String, dynamic>> checkAndCopyProductLink({required Duration timeout}) {
    throw UnimplementedError('checkAndCopyProductLink() has not been implemented.');
  }
}
