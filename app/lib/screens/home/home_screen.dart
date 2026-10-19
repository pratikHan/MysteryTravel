import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
import '../../data/plan_fixtures.dart';
import '../../data/plan_models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/companion_bubble.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Home (reference: design1001/home.png, bottom tabs ignored — the app
/// shell provides ours).
///
/// Miku the live companion greets with an animated bubble; the most
/// recent adventure is the hero card with a progress ring; later
/// adventures stack below as compact cards (See all past 4); then the
/// streak bar, the three action cards, and "Start today's quest".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAll = false;
  int _bubbleIndex = 0;
  Timer? _bubbleTimer;

  static const _maxVisible = 4;

  @override
  void initState() {
    super.initState();
    // Miku keeps talking: rotate the bubble line every few seconds —
    // each change replays the typing-dots animation.
    _bubbleTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted) setState(() => _bubbleIndex++);
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    final opener = hour < 12
        ? 'Good morning, explorer!'
        : hour < 18
            ? 'Good afternoon, explorer!'
            : 'Good evening, explorer!';
    final lines = [
      '$opener\nA new day and new little surprises are waiting for you. 💛',
      'Your streak is on fire — ${PlanFixtures.streakCount} days and counting! 🔥',
      'Two taps and today\'s quest begins. Ready when you are! 🧭',
    ];
    return lines[_bubbleIndex % lines.length];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final adventures = state.savedAdventures;
    final hero = adventures.isEmpty ? null : adventures.first;
    final rest = adventures.length <= 1
        ? <SavedAdventure>[]
        : adventures.sublist(1);
    final visibleRest =
        _showAll ? rest : rest.take(_maxVisible - 1).toList();
    final hiddenCount = rest.length - (_maxVisible - 1);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
              AppSpace.l, AppSpace.screenGutter, AppSpace.xl),
          physics: const BouncingScrollPhysics(),
          children: [
            // ---- Miku greets ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const LiveMascot(MascotState.idle, size: 80),
                    const SizedBox(height: 2),
                    AppText('Miku', AppType.caption, color: c.muted),
                  ],
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpace.xs),
                    child: _MikuBubble(message: _greeting),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            // ---- Hero: most recent adventure ----
            if (hero != null) ...[
              _HeroAdventureCard(saved: hero),
              const SizedBox(height: AppSpace.m),
              for (final (i, saved) in visibleRest.indexed) ...[
                FadeRiseIn(
                  delay: Duration(milliseconds: 60 * i),
                  child: _CompactAdventureCard(saved: saved),
                ),
                const SizedBox(height: AppSpace.s + 2),
              ],
              if (hiddenCount > 0 && !_showAll)
                Pressable(
                  onTap: () => setState(() => _showAll = true),
                  sfx: Sfx.pop,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: c.border, width: 1.5),
                    ),
                    child: Center(
                      child: AppText(
                          'See all (${adventures.length} adventures)',
                          AppType.itemTitle,
                          color: c.muted),
                    ),
                  ),
                ),
              if (_showAll && hiddenCount > 0)
                Pressable(
                  onTap: () => setState(() => _showAll = false),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpace.s),
                      child: AppText('Show less', AppType.chip,
                          color: c.muted),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpace.l),
            ],
            // ---- Streak bar ----
            _StreakBar(),
            const SizedBox(height: AppSpace.l),
            // ---- Action cards ----
            _ActionCard(
              emoji: '🗺️',
              title: 'Mystery Adventure',
              blurb:
                  'Follow today\'s clues and discover hidden gems around the city.',
              pills: const ['🔮 4 stops', '🕐 ~4–5 hrs'],
              highlighted: true,
              onTap: () {
                AppScope.read(context)
                    .setExplorationMode(ExplorationMode.mystery);
                context.go('/plan');
              },
            ),
            const SizedBox(height: AppSpace.s + 2),
            _ActionCard(
              emoji: '📅',
              title: 'Plan My Day',
              blurb: 'Create a custom adventure with your favorite themes.',
              pills: [
                if (state.plan.city.isNotEmpty)
                  '📍 ${state.plan.city}'
                else
                  '📍 Pick a city',
                '🗓️ Any date',
              ],
              onTap: () {
                AppScope.read(context)
                    .setExplorationMode(ExplorationMode.planned);
                context.go('/plan');
              },
            ),
            const SizedBox(height: AppSpace.s + 2),
            _ActionCard(
              emoji: '🏅',
              title: 'Rewards',
              blurb: 'See your stamps, streaks and special surprises.',
              pills: const ['🎁 5 stamps collected'],
              onTap: () => context.go('/passport'),
            ),
            const SizedBox(height: AppSpace.xl),
            // ---- CTA ----
            BouncyPressable(
              sfx: Sfx.success,
              haptic: Haptic.medium,
              onTap: () {
                AppScope.read(context).startSavedAdventure();
                context.go('/adventure');
              },
              child: Container(
                height: AppSize.cta,
                decoration: BoxDecoration(
                  color: c.pill,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: [
                    BoxShadow(
                        color: c.shadow(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🧭', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: AppSpace.s),
                    AppText('Start today\'s quest', AppType.cta,
                        color: c.onDark),
                    const SizedBox(width: AppSpace.s),
                    Icon(Icons.arrow_forward_rounded,
                        color: c.onDark, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Miku's bubble — CompanionBubble's typing animation without the
// built-in mascot (Miku stands beside it, alive).
// ---------------------------------------------------------------------------

class _MikuBubble extends StatelessWidget {
  const _MikuBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // Reuse CompanionBubble's typing behavior via a zero-size mascot.
    return CompanionBubble(
      message: message,
      mascotSize: 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Adventure cards
// ---------------------------------------------------------------------------

const _weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _dateLabel(DateTime d) =>
    '${_weekdaysShort[d.weekday - 1]}, ${_monthsShort[d.month - 1]} ${d.day}';

class _ModePill extends StatelessWidget {
  const _ModePill({required this.mode, this.compact = false});

  final ExplorationMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mystery = mode == ExplorationMode.mystery;
    final tint = mystery ? context.accents.night : context.accents.peaceful;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpace.s : AppSpace.m,
          vertical: compact ? 2 : AppSpace.xs),
      decoration: BoxDecoration(
        color: tint.softFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: tint.softBorder, width: 1),
      ),
      child: AppText(
        compact
            ? (mystery ? '🔮 Mystery' : '🗺️ Planned')
            : (mystery ? '🔮 Mystery mode' : '🗺️ Planned mode'),
        AppType.caption,
        color: Color.lerp(tint, c.ink, 0.3)!,
      ),
    );
  }
}

/// The big most-recent adventure card: progress ring + art + details.
class _HeroAdventureCard extends StatelessWidget {
  const _HeroAdventureCard({required this.saved});

  final SavedAdventure saved;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final total = saved.playlist.items.length;
    final done = state.adventureComplete
        ? total
        : state.currentChapter.clamp(0, total);
    final remaining = total - done;
    return Pressable(
      onTap: () => context.go('/adventure'),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.card + 4),
          boxShadow: [
            BoxShadow(
                color: c.shadow(0.12),
                blurRadius: 16,
                offset: const Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card + 4),
          child: Stack(
            children: [
              // Scenic art fading in from the right.
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 150,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0, 0.65],
                    colors: [Colors.transparent, Colors.black],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(saved.playlist.scene,
                      fit: BoxFit.cover, alignment: Alignment.centerRight),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.l, AppSpace.l, 68, AppSpace.l),
                child: Row(
                  children: [
                    _ProgressRing(done: done, total: total),
                    const SizedBox(width: AppSpace.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.place_rounded,
                                  size: 13, color: context.accents.stories),
                              const SizedBox(width: 3),
                              AppText(saved.city, AppType.chip,
                                  color: c.muted),
                            ],
                          ),
                          const SizedBox(height: 3),
                          AppText(saved.playlist.title, AppType.sectionHeader,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: AppSpace.s),
                          _ModePill(mode: saved.mode),
                          const SizedBox(height: AppSpace.s + 2),
                          Row(
                            children: [
                              AppText(
                                remaining > 0
                                    ? '$remaining more ${remaining == 1 ? 'place' : 'places'} to discover'
                                    : 'All places discovered!',
                                AppType.chip,
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  size: 16, color: c.muted),
                            ],
                          ),
                        ],
                      ),
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

/// Animated circular progress: arc fills on entry.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final target = total == 0 ? 0.0 : done / total;
    final reduced = MotionSettings.reduced(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? target : 0, end: target),
      duration: AppMotion.barFill,
      curve: AppMotion.easeOut,
      builder: (context, t, child) => CustomPaint(
        painter: _RingPainter(
          progress: t,
          track: c.lockedFill,
          fill: c.success,
        ),
        child: child,
      ),
      child: SizedBox(
        width: 108,
        height: 108,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔭', style: TextStyle(fontSize: 16)),
            AppText('$done / $total', AppType.formHeader),
            AppText('stops today', AppType.caption, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      final fillPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * math.pi * 2,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.fill != fill;
}

/// Later adventures: same pattern, compact.
class _CompactAdventureCard extends StatelessWidget {
  const _CompactAdventureCard({required this.saved});

  final SavedAdventure saved;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: () => context.go('/adventure'),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.m - 2),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(saved.playlist.heroImage,
                  width: 46, height: 46, fit: BoxFit.cover),
            ),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(saved.playlist.title, AppType.itemTitle,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.place_rounded,
                          size: 11, color: context.accents.stories),
                      const SizedBox(width: 2),
                      Flexible(
                        child: AppText(saved.city, AppType.caption,
                            color: c.muted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: AppSpace.s),
                      Icon(Icons.event_rounded, size: 11, color: c.muted),
                      const SizedBox(width: 2),
                      Flexible(
                        child: AppText(
                            _dateLabel(saved.openOn), AppType.caption,
                            color: c.muted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s),
            _ModePill(mode: saved.mode, compact: true),
            Icon(Icons.chevron_right_rounded, size: 18, color: c.muted),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak bar
// ---------------------------------------------------------------------------

class _StreakBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.m, vertical: AppSpace.m),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpace.xs + 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('${PlanFixtures.streakCount}', AppType.sectionHeader),
              AppText('day streak', AppType.caption, color: c.muted),
            ],
          ),
          const Spacer(),
          for (final (label, done, isToday) in PlanFixtures.streakWeek)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  isToday
                      ? PopIn(
                          peak: 1.3,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: c.gold.softFill,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.gold, width: 2),
                            ),
                            child: Icon(Icons.star_rounded,
                                size: 14, color: c.goldDeep),
                          ),
                        )
                      : Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: done ? c.success : c.lockedFill,
                            shape: BoxShape.circle,
                          ),
                          child: done
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                  const SizedBox(height: 2),
                  AppText(label, AppType.caption,
                      color: isToday ? c.goldDeep : c.muted),
                ],
              ),
            ),
          const Spacer(),
          const Text('🎁', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpace.xs),
          SizedBox(
            width: 64,
            child: AppText('1 more day for a surprise!', AppType.caption,
                color: c.muted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action cards
// ---------------------------------------------------------------------------

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.blurb,
    required this.pills,
    required this.onTap,
    this.highlighted = false,
  });

  final String emoji;
  final String title;
  final String blurb;
  final List<String> pills;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.l),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: highlighted ? c.gold : c.border,
            width: highlighted ? 2 : 1.5,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                      color: c.gold.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ]
              : null,
        ),
        child: Row(
          children: [
            Floaty(child: Text(emoji, style: const TextStyle(fontSize: 34))),
            const SizedBox(width: AppSpace.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, AppType.sectionHeader),
                  const SizedBox(height: 2),
                  AppText(blurb, AppType.chip, color: c.muted),
                  const SizedBox(height: AppSpace.s),
                  Wrap(
                    spacing: AppSpace.s,
                    runSpacing: AppSpace.xs,
                    children: [
                      for (final pill in pills)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.s + 1, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.cardAlt,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border:
                                Border.all(color: c.border, width: 1),
                          ),
                          child: AppText(pill, AppType.caption),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: highlighted ? c.gold : c.cardAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 18, color: highlighted ? Colors.white : c.ink),
            ),
          ],
        ),
      ),
    );
  }
}
