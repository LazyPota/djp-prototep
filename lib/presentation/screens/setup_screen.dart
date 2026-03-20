import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

import '../../l10n/l10n_extensions.dart';
import '../providers/app_state_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.isVisible});

  final bool isVisible;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _bridge = const FraudAccessibilityBridge();
  bool? _overlayGrantedValue;
  bool? _accessibilityEnabledValue;
  bool _isRefreshing = false;

  Future<bool> _overlayGranted() => FlutterOverlayWindow.isPermissionGranted();

  Future<bool> _accessibilityEnabled() async {
    if (!Platform.isAndroid) return true;
    return _bridge.isAccessibilityServiceEnabled();
  }

  Future<void> _reloadStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    final values = await Future.wait<bool>([
      _overlayGranted(),
      _accessibilityEnabled(),
    ]);

    if (!mounted) return;
    setState(() {
      _overlayGrantedValue = values[0];
      _accessibilityEnabledValue = values[1];
      _isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _reloadStatus();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
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
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final localeCode = locale?.languageCode ?? 'auto';

    return RefreshIndicator(
      onRefresh: _reloadStatus,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.appearance, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.auto)),
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.light)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.dark)),
            ],
            selected: <ThemeMode>{themeMode},
            onSelectionChanged: (selection) {
              final mode = selection.first;
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
          ),
          const SizedBox(height: 18),
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'auto', label: Text(l10n.auto)),
              ButtonSegment(value: 'en', label: Text(l10n.english)),
              ButtonSegment(value: 'id', label: Text(l10n.indonesian)),
            ],
            selected: <String>{localeCode},
            onSelectionChanged: (selection) {
              ref.read(appLocaleProvider.notifier).setLocaleCode(selection.first);
            },
          ),
          const SizedBox(height: 18),
          Text(l10n.permissions, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
          if (_isRefreshing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
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
