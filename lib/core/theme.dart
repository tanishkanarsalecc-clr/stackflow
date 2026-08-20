import 'package:flutter/material.dart';

class StackFlowColors {
  static const primary = Color(0xFF08AFA5);
  static const primaryDark = Color(0xFF078D98);

  static const blue = Color(0xFF087FD1);
  static const darkBlue = Color(0xFF173B5E);

  static const background = Color(0xFFF6FBFC);
  static const card = Colors.white;

  static const text = Color(0xFF172B4D);
  static const secondaryText = Color(0xFF718096);

  static const green = Color(0xFF20B486);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFE74C4C);

  static const border = Color(0xFFE1ECEF);
}

class StackFlowTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: StackFlowColors.background,
      fontFamily: 'Roboto',

      colorScheme: ColorScheme.fromSeed(
        seedColor: StackFlowColors.primary,
        primary: StackFlowColors.primary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: StackFlowColors.text,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: StackFlowColors.secondaryText,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: StackFlowColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: StackFlowColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: StackFlowColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}