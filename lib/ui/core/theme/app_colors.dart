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

  // Tube water colors - solid, vibrant, easily distinguishable
  static const List<Color> waterColors = [
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFDD835), // Yellow
    Color(0xFFFF8F00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFFEC407A), // Pink
    Color(0xFF00ACC1), // Cyan
    Color(0xFFB39DDB), // Lavender
    Color(0xFFFF7043), // Coral
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFF8D6E63), // Brown
    Color(0xFFB71C1C), // Crimson
    Color(0xFFAD1457), // Maroon
    Color(0xFF9E9D24), // Olive
  ];
}
