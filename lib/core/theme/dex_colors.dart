import 'dart:ui';

class DexColors {
  DexColors._();

  // ─── Primary Palette (Vibrant Rich Purple / Violet) ───
  static const Color primary = Color(0xFF7C3AED); // Nice rich Violet/Purple
  static const Color primaryGlow = Color(0xFF9F7AEA); // Glowing Purple
  static const Color primaryDark = Color(0xFF4C1D95); // Deep Royal Purple
  static const Color primarySurface = Color(0x1A7C3AED);

  // ─── Background Layers ───
  static const Color background = Color(0xFF000000); // Pitch Black
  static const Color surface = Color(0xFF07040D); // Deep Space Purple-Black
  static const Color surfaceLight = Color(0xFF130D22); // Dark Purple-Grey Surface
  static const Color surfaceGlass = Color(0x7F000000); // 50% opacity pure black
  static const Color card = Color(0xFF0C0717); // Dark Violet Card

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF8B5CF6);

  // ─── Accent (Electric Cyan & Neon Magenta for high contrast) ───
  static const Color accent = Color(0xFF00F2FE); // Cyber Cyan
  static const Color accentGlow = Color(0xFFD946EF); // Neon Fuchsia/Pink

  // ─── Text ───
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC0BDF2); // Subtle Lavender-White
  static const Color textMuted = Color(0xFF8A82A6); // Lavender Muted
  static const Color textDim = Color(0xFF5B5475);

  // ─── Borders ───
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderLight = Color(0x2AFFFFFF);
  static const Color borderActive = Color(0x337C3AED);

  // ─── Gradient Presets ───
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED), // Rich Purple
    Color(0xFFEC4899), // Neon Pink/Fuchsia
  ];

  static const List<Color> glassGradient = [
    Color(0x1AFFFFFF),
    Color(0x08FFFFFF),
  ];

  static const List<Color> surfaceGradient = [
    Color(0xFF130D22),
    Color(0xFF07040D),
  ];
}
