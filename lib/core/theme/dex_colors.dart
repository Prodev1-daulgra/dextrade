import 'dart:ui';

class DexColors {
  DexColors._();

  // ─── Primary Palette (Neon Lemon) ───
  static const Color primary = Color(0xFFC9FF00); // Robinhood Lemon
  static const Color primaryGlow = Color(0x66C9FF00); // Glowing Lemon
  static const Color primaryDark = Color(0xFF7CA100); // Deep Lemon
  static const Color primarySurface = Color(0x0DC9FF00); // 5% Lemon

  // ─── Background Layers ───
  static const Color background = Color(0xFF020205); // Deep Space Black
  static const Color surface = Color(0xFF050505); // Slightly lighter black
  static const Color surfaceLight = Color(0xFF0A0A0A); 
  static const Color surfaceGlass = Color(0x66050505); // 40% black for blur
  static const Color card = Color(0xFF060606); // Dark Card

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF00FF88); // Neon Green (up)
  static const Color successGlow = Color(0x4D00FF88);
  static const Color error = Color(0xFFFF3B30); // Neon Red (down)
  static const Color errorGlow = Color(0x4DFF3B30);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF00F2FE);

  // ─── Accent ───
  static const Color accent = Color(0xFFFFFFFF); // White accent
  static const Color accentGlow = Color(0x33FFFFFF);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA3A3A3); // Muted
  static const Color textMuted = Color(0xFF737373);
  static const Color textDim = Color(0xFF404040);

  // ─── Borders ───
  static const Color border = Color(0x0DFFFFFF); // 5% white
  static const Color borderLight = Color(0x1AFFFFFF); // 10% white
  static const Color borderActive = Color(0x33C9FF00); // Lemon border

  // ─── Gradient Presets ───
  static const List<Color> primaryGradient = [
    Color(0xFFC9FF00),
    Color(0xFF7CA100),
  ];

  static const List<Color> glassGradient = [
    Color(0x0DFFFFFF),
    Color(0x03FFFFFF),
  ];

  static const List<Color> surfaceGradient = [
    Color(0xFF0A0A0A),
    Color(0xFF020205),
  ];
}
