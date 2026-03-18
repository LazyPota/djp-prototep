import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/trust_score_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

class SharedIntentService {
  final Ref ref;
  // Menambahkan tipe data yang spesifik pada StreamSubscription
  late StreamSubscription<List<SharedMediaFile>> _intentDataStreamSubscription;
  final MethodChannel _iosShareChannel = const MethodChannel('com.yourcompany.ecommerce_fraud_detector/share');

  SharedIntentService(this.ref) {
    _initIntentListening();
    _checkIOSManualShareExtension();
  }

  void _initIntentListening() {
    // 1. Saat aplikasi sudah berada di background/memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _processSharedFiles(value);
        // Wajib reset agar file tidak terproses berkali-kali
        ReceiveSharingIntent.instance.reset();
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // 2. Saat aplikasi baru dibuka (Terminated state)
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _processSharedFiles(value);
        // Wajib reset agar file tidak terproses berkali-kali
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  void _processSharedFiles(List<SharedMediaFile> files) {
    for (var file in files) {
      if (file.path.isNotEmpty) {
        _triggerAnalysis(file.path);
        break; 
      }
    }
  }

  // Fallback for custom iOS App Group implementation if receive_sharing_intent doesn't capture the raw text URL properly
  Future<void> _checkIOSManualShareExtension() async {
    try {
      final String? sharedUrl = await _iosShareChannel.invokeMethod('getSharedData');
      if (sharedUrl != null && sharedUrl.isNotEmpty) {
        _triggerAnalysis(sharedUrl);
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get shared data: '${e.message}'.");
    }
  }

  void _triggerAnalysis(String url) {
    ref.read(trustScoreNotifierProvider.notifier).analyzeUrl(url);
  }

  void dispose() {
    _intentDataStreamSubscription.cancel();
  }
}

// Provider to hold the service instance
final sharedIntentServiceProvider = Provider<SharedIntentService>((ref) {
  final service = SharedIntentService(ref);
  
  // Mengaitkan method dispose milik class ke siklus hidup (lifecycle) Riverpod
  // Ini mencegah terjadinya memory leak!
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});