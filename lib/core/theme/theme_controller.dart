import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ThemeController(prefs);
    });

class ThemeController extends StateNotifier<ThemeMode> {
  static const _themeKey = 'preferred_theme_mode';
  final SharedPreferences _prefs;

  ThemeController(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setInt(_themeKey, mode.index);
  }
}
