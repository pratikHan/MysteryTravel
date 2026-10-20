import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../data/fixtures.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';
import '../../widgets/menu_button.dart';

/// Profile with animating XP bar, stats, and menu (source: profile.dc.html
/// plus the richer XP-bar variant from 24_profile.png).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.prefsGutter, vertical: AppSpace.l),
          physics: const BouncingScrollPhysics(),
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Align(
                    alignment: Alignment.centerLeft, child: MenuButton()),
                AppText('My Explorer Profile', AppType.pageTitle),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: c.shadow(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      AssetImage('assets/images/profile/avatar.png'),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.m - 2),
            Center(child: AppText(Fixtures.profileName, AppType.statNumber)),
            const SizedBox(height: 2),
            Center(
              child: AppText('4 Adventures Completed', AppType.chip,
                  color: c.muted),
            ),
            const SizedBox(height: AppSpace.l),
            _XpBar(),
            const SizedBox(height: AppSpace.xl),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpace.l),
              decoration: BoxDecoration(
                color: c.cardAlt,
                borderRadius: BorderRadius.circular(AppRadius.row),
                border: Border.all(color: c.border, width: 2),
              ),
              child: Row(
                children: [
                  for (final (i, (value, label))
                      in Fixtures.profileStats.indexed)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: i == 1
                              ? Border.symmetric(
                                  vertical: BorderSide(
                                      color: c.border, width: 1.5))
                              : null,
                        ),
                        child: Column(
                          children: [
                            CountUp(int.parse(value), AppType.statNumber),
                            const SizedBox(height: 2),
                            AppText(label, AppType.metaSub, color: c.muted),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xl),
            _MenuRow(
              icon: Icons.explore_outlined,
              label: 'My Adventures',
              onTap: () => context.go('/adventure'),
            ),
            _MenuRow(
              icon: Icons.favorite_border_rounded,
              label: 'Saved Places',
              onTap: () =>
                  showAppToast(context, 'Saved places arrive in stage 2!'),
            ),
            _MenuRow(
              icon: Icons.star_border_rounded,
              label: 'Achievements',
              onTap: () => context.go('/profile/achievements'),
            ),
            _MenuRow(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.go('/profile/settings'),
            ),
            const SizedBox(height: AppSpace.xl),
          ],
        ),
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduced = MotionSettings.reduced(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText('Level ${Fixtures.profileLevel} Explorer', AppType.meta),
            AppText(
                '${(Fixtures.profileXpProgress * 100).round()}% to Level ${Fixtures.profileLevel + 1}',
                AppType.metaSub,
                color: c.muted),
          ],
        ),
        const SizedBox(height: AppSpace.s - 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
                begin: reduced ? Fixtures.profileXpProgress : 0,
                end: Fixtures.profileXpProgress),
            duration: AppMotion.barFill,
            curve: AppMotion.easeOut,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 10,
              backgroundColor: c.lockedFill,
              valueColor: AlwaysStoppedAnimation(c.gold),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s + 2),
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.xl - 2, vertical: AppSpace.l + 1),
          decoration: BoxDecoration(
            color: c.cardAlt,
            borderRadius: BorderRadius.circular(AppRadius.row),
            border: Border.all(color: c.border, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: c.ink),
              const SizedBox(width: AppSpace.l),
              Expanded(child: AppText(label, AppType.rowTitle)),
              Icon(Icons.chevron_right_rounded, size: 18, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}
