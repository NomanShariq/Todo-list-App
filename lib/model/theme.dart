import 'package:flutter/material.dart';

enum AppTheme {
  Light,
  Dark,
}

final lightTheme = ThemeData(
  // Define your light theme data here
  brightness: Brightness.light,
  // Other style properties
);

final darkTheme = ThemeData(
  // Define your dark theme data here
  brightness: Brightness.dark,
  // Other style properties
);
