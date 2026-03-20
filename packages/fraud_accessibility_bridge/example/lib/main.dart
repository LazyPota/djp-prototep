import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Unknown';
  final _fraudAccessibilityBridgePlugin = const FraudAccessibilityBridge();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String status;
    try {
      final enabled = await _fraudAccessibilityBridgePlugin.isAccessibilityServiceEnabled();
      status = enabled ? 'Accessibility enabled' : 'Accessibility not enabled';
    } on PlatformException {
      status = 'Plugin not available on this platform.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Text(_status)),
      ),
    );
  }
}
