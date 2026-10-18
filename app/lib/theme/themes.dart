import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// The two shipped themes. Both are built from design-handoff/tokens.json;
/// the handoff required picking one ink as default — the majority of built
/// screens use the navy ink, so Voyage (navy) is the default and
/// Expedition (warm brown) proves the switch works.
abstract final class AppThemes {
  static const voyage = AppTokens(
    id: 'voyage',
    label: 'Voyage (Navy)',
    colors: AppColors(
      ink: Color(0xFF16325A),
      muted: Color(0xFF54627E),
      ground: Color(0xFFF8F3E2),
      groundTop: Color(0xFFD9E7F1),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFBECCD),
      cardAlt: Color(0xFFFCF7EA),
      border: Color(0xFFEFE2C4),
      pill: Color(0xFF112C4A),
      onDark: Color(0xFFFFF7E6),
      heart: Color(0xFFFF6B74),
      success: Color(0xFF5BA85F),
      danger: Color(0xFFC8403A),
      gold: Color(0xFFE8A73C),
      goldDeep: Color(0xFFC9872A),
      lockedFill: Color(0xFFEDE4CC),
      shadowTint: Color(0xFF16325A),
    ),
    accents: QuestAccents(
      peaceful: Color(0xFF3E8E5B),
      night: Color(0xFF8A4FD3),
      artistic: Color(0xFFE8862B),
      stories: Color(0xFFD94F4F),
    ),
  );

  static const expedition = AppTokens(
    id: 'expedition',
    label: 'Expedition (Warm)',
    colors: AppColors(
      ink: Color(0xFF27211A),
      muted: Color(0xFF6E6459),
      ground: Color(0xFFF7F2E8),
      groundTop: Color(0xFFF3E6CC),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFBECCD),
      cardAlt: Color(0xFFFDF8EE),
      border: Color(0xFFE4DBC9),
      pill: Color(0xFF211B15),
      onDark: Color(0xFFFFF7EA),
      heart: Color(0xFFFF6B74),
      success: Color(0xFF5BA85F),
      danger: Color(0xFFC8403A),
      gold: Color(0xFFE8A73C),
      goldDeep: Color(0xFFC9872A),
      lockedFill: Color(0xFFEDE6D6),
      shadowTint: Color(0xFF42321C),
    ),
    accents: QuestAccents(
      peaceful: Color(0xFF3E8E5B),
      night: Color(0xFF8A4FD3),
      artistic: Color(0xFFE8862B),
      stories: Color(0xFFD94F4F),
    ),
  );

  static const all = [voyage, expedition];

  static AppTokens byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => voyage);
}

ThemeData buildTheme(AppTokens tokens) {
  final c = tokens.colors;
  final textTheme = GoogleFonts.nunitoTextTheme().apply(
    bodyColor: c.ink,
    displayColor: c.ink,
  );
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: c.ground,
    colorScheme: ColorScheme.light(
      primary: c.pill,
      onPrimary: c.onDark,
      secondary: c.gold,
      surface: c.ground,
      onSurface: c.ink,
      error: c.danger,
    ),
    textTheme: textTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: c.border,
    extensions: [tokens],
  );
}

/// Styled-text helper so screens write `AppText(AppType.body)` and never
/// a literal size/weight.
extension TypeToStyle on TypeStyle {
  TextStyle style(Color color) => GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color,
      );
}
