import 'dart:ui';

class DexColors {
  DexColors._();

  // ─── Primary Palette ───
  static const Color primary = Color(0xFF00F2FE); // Electric Cyan
  static const Color primaryGlow = Color(0xFF4FACFE); // Bright Blue
  static const Color primaryDark = Color(0xFF00C6FB); // Deep Cyan
  static const Color primarySurface = Color(0x1A00F2FE);

  // ─── Background Layers ───
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF09090B);
  static const Color surfaceLight = Color(0xFF18181B);
  static const Color surfaceGlass = Color(0x7F000000); // 50% opacity pure black
  static const Color card = Color(0xFF09090B);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Accent (Yellow for high contrast) ───
  static const Color accent = Color(0xFFFACC15);
  static const Color accentGlow = Color(0xFFFDE047);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textDim = Color(0xFF52525B);

  // ─── Borders ───
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderLight = Color(0x2AFFFFFF);
  static const Color borderActive = Color(0x3300F2FE);

  // ─── Gradient Presets ───
  static const List<Color> primaryGradient = [
    Color(0xFF00F2FE),
    Color(0xFF4FACFE),
  ];

  static const List<Color> glassGradient = [
    Color(0x1AFFFFFF),
    Color(0x08FFFFFF),
  ];

  static const List<Color> surfaceGradient = [
    Color(0xFF12121E),
    Color(0xFF0A0A12),
  ];
}
