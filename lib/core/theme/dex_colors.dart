import 'dart:ui';

class DexColors {
  DexColors._();

  // ─── Primary Palette ───
  static const Color primary = Color(0xFFA855F7);
  static const Color primaryGlow = Color(0xFFC084FC);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primarySurface = Color(0x1AA855F7);

  // ─── Background Layers ───
  static const Color background = Color(0xFF0A0A12);
  static const Color surface = Color(0xFF12121E);
  static const Color surfaceLight = Color(0xFF1A1A2E);
  static const Color surfaceGlass = Color(0x9912121E);
  static const Color card = Color(0xFF141422);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Accent (Cyan for positive states) ───
  static const Color accent = Color(0xFF22D3EE);
  static const Color accentGlow = Color(0xFF67E8F9);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDim = Color(0xFF475569);

  // ─── Borders ───
  static const Color border = Color(0x14FFFFFF);
  static const Color borderLight = Color(0x1FFFFFFF);
  static const Color borderActive = Color(0x33A855F7);

  // ─── Gradient Presets ───
  static const List<Color> primaryGradient = [
    Color(0xFFA855F7),
    Color(0xFF7C3AED),
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
