import 'package:flutter/material.dart';

class MaternityTheme {
  static const Color primaryPink = Color(0xFFFF8DC7);
  static const Color lightPink = Color(0xFFFFE5F1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textLight = Color(0xFF6B7280);

  

  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryPink.withOpacity(0.1),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static TextStyle headingStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static TextStyle subheadingStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textLight,
  );
}