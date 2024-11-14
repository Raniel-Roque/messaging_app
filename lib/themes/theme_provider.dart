import 'package:flutter/material.dart';
import 'package:Whispr/themes/dark_mode.dart';
import 'package:Whispr/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Set the default theme to darkMode instead of lightMode
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
