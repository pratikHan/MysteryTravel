import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Pause modal over the dimmed path (reference: 20_pause.png).
/// End Adventure swaps inline to a confirm step before acting.
void showPauseDialog(BuildContext context) {
  SoundService.instance.play(Sfx.tap, haptic: Haptic.light);
  final c = context.colors;
  showDialog<void>(
    context: context,
    barrierColor: c.ink.withValues(alpha: 0.5),
    builder: (dialogContext) {
      var confirmingEnd = false;
      return StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
          child: PopIn(
            peak: 1.04,
            child: Container(
              padding: const EdgeInsets.all(AppSpace.xxl),
              decoration: BoxDecoration(
                color: c.ground,
                borderRadius: BorderRadius.circular(AppRadius.sheet),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Pressable(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Icon(Icons.close_rounded,
                          color: c.muted, size: 22),
                    ),
                  ),
                  const Mascot(MascotState.resting, size: 150),
                  const SizedBox(height: AppSpace.l),
                  AppText(
                      confirmingEnd ? 'End this adventure?' : 'Take a Break?',
                      AppType.detailTitle),
                  const SizedBox(height: AppSpace.s),
                  AppText(
                    confirmingEnd
                        ? 'Your completed chapters stay in your passport. This can\'t be undone.'
                        : 'You can pause your adventure\nand continue anytime.',
                    AppType.body,
                    color: c.muted,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpace.xl),
                  if (!confirmingEnd) ...[
                    _DialogButton(
                      label: 'Pause Adventure',
                      fill: c.pill,
                      textColor: c.onDark,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        showAppToast(context,
                            'Adventure paused — resume anytime.');
                      },
                    ),
                    const SizedBox(height: AppSpace.m),
                    _DialogButton(
                      label: 'End Adventure',
                      fill: c.surface,
                      textColor: c.danger,
                      border: c.border,
                      icon: Icons.stop_circle_outlined,
                      onTap: () => setState(() => confirmingEnd = true),
                    ),
                    const SizedBox(height: AppSpace.m),
                    _DialogButton(
                      label: 'Keep Exploring',
                      fill: c.surface,
                      textColor: c.ink,
                      border: c.border,
                      icon: Icons.play_arrow_rounded,
                      onTap: () => Navigator.of(dialogContext).pop(),
                    ),
                  ] else ...[
                    _DialogButton(
                      label: 'Yes, End Adventure',
                      fill: c.danger,
                      textColor: c.onDark,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        AppScope.read(context).resetAdventure();
                        context.go('/home');
                        showAppToast(context,
                            'Adventure ended. Your stamps are safe!');
                      },
                    ),
                    const SizedBox(height: AppSpace.m),
                    _DialogButton(
                      label: 'Go Back',
                      fill: c.surface,
                      textColor: c.ink,
                      border: c.border,
                      onTap: () => setState(() => confirmingEnd = false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.fill,
    required this.textColor,
    required this.onTap,
    this.border,
    this.icon,
  });

  final String label;
  final Color fill;
  final Color textColor;
  final VoidCallback onTap;
  final Color? border;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: AppSize.cta - 6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border:
              border == null ? null : Border.all(color: border!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 19),
              const SizedBox(width: AppSpace.s),
            ],
            AppText(label, AppType.itemTitle, color: textColor),
          ],
        ),
      ),
    );
  }
}
