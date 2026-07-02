import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

// Riverpod eklendiğinde StateNotifier'a dönüştürülecek
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  SharedPreferences? _prefs;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getString(_kThemeKey);
    if (saved == 'dark') {
      _mode = ThemeMode.dark;
      notifyListeners();
    }
  }

  Future<void> toggle() =>
      setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_kThemeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
