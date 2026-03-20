// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'fraud_accessibility_bridge_platform_interface.dart';

class FraudAccessibilityBridge {
  const FraudAccessibilityBridge();

  Future<String?> getCurrentForegroundApp() {
    return FraudAccessibilityBridgePlatform.instance.getCurrentForegroundApp();
  }

  Future<bool> isAccessibilityServiceEnabled() {
    return FraudAccessibilityBridgePlatform.instance.isAccessibilityServiceEnabled();
  }

  Future<void> openAccessibilitySettings() {
    return FraudAccessibilityBridgePlatform.instance.openAccessibilitySettings();
  }

  /// Attempts to automate: find Share button -> click -> find Copy Link -> click.
  ///
  /// Returns a map like:
  /// - `{status: success, copiedText: "https://..."}`
  /// - `{status: not_product, message: "..."}`
  /// - `{status: error, message: "..."}`
  Future<Map<String, dynamic>> checkAndCopyProductLink({Duration timeout = const Duration(seconds: 20)}) {
    return FraudAccessibilityBridgePlatform.instance.checkAndCopyProductLink(timeout: timeout);
  }
}
