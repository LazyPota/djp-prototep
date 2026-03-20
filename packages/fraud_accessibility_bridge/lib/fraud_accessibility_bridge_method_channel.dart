import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fraud_accessibility_bridge_platform_interface.dart';

/// An implementation of [FraudAccessibilityBridgePlatform] that uses method channels.
class MethodChannelFraudAccessibilityBridge extends FraudAccessibilityBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fraud_accessibility_bridge');

  @override
  Future<String?> getCurrentForegroundApp() async {
    return methodChannel.invokeMethod<String>('getCurrentForegroundApp');
  }

  @override
  Future<bool> isAccessibilityServiceEnabled() async {
    final enabled = await methodChannel.invokeMethod<bool>('isAccessibilityServiceEnabled');
    return enabled ?? false;
  }

  @override
  Future<void> openAccessibilitySettings() async {
    await methodChannel.invokeMethod<void>('openAccessibilitySettings');
  }

  @override
  Future<Map<String, dynamic>> checkAndCopyProductLink({required Duration timeout}) async {
    final result = await methodChannel.invokeMethod<Map>('checkAndCopyProductLink', {
      'timeoutMs': timeout.inMilliseconds,
    });
    return (result ?? <dynamic, dynamic>{}).cast<String, dynamic>();
  }
}
