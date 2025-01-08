import 'package:flutter/material.dart';


ThemeData mytheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Colors.white70,
    secondary:  Colors.cyan,
    tertiary: Colors.green,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  )
);