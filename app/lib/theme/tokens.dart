import 'package:flutter/material.dart';

/// Design tokens, generated from design-handoff/tokens.json.
///
/// Rule from the handoff: NO screen may contain a color, font size, spacing,
/// radius or duration literal — only token references. Swapping the whole
/// [AppTokens] bundle re-themes the app.
@immutable
class AppColors {
  const AppColors({
    required this.ink,
    required this.muted,
    required this.ground,
    required this.groundTop,
    required this.surface,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.pill,
    required this.onDark,
    required this.heart,
    required this.success,
    required this.danger,
    required this.gold,
    required this.goldDeep,
    required this.lockedFill,
    required this.shadowTint,
  });

  /// Primary text / icon color.
  final Color ink;

  /// Secondary text color.
  final Color muted;

  /// Screen background.
  final Color ground;

  /// Sky tint used at the top of gradient screens.
  final Color groundTop;

  /// Plain white surface (cards over ground).
  final Color surface;

  /// Warm tinted card fill.
  final Color card;

  /// Slightly lighter tinted card fill (rows, tiles).
  final Color cardAlt;

  /// Hairline / tile border.
  final Color border;

  /// Dark pill CTA background.
  final Color pill;

  /// Text/icon color on dark pill.
  final Color onDark;

  /// Favorite heart.
  final Color heart;

  final Color success;
  final Color danger;
  final Color gold;
  final Color goldDeep;

  /// Fill for locked/disabled chips and badges.
  final Color lockedFill;

  /// Base tint for drop shadows.
  final Color shadowTint;

  Color shadow(double opacity) => shadowTint.withValues(alpha: opacity);
}

@immutable
class QuestAccents {
  const QuestAccents({
    required this.peaceful,
    required this.night,
    required this.artistic,
    required this.stories,
  });

  final Color peaceful;
  final Color night;
  final Color artistic;
  final Color stories;
}

/// tokens.json → color.accentSoftRule.
extension AccentSoft on Color {
  /// "soft fill = accent mixed 16% into white"
  Color get softFill => Color.lerp(Colors.white, this, 0.16)!;

  /// "soft border = accent mixed 45% into white"
  Color get softBorder => Color.lerp(Colors.white, this, 0.45)!;

  Color softOn(Color base, [double amount = 0.16]) =>
      Color.lerp(base, this, amount)!;
}

@immutable
class TypeStyle {
  const TypeStyle(this.size, this.weight, {this.height, this.spacing});

  final double size;
  final FontWeight weight;
  final double? height;
  final double? spacing;
}

@immutable
class AppType {
  const AppType();

  static const displayTitle =
      TypeStyle(27, FontWeight.w800, height: 1.22, spacing: -0.3);
  static const screenTitle = TypeStyle(26, FontWeight.w800, spacing: -0.3);
  static const pageTitle = TypeStyle(23, FontWeight.w800, spacing: -0.3);
  static const detailTitle = TypeStyle(24, FontWeight.w800, spacing: -0.3);
  static const sectionHeader = TypeStyle(17, FontWeight.w800);

  /// Bold question headers on form screens (Mood Builder).
  static const formHeader = TypeStyle(20, FontWeight.w800, spacing: -0.2);
  static const rowTitle = TypeStyle(15, FontWeight.w800);
  static const body = TypeStyle(14, FontWeight.w600, height: 1.45);
  static const itemTitle = TypeStyle(14, FontWeight.w800);
  static const chip = TypeStyle(12, FontWeight.w700);
  static const meta = TypeStyle(12, FontWeight.w800);
  static const metaSub = TypeStyle(11, FontWeight.w600);
  static const caption = TypeStyle(10.5, FontWeight.w700);
  static const cta = TypeStyle(16, FontWeight.w800);
  static const tabLabel = TypeStyle(10, FontWeight.w700);
  static const statNumber = TypeStyle(20, FontWeight.w800);

  /// Spaced uppercase group labels (Side Menu "ACCOUNT", "SUPPORT").
  static const overline = TypeStyle(12, FontWeight.w800, spacing: 1.6);

  /// Side Menu promo-card headline.
  static const promoTitle = TypeStyle(19, FontWeight.w900, spacing: -0.2);
}

@immutable
class AppSpace {
  const AppSpace();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 14;
  static const double xl = 18;
  static const double xxl = 22;
  static const double screenGutter = 18;
  static const double prefsGutter = 22;
}

@immutable
class AppRadius {
  const AppRadius();

  static const double pill = 999;
  static const double sheet = 26;
  static const double card = 18;
  static const double row = 16;
  static const double thumb = 14;
  static const double small = 12;

  /// Tiny corner for speech-bubble tails.
  static const double tail = 4;
}

@immutable
class AppSize {
  const AppSize();

  static const double cta = 54;
  static const double iconButton = 40;
  static const double badge = 46;
  static const double stopNumber = 26;
  static const double stopThumb = 48;
  static const double expectThumb = 86;
  static const double touchMin = 44;
  static const double pathNode = 58;

  /// Emoji icon box on Side Menu tiles and rows.
  static const double menuIcon = 34;
  static const double menuTile = 76;
}

@immutable
class AppMotion {
  const AppMotion();

  static const press = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const pop = Duration(milliseconds: 300);
  static const heartPop = Duration(milliseconds: 350);
  static const entrance = Duration(milliseconds: 400);
  static const float = Duration(milliseconds: 4500);
  static const kenburns = Duration(milliseconds: 10000);
  static const countUp = Duration(milliseconds: 900);
  static const barFill = Duration(milliseconds: 1000);
  static const shake = Duration(milliseconds: 300);

  static const double pressScale = 0.97;
  static const double popPeakScale = 1.2;
  static const double heartPeakScale = 1.35;
  static const double floatTranslateY = -5;
  static const double cardLiftY = -4;
  static const double kenburnsScaleTo = 1.07;

  static const Curve easeOut = Curves.easeOut;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve gentle = Curves.easeInOut;
}

/// The full token bundle a theme supplies. Exposed through
/// [ThemeExtension] so `context.tokens` works everywhere.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.id,
    required this.label,
    required this.colors,
    required this.accents,
  });

  final String id;
  final String label;
  final AppColors colors;
  final QuestAccents accents;

  @override
  AppTokens copyWith({AppColors? colors, QuestAccents? accents}) => AppTokens(
        id: id,
        label: label,
        colors: colors ?? this.colors,
        accents: accents ?? this.accents,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) =>
      t < 0.5 ? this : (other as AppTokens? ?? this);
}

extension TokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  AppColors get colors => tokens.colors;
  QuestAccents get accents => tokens.accents;
}
