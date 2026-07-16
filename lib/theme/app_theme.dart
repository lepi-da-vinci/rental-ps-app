import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundDark = Color(0xFF0F0F16);
  static const Color surfaceDark = Color(0xFF171721);
  static const Color cardDark = Color(0xFF1E1E2C);
  static const Color accentCyan = Color(0xFF00D0FF); // Softer Cyan
  static const Color accentMagenta = Color(0xFFE024C5); // Softer Magenta
  static const Color accentTeal = Color(0xFF5BA4A4); // Muted for subtle
  static const Color accentGreen = Color(0xFF00E676); // Softer Neon Green
  static const Color accentRed = Color(0xFFEF4444); // Softer Neon Red
  static const Color textPrimary = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFFA5A5B5);
  static const Color textMuted = Color(0xFF6B6B7B);
  static const Color dividerColor = Color(0xFF2A2A3D);

  static const Color glassSurface = Color(0x1AFFFFFF); // 10% white for frosted glass
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white for subtle edge
  static const Color glassHighlight = Color(0x4DFFFFFF); // 30% white for specular highlight

  // ── Booking Colors Palette ──
  static const List<Color> bookingColors = [
    accentCyan,
    accentGreen,
    accentMagenta,
    Colors.orangeAccent,
    Colors.amber,
    Colors.purpleAccent,
    accentTeal,
    Colors.deepOrangeAccent,
    Colors.indigoAccent,
    Colors.pinkAccent,
    Colors.limeAccent,
    Colors.lightBlueAccent,
    Colors.yellowAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.lightGreenAccent,
  ];

  static Color getBookingColor(String id) {
    if (id.isEmpty) return accentCyan;
    // Better hash function to prevent collisions for similar strings (e.g. 18 vs 81)
    int hash = 5381;
    for (int i = 0; i < id.length; i++) {
      hash = ((hash << 5) + hash) + id.codeUnitAt(i); // hash * 33 + c
    }
    // Ensure positive index
    return bookingColors[hash.abs() % bookingColors.length];
  }

  // ── Soft shadow for glass depth ──
  static List<BoxShadow> neonShadow(
    Color color, {
    double spread = 1,
    double blur = 15,
    Offset offset = const Offset(0, 8),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.15),
        blurRadius: blur,
        spreadRadius: spread,
        offset: offset,
      ),
    ];
  }

  // ── Liquid Glass Decoration ──
  static BoxDecoration glassDecoration({
    Color? borderColor,
    double borderRadius = 14,
    Color? surfaceColor,
    bool addHighlight = true,
  }) {
    return BoxDecoration(
      color: surfaceColor ?? glassSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? glassBorder,
        width: 1,
      ),
      gradient: addHighlight ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.02),
        ],
        stops: const [0.0, 0.5],
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ── Legacy Card decoration (updated to faux glass) ──
  static BoxDecoration cardDecoration({
    Color? borderColor,
    double borderRadius = 14,
  }) {
    return glassDecoration(borderColor: borderColor, borderRadius: borderRadius, addHighlight: false, surfaceColor: cardDark.withValues(alpha: 0.6));
  }

  // ── Gradient (Neon) ──
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── ThemeData ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentMagenta,
        tertiary: accentTeal,
        surface: surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
        iconTheme: const IconThemeData(color: accentCyan),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentCyan,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        labelStyle: GoogleFonts.spaceGrotesk(color: textSecondary),
        hintStyle: GoogleFonts.spaceGrotesk(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.pressStart2p(
          fontSize: 20,
          color: textPrimary,
          height: 1.5,
        ),
        headlineMedium: GoogleFonts.pressStart2p(
          fontSize: 16,
          color: textPrimary,
          height: 1.5,
        ),
        headlineSmall: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textSecondary,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: accentCyan,
        ),
      ),
    );
  }
}
