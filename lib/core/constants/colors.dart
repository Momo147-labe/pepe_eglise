import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundLight = Color(0xFFF5F5F0);
  static const Color backgroundDark = Color(0xFF1A433A);
  static const Color primaryOrange = Color(0xFFFF6B1A);
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF1A433A);
  static const Color inputBackground = Color(0x1AFFFFFF); // 10% white
  static const Color inputBorder = Color(0x33FFFFFF); // 20% white
}

extension ThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get surfaceHighlightColor =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFF7FAFC);
  Color get textColor => isDarkMode ? Colors.white : AppColors.textDark;
  Color get subtitleColor => isDarkMode ? Colors.white70 : Colors.black45;
  Color get iconColor => isDarkMode ? Colors.white54 : Colors.black38;
  Color get borderColor =>
      isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05);
  Color get dividerColor => isDarkMode ? Colors.white24 : Colors.black12;

  // Input specific
  Color get inputBackgroundColor =>
      isDarkMode ? const Color(0x1AFFFFFF) : Colors.black.withOpacity(0.02);
  Color get inputBorderColor =>
      isDarkMode ? const Color(0x33FFFFFF) : Colors.black.withOpacity(0.1);
  Color get inputLabelColor => isDarkMode ? Colors.white70 : Colors.black54;

  Color get sidebarColor =>
      isDarkMode ? const Color(0xFF0F172A) : AppColors.backgroundDark;
}
