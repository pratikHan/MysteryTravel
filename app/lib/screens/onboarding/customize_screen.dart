import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Radio modes + travel-style tiles (source: customize_adventure.dc.html,
/// with the illustrated bird avatar tweak applied).
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpace.s),
              ScreenHeader(
                title: 'Customize\nYour Adventure',
                subtitle: 'Make it your own!',
                titleType: AppType.screenTitle,
                onBack: () => context.go('/mode'),
              ),
              const SizedBox(height: AppSpace.xxl),
              AppText('Adventure Mode', AppType.sectionHeader),
              const SizedBox(height: AppSpace.m),
              for (final (id, label, sub) in Fixtures.adventureModes) ...[
                _RadioRow(
                  label: label,
                  sub: sub,
                  selected: state.adventureModeId == id,
                  onTap: () => state.setAdventureMode(id),
                ),
                const SizedBox(height: AppSpace.s + 2),
              ],
              const SizedBox(height: AppSpace.m),
              AppText('Travel Style', AppType.sectionHeader),
              const SizedBox(height: AppSpace.m),
              Row(
                children: [
                  for (final (id, label, image) in Fixtures.travelStyles) ...[
                    Expanded(
                      child: _StyleTile(
                        label: label,
                        image: image,
                        selected: state.travelStyleId == id,
                        onTap: () => state.setTravelStyle(id),
                      ),
                    ),
                    if (id != Fixtures.travelStyles.last.$1)
                      const SizedBox(width: AppSpace.s + 2),
                  ],
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Preview Adventure',
                onTap: () => context.go('/preview'),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sub;
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
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.xl - 2, vertical: AppSpace.l),
          decoration: BoxDecoration(
            color: selected ? c.surface : c.cardAlt,
            borderRadius: BorderRadius.circular(AppRadius.row),
            border:
                Border.all(color: selected ? c.ink : c.border, width: 2),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.base,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: selected ? c.ink : c.muted.withValues(alpha: 0.5),
                      width: 2.5),
                ),
                child: selected
                    ? Center(
                        child: PopIn(
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                                color: c.ink, shape: BoxShape.circle),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpace.l),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(label, AppType.rowTitle),
                  const SizedBox(height: 2),
                  AppText(sub, AppType.chip, color: c.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.label,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String image;
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
        padding: const EdgeInsets.fromLTRB(
            AppSpace.xs, AppSpace.s + 2, AppSpace.xs, AppSpace.s + 1),
        decoration: BoxDecoration(
          color: selected ? c.surface : c.cardAlt,
          borderRadius: BorderRadius.circular(AppRadius.row),
          border: Border.all(color: selected ? c.ink : c.border, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: c.shadow(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ]
              : null,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(image,
                  width: 50, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(height: AppSpace.s - 1),
            AppText(label, AppType.chip),
          ],
        ),
      ),
    );
  }
}
