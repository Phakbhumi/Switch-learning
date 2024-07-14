import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.yellow.shade100,
    primary: Colors.black,
    secondary: Colors.yellow.shade300,
    surface: Colors.amber.shade200,
  ),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade800,
    primary: Colors.white,
    secondary: Colors.grey.shade600,
  ),
  useMaterial3: true,
);
