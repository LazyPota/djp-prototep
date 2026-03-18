import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';
import '../../presentation/widgets/trust_gauge.dart';

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayApp());
}

class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  int _score = 0;
  String _riskLevel = 'Analyzing...';
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    SystemAlertWindow.overlayListener.listen((event) {
      if (event is String && event == 'close') {
         setState(() {
           _isVisible = false;
         });
         SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
      }
    });

    ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'overlay_send_port');

    receivePort.listen((message) {
      if (message is Map) {
        setState(() {
          _score = message['score'] ?? 0;
          _riskLevel = message['riskLevel'] ?? 'Unknown';
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fraud Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                         setState(() {
                           _isVisible = false;
                         });
                         SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
                      },
                    )
                  ],
                ),
                TrustGauge(score: _score, riskLevel: _riskLevel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void updateOverlayData(Map data) {
  // We send data to the background isolate's receive port
  final sendPort = IsolateNameServer.lookupPortByName('overlay_send_port');
  if (sendPort != null) {
      sendPort.send(data);
  } else {
      // If the port doesn't exist, it means the overlay is not running yet.
      // We start it.
      SystemAlertWindow.showSystemWindow(
        height: 350,
        width: 350,
        gravity: SystemWindowGravity.CENTER,
        prefMode: SystemWindowPrefMode.OVERLAY,
      );

      // We must wait a brief moment for the isolate to spin up and register its port
      Future.delayed(const Duration(milliseconds: 500), () {
         final retryPort = IsolateNameServer.lookupPortByName('overlay_send_port');
         retryPort?.send(data);
      });
  }
}