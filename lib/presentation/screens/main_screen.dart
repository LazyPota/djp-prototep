import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trust_score_provider.dart';
import '../widgets/trust_gauge.dart';
import '../widgets/risk_flags_list.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../core/services/shared_intent_service.dart';
import '../../core/utils/overlay_handler.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    // Initialize intent listening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sharedIntentServiceProvider);
    });
  }

  Future<void> _requestPermissions() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      await FlutterOverlayWindow.requestPermission();
    }
  }

  void _showOverlayIfRequested(int score, String riskLevel) {
    // Only show if we actually have data and want to run in background mode
    // Normally you'd check app lifecycle state, but for this boilerplate we'll trigger it explicitly
    // or when the app goes to background.

    // Using the same isolate communication pattern defined in overlay_handler
    // But for simplicity in this boilerplate, we can also directly call the UI builder if in foreground
    // Since system_alert_window manages its own UI independently of Flutter's widget tree

    // We update the data via the same method our isolate uses
    updateOverlayData({'score': score, 'riskLevel': riskLevel});
  }

  @override
  Widget build(BuildContext context) {
    final trustScoreNotifierState = ref.watch(trustScoreNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Fraud Detector'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Product URL',
                  hintText: 'Paste e-commerce link here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final url = _urlController.text.trim();
                  if (url.isNotEmpty) {
                    ref.read(trustScoreNotifierProvider.notifier).analyzeUrl(url);
                  }
                },
                child: const Text('Analyze URL'),
              ),
              const SizedBox(height: 32),
              trustScoreNotifierState.when(
                data: (score) {
                  if (score == null) {
                    return const Center(child: Text('Enter a URL to analyze.'));
                  }

                  // In a real app, this would be triggered when app goes to background
                  // Here we provide a manual trigger for demonstration of the boilerplate
                  return Column(
                    children: [
                      TrustGauge(score: score.friScore, riskLevel: score.riskLevel),
                      const SizedBox(height: 24),
                      RiskFlagsList(flags: score.flags),
                      const SizedBox(height: 16),
                      Text("Negative Review Ratio: ${(score.metrics.negativeReviewRatio * 100).toStringAsFixed(1)}%"),
                      Text("Price Anomaly: ${score.metrics.priceAnomaly ? 'Yes' : 'No'}"),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                           _showOverlayIfRequested(score.friScore, score.riskLevel);
                        },
                        child: const Text('Simulate Android Overlay (Background)'),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
