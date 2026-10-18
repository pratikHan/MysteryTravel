import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Multi-select interest tiles (source: set_preferences.dc.html).
class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final count = state.interests.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.xl),
              AppText('What Do You\nLove Exploring?', AppType.displayTitle,
                  align: TextAlign.center),
              const SizedBox(height: AppSpace.m - 2),
              AppText('Choose a few to personalize your adventures.',
                  AppType.body,
                  color: c.muted, align: TextAlign.center),
              const SizedBox(height: AppSpace.xl + 2),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpace.l,
                  crossAxisSpacing: AppSpace.l,
                  childAspectRatio: 1.18,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (final (i, interest)
                        in Fixtures.interests.indexed)
                      FadeRiseIn(
                        delay: Duration(milliseconds: 60 * i),
                        child: _InterestTile(
                          label: interest.label,
                          icon: interest.icon,
                          selected: state.interests.contains(interest.id),
                          onTap: () => state.toggleInterest(interest.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              PrimaryButton(
                label: count > 0 ? 'Continue ($count)' : 'Continue',
                enabled: count > 0,
                onTap: () => context.go('/city'),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.pop,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: AppMotion.base,
            curve: AppMotion.easeOut,
            decoration: BoxDecoration(
              color: selected ? c.cardAlt : c.card,
              border: Border.all(
                  color: selected ? c.ink : c.border, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: c.shadow(0.14),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ]
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(icon, width: 58, height: 58),
                  const SizedBox(height: AppSpace.s + 2),
                  AppText(label, AppType.itemTitle),
                ],
              ),
            ),
          ),
          if (selected)
            const Positioned(top: AppSpace.s, right: AppSpace.s, child: CheckBadge()),
        ],
      ),
    );
  }
}
