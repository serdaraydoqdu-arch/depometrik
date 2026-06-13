import 'package:flutter/material.dart';

class AppTheme {
  // Premium Açık Renk Tasarım Sistemi Renkleri
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50 (Ferah, açık arka plan)
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White (Kartlar ve yüzeyler)
  static const Color primaryTeal = Color(0xFF0891B2); // Cyan 600 (Açık temada yüksek kontrastlı marka rengi)
  static const Color accentOrange = Color(0xFFEA580C); // Orange 600 (Vurgu rengi)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (Ana metinler)
  static const Color textSecondary = Color(0xFF475569); // Slate 600 (Yardımcı metinler)
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200 (Yumuşak sınırlar)
  static const Color errorRed = Color(0xFFDC2626); // Red 600 (Hata durumları)

  // Geriye Dönük Uyumluluk Haritalaması (Ekranların derleme hatası almaması için)
  static const Color darkBg = lightBg;
  static const Color darkSurface = lightSurface;
  static const Color primaryCyan = primaryTeal;

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Plus Jakarta Sans',
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primaryTeal,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentOrange,
        surface: lightSurface,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0.5,
        centerTitle: true,
        shadowColor: borderLight,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: primaryTeal),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: textPrimary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: lightSurface,
          elevation: 2,
          shadowColor: primaryTeal.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryTeal;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryTeal.withValues(alpha: 0.5);
          return null;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: lightSurface,
        elevation: 4,
      ),
    );
  }
}
