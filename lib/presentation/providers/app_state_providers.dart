import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fraud_accessibility_bridge/fraud_accessibility_bridge.dart';

import '../../core/services/fraud_api_service.dart';
import '../../core/services/protection_prefs.dart';
import '../../core/utils/supported_apps.dart';

final protectionPrefsProvider = Provider<ProtectionPrefs>((ref) {
  return ProtectionPrefs();
});

final fraudApiServiceProvider = Provider<FraudApiService>((ref) {
  return const FraudApiService();
});

final accessibilityBridgeProvider = Provider<FraudAccessibilityBridge>((ref) {
  return const FraudAccessibilityBridge();
});

final supportedShoppingAppsProvider = Provider<List<String>>((ref) {
  return supportedShoppingApps;
});

class AppLocaleNotifier extends Notifier<Locale?> {
  static const _key = 'appLocale';

  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw == 'auto') {
      state = null;
      return;
    }
    state = Locale(raw);
  }

  Future<void> setLocaleCode(String code) async {
    if (code == 'auto') {
      state = null;
    } else {
      state = Locale(code);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale?>(AppLocaleNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  static const _key = 'themeMode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    switch (raw) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_key, value);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final hasOnboardedProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.read(protectionPrefsProvider);
  return prefs.hasOnboarded();
});

final protectedCountProvider = FutureProvider<int>((ref) async {
  final prefs = ref.read(protectionPrefsProvider);
  return prefs.getProtectedCount();
});

final globalProtectedCountProvider = FutureProvider<int?>((ref) async {
  final api = ref.read(fraudApiServiceProvider);
  return api.fetchGlobalProtectedCount();
});

final currentForegroundAppProvider = StreamProvider<String?>((ref) async* {
  if (!Platform.isAndroid) {
    yield null;
    return;
  }

  final bridge = ref.read(accessibilityBridgeProvider);
  while (true) {
    String? value;
    try {
      value = await bridge.getCurrentForegroundApp();
    } catch (_) {
      value = null;
    }
    yield value;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }
});
