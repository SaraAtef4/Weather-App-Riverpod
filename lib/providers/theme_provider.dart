import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = "THEME_KEY";

  @override
  ThemeMode build() {
    _loadThemeFromStorage();
    return ThemeMode.system; /// to detect current device mode
  }

  Future<void> _loadThemeFromStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? isDark = prefs.getBool(_themeKey);

      if (isDark != null) {
        final savedTheme = isDark ? ThemeMode.dark : ThemeMode.light;
        state = savedTheme;
      }
    } catch (error) {
      print('Failed to load theme: $error');
    }
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state == ThemeMode.dark);
    } catch (error) {
      print('Failed to save theme: $error');
    }
  }
}

final ThemeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
      () => ThemeNotifier(),
);