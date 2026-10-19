import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/plan_fixtures.dart';
import '../../data/plan_models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Curated Adventures — the (dummy) engine's 4–5 playlist suggestions.
/// SKELETON: simple cards; full design in Slice 3.
class CuratedAdventuresScreen extends StatelessWidget {
  const CuratedAdventuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final mystery = state.plan.mode == ExplorationMode.mystery;
    final suggestions = PlanFixtures.recommendPlaylists(state.plan);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.l, AppSpace.screenGutter, 0),
              child: ScreenHeader(
                title: 'Your Curated Adventures',
                subtitle: state.plan.wishText.trim().isEmpty
                    ? 'Built around what you love'
                    : '"${state.plan.wishText.trim()}"',
                onBack: () => context.go('/plan'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.screenGutter),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (final (i, playlist) in suggestions.indexed)
                    FadeRiseIn(
                      delay: Duration(milliseconds: 70 * i),
                      child: _PlaylistCard(
                        playlist: playlist,
                        mystery: mystery,
                        onTap: () {
                          state.pickPlaylist(playlist);
                          context.go('/playlist');
                        },
                      ),
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

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.mystery,
    required this.onTap,
  });

  final AdventurePlaylist playlist;
  final bool mystery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: Pressable(
        onTap: onTap,
        sfx: Sfx.pop,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.border, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.card)),
                child: Image.asset(playlist.heroImage,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(playlist.title, AppType.sectionHeader),
                    const SizedBox(height: 2),
                    AppText(playlist.tagline, AppType.body,
                        color: c.muted),
                    const SizedBox(height: AppSpace.s + 2),
                    Wrap(
                      spacing: AppSpace.s,
                      runSpacing: AppSpace.s,
                      children: [
                        TagChip(
                            '${playlist.items.length} stops · ${playlist.duration}'),
                        for (final id in playlist.categoryIds)
                          TagChip(
                              '${PlanFixtures.categoryById(id).emoji} ${PlanFixtures.categoryById(id).label}'),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s + 2),
                    AppText(
                      playlist.items
                          .map((item) => mystery
                              ? item.mysteryTitle
                              : item.place.name)
                          .join('  ·  '),
                      AppType.caption,
                      color: c.muted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
