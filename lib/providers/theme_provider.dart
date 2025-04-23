import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  // Getter for themeMode that was missing in your implementation
  ThemeMode get themeMode => _themeMode;

  // Constructor that loads saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode');
    
    if (savedThemeMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedThemeMode == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }

  // Save theme preference and update state
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    
    switch (mode) {
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
    
    await prefs.setString('themeMode', themeModeString);
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  // Check if current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
}