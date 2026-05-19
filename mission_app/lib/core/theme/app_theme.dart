import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFDFBF7);       // Warm cream
  static const Color backgroundAlt = Color(0xFFF5F3EE);    // Slightly darker cream
  static const Color surfaceLight = Color(0xFFFFFFFF);      // Pure white cards
  static const Color surfaceDark = Color(0xFF1E1E1E);       // Near-black for dark cards
  static const Color surfaceMid = Color(0xFF2C2C2C);        // Slightly lighter dark

  static const Color accentYellow = Color(0xFFFFD166);      // Primary golden yellow
  static const Color accentYellowLight = Color(0xFFFFF3C4); // Yellow tint for backgrounds
  static const Color accentYellowDark = Color(0xFFE5B84A);  // Pressed state

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimaryClaro = Color(0xFF1A1A1A);
  static const Color textSecondaryClaro = Color(0xFF6B7280);
  static const Color textTertiaryClaro = Color(0xFF9CA3AF);
  static const Color textPrimaryEscuro = Color(0xFFFFFFFF);
  static const Color textSecondaryEscuro = Color(0xFFA3A3A3);

  // ── Status Colors ───────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  // ── HUD Theme (Landing / Home page) ────────────────────────────────────────
  static const Color hudBackground = Color(0xFF030A0A);
  static const Color hudAccent = Color(0xFF00FF85);
  static const Color hudSurface = Color(0xFF0A1414);

  // ── Border Radius ───────────────────────────────────────────────────────────
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Legacy aliases
  static const double borderRadius = 24.0;
  static const double borderRadiusSharp = 2.0;

  // ── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> get cardShadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceDark, surfaceMid],
  );
  static const LinearGradient warmHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8E1), Color(0xFFFDFBF7)],
  );

  // ── Legacy Aliases ───────────────────────────────────────────────────────────
  static Color get primaryGreen => accentYellow;
  static Color get accentGreen => accentYellow;
  static Color get darkGreen => surfaceDark;
  static Color get textDark => textPrimaryClaro;
  static Color get textLight => surfaceLight;
  static Color get bgLight => background;
  static LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.7)],
  );

  // ── Typography ───────────────────────────────────────────────────────────────
  static TextTheme get hudTextTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: GoogleFonts.inter(color: Colors.white),
      bodyMedium: GoogleFonts.inter(color: textSecondaryEscuro),
    );
  }

  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: textPrimaryClaro, letterSpacing: -1.5),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w800, color: textPrimaryClaro, letterSpacing: -1),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textPrimaryClaro, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textPrimaryClaro),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimaryClaro),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimaryClaro),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimaryClaro),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimaryClaro),
      bodyLarge: GoogleFonts.inter(color: textPrimaryClaro, height: 1.5),
      bodyMedium: GoogleFonts.inter(color: textPrimaryClaro, height: 1.5),
      bodySmall: GoogleFonts.inter(color: textSecondaryClaro, fontSize: 12),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: 0.8, color: textSecondaryClaro),
    );
  }

  // ── Input Decoration ─────────────────────────────────────────────────────────
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: const BorderSide(color: accentYellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: const BorderSide(color: errorRed),
      ),
      hintStyle: GoogleFonts.inter(color: textTertiaryClaro, fontSize: 15),
      labelStyle: GoogleFonts.inter(color: textSecondaryClaro, fontWeight: FontWeight.w500),
    );
  }

  // ── Main Theme Data ───────────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentYellow,
        primary: accentYellow,
        onPrimary: textPrimaryClaro,
        secondary: surfaceDark,
        onSecondary: textPrimaryEscuro,
        surface: surfaceLight,
        onSurface: textPrimaryClaro,
      ).copyWith(
        error: errorRed,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      inputDecorationTheme: inputDecorationTheme,
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: textPrimaryClaro,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(0, 54),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryClaro,
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(0, 54),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimaryClaro,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimaryClaro),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryClaro,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: textPrimaryClaro,
        unselectedItemColor: textTertiaryClaro,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF3F4F6),
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? accentYellow : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? accentYellow.withOpacity(0.4) : const Color(0xFFE5E7EB)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentYellow,
        linearTrackColor: accentYellowLight,
      ),
    );
  }

  // ── HUD Theme (Landing / Home page dark overlay) ──────────────────────────
  static ThemeData get hudTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: hudBackground,
      colorScheme: const ColorScheme.dark(
        primary: hudAccent,
        onPrimary: hudBackground,
        surface: hudSurface,
        onSurface: Colors.white,
      ),
      textTheme: hudTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: hudSurface.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: const BorderSide(color: hudAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondaryEscuro),
        hintStyle: TextStyle(color: textSecondaryEscuro.withOpacity(0.7), fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hudAccent,
          foregroundColor: hudBackground,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(0, 54),
        ),
      ),
    );
  }
}
