import 'package:flutter/material.dart';

// Şu an yalnızca Türkçe destekleniyor; çoklu dil için iskelet hazır
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
