import 'package:flutter/material.dart';
import 'package:switch_learning/src/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  bool _showMisc = false;

  ThemeData get themeData => _themeData;
  bool get showMisc => _showMisc;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  set showMisc(bool showMisc) {
    _showMisc = showMisc;
    notifyListeners();
  }

  void toggleMisc() {
    _showMisc = !_showMisc;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }
}
