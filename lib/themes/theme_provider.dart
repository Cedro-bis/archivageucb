import 'package:archivageucb/themes/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = modeClair;
  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void changerLeTheme() {
    if (_themeData == modeClair) {
      themeData = modeSombre;
    } else {
      themeData = modeClair;
    }
  }
}
