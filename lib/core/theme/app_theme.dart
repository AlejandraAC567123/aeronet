import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color cardColor = Color(0xFF161B22);
  static const Color accentColor = Color(0xFF2DD4BF);
  static const Color primaryColor = Color(0xFF2DD4BF);

  static const Color surfaceSecondary = Color(0xFF222840);
  static const Color borderDividerColor = Color(0xFF2B3150);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xA6FFFFFF);
  static const Color textTertiaryColor = Color(0x66FFFFFF);
  static const Color alertColor = Color(0xFFFFB454);
  static const Color errorColor = Color(0xFFFF6B6B);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final titleTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        background: backgroundColor,
        error: errorColor,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: titleTextTheme.displayLarge?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w800),
        displayMedium: titleTextTheme.displayMedium?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w800),
        displaySmall: titleTextTheme.displaySmall?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w800),
        headlineLarge: titleTextTheme.headlineLarge?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w700),
        headlineMedium: titleTextTheme.headlineMedium?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w700),
        headlineSmall: titleTextTheme.headlineSmall?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w700),
        titleLarge: titleTextTheme.titleLarge?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w700),
        titleMedium: titleTextTheme.titleMedium?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w600),
        titleSmall: titleTextTheme.titleSmall?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimaryColor, fontWeight: FontWeight.w500),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondaryColor, fontWeight: FontWeight.w400),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textTertiaryColor, fontWeight: FontWeight.w400),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: textSecondaryColor, fontWeight: FontWeight.w600),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: textSecondaryColor, fontWeight: FontWeight.w500),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: textTertiaryColor, fontWeight: FontWeight.w400),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          side: BorderSide(color: borderDividerColor, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimaryColor),
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: borderDividerColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: borderDividerColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: errorColor, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textTertiaryColor),
        prefixIconColor: textSecondaryColor,
        suffixIconColor: textSecondaryColor,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryColor,
          side: const BorderSide(color: borderDividerColor, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: textTertiaryColor, fontSize: 12, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: textTertiaryColor);
        }),
      ),
    );
  }
}
