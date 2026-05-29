import 'package:flutter/material.dart';

class AppTheme {
  // Colors — matches actual AutoPulse app
  static const bg = Color(0xFF0D1117);
  static const cardBg = Color(0xFF141B24);
  static const cardBgLight = Color(0xFF1A2535);
  static const accent = Color(0xFF00BCD4); // cyan
  static const accentDark = Color(0xFF007B8A); // teal
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A9BB0); // muted blue-grey
  static const divider = Color(0xFF1E2A38);
  static const error = Color(0xFFFF4444);
  static const warning = Color(0xFFFFA500);
  static const success = Color(0xFF00BCD4);

  // Vehicle card teal gradient
  static const vehicleCardGradient = LinearGradient(
    colors: [Color(0xFF007B8A), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text styles
  static const sectionLabel = TextStyle(
    color: textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );

  static const cardTitle = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const accentValue = TextStyle(
    color: accent,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const bodyMuted = TextStyle(
    color: textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // Card decoration
  static BoxDecoration get card => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration get cardLight => BoxDecoration(
        color: cardBgLight,
        borderRadius: BorderRadius.circular(12),
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: accent,
      fontFamily: 'System',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
