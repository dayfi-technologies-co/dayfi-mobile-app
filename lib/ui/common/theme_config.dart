import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeConfig {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xff5645F5), // Lime green
      scaffoldBackgroundColor: Color(0xffF7F7F7), // Light grayish-green
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xff011B33)), // Dark green
        bodyMedium: TextStyle(color: Color(0xff011B33)),
        labelLarge: TextStyle(color: Color(0xff011B33)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff5645F5), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color(0xff011B33).withOpacity(0.25), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color(0xff011B33).withOpacity(0.25), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.red.shade700.withOpacity(0.5), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.red.shade700.withOpacity(0.5), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xff5645F5),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xff7cc458), // Muted lime green
      scaffoldBackgroundColor: const Color(0xff1c2520), // Dark gray
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xffe0e0e0)), // Light gray
        bodyMedium: TextStyle(color: Color(0xffe0e0e0)),
        labelLarge: TextStyle(color: Color(0xffe0e0e0)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff2a332e), // Slightly lighter dark gray
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff7cc458), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color(0xffe0e0e0).withOpacity(0.2), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color(0xffe0e0e0).withOpacity(0.2), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.red.shade700.withOpacity(0.5), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.red.shade700.withOpacity(0.5), width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xff7cc458),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'theme_mode';

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}
