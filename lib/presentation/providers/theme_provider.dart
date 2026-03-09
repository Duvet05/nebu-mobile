import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../presentation/providers/auth_provider.dart' as auth;

// Theme state
class ThemeState {
  ThemeState({this.themeMode = ThemeMode.system, this.isDarkMode = false});
  final ThemeMode themeMode;
  final bool isDarkMode;

  ThemeState copyWith({ThemeMode? themeMode, bool? isDarkMode}) => ThemeState(
    themeMode: themeMode ?? this.themeMode,
    isDarkMode: isDarkMode ?? this.isDarkMode,
  );
}

// Theme notifier
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  SharedPreferences? _prefs;

  @override
  Future<ThemeState> build() async {
    _prefs = await ref.read(auth.sharedPreferencesProvider.future);
    return _loadTheme();
  }

  // Load theme from storage
  Future<ThemeState> _loadTheme() async {
    final themeModeString = _prefs?.getString(StorageKeys.themeMode);

    ThemeMode themeMode;
    bool isDarkMode;

    if (themeModeString == null) {
      themeMode = ThemeMode.system;
      isDarkMode = false;
    } else {
      switch (themeModeString) {
        case 'dark':
          themeMode = ThemeMode.dark;
          isDarkMode = true;
          break;
        case 'light':
          themeMode = ThemeMode.light;
          isDarkMode = false;
          break;
        default:
          themeMode = ThemeMode.system;
          isDarkMode = false;
      }
    }

    return ThemeState(themeMode: themeMode, isDarkMode: isDarkMode);
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final newIsDarkMode = !currentState.isDarkMode;
    final newThemeMode = newIsDarkMode ? ThemeMode.dark : ThemeMode.light;

    await _saveTheme(newThemeMode);

    state = AsyncValue.data(
      ThemeState(themeMode: newThemeMode, isDarkMode: newIsDarkMode),
    );
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _saveTheme(themeMode);

    state = AsyncValue.data(
      ThemeState(themeMode: themeMode, isDarkMode: themeMode == ThemeMode.dark),
    );
  }

  // Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  // Save theme to storage
  Future<void> _saveTheme(ThemeMode themeMode) async {
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await _prefs?.setString(StorageKeys.themeMode, themeModeString);
  }
}

// Provider
final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
