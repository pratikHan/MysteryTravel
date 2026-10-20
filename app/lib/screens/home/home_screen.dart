import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
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
      'Every stop you finish earns a stamp for your passport! 🏅',
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
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          // ---- Miku's world: animated sky scene (finch1.PNG layout,
          // mountains + drifting clouds per the screen recording) ----
          _SkyScene(greeting: _greeting),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter, 0,
                AppSpace.screenGutter, AppSpace.xl),
            // The whole content column rides up over the scene's hill,
            // Finch-style.
            child: Transform.translate(
              offset: const Offset(0, -AppSpace.xxl),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // ---- Hero: most recent adventure (overlaps the scene) ----
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
          ),
        ],
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
// Miku's world — the animated sky scene (finch1.PNG top-of-screen
// layout; sun/cloud motion from the design1001 screen recording,
// mountains added per the brief).
// ---------------------------------------------------------------------------

class _SkyScene extends StatefulWidget {
  const _SkyScene({required this.greeting});

  final String greeting;

  @override
  State<_SkyScene> createState() => _SkySceneState();
}

class _SkySceneState extends State<_SkyScene>
    with SingleTickerProviderStateMixin {
  // One slow cycle drives cloud drift; the sun pulse rides a higher
  // frequency of the same phase.
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 36));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MotionSettings.reduced(context)) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: top + 316,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) => CustomPaint(
              painter: _SkyScenePainter(
                t: MotionSettings.reduced(context) ? 0.3 : _c.value,
                colors: c,
                topPadding: top,
              ),
            ),
          ),
          // Side Menu entry (design1001/side_menu1.png).
          Positioned(
            left: AppSpace.screenGutter - AppSpace.xs,
            top: top + AppSpace.s,
            child: Pressable(
              onTap: () => context.push('/menu'),
              child: Container(
                width: AppSize.iconButton,
                height: AppSize.iconButton,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: c.shadow(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(Icons.menu_rounded, size: 22, color: c.ink),
              ),
            ),
          ),
          Positioned(
            left: AppSpace.screenGutter,
            right: AppSpace.screenGutter,
            bottom: AppSpace.xxl + AppSpace.l,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LiveMascot(MascotState.idle, size: 104),
                    const SizedBox(height: 2),
                    AppText('Miku', AppType.caption, color: c.ink),
                  ],
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.xl),
                    child: _MikuBubble(message: widget.greeting),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyScenePainter extends CustomPainter {
  _SkyScenePainter({
    required this.t,
    required this.colors,
    required this.topPadding,
  });

  final double t;
  final AppColors colors;
  final double topPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Flat-illustration sunny palette, derived from tokens (groundTop
    // re-saturated so the sky reads sunny rather than overcast).
    final skyHsl = HSLColor.fromColor(colors.groundTop);
    final sky =
        skyHsl.withSaturation(0.62).withLightness(0.72).toColor();
    final skyLow =
        skyHsl.withSaturation(0.5).withLightness(0.85).toColor();
    final cloudWhite = Colors.white.withValues(alpha: 0.92);
    final cloudSoft = Colors.white.withValues(alpha: 0.55);
    final cloudDeep = Color.lerp(colors.pill, Colors.white, 0.42)!;
    final ridgeFar = Color.lerp(colors.pill, Colors.white, 0.62)!;
    final ridgeNear = Color.lerp(colors.pill, colors.groundTop, 0.45)!;
    final hill = Color.lerp(colors.ground, colors.success, 0.38)!;

    // Sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky, skyLow],
        ).createShader(Offset.zero & size),
    );

    // Sun with breathing halo rings (recording: pulsing glow).
    final pulse = math.sin(t * math.pi * 2 * 6);
    final sunCenter = Offset(w * 0.26, topPadding + 74);
    canvas.drawCircle(sunCenter, 66 + 3 * pulse,
        Paint()..color = Colors.white.withValues(alpha: 0.22));
    canvas.drawCircle(sunCenter, 46 + 2 * pulse,
        Paint()..color = Colors.white.withValues(alpha: 0.3));
    canvas.drawCircle(sunCenter, 27,
        Paint()..color = colors.gold.withValues(alpha: 0.55));
    canvas.drawCircle(sunCenter, 20, Paint()..color = colors.gold);

    // Small cloud crossing the whole sky.
    final smallX = -70 + ((t * 2) % 1.0) * (w + 140);
    _cloud(canvas, Offset(smallX, topPadding + 46), 14, cloudSoft);

    // Big soft clouds drifting gently (right mass like the recording).
    final drift1 = math.sin(t * math.pi * 2) * 14;
    _cloud(canvas, Offset(w * 0.9 + drift1, topPadding + 120), 52, cloudWhite);
    final drift2 = math.sin(t * math.pi * 2 + 2.2) * 10;
    _cloud(canvas, Offset(w * 0.18 + drift2, topPadding + 150), 34, cloudSoft);

    // Mountains: far ridge then near ridge.
    _ridge(canvas, w, h,
        base: h - 118,
        peakH: 74,
        peaks: const [0.12, 0.42, 0.74, 1.02],
        color: ridgeFar);
    _ridge(canvas, w, h,
        base: h - 96,
        peakH: 58,
        peaks: const [-0.06, 0.28, 0.6, 0.92],
        color: ridgeNear);

    // Deep-blue cumulus bank hugging the bottom-left (recording motif).
    final bob = math.sin(t * math.pi * 2 + 1) * 5;
    for (final (dx, dy, r) in [
      (-10.0, 0.0, 34.0),
      (34.0, 10.0, 26.0),
      (72.0 + bob, 18.0, 20.0),
    ]) {
      canvas.drawCircle(
          Offset(dx + bob * 0.4, h - 96 + dy), r, Paint()..color = cloudDeep);
    }

    // Foreground hill Miku sits on.
    canvas.drawOval(
      Rect.fromLTWH(-w * 0.2, h - 64, w * 1.4, 130),
      Paint()..color = hill,
    );
  }

  void _cloud(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(r * 0.95, r * 0.18), r * 0.78, paint);
    canvas.drawCircle(center.translate(-r * 0.95, r * 0.22), r * 0.72, paint);
    canvas.drawCircle(center.translate(r * 0.2, -r * 0.4), r * 0.6, paint);
  }

  void _ridge(Canvas canvas, double w, double h,
      {required double base,
      required double peakH,
      required List<double> peaks,
      required Color color}) {
    final path = Path()..moveTo(-10, base);
    for (final p in peaks) {
      final x = w * p;
      path.quadraticBezierTo(
          x - w * 0.09, base - peakH, x, base - peakH * 0.35);
      path.quadraticBezierTo(x + w * 0.07, base - peakH * 0.05, x + w * 0.14, base);
    }
    path
      ..lineTo(w + 10, base)
      ..lineTo(w + 10, h)
      ..lineTo(-10, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SkyScenePainter old) =>
      old.t != t || old.colors != colors;
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
                    AppSpace.l, AppSpace.l, 56, AppSpace.l),
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
                              Flexible(
                                child: AppText(saved.city, AppType.chip,
                                    color: c.muted,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
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
                              Flexible(
                                child: AppText(
                                  remaining > 0
                                      ? '$remaining more ${remaining == 1 ? 'place' : 'places'} to discover'
                                      : 'All places discovered!',
                                  AppType.chip,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
