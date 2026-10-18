import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Single-select mystery mode rows (reference: 05_mystery_mode.png).
class MysteryModeScreen extends StatelessWidget {
  const MysteryModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.s),
              ScreenHeader(
                title: 'Choose Mystery Mode',
                onBack: () => context.go('/city'),
              ),
              const SizedBox(height: AppSpace.l),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Image.asset(
                        'assets/images/mode/hero.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    for (final (i, mode) in Fixtures.mysteryModes.indexed) ...[
                      FadeRiseIn(
                        delay: Duration(milliseconds: 80 * i),
                        child: _ModeRow(
                          mode: mode,
                          selected: state.mysteryModeId == mode.id,
                          onTap: () => state.setMysteryMode(mode.id),
                        ),
                      ),
                      const SizedBox(height: AppSpace.m),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s),
              PrimaryButton(
                label: 'Continue',
                trailingArrow: true,
                onTap: () => context.go('/customize'),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final MysteryMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        sfx: Sfx.pop,
        child: AnimatedContainer(
          duration: AppMotion.base,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
                color: selected ? c.ink : c.border, width: 2),
            boxShadow: [
              BoxShadow(
                  color: c.shadow(selected ? 0.16 : 0.07),
                  blurRadius: selected ? 16 : 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card - 2),
            child: Row(
              children: [
                Image.asset(mode.image,
                    width: 108, height: 96, fit: BoxFit.cover),
                const SizedBox(width: AppSpace.m),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: mode.badgeColor, shape: BoxShape.circle),
                  child:
                      Icon(mode.badgeIcon, color: Colors.white, size: 19),
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpace.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(mode.title, AppType.rowTitle),
                        const SizedBox(height: 2),
                        AppText(mode.subtitle, AppType.metaSub,
                            color: c.muted),
                      ],
                    ),
                  ),
                ),
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.m),
                    child: CheckBadge(color: mode.badgeColor),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.m),
                    child: Icon(Icons.chevron_right_rounded,
                        color: c.muted, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
