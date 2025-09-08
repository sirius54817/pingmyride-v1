import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Retro white/black theme colors
  static const Color primaryColor = Color(0xFF000000);  // Pure black
  static const Color secondaryColor = Color(0xFF424242); // Dark grey
  static const Color backgroundColor = Color(0xFFFFFFF8); // Cream white
  static const Color surfaceColor = Color(0xFFFFFFFF);   // Pure white
  static const Color accentColor = Color(0xFF212121);    // Charcoal
  static const Color errorColor = Color(0xFF303030);     // Dark grey for errors
  static const Color successColor = Color(0xFF424242);   // Medium grey
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        surface: surfaceColor,
        background: backgroundColor,
        primary: primaryColor,
        onPrimary: surfaceColor,
        secondary: secondaryColor,
        onSecondary: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withOpacity(0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // More rounded for wider appearance
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 4,
        height: 70, // Reduced height to prevent overflow
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Hide labels
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              size: 26, // Slightly smaller icons to fit better
              color: primaryColor,
            );
          }
          return const IconThemeData(
            size: 22,
            color: secondaryColor,
          );
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // More retro square corners
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Square corners for retro feel
          borderSide: const BorderSide(color: secondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}