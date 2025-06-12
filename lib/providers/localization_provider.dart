import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationNotifier extends Notifier<Locale> {
  static const String _localeKey = "LOCALE_KEY";

  @override
  Locale build() {
    _loadLocaleFromStorage();
    return const Locale('en');
  }

  Future<void> _loadLocaleFromStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? storedLanguageCode = prefs.getString(_localeKey);

      if (storedLanguageCode != null) {
        final savedLocale = Locale(storedLanguageCode);
        state = savedLocale;
      }
    } catch (error) {
      print('Failed to load locale: $error');
    }
  }

  Future<void> changeLocale(String languageCode) async {
    final newLocale = Locale(languageCode);

    state = newLocale;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (error) {
      print('Failed to save locale: $error');
    }
  }
}

final LocalizationProvider =
    NotifierProvider<LocalizationNotifier, Locale>(
      () => LocalizationNotifier(),
    );
