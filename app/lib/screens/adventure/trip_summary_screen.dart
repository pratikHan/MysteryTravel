import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Post-adventure recap: places list + scrollable moments strip
/// (reference: 22_trip_summary.png).
class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/complete/adventure_hero.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              // Scrim so the title stays readable over the busy art.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        c.groundTop.withValues(alpha: 0.9),
                        c.groundTop.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + AppSpace.s,
                left: AppSpace.l,
                child: CircleIconButton(
                  icon: Icons.chevron_left_rounded,
                  onDark: true,
                  semanticLabel: 'Back',
                  onTap: () => context.go('/adventure'),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + AppSpace.l,
                left: 0,
                right: 0,
                child: Text(
                  'Your Adventure\nSummary',
                  textAlign: TextAlign.center,
                  style: AppType.pageTitle.style(c.ink).copyWith(
                    shadows: [
                      Shadow(
                          color: c.surface.withValues(alpha: 0.9),
                          blurRadius: 12),
                      Shadow(
                          color: c.surface.withValues(alpha: 0.9),
                          blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  transform: Matrix4.translationValues(0, -AppSpace.xxl, 0),
                  padding: const EdgeInsets.all(AppSpace.l),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: [
                      BoxShadow(
                          color: c.shadow(0.14),
                          blurRadius: 16,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.thumb),
                        child: Image.asset(
                            'assets/images/complete/moment_1.png',
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(width: AppSpace.l),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(Fixtures.activeAdventureTitle,
                                AppType.sectionHeader),
                            const SizedBox(height: 2),
                            AppText(Fixtures.activeAdventureCity,
                                AppType.chip,
                                color: c.muted),
                            const SizedBox(height: AppSpace.xs + 2),
                            Row(
                              children: [
                                Icon(Icons.event_rounded,
                                    size: 14, color: c.muted),
                                const SizedBox(width: AppSpace.xs),
                                AppText('Oct 16, 2026', AppType.metaSub,
                                    color: c.muted),
                                const SizedBox(width: AppSpace.m),
                                Icon(Icons.auto_stories_rounded,
                                    size: 14, color: c.muted),
                                const SizedBox(width: AppSpace.xs),
                                AppText(
                                    '${Fixtures.chapters.length} Chapters',
                                    AppType.metaSub,
                                    color: c.muted),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppText('Places You Explored', AppType.sectionHeader),
                const SizedBox(height: AppSpace.m),
                for (final (i, chapter) in Fixtures.chapters.indexed)
                  FadeRiseIn(
                    delay: Duration(milliseconds: 60 * i),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpace.m),
                      child: Pressable(
                        onTap: () => showAppToast(context,
                            '${chapter.venueName}: ${chapter.venueStory}'),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpace.m),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.row),
                            border:
                                Border.all(color: c.border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: [
                                    c.success,
                                    c.gold,
                                    context.accents.night,
                                    c.muted
                                  ][i % 4],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: AppText('${chapter.number}',
                                      AppType.meta,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: AppSpace.m),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppRadius.small),
                                child: Image.asset(chapter.image,
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover),
                              ),
                              const SizedBox(width: AppSpace.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    AppText(chapter.venueName,
                                        AppType.itemTitle),
                                    AppText(chapter.venueStory,
                                        AppType.metaSub,
                                        color: c.muted,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: c.muted, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpace.s),
                AppText('Moments from Your Adventure',
                    AppType.sectionHeader),
                const SizedBox(height: AppSpace.m),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: Fixtures.moments.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(width: AppSpace.m),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppRadius.thumb),
                      child: Image.asset(Fixtures.moments[i].image,
                          width: 96, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xxl),
                PrimaryButton(
                  label: 'Save to My Passport',
                  sfx: Sfx.stamp,
                  onTap: () {
                    showAppToast(
                        context, 'Saved! Your stamps are in the passport.');
                    context.go('/passport');
                  },
                ),
                const SizedBox(height: AppSpace.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
