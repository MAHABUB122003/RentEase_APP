import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const _key = 'rentease_is_dark';
  bool _isDark = false;

  ThemeProvider() {
    _load();
  }

  bool get isDark => _isDark;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }
}
