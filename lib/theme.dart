import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getThemeData(String theme) {
    switch (theme) {
      case 'Dark':
        return ThemeData.dark();
      case 'OLED Dark':
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
        );
      case 'Tinseltown':
        Color lightYellow = Colors.yellow.shade100;
        return ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red,
            accentColor: Colors.yellow,
          ).copyWith(
            secondary: Colors.yellow,
            surface: Colors.red.shade100,
          ),
          scaffoldBackgroundColor: lightYellow,
          drawerTheme: DrawerThemeData(
            backgroundColor: lightYellow,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        );
      case 'Blockbusted':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF0056A0),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: const Color(0xFFFEC524),
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0056A0),
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: Color(0xFF0056A0)),
            headlineMedium: TextStyle(color: Color(0xFF0056A0)),
            headlineSmall: TextStyle(color: Color(0xFF0056A0)),
            titleLarge: TextStyle(color: Colors.black),
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            labelLarge: TextStyle(color: Color(0xFFFEC524)),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFEC524),
          ),
        );
      default:
        return ThemeData.light();
    }
  }
}
