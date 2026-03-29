import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlodoColors {
  FlodoColors._();

  // Premium Dark Mode Palette
  static const Color bg = Color(0xFF09090B); // deep pitch black
  static const Color surface = Color(0xFF141417); // elevated surface
  static const Color sidebarBg = Color(0xFF0E0E11); // distinct sidebar
  static const Color surfaceHighlight = Color(0xFF1F1F24); // hover state

  // Borders
  static const Color border = Color(0xFF27272A);
  static const Color divider = Color(0xFF1E1E22);

  // Typography
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSec = Color(0xFFA1A1AA);
  static const Color textHint = Color(0xFF71717A);

  // Brand
  static const Color accent = Color(0xFF6366F1); // vibrant indigo
  static const Color accentSoft = Color(0xFF312E81);

  // Status
  static const Color todo = Color(0xFFE4E4E7);
  static const Color todoSoft = Color(0xFF27272A);

  static const Color inProgress = Color(0xFF3B82F6);
  static const Color inProgressSoft = Color(0xFF1E3A8A);

  static const Color done = Color(0xFF10B981);
  static const Color doneSoft = Color(0xFF064E3B);

  static const Color blocked = Color(0xFF71717A);
  static const Color blockedBg = Color(0xFF09090B);

  // Danger
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFF7F1D1D);

  // Aliases for pasted code
  static const Color background = bg;
  static const Color sidebar = sidebarBg;
  static const Color sidebarHover = surfaceHighlight;
  static const Color textSecondary = textSec;
  static const Color textMuted = textHint;
}

class FlodoTheme {
  FlodoTheme._();

  static ThemeData get light {
    final base = GoogleFonts.outfitTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlodoColors.accent,
        brightness: Brightness.light,
        surface: const Color(0xFFFFFFFF),
        error: FlodoColors.danger,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      textTheme: base.apply(
        bodyColor: const Color(0xFF111111),
        displayColor: const Color(0xFF111111),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FlodoColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FlodoColors.danger),
        ),
        hintStyle: const TextStyle(color: FlodoColors.textHint, fontSize: 14),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 10,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FlodoColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFAFAFA),
        selectedColor: FlodoColors.accentSoft,
        side: const BorderSide(color: Color(0xFFE5E5E5)),
        labelStyle: const TextStyle(
            fontSize: 13, color: FlodoColors.textSec, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(4),
        radius: Radius.circular(4),
      ),
    );
  }

  static ThemeData get dark {
    final base = GoogleFonts.outfitTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlodoColors.accent,
        brightness: Brightness.dark,
        surface: FlodoColors.surface,
        error: FlodoColors.danger,
      ),
      scaffoldBackgroundColor: FlodoColors.bg,
      textTheme: base.apply(
        bodyColor: FlodoColors.textPrimary,
        displayColor: FlodoColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlodoColors.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FlodoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FlodoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FlodoColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FlodoColors.danger),
        ),
        hintStyle: const TextStyle(color: FlodoColors.textHint, fontSize: 14),
      ),
      cardTheme: const CardThemeData(
        color: FlodoColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: FlodoColors.border, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: FlodoColors.surface,
        elevation: 10,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FlodoColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FlodoColors.bg,
        selectedColor: FlodoColors.accentSoft,
        side: const BorderSide(color: FlodoColors.border),
        labelStyle: const TextStyle(
            fontSize: 13, color: FlodoColors.textSec, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(4),
        radius: Radius.circular(4),
      ),
    );
  }
}
