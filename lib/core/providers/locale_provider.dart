import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Şu an yalnızca Türkçe destekleniyor; çoklu dil için iskelet hazır
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr'));

  void setLocale(Locale locale) {
    if (state == locale) return;
    state = locale;
  }
}
