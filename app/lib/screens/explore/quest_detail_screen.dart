import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import 'scenes/quest_scene.dart';

/// One parameterized quest detail screen; the accent comes from the
/// quest's theme (source: quest_detail_*.dc.html — never fork this).
class QuestDetailScreen extends StatelessWidget {
  const QuestDetailScreen({super.key, required this.questId});

  final String questId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final quest = Fixtures.questById(questId);
    final accent = quest.theme.accent(context.accents);
    final favorite = state.favorites.contains(quest.id);
    final scene = questSceneFor(quest.id);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: questSceneIsDark(quest.id)
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 248,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Animated scene when the quest has one (scenes/), else
                  // the static hero art.
                  if (scene != null)
                    Hero(
                      tag: 'quest-${quest.id}',
                      // Card art cross-fades into the live scene in flight.
                      // (Flight animation runs 0→1 on push, 1→0 on pop.)
                      flightShuttleBuilder:
                          (_, animation, direction, from, to) {
                            final push = direction == HeroFlightDirection.push;
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                (push ? to : from).widget,
                                FadeTransition(
                                  opacity: ReverseAnimation(animation),
                                  child: (push ? from : to).widget,
                                ),
                              ],
                            );
                          },
                      child: scene,
                    )
                  else
                    KenBurns(
                      child: Hero(
                        tag: 'quest-${quest.id}',
                        child: Image.asset(quest.heroImage, fit: BoxFit.cover),
                      ),
                    ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpace.m,
                    left: AppSpace.l,
                    child: CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onDark: true,
                      semanticLabel: 'Back to Explore',
                      onTap: () => context.go('/explore'),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpace.m,
                    right: AppSpace.l,
                    child: Pressable(
                      onTap: () => state.toggleFavorite(quest.id),
                      sfx: Sfx.pop,
                      haptic: Haptic.medium,
                      child: Container(
                        width: AppSize.iconButton,
                        height: AppSize.iconButton,
                        decoration: BoxDecoration(
                          color: c.ink.withValues(alpha: 0.38),
                          shape: BoxShape.circle,
                        ),
                        child: favorite
                            ? PopIn(
                                peak: AppMotion.heartPeakScale,
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: c.heart,
                                  size: 20,
                                ),
                              )
                            : const Icon(
                                Icons.favorite_border_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -AppRadius.sheet, 0),
              decoration: BoxDecoration(
                color: c.ground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenGutter,
                AppSpace.xxl,
                AppSpace.screenGutter,
                AppSpace.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSize.badge,
                        height: AppSize.badge,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _questIcon(quest),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                        child: AppText(quest.title, AppType.detailTitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.m - 2),
                  AppText(quest.description, AppType.body, color: c.muted),
                  const SizedBox(height: AppSpace.l),
                  Wrap(
                    spacing: AppSpace.s,
                    runSpacing: AppSpace.s,
                    children: [for (final tag in quest.tags) TagChip(tag)],
                  ),
                  const SizedBox(height: AppSpace.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MetaItem(
                        icon: Icons.schedule_rounded,
                        title: quest.duration,
                        sub: quest.stopsLabel,
                      ),
                      _MetaItem(
                        icon: Icons.directions_walk_rounded,
                        title: quest.travelLabel,
                        sub: quest.travelSub,
                      ),
                      _MetaItem(
                        icon: Icons.groups_rounded,
                        title: quest.audienceLabel,
                        sub: quest.audienceSub,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  AppText('What to expect', AppType.sectionHeader),
                  const SizedBox(height: AppSpace.m),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, item) in quest.expect.indexed) ...[
                        Expanded(
                          child: FadeRiseIn(
                            delay: Duration(milliseconds: 70 * i),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.thumb,
                                  ),
                                  child: Image.asset(
                                    item.image,
                                    height: AppSize.expectThumb,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: AppSpace.xs + 1),
                                AppText(
                                  item.label,
                                  AppType.caption,
                                  color: c.muted,
                                  align: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i != quest.expect.length - 1)
                          const SizedBox(width: AppSpace.s + 2),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  AppText('Sample stops', AppType.sectionHeader),
                  const SizedBox(height: AppSpace.l),
                  _StopsTimeline(quest: quest, accent: accent),
                  const SizedBox(height: AppSpace.xxl + 2),
                  PrimaryButton(
                    label: 'Start this adventure',
                    sfx: Sfx.success,
                    onTap: () {
                      AppScope.read(context).resetAdventure();
                      context.go('/adventure');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quests that share a colour theme still get their own badge icon
  /// (matching their Explore card art).
  IconData _questIcon(Quest quest) => switch (quest.id) {
    'foodie' => Icons.restaurant_rounded,
    'family' => Icons.family_restroom_rounded,
    'couples' => Icons.favorite_rounded,
    'secrets' => Icons.diamond_rounded,
    _ => switch (quest.theme) {
      QuestTheme.peaceful => Icons.spa_rounded,
      QuestTheme.night => Icons.nightlife_rounded,
      QuestTheme.artistic => Icons.palette_rounded,
      QuestTheme.stories => Icons.auto_stories_rounded,
    },
  };
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.title, required this.sub});

  final IconData icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: c.ink),
        const SizedBox(width: AppSpace.xs + 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(title, AppType.meta),
            AppText(sub, AppType.metaSub, color: c.muted),
          ],
        ),
      ],
    );
  }
}

class _StopsTimeline extends StatelessWidget {
  const _StopsTimeline({required this.quest, required this.accent});

  final Quest quest;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Positioned(
          left: AppSize.stopNumber / 2,
          top: AppSpace.xl,
          bottom: AppSpace.xl,
          child: CustomPaint(
            painter: _DashedLinePainter(
              color: Color.lerp(c.ground, accent, 0.45)!,
            ),
            size: const Size(2, double.infinity),
          ),
        ),
        Column(
          children: [
            for (final (i, stop) in quest.stops.indexed) ...[
              Row(
                children: [
                  Container(
                    width: AppSize.stopNumber,
                    height: AppSize.stopNumber,
                    decoration: BoxDecoration(
                      color: accent.softFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.softBorder, width: 1.5),
                    ),
                    child: Center(
                      child: AppText('${i + 1}', AppType.chip, color: accent),
                    ),
                  ),
                  const SizedBox(width: AppSpace.m - 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Image.asset(
                      stop.image,
                      width: AppSize.stopThumb,
                      height: AppSize.stopThumb,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpace.m - 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(stop.title, AppType.itemTitle),
                        AppText(stop.subtitle, AppType.chip, color: c.muted),
                      ],
                    ),
                  ),
                ],
              ),
              if (i != quest.stops.length - 1)
                const SizedBox(height: AppSpace.xl - 2),
            ],
          ],
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 5), paint);
      y += 9;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
