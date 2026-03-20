import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

import '../../l10n/l10n_extensions.dart';
import '../providers/app_state_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with WidgetsBindingObserver {
  final _bridge = const FraudAccessibilityBridge();
  bool? _overlayGrantedValue;
  bool? _accessibilityEnabledValue;
  bool _isCompletingOnboarding = false;

  Future<bool> _overlayGranted() => FlutterOverlayWindow.isPermissionGranted();

  Future<bool> _accessibilityEnabled() async {
    if (!Platform.isAndroid) return true;
    return _bridge.isAccessibilityServiceEnabled();
  }

  Future<void> _reloadStatus() async {
    final values = await Future.wait<bool>([
      _overlayGranted(),
      _accessibilityEnabled(),
    ]);

    if (!mounted) return;
    setState(() {
      _overlayGrantedValue = values[0];
      _accessibilityEnabledValue = values[1];
    });

    await _completeOnboardingIfReady();
  }

  Future<void> _completeOnboardingIfReady() async {
    if (_isCompletingOnboarding) return;
    if (_overlayGrantedValue != true || _accessibilityEnabledValue != true) return;

    _isCompletingOnboarding = true;
    await ref.read(protectionPrefsProvider).setOnboarded();
    if (!mounted) return;
    ref.invalidate(hasOnboardedProvider);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reloadStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadStatus();
    }
  }

  Future<void> _requestOverlayPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      await FlutterOverlayWindow.requestPermission();
    }
    await _reloadStatus();
  }

  Future<void> _openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    await _bridge.openAccessibilitySettings();
    await _reloadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.onboardingSetupDescription,
            ),
            const SizedBox(height: 16),
            _SetupTile(
              title: l10n.showOnOtherApps,
              subtitle: l10n.floatingPermission,
              enabled: _overlayGrantedValue,
              buttonLabel: _overlayGrantedValue == true ? l10n.granted : l10n.grant,
              onPressed: _requestOverlayPermission,
            ),
            const SizedBox(height: 12),
            _SetupTile(
              title: l10n.accessibilityApi,
              subtitle: l10n.accessibilityNeeded,
              enabled: _accessibilityEnabledValue,
              buttonLabel: _accessibilityEnabledValue == true ? l10n.granted : l10n.openSettings,
              onPressed: _openAccessibilitySettings,
            ),
            const Spacer(),
            FilledButton(
              onPressed: _overlayGrantedValue == true && _accessibilityEnabledValue == true
                  ? () async {
                      await ref.read(protectionPrefsProvider).setOnboarded();
                      ref.invalidate(hasOnboardedProvider);
                    }
                  : null,
              child: Text(l10n.continueLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool? enabled;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  enabled == null ? l10n.checking : (enabled! ? l10n.enabled : l10n.notEnabled),
                  style: TextStyle(
                    color: enabled == null
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : (enabled! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Opacity(
            opacity: enabled == true ? 0.6 : 1,
            child: OutlinedButton(
              onPressed: enabled == true ? null : onPressed,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
