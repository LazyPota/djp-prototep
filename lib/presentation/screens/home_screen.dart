import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

import '../../core/utils/overlay_handler.dart';
import '../../l10n/l10n_extensions.dart';
import '../providers/app_state_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  final _bridge = const FraudAccessibilityBridge();
  bool _isOverlayActive = false;
  bool _isActionBusy = false;

  Future<bool> _showOverlayWithRetry() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        overlayTitle: 'Awas!',
        overlayContent: 'Tap to check product',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.right,
        height: 64,
        width: 40,
      );

      await Future<void>.delayed(Duration(milliseconds: 180 + (attempt * 120)));
      final active = await FlutterOverlayWindow.isActive();
      if (active) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _showStartGuideDialog({
    required bool needOverlayPermission,
    required bool needAccessibilityPermission,
  }) async {
    if (!needOverlayPermission && !needAccessibilityPermission) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        final steps = <String>[];
        if (needOverlayPermission) {
          steps.add('1. ${l10n.beforeStartNeedOverlay}');
        }
        if (needAccessibilityPermission) {
          final index = steps.length + 1;
          steps.add('$index. ${l10n.beforeStartNeedAccessibility}');
        }
        return AlertDialog(
          title: Text(l10n.beforeStartTitle),
          content: Text(steps.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.continueLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshOverlayState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(protectedCountProvider);
      ref.invalidate(globalProtectedCountProvider);
      _refreshOverlayState();
    }
  }

  Future<void> _refreshOverlayState() async {
    final active = await FlutterOverlayWindow.isActive();
    if (!mounted) return;
    setState(() {
      _isOverlayActive = active;
    });
  }

  Future<void> _toggleProtection() async {
    if (_isActionBusy) return;
    setState(() {
      _isActionBusy = true;
    });

    try {
      if (_isOverlayActive) {
        setState(() {
          _isOverlayActive = false;
        });
        await FlutterOverlayWindow.closeOverlay();
        await Future<void>.delayed(const Duration(milliseconds: 220));
        await _refreshOverlayState();
        return;
      }

      var overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
      var accessibilityEnabled = true;
      if (Platform.isAndroid) {
        accessibilityEnabled = await _bridge.isAccessibilityServiceEnabled();
      }

      final proceed = await _showStartGuideDialog(
        needOverlayPermission: !overlayGranted,
        needAccessibilityPermission: !accessibilityEnabled,
      );
      if (!proceed) {
        await _refreshOverlayState();
        return;
      }

      if (!overlayGranted) {
        await FlutterOverlayWindow.requestPermission();
        overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
      }
      if (!overlayGranted) {
        await _refreshOverlayState();
        return;
      }

      if (Platform.isAndroid) {
        if (!accessibilityEnabled) {
          await _bridge.openAccessibilitySettings();
          accessibilityEnabled = await _bridge.isAccessibilityServiceEnabled();
        }
        if (!accessibilityEnabled) {
          await _refreshOverlayState();
          return;
        }
      }

      final shown = await _showOverlayWithRetry();
      if (!shown) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Floating button failed to appear. Check overlay permission and try again.')),
          );
        }
        await _refreshOverlayState();
        return;
      }

      if (mounted) {
        setState(() {
          _isOverlayActive = true;
        });
      }

      await updateOverlayData({
        'type': 'ready',
      });
      await _refreshOverlayState();
    } finally {
      if (mounted) {
        setState(() {
          _isActionBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final protectedCount = ref.watch(protectedCountProvider);
    final globalProtectedCount = ref.watch(globalProtectedCountProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.protected,
                  value: protectedCount.when(
                    data: (v) => v.toString(),
                    loading: () => '…',
                    error: (error, stackTrace) => '—',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l10n.global,
                  value: globalProtectedCount.when(
                    data: (v) => v?.toString() ?? '—',
                    loading: () => '…',
                    error: (error, stackTrace) => '—',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isActionBusy ? null : _toggleProtection,
            child: Text(_isOverlayActive ? l10n.stop : l10n.start),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.homeHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
