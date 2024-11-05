import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/themes/dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _themeKey = 'theme';

  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;

  ThemeProvider() {
    _loadTheme();
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveTheme(themeData);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  // Load the theme from Hive storage
  Future<void> _loadTheme() async {
    Box box = await Hive.openBox(_boxName);
    if (box.containsKey(_themeKey)) {
      String storedTheme = box.get(_themeKey);
      _themeData = storedTheme == 'dark' ? darkMode : lightMode;
      notifyListeners();
    }
  }

  // Save the theme to Hive storage
  Future<void> _saveTheme(ThemeData themeData) async {
    Box box = await Hive.openBox(_boxName);
    String theme = themeData == darkMode ? 'dark' : 'light';
    box.put(_themeKey, theme);
  }
}
