import 'package:flutter/material.dart';

class ThemeModel with ChangeNotifier {
  // The current theme mode (light or dark)
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Method to toggle the theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();  // Notify listeners (widgets that are using this provider)
  }
}