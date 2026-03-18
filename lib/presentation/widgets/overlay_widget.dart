import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'trust_gauge.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _isExpanded = false;
  int _score = 0;
  String _riskLevel = 'Analyzing...';
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        setState(() {
          _score = event['score'] ?? 0;
          _riskLevel = event['riskLevel'] ?? 'Unknown';
          // When data comes in, expand the bubble
          _isExpanded = true;
        });
        _resizeForExpanded();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

void _resizeForExpanded() async {
    // Resize window to act like a bottom sheet or centered partial view
    await FlutterOverlayWindow.resizeOverlay(
      WindowSize.matchParent,
      WindowSize.matchParent,
      true, // ADD THIS: enable animation for resizing
    );
  }

  void _resizeForCollapsed() async {
    await FlutterOverlayWindow.resizeOverlay(
      150,
      150,
      true, // ADD THIS: enable animation for resizing
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
      ),
    );
  }

  Widget _buildCollapsedView() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
        _resizeForExpanded();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
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
          Icons.security,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              const Text(
                'Fraud Risk Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
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
          const SizedBox(height: 16),
          TrustGauge(score: _score, riskLevel: _riskLevel),
        ],
      ),
    );
  }
}
