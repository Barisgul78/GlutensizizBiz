import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  SharedPreferences? _prefs;

  bool get isDark => state == ThemeMode.dark;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getString(_kThemeKey);
    if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggle() =>
      setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!
        .setString(_kThemeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
