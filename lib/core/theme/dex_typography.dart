import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dex_colors.dart';

class DexTypography {
  DexTypography._();

  static const List<String> _fallbacks = [
    '-apple-system',
    'BlinkMacSystemFont',
    'SF Pro Display',
    'SF Pro Text',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static const List<String> _monoFallbacks = [
    'JetBrains Mono',
    'SFMono-Regular',
    'Consolas',
    'Liberation Mono',
    'Courier New',
    'monospace',
  ];

  static TextStyle get _baseInter =>
      GoogleFonts.inter().copyWith(fontFamilyFallback: _fallbacks);

  // ─── God-Tier Display (Hero / Landing) ───
  static TextStyle displayMassive = _baseInter.copyWith(
    fontSize: 160,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -6.0,
    height: 0.8,
    color: DexColors.textPrimary,
  );
  
  static TextStyle displayLarge = _baseInter.copyWith(
    fontSize: 96,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -3.0,
    height: 0.85,
    color: DexColors.textPrimary,
  );
  
  static TextStyle displayMedium = _baseInter.copyWith(
    fontSize: 64,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -2.0,
    height: 0.9,
    color: DexColors.textPrimary,
  );

  // ─── Headings ───
  static TextStyle h1 = _baseInter.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -1.5,
    color: DexColors.textPrimary,
  );
  static TextStyle h2 = _baseInter.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -1,
    color: DexColors.textPrimary,
  );
  static TextStyle h3 = _baseInter.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: DexColors.textPrimary,
  );

  // ─── Body ───
  static TextStyle bodyLarge = _baseInter.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: DexColors.textSecondary,
    height: 1.6,
  );
  static TextStyle bodyMedium = _baseInter.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: DexColors.textSecondary,
    height: 1.5,
  );
  static TextStyle bodySmall = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: DexColors.textMuted,
    height: 1.5,
  );

  // ─── Labels & Captions (Institutional caps) ───
  static TextStyle label = _baseInter.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.5, // Extremely wide tracking
    color: DexColors.textMuted,
  );
  static TextStyle caption = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: DexColors.textDim,
  );

  // ─── Mono (Numbers, Prices, Addresses) ───
  static TextStyle mono = GoogleFonts.jetBrainsMono().copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: DexColors.textPrimary,
    letterSpacing: -0.5,
    fontFamilyFallback: _monoFallbacks,
  );
  static TextStyle monoLarge = GoogleFonts.jetBrainsMono().copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: DexColors.textPrimary,
    letterSpacing: -1.5,
    fontFamilyFallback: _monoFallbacks,
  );
  static TextStyle monoHero = GoogleFonts.jetBrainsMono().copyWith(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: DexColors.textPrimary,
    letterSpacing: -3.0,
    fontFamilyFallback: _monoFallbacks,
  );

  // ─── Buttons ───
  static TextStyle button = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
    color: DexColors.textPrimary,
  );
  static TextStyle buttonLarge = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.5,
    color: DexColors.background,
  );
}
