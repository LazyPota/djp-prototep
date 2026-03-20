import 'package:shared_preferences/shared_preferences.dart';

class ProtectionPrefs {
  static const _hasOnboardedKey = 'hasOnboarded';
  static const _protectedCountKey = 'protectedCount';

  Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasOnboardedKey) ?? false;
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasOnboardedKey, true);
  }

  Future<int> getProtectedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_protectedCountKey) ?? 0;
  }

  Future<int> incrementProtectedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_protectedCountKey) ?? 0) + 1;
    await prefs.setInt(_protectedCountKey, next);
    return next;
  }
}
