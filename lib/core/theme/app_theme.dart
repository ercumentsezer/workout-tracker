import 'package:flutter/material.dart';

class AppTheme {
  static const Color oledBlack = Colors.black;
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color neonAccent = Color(0xFFCCFF00);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: oledBlack,
      primaryColor: neonAccent,
      cardColor: darkCard,
      useMaterial3: true,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: oledBlack,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Input (TextField) Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: oledBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}