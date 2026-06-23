import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color primary = Color(0xFF86EF4D); // Accent / Lime Green
  static const Color accent = Color(0xFF86EF4D);
  static const Color headingWhite = Color(0xFFFFFFFF);
  static const Color subtext = Color(0xFF808080);
  static const Color bg = Color(0xFF121212); // Deep Off-Black
  static const Color gridLines = Color(0xFF222222); // Faint Charcoal

  // Unified theme configs to deep off-black
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF16161C);
  static const Color darkCard = Color(0xFF1C1C22);
  static const Color darkBorder = Color(0xFF86EF4D);

  static const Color lightBg = Color(0xFF121212);
  static const Color lightSurface = Color(0xFF16161C);
  static const Color lightCard = Color(0xFF1C1C22);
  static const Color lightBorder = Color(0xFF86EF4D);

  // Tube water colors - solid, vibrant, saturated
  static const List<Color> waterColors = [
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFDD835), // Yellow
    Color(0xFFFF8F00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFFEC407A), // Pink
    Color(0xFF00ACC1), // Cyan
    Color(0xFF7CB342), // Lime
    Color(0xFFFB8C00), // Deep Orange
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF26A69A), // Teal
  ];
}
