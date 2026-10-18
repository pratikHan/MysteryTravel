import 'package:flutter/material.dart';

import '../core/sounds.dart';
import '../theme/tokens.dart';
import 'app_text.dart';
import 'motion_widgets.dart';

/// The 54pt pill CTA used at the bottom of nearly every screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.trailingArrow = false,
    this.enabled = true,
    this.sfx = Sfx.tap,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final bool trailingArrow;
  final bool enabled;
  final Sfx? sfx;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      sfx: sfx,
      haptic: Haptic.light,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.55,
        duration: AppMotion.base,
        child: Container(
          height: AppSize.cta,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color ?? c.pill,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: [
              BoxShadow(
                color: c.shadow(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(label, AppType.cta, color: c.onDark),
              if (trailingArrow) ...[
                const SizedBox(width: AppSpace.s),
                Icon(Icons.arrow_forward_rounded, color: c.onDark, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 40pt round icon button (back, settings, close).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.onDark = false,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;

  /// Frosted dark variant used over imagery.
  final bool onDark;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: AppSize.iconButton,
          height: AppSize.iconButton,
          decoration: BoxDecoration(
            color: onDark ? c.ink.withValues(alpha: 0.38) : c.surface,
            shape: BoxShape.circle,
            border: onDark ? null : Border.all(color: c.border, width: 1.5),
          ),
          child: Icon(icon, size: 19, color: onDark ? Colors.white : c.ink),
        ),
      ),
    );
  }
}

/// Standard screen header: back button + centered title (+ optional sub).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.titleType = AppType.pageTitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final TypeStyle titleType;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null)
          CircleIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: onBack,
            semanticLabel: 'Back',
          )
        else
          const SizedBox(width: AppSize.iconButton),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 2),
              AppText(title, titleType, align: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpace.xs),
                AppText(subtitle!, AppType.body,
                    color: c.muted, align: TextAlign.center),
              ],
            ],
          ),
        ),
        trailing ?? const SizedBox(width: AppSize.iconButton),
      ],
    );
  }
}

/// Pop-in circular check badge used on selected tiles/cards.
class CheckBadge extends StatelessWidget {
  const CheckBadge({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return PopIn(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? context.colors.ink,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded,
            size: size * 0.58, color: context.colors.onDark),
      ),
    );
  }
}

/// Outlined tag chip ("Nature", "Parks"...).
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.m, vertical: AppSpace.s - 1),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AppText(label, AppType.chip),
    );
  }
}

/// Filter chip with selected (dark pill) state.
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.pop,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.easeOut,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.l + 2, vertical: AppSpace.s + 1),
        decoration: BoxDecoration(
          color: selected ? c.pill : c.surface,
          border: Border.all(
              color: selected ? c.pill : c.border, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AppText(label, AppType.chip,
            color: selected ? c.onDark : c.ink),
      ),
    );
  }
}

/// Mascot speech bubble with asymmetric corner, floats gently.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text, {super.key, this.maxWidth = 240});

  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Floaty(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.l, vertical: AppSpace.m - 2),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.card),
            topRight: Radius.circular(AppRadius.card),
            bottomRight: Radius.circular(AppRadius.card),
            bottomLeft: Radius.circular(AppRadius.tail),
          ),
          boxShadow: [
            BoxShadow(
              color: c.shadow(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppText(text, AppType.body),
      ),
    );
  }
}
