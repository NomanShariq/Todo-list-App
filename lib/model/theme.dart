import 'package:flutter/material.dart';

class myThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
    colorScheme: const ColorScheme.dark(),
  );
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(),
  );
}
