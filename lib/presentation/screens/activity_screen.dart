import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

import '../../l10n/l10n_extensions.dart';
import '../providers/app_state_providers.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _bridge = const FraudAccessibilityBridge();
  final List<String> _logs = <String>[];
  String? _lastPackage;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _startLogging();
  }

  @override
  void dispose() {
    _isRunning = false;
    super.dispose();
  }

  void _appendLog(String entry) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, entry);
      if (_logs.length > 120) {
        _logs.removeRange(120, _logs.length);
      }
    });
  }

  String _timestamp() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  Future<void> _startLogging() async {
    if (_isRunning) return;
    _isRunning = true;
    final supportedApps = ref.read(supportedShoppingAppsProvider);
    _appendLog('[${_timestamp()}] Started support checks');

    while (_isRunning && mounted) {
      try {
        final pkg = await _bridge.getCurrentForegroundApp();
        if (pkg != null && pkg != _lastPackage) {
          _lastPackage = pkg;
          final supported = supportedApps.contains(pkg);
          if (supported) {
            _appendLog('[${_timestamp()}] Supported app detected: $pkg');
          } else {
            _appendLog('[${_timestamp()}] Unsupported app: $pkg');
          }
        }
      } catch (e) {
        _appendLog('[${_timestamp()}] Detection error: $e');
      }

      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
  }

  String _friendlyName(String packageName) {
    if (packageName.contains('tokopedia')) return 'Tokopedia';
    if (packageName.contains('shopee')) return 'Shopee';
    if (packageName.contains('lazada')) return 'Lazada';
    if (packageName.contains('tiktok')) return 'TikTok Shop';
    return packageName;
  }

  Widget _buildLogs(BuildContext context) {
    if (_logs.isEmpty) {
      return Text(context.l10n.noChecks);
    }

    final items = _logs.take(24).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(line, style: Theme.of(context).textTheme.bodySmall),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final supportedApps = ref.watch(supportedShoppingAppsProvider);
    final supportedText = supportedApps.join(', ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.activityTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l10n.supportedPackages(supportedText),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: _buildLogs(context),
        ),
        if (_lastPackage != null)
          const SizedBox(height: 10),
        if (_lastPackage != null)
          Text(
            l10n.lastObserved(_friendlyName(_lastPackage!)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
