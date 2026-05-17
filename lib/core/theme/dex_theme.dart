import 'package:flutter/material.dart';
import 'dex_colors.dart';
import 'dex_typography.dart';

class DexTheme {
  DexTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DexColors.background,
      primaryColor: DexColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: DexColors.primary,
        onPrimary: DexColors.background,
        secondary: DexColors.accent,
        onSecondary: DexColors.background,
        surface: DexColors.surface,
        onSurface: DexColors.textPrimary,
        error: DexColors.error,
        onError: Colors.white,
      ),
      cardColor: DexColors.card,
      dividerColor: DexColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: DexColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: DexTypography.h3,
        iconTheme: const IconThemeData(color: DexColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DexColors.surface,
        selectedItemColor: DexColors.primary,
        unselectedItemColor: DexColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.015),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DexColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DexColors.error),
        ),
        hintStyle: DexTypography.bodyMedium.copyWith(color: DexColors.textDim),
        labelStyle: DexTypography.label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DexColors.primary,
          foregroundColor: DexColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: DexTypography.buttonLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DexColors.textPrimary,
          side: const BorderSide(color: DexColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: DexTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DexColors.primary,
          textStyle: DexTypography.button,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DexColors.surface,
        contentTextStyle: DexTypography.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DexColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: DexTypography.h2,
        contentTextStyle: DexTypography.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DexColors.surface,
        modalBackgroundColor: DexColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
