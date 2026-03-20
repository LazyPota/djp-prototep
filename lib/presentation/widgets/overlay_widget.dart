import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

import '../../core/services/fraud_api_service.dart';
import '../../core/services/protection_prefs.dart';
import '../../core/utils/supported_apps.dart';
import '../../domain/entities/trust_score.dart';
import '../../l10n/l10n_extensions.dart';
import 'trust_gauge.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  final _bridge = const FraudAccessibilityBridge();
  final _api = const FraudApiService();
  final _prefs = ProtectionPrefs();

  bool _isExpanded = false;
  bool _isBusy = false;
  bool _hasError = false;
  Offset _modalOffset = Offset.zero;

  String _status = '';
  String? _copiedUrl;
  TrustScore? _result;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        setState(() {
          if (event['type'] == 'ready') {
            _status = context.l10n.tapToCheck;
          }
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _status = context.l10n.tapToCheck;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _resizeForExpanded() async {
    await FlutterOverlayWindow.resizeOverlay(
      WindowSize.matchParent,
      WindowSize.matchParent,
      true,
    );
  }

  Future<void> _resizeForCollapsed() async {
    await FlutterOverlayWindow.resizeOverlay(
      40,
      64,
      true,
    );
  }

  Future<void> _runCheck() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _hasError = false;
      _result = null;
      _copiedUrl = null;
      _status = context.l10n.checkingCurrentScreen;
    });

    try {
      final pkg = await _bridge.getCurrentForegroundApp();
      final isSupported = pkg != null && supportedShoppingApps.contains(pkg);
      if (!isSupported) {
        setState(() {
          _status = context.l10n.scanSupportedOnly;
        });
        return;
      }

      final copyResult = await _bridge.checkAndCopyProductLink();
      final status = (copyResult['status'] ?? '').toString();

      if (status == 'not_product') {
        setState(() {
          _status = (copyResult['message'] ?? 'Not on a product page.').toString();
        });
        return;
      }

      if (status != 'success') {
        setState(() {
          _status = (copyResult['message'] ?? 'Could not copy a product link.').toString();
        });
        return;
      }

      final copied = (copyResult['copiedText'] ?? '').toString();
      if (copied.isEmpty) {
        setState(() {
          _status = 'Clipboard copy succeeded, but no link was found.';
        });
        return;
      }

      setState(() {
        _copiedUrl = copied;
        _status = context.l10n.sendingLink;
      });

      final result = await _api.analyzeUrl(copied);
      await _prefs.incrementProtectedCount();

      setState(() {
        _result = result;
        _status = context.l10n.done;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _status = context.l10n.checkFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isExpanded
          ? Stack(
              children: [
                const Positioned.fill(child: SizedBox.shrink()),
                Center(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _modalOffset += details.delta;
                      });
                    },
                    child: Transform.translate(
                      offset: _modalOffset,
                      child: _buildExpandedView(),
                    ),
                  ),
                ),
              ],
            )
          : Align(
              alignment: Alignment.centerRight,
              child: _buildCollapsedView(),
            ),
    );
  }

  Widget _buildCollapsedView() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
          _modalOffset = Offset.zero;
        });
        _resizeForExpanded();
        _runCheck();
      },
      child: SizedBox(
        width: 40,
        height: 64,
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 0.62,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.cyan.shade600,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Awas!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Check again',
                    onPressed: _isBusy ? null : _runCheck,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_fullscreen),
                    tooltip: 'Collapse',
                    onPressed: () {
                      setState(() {
                        _isExpanded = false;
                      });
                      _resizeForCollapsed();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close Overlay',
                    onPressed: () async {
                      await FlutterOverlayWindow.closeOverlay();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _status,
              style: TextStyle(
                color: _hasError ? Colors.red : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_copiedUrl != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _copiedUrl!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isBusy) const LinearProgressIndicator(minHeight: 3),
          if (_result != null) ...[
            const SizedBox(height: 16),
            TrustGauge(score: _result!.friScore, riskLevel: _result!.riskLevel),
          ],
          if (!_isBusy && _result == null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.openProductThenRefresh,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
