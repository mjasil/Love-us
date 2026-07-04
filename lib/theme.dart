import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Knot palette — dusk tones for a private space, not a bright social app.
class K {
  static const ink = Color(0xFF1C1418); // near-black plum
  static const card = Color(0xFF2A1F26); // raised surface
  static const rose = Color(0xFFE8788A); // primary — muted rose
  static const gold = Color(0xFFD9B36C); // accents / countdown
  static const milk = Color(0xFFF5EDEA); // text
  static const faded = Color(0xFF9C8B93); // secondary text
}

final knotTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: K.ink,
  colorScheme: const ColorScheme.dark(
    primary: K.rose,
    secondary: K.gold,
    surface: K.card,
  ),
  textTheme: TextTheme(
    displayMedium: GoogleFonts.fraunces(
        color: K.milk, fontWeight: FontWeight.w600, fontSize: 34),
    titleLarge: GoogleFonts.fraunces(
        color: K.milk, fontWeight: FontWeight.w600, fontSize: 22),
    bodyMedium: GoogleFonts.inter(color: K.milk, fontSize: 15),
    bodySmall: GoogleFonts.inter(color: K.faded, fontSize: 13),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: K.rose,
      foregroundColor: K.ink,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: K.card,
    hintStyle: GoogleFonts.inter(color: K.faded),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
);
