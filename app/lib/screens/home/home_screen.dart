import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../state/app_state.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Home: hero scene with greeting, resume-adventure card, featured cards
/// with heart toggles (reference: 08_home.png).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          Stack(
            children: [
              KenBurns(
                child: Image.asset(
                  'assets/images/home/hero.png',
                  width: double.infinity,
                  height: 360,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              // The hero asset carries the baked speech bubble; only the
              // greeting is real text, with a soft halo for legibility.
              Positioned(
                left: AppSpace.screenGutter,
                right: AppSpace.screenGutter,
                top: MediaQuery.paddingOf(context).top + AppSpace.l,
                child: FadeRiseIn(
                  child: Text(
                    'Good morning,\nExplorer!',
                    style: AppType.screenTitle.style(c.ink).copyWith(
                      shadows: [
                        Shadow(
                            color: c.surface.withValues(alpha: 0.9),
                            blurRadius: 14),
                        Shadow(
                            color: c.surface.withValues(alpha: 0.9),
                            blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            transform: Matrix4.translationValues(0, -AppRadius.sheet, 0),
            decoration: BoxDecoration(
              color: c.ground,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet)),
            ),
            padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                AppSpace.xxl, AppSpace.screenGutter, AppSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResumeCard(
                  onTap: () => context.go('/adventure'),
                ),
                const SizedBox(height: AppSpace.xxl),
                Row(
                  children: [
                    Expanded(
                        child: AppText(
                            'Featured Adventures', AppType.detailTitle)),
                    Pressable(
                      onTap: () => context.go('/explore'),
                      child: Row(
                        children: [
                          AppText('See all', AppType.chip, color: c.muted),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: c.muted),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.l),
                for (final (i, card) in Fixtures.featuredHome.indexed) ...[
                  FadeRiseIn(
                    delay: Duration(milliseconds: 100 * i),
                    child: _FeaturedCard(
                      card: card,
                      favorite: state.favorites.contains(card.questId),
                      onHeart: () => state.toggleFavorite(card.questId),
                      onTap: () =>
                          context.go('/explore/quest/${card.questId}'),
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final done = state.doneCount;
    final total = Fixtures.chapters.length;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.l),
        decoration: BoxDecoration(
          color: c.pill,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
                color: c.shadow(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.thumb),
              child: Image.asset(Fixtures.activeAdventureImage,
                  width: 56, height: 56, fit: BoxFit.cover),
            ),
            const SizedBox(width: AppSpace.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                      state.adventureComplete
                          ? 'Adventure complete!'
                          : 'Continue your adventure',
                      AppType.caption,
                      color: c.onDark.withValues(alpha: 0.75)),
                  const SizedBox(height: 3),
                  AppText(Fixtures.activeAdventureTitle, AppType.rowTitle,
                      color: c.onDark),
                  const SizedBox(height: AppSpace.s),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: done / total,
                      minHeight: 6,
                      backgroundColor: c.onDark.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation(c.gold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.l),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: c.onDark.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, color: c.onDark, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.card,
    required this.favorite,
    required this.onHeart,
    required this.onTap,
  });

  final dynamic card;
  final bool favorite;
  final VoidCallback onHeart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
                color: c.shadow(0.1),
                blurRadius: 12,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.card)),
                  child: Image.asset(card.image,
                      width: double.infinity, height: 170, fit: BoxFit.cover),
                ),
                Positioned(
                  top: AppSpace.m,
                  right: AppSpace.m,
                  child: _HeartButton(favorite: favorite, onTap: onHeart),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSize.badge,
                        height: AppSize.badge,
                        decoration: BoxDecoration(
                            color: card.iconColor, shape: BoxShape.circle),
                        child:
                            Icon(card.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                          child: AppText(card.title, AppType.sectionHeader)),
                      Icon(Icons.chevron_right_rounded,
                          color: c.muted, size: 22),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s),
                  AppText(card.blurb, AppType.body, color: c.muted),
                  const SizedBox(height: AppSpace.m),
                  Wrap(
                    spacing: AppSpace.s,
                    runSpacing: AppSpace.s,
                    children: [
                      for (final chip in card.chips) TagChip(chip),
                    ],
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

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.favorite, required this.onTap});

  final bool favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.pop,
      haptic: Haptic.medium,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: c.ink.withValues(alpha: 0.35), shape: BoxShape.circle),
        child: favorite
            ? PopIn(
                peak: AppMotion.heartPeakScale,
                child: Icon(Icons.favorite_rounded, color: c.heart, size: 19),
              )
            : const Icon(Icons.favorite_border_rounded,
                color: Colors.white, size: 19),
      ),
    );
  }
}
