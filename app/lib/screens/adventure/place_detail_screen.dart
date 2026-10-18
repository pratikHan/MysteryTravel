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

/// Fullscreen expansion of a trail place card: ratings, reviews,
/// highlights, offers, fun fact and the mini quiz (quizzes live here
/// now, not on the trail). Pops `true` when the stop is marked done.
class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.index});

  final int index;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int? _quizPicked;

  Place get place => Fixtures.places[widget.index];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = context.accents.peaceful;
    final state = AppScope.of(context);
    final status = state.chapterStatus(widget.index);
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              // ---- Hero ----
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    KenBurns(
                      child:
                          Image.asset(place.image, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + AppSpace.m,
                      left: AppSpace.l,
                      child: CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onDark: true,
                        semanticLabel: 'Back to trail',
                        onTap: () => context.pop(false),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + AppSpace.m,
                      right: AppSpace.l,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.m,
                            vertical: AppSpace.xs + 2),
                        decoration: BoxDecoration(
                          color: c.ink.withValues(alpha: 0.42),
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: AppSpace.xs + 1),
                            AppText(place.time, AppType.chip,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ---- Sheet ----
              Container(
                transform:
                    Matrix4.translationValues(0, -AppRadius.sheet, 0),
                decoration: BoxDecoration(
                  color: c.ground,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.sheet)),
                ),
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.screenGutter,
                    AppSpace.xxl,
                    AppSpace.screenGutter,
                    AppSize.cta + AppSpace.xxl * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(place.name, AppType.detailTitle),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.place_rounded,
                                      size: 14, color: accent),
                                  const SizedBox(width: AppSpace.xs),
                                  AppText(place.category, AppType.chip,
                                      color: c.muted),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (status == ChapterStatus.done)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpace.m,
                                vertical: AppSpace.xs + 2),
                            decoration: BoxDecoration(
                              color: c.success.softFill,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                  color: c.success.softBorder,
                                  width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 15, color: c.success),
                                const SizedBox(width: AppSpace.xs),
                                AppText('Visited', AppType.chip,
                                    color: c.success),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.l),
                    // ---- Rating row ----
                    _Card(
                      child: Row(
                        children: [
                          AppText('${place.rating}', AppType.screenTitle),
                          const SizedBox(width: AppSpace.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _Stars(
                                    rating: place.rating,
                                    color: c.gold,
                                    size: 16),
                                const SizedBox(height: 3),
                                AppText(place.reviewsLabel,
                                    AppType.metaSub,
                                    color: c.muted),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(Icons.trending_up_rounded,
                                  size: 18, color: accent),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 130,
                                child: AppText(
                                    place.popularity, AppType.caption,
                                    color: c.muted,
                                    align: TextAlign.end),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.l),
                    AppText(place.description, AppType.body,
                        color: c.muted),
                    const SizedBox(height: AppSpace.xl),
                    // ---- Highlights ----
                    AppText(place.highlightsTitle, AppType.sectionHeader),
                    const SizedBox(height: AppSpace.m),
                    Row(
                      children: [
                        for (final (i, (emoji, label, price))
                            in place.highlights.indexed) ...[
                          Expanded(
                            child: FadeRiseIn(
                              delay: Duration(milliseconds: 60 * i),
                              child: _Card(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpace.s,
                                    vertical: AppSpace.m),
                                child: Column(
                                  children: [
                                    Text(emoji,
                                        style: const TextStyle(
                                            fontSize: 26)),
                                    const SizedBox(
                                        height: AppSpace.xs + 2),
                                    AppText(label, AppType.caption,
                                        align: TextAlign.center),
                                    if (price != null) ...[
                                      const SizedBox(height: 2),
                                      AppText(price, AppType.caption,
                                          color: c.muted),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (i != place.highlights.length - 1)
                            const SizedBox(width: AppSpace.s + 2),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpace.xl),
                    // ---- Offer ----
                    if (place.offer != null) ...[
                      _OfferTicket(offer: place.offer!, accent: accent),
                      const SizedBox(height: AppSpace.xl),
                    ],
                    // ---- Reviews ----
                    AppText('Top reviews', AppType.sectionHeader),
                    const SizedBox(height: AppSpace.m),
                    for (final (author, stars, text) in place.reviews)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpace.m),
                        child: _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    backgroundColor: accent.softFill,
                                    child: AppText(author[0],
                                        AppType.chip,
                                        color: accent),
                                  ),
                                  const SizedBox(width: AppSpace.s + 2),
                                  AppText(author, AppType.itemTitle),
                                  const Spacer(),
                                  _Stars(
                                      rating: stars.toDouble(),
                                      color: c.gold,
                                      size: 13),
                                ],
                              ),
                              const SizedBox(height: AppSpace.s),
                              AppText('"$text"', AppType.body,
                                  color: c.muted),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpace.s),
                    // ---- Fun fact ----
                    _Card(
                      color: c.card,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_rounded,
                              color: c.goldDeep, size: 22),
                          const SizedBox(width: AppSpace.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                AppText(
                                    'Did you know?', AppType.itemTitle),
                                const SizedBox(height: 3),
                                AppText(place.funFact, AppType.body,
                                    color: c.muted),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    // ---- Mini quiz ----
                    _QuizCard(
                      place: place,
                      accent: accent,
                      picked: _quizPicked,
                      onPick: (i) {
                        if (_quizPicked != null) return;
                        setState(() => _quizPicked = i);
                        SoundService.instance.play(
                            i == place.quizAnswer
                                ? Sfx.success
                                : Sfx.wrong,
                            haptic: i == place.quizAnswer
                                ? Haptic.success
                                : Haptic.warning);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ---- Sticky CTA ----
          Positioned(
            left: AppSpace.screenGutter,
            right: AppSpace.screenGutter,
            bottom: AppSpace.xxl,
            child: switch (status) {
              ChapterStatus.current => PrimaryButton(
                  label: 'Mark Stop as Done',
                  sfx: Sfx.success,
                  onTap: () => context.pop(true),
                ),
              ChapterStatus.done => PrimaryButton(
                  label: 'Visited ✓',
                  enabled: false,
                  color: context.colors.success,
                ),
              ChapterStatus.locked => PrimaryButton(
                  label: 'Up next — finish earlier stops first',
                  enabled: false,
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding, this.color});

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: child,
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars(
      {required this.rating, required this.color, required this.size});

  final double rating;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : (rating - i >= 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded),
            color: color,
            size: size,
          ),
      ],
    );
  }
}

class _OfferTicket extends StatelessWidget {
  const _OfferTicket({required this.offer, required this.accent});

  final String offer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: accent.softFill,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: accent.softBorder, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.local_activity_rounded, color: accent, size: 24),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Current offer', AppType.caption, color: accent),
                const SizedBox(height: 2),
                AppText(offer, AppType.itemTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.place,
    required this.accent,
    required this.picked,
    required this.onPick,
  });

  final Place place;
  final Color accent;
  final int? picked;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final answered = picked != null;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🧠', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpace.s),
              AppText('Mini Quiz', AppType.sectionHeader),
              const Spacer(),
              AppText('Optional', AppType.caption, color: c.muted),
            ],
          ),
          const SizedBox(height: AppSpace.s + 2),
          AppText(place.quizQuestion, AppType.body),
          const SizedBox(height: AppSpace.m),
          for (final (i, option) in place.quizOptions.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s),
              child: Pressable(
                onTap: () => onPick(i),
                sfx: null,
                child: AnimatedContainer(
                  duration: AppMotion.base,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.l, vertical: AppSpace.m - 1),
                  decoration: BoxDecoration(
                    color: !answered
                        ? c.cardAlt
                        : i == place.quizAnswer
                            ? c.success
                            : i == picked
                                ? c.danger.withValues(alpha: 0.1)
                                : c.cardAlt,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: !answered
                          ? c.border
                          : i == place.quizAnswer
                              ? c.success
                              : i == picked
                                  ? c.danger
                                  : c.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        answered && i == place.quizAnswer
                            ? Icons.check_circle_rounded
                            : answered && i == picked
                                ? Icons.cancel_rounded
                                : Icons.circle_outlined,
                        size: 17,
                        color: answered && i == place.quizAnswer
                            ? Colors.white
                            : answered && i == picked
                                ? c.danger
                                : c.muted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: AppSpace.m),
                      AppText(
                        option,
                        AppType.itemTitle,
                        color: answered && i == place.quizAnswer
                            ? Colors.white
                            : c.ink,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          AnimatedSize(
            duration: AppMotion.base,
            curve: AppMotion.easeOut,
            child: answered
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: AppSpace.xs),
                    padding: const EdgeInsets.all(AppSpace.m),
                    decoration: BoxDecoration(
                      color: accent.softFill,
                      borderRadius:
                          BorderRadius.circular(AppRadius.small),
                    ),
                    child: AppText(place.quizFact, AppType.body,
                        color: c.ink),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
