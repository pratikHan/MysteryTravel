import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Achievements list: progress bar fills on entry, locked rows shake on
/// tap (source: achievements.dc.html).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduced = MotionSettings.reduced(context);
    const progress =
        Fixtures.achievementsUnlocked / Fixtures.achievementsTotal;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.prefsGutter,
                  AppSpace.l, AppSpace.prefsGutter, 0),
              child: ScreenHeader(
                title: 'Achievements',
                subtitle:
                    '${Fixtures.achievementsUnlocked}/${Fixtures.achievementsTotal} unlocked',
                onBack: () => context.go('/profile'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.prefsGutter,
                  AppSpace.l, AppSpace.prefsGutter, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduced ? progress : 0, end: progress),
                  duration: AppMotion.barFill,
                  curve: AppMotion.easeOut,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 12,
                    backgroundColor: c.lockedFill,
                    valueColor: AlwaysStoppedAnimation(c.success),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.prefsGutter,
                    vertical: AppSpace.xl),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (final (i, a) in Fixtures.achievements.indexed)
                    FadeRiseIn(
                      delay: Duration(milliseconds: 60 * i),
                      child: _AchievementRow(achievement: a),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementRow extends StatefulWidget {
  const _AchievementRow({required this.achievement});

  final Achievement achievement;

  @override
  State<_AchievementRow> createState() => _AchievementRowState();
}

class _AchievementRowState extends State<_AchievementRow> {
  final _shakerKey = GlobalKey<ShakerState>();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final a = widget.achievement;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s + 2),
      child: Shaker(
        key: _shakerKey,
        child: Pressable(
          onTap: a.done
              ? null
              : () {
                  SoundService.instance
                      .play(Sfx.wrong, haptic: Haptic.warning);
                  _shakerKey.currentState?.shake();
                },
          sfx: a.done ? Sfx.tap : null,
          child: Opacity(
            opacity: a.done ? 1 : 0.82,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.l + 1, vertical: AppSpace.m + 1),
              decoration: BoxDecoration(
                color: c.cardAlt,
                borderRadius: BorderRadius.circular(AppRadius.row),
                border: Border.all(color: c.border, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.gold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: c.gold.withValues(alpha: 0.45),
                          width: 1.5),
                    ),
                    child: Icon(Icons.military_tech_rounded,
                        color: c.goldDeep, size: 22),
                  ),
                  const SizedBox(width: AppSpace.m + 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(a.title, AppType.itemTitle),
                        const SizedBox(height: 2),
                        AppText(a.subtitle, AppType.chip, color: c.muted),
                      ],
                    ),
                  ),
                  if (a.done)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                          color: c.success, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 15),
                    )
                  else
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                          color: c.lockedFill, shape: BoxShape.circle),
                      child: Icon(Icons.lock_outline_rounded,
                          color: c.muted, size: 14),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
