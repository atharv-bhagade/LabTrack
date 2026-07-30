import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundGradientEnd,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.tileLight,
    required this.tileDark,
    required this.working,
    required this.defective,
    required this.shadow,
  });

  final Color background;
  final Color backgroundGradientEnd;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color tileLight;
  final Color tileDark;
  final Color working;
  final Color defective;
  final Color shadow;

  static const dark = AppPalette(
    background: Color(0xFF0B0E14),
    backgroundGradientEnd: Color(0xFF121824),
    surface: Color(0xFF161B26),
    surfaceElevated: Color(0xFF1C2333),
    border: Color(0xFF2A3344),
    borderSubtle: Color(0xFF232B3A),
    textPrimary: Color(0xFFF0F2F5),
    textSecondary: Color(0xFF8B95A8),
    accent: Color(0xFF6C8EFF),
    tileLight: Color(0xFF252D3D),
    tileDark: Color(0xFF1A2130),
    working: Color(0xFF34D399),
    defective: Color(0xFFF87171),
    shadow: Color(0x66000000),
  );

  static const light = AppPalette(
    background: Color(0xFFF4F6FA),
    backgroundGradientEnd: Color(0xFFE9EEF5),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF8FAFD),
    border: Color(0xFFD8DEE8),
    borderSubtle: Color(0xFFE4E9F0),
    textPrimary: Color(0xFF1A2230),
    textSecondary: Color(0xFF5B677A),
    accent: Color(0xFF4F6BF6),
    tileLight: Color(0xFFEEF2F8),
    tileDark: Color(0xFFE3E9F2),
    working: Color(0xFF059669),
    defective: Color(0xFFDC2626),
    shadow: Color(0x33000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? backgroundGradientEnd,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? tileLight,
    Color? tileDark,
    Color? working,
    Color? defective,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      backgroundGradientEnd:
          backgroundGradientEnd ?? this.backgroundGradientEnd,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      tileLight: tileLight ?? this.tileLight,
      tileDark: tileDark ?? this.tileDark,
      working: working ?? this.working,
      defective: defective ?? this.defective,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundGradientEnd:
          Color.lerp(backgroundGradientEnd, other.backgroundGradientEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      tileLight: Color.lerp(tileLight, other.tileLight, t)!,
      tileDark: Color.lerp(tileDark, other.tileDark, t)!,
      working: Color.lerp(working, other.working, t)!,
      defective: Color.lerp(defective, other.defective, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
