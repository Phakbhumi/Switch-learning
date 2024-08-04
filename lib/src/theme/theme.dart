import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: Colors.yellow.shade300,
    surface: Colors.yellow.shade100,
    surfaceTint: Colors.amber.shade200,
  ),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.grey.shade600,
    surface: Colors.grey.shade800,
    surfaceTint: Colors.grey.shade900,
  ),
  useMaterial3: true,
);
