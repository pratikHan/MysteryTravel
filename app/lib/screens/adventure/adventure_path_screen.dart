import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/confetti.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';
import 'pause_dialog.dart';

/// The adventure trail (reference: design/new_adv_path.png).
///
/// One long scrollable illustrated scene — morning sky and bridge at the
/// top, park greens, a golden band, mist at the bottom — with a winding
/// dashed route through four fully-revealed place cards. Marking a stop
/// done animates the route forward to the next stop. Everything ambient
/// (clouds, trees, fog, glow) drifts gently; scenery layers parallax
/// against the scroll. All loops stop under reduced motion.
class AdventurePathScreen extends StatefulWidget {
  const AdventurePathScreen({super.key});

  @override
  State<AdventurePathScreen> createState() => _AdventurePathScreenState();
}

class _AdventurePathScreenState extends State<AdventurePathScreen>
    with TickerProviderStateMixin {
  final _scroll = ScrollController();

  /// One slow repeating phase drives every ambient motion.
  late final AnimationController _ambient = AnimationController(
      vsync: this, duration: const Duration(seconds: 14));

  /// Runs once per completed stop: colors the next route segment and
  /// walks a glow dot along it.
  late final AnimationController _travel = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  bool _traveling = false;
  bool _celebrating = false;

  /// Normalized node anchors along the scene, top → bottom,
  /// alternating sides like the reference.
  static const _anchors = [
    Offset(0.26, 0.255),
    Offset(0.70, 0.42),
    Offset(0.28, 0.585),
    Offset(0.70, 0.75),
  ];
  static const _finish = Offset(0.46, 0.875);

  /// Dev hook for screenshots: boots the trail pre-scrolled, as a
  /// percentage, e.g. `--dart-define=TRAIL_SCROLL=50`. Debug only.
  static const _devScrollPct = kDebugMode
      ? int.fromEnvironment('TRAIL_SCROLL', defaultValue: 0)
      : 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MotionSettings.reduced(context)) _ambient.repeat();
    });
    if (_devScrollPct > 0) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _scroll.hasClients) {
          _scroll.jumpTo(
              _scroll.position.maxScrollExtent * _devScrollPct / 100);
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ambient.dispose();
    _travel.dispose();
    super.dispose();
  }

  double _sceneHeight(BoxConstraints box) =>
      math.max(2250, box.maxHeight * 2.55);

  Future<void> _openPlace(int index) async {
    final done = await context.push<bool>('/stop/$index');
    if (done == true && mounted) _completeStop(index);
  }

  /// The done ceremony: check pop + confetti, route segment animates to
  /// the next stop, then focus (and the scroll) travels there.
  Future<void> _completeStop(int index) async {
    final state = AppScope.read(context);
    if (_traveling || state.chapterStatus(index) != ChapterStatus.current) {
      return;
    }
    final isLast = index >= Fixtures.places.length - 1;
    SoundService.instance.play(Sfx.success, haptic: Haptic.success);
    setState(() {
      _traveling = true;
      _celebrating = true;
    });

    if (MotionSettings.reduced(context)) {
      _travel.value = 1;
    } else {
      await _travel.forward(from: 0);
    }
    if (!mounted) return;

    state.completeCurrentChapter();
    setState(() {
      _traveling = false;
      _celebrating = false;
    });
    _travel.value = 0;

    if (isLast) {
      SoundService.instance.play(Sfx.fanfare, haptic: Haptic.heavy);
      context.push('/chapter/stamp');
    } else {
      SoundService.instance.play(Sfx.pop, haptic: Haptic.light);
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    if (!_scroll.hasClients) return;
    final state = AppScope.read(context);
    final box = context.size;
    if (box == null) return;
    final sceneH = _scroll.position.maxScrollExtent + box.height;
    final target = (_anchors[state.currentChapter].dy * sceneH -
            box.height * 0.42)
        .clamp(0.0, _scroll.position.maxScrollExtent);
    if (MotionSettings.reduced(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(target,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic);
    }
  }

  void _openMenu() {
    final c = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.ground,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.screenGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (icon, label, action) in [
                (Icons.pause_circle_outline_rounded, 'Pause adventure',
                    () => showPauseDialog(context)),
                (Icons.format_list_bulleted_rounded, 'All stops',
                    () => context.push('/journey/chapters')),
                (Icons.menu_book_rounded, 'Adventure summary',
                    () => context.push('/journey/summary')),
              ])
                Pressable(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    action();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.m, horizontal: AppSpace.s),
                    child: Row(
                      children: [
                        Icon(icon, size: 21, color: c.ink),
                        const SizedBox(width: AppSpace.l),
                        AppText(label, AppType.rowTitle),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = context.accents.peaceful;
    final state = AppScope.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final sceneH = _sceneHeight(box);
          final nodes = [
            for (final a in _anchors) Offset(a.dx * w, a.dy * sceneH),
          ];
          final finish = Offset(_finish.dx * w, _finish.dy * sceneH);
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: w,
                  height: sceneH,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation:
                              Listenable.merge([_scroll, _ambient, _travel]),
                          builder: (context, child) => CustomPaint(
                            painter: _TrailScenePainter(
                              colors: c,
                              accent: accent,
                              nodes: nodes,
                              finish: finish,
                              coloredUpTo: state.adventureComplete
                                  ? nodes.length - 1 + _travel.value
                                  : state.currentChapter +
                                      (_traveling ? _travel.value : 0),
                              traveling: _traveling,
                              travelT: _travel.value,
                              ambient: _ambient.value,
                              scrollOffset: _scroll.hasClients
                                  ? _scroll.offset
                                  : 0,
                            ),
                          ),
                        ),
                      ),
                      // ---- Welcome scene at the top ----
                      Positioned(
                        top: sceneH * 0.055,
                        left: AppSpace.screenGutter,
                        right: AppSpace.screenGutter,
                        child: _WelcomeHeader(),
                      ),
                      // ---- Stops ----
                      for (final (i, pos) in nodes.indexed) ...[
                        Positioned(
                          left: pos.dx - _TrailNode.size / 2,
                          top: pos.dy - _TrailNode.size / 2,
                          child: _TrailNode(
                            index: i,
                            status: _visualStatus(state, i),
                            ambient: _ambient,
                            onTap: () => _openPlace(i),
                          ),
                        ),
                        Positioned(
                          left: pos.dx < w / 2
                              ? pos.dx + _TrailNode.size * 0.75
                              : null,
                          right: pos.dx >= w / 2
                              ? (w - pos.dx) + _TrailNode.size * 0.75
                              : null,
                          top: pos.dy - 46,
                          child: _PlaceCard(
                            place: Fixtures.places[i],
                            status: _visualStatus(state, i),
                            width: w * 0.52,
                            onTap: () => _openPlace(i),
                            onDone: () => _completeStop(i),
                          ),
                        ),
                      ],
                      // ---- Mascot walks beside the current stop ----
                      // Mascot stands on the card-free side of the node.
                      if (!state.adventureComplete && !_traveling)
                        Positioned(
                          left: nodes[state.currentChapter].dx < w / 2
                              ? math.max(
                                  AppSpace.xs,
                                  nodes[state.currentChapter].dx - 100)
                              : nodes[state.currentChapter].dx + 12,
                          top: nodes[state.currentChapter].dy -
                              _TrailNode.size / 2 -
                              100,
                          child: const Mascot(MascotState.walking, size: 88),
                        ),
                      // ---- Finish ----
                      Positioned(
                        left: finish.dx - 60,
                        top: finish.dy - 24,
                        width: 120,
                        child: _FinishBadge(
                            complete: state.adventureComplete),
                      ),
                      Positioned(
                        left: AppSpace.prefsGutter,
                        right: AppSpace.prefsGutter,
                        top: sceneH * 0.945,
                        child: Column(
                          children: [
                            AppText(
                              state.adventureComplete
                                  ? 'All stops explored —\nenjoy the view!'
                                  : 'Finish all stops to earn\nyour passport stamp!',
                              AppType.body,
                              color: c.muted,
                              align: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpace.s),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                color: c.muted, size: 22),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _Header(onMenu: _openMenu),
              if (_celebrating)
                const Positioned.fill(
                    child: ConfettiBurst(pieces: 26)),
            ],
          );
        },
      ),
    );
  }

  /// During the travel animation the just-finished stop already reads as
  /// done, while the next stop stays "up next" until the glow arrives.
  ChapterStatus _visualStatus(AppState state, int i) {
    final status = state.chapterStatus(i);
    if (_traveling && status == ChapterStatus.current) {
      return ChapterStatus.done;
    }
    return status;
  }
}

// ---------------------------------------------------------------------------
// Header + welcome
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpace.l,
          MediaQuery.paddingOf(context).top + AppSpace.s,
          AppSpace.l,
          AppSpace.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.groundTop.withValues(alpha: 0.95),
            c.groundTop.withValues(alpha: 0),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Back to Home',
            onTap: () => context.go('/home'),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(Fixtures.activeAdventureTitle, AppType.pageTitle),
                const SizedBox(height: 1),
                AppText(
                  '${Fixtures.activeAdventureCity} · ${Fixtures.activeAdventureDuration}',
                  AppType.chip,
                  color: c.muted,
                ),
              ],
            ),
          ),
          CircleIconButton(
            icon: Icons.menu_rounded,
            semanticLabel: 'Adventure menu',
            onTap: onMenu,
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Mascot(MascotState.idle, size: 104),
        const SizedBox(width: AppSpace.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpeechBubble(Fixtures.activeAdventureWelcome, maxWidth: 220),
              const SizedBox(height: AppSpace.s + 2),
              Floaty(
                delay: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.m, vertical: AppSpace.s - 1),
                  decoration: BoxDecoration(
                    color: c.card.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: c.border, width: 1.5),
                  ),
                  child: AppText(
                    Fixtures.activeAdventureMeta,
                    AppType.caption,
                    color: c.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Nodes + cards
// ---------------------------------------------------------------------------

class _TrailNode extends StatelessWidget {
  const _TrailNode({
    required this.index,
    required this.status,
    required this.ambient,
    required this.onTap,
  });

  static const double size = 52;

  final int index;
  final ChapterStatus status;
  final Animation<double> ambient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = context.accents.peaceful;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.tap,
      child: switch (status) {
        ChapterStatus.done => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c.success,
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: 3.5),
              boxShadow: [
                BoxShadow(
                    color: c.shadow(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 26),
          ),
        ChapterStatus.current => AnimatedBuilder(
            animation: ambient,
            builder: (context, child) {
              final pulse = MotionSettings.reduced(context)
                  ? 0.5
                  : 0.5 + 0.5 * math.sin(ambient.value * math.pi * 6);
              return Container(
                width: size + 8,
                height: size + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.gold.withValues(alpha: 0.35 + 0.3 * pulse),
                      blurRadius: 14 + 10 * pulse,
                      spreadRadius: 1 + 3 * pulse,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: c.gold,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 3.5),
              ),
              child: Center(
                child: AppText('${index + 1}', AppType.statNumber,
                    color: Colors.white),
              ),
            ),
          ),
        ChapterStatus.locked => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: accent.softFill,
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: 3),
              boxShadow: [
                BoxShadow(
                    color: c.shadow(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Center(
              child: AppText('${index + 1}', AppType.sectionHeader,
                  color: accent),
            ),
          ),
      },
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.status,
    required this.width,
    required this.onTap,
    required this.onDone,
  });

  final Place place;
  final ChapterStatus status;
  final double width;
  final VoidCallback onTap;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = context.accents.peaceful;
    final current = status == ChapterStatus.current;
    final done = status == ChapterStatus.done;
    return SizedBox(
      width: width,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpace.m - 2),
          decoration: BoxDecoration(
            color: done
                ? c.surface.withValues(alpha: 0.88)
                : c.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: current ? c.gold : c.border,
              width: current ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: c.shadow(current ? 0.18 : 0.1),
                blurRadius: current ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Image.asset(place.image,
                        width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: AppSpace.s + 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(place.name, AppType.itemTitle,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        AppText(place.category, AppType.caption,
                            color: c.muted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (done)
                    Icon(Icons.check_circle_rounded,
                        color: c.success, size: 18),
                ],
              ),
              const SizedBox(height: AppSpace.s),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: c.gold, size: 14),
                  const SizedBox(width: 2),
                  Flexible(
                    child: AppText(
                        '${place.rating} (${place.reviewsLabel.split(' ').first})',
                        AppType.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Spacer(),
                  Icon(Icons.schedule_rounded, size: 12, color: c.muted),
                  const SizedBox(width: 2),
                  AppText(place.time, AppType.caption,
                      maxLines: 1, color: c.muted),
                ],
              ),
              const SizedBox(height: AppSpace.xs),
              AppText(place.specialty, AppType.caption,
                  color: c.muted,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if (current) ...[
                const SizedBox(height: AppSpace.s + 1),
                Row(
                  children: [
                    Expanded(
                      child: Pressable(
                        onTap: onDone,
                        sfx: null,
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: AppSpace.xs),
                              AppText('Done', AppType.chip,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.s),
                    AppText('Details', AppType.caption, color: c.muted),
                    Icon(Icons.chevron_right_rounded,
                        size: 14, color: c.muted),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishBadge extends StatelessWidget {
  const _FinishBadge({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Floaty(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: complete ? c.gold : c.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: 3),
              boxShadow: [
                BoxShadow(
                    color: c.shadow(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: complete ? Colors.white : c.goldDeep,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          AppText(complete ? 'Stamp earned!' : 'Your stamp',
              AppType.caption,
              color: c.muted, align: TextAlign.center),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scene painter
// ---------------------------------------------------------------------------

class _TrailScenePainter extends CustomPainter {
  _TrailScenePainter({
    required this.colors,
    required this.accent,
    required this.nodes,
    required this.finish,
    required this.coloredUpTo,
    required this.traveling,
    required this.travelT,
    required this.ambient,
    required this.scrollOffset,
  });

  final AppColors colors;
  final Color accent;
  final List<Offset> nodes;
  final Offset finish;

  /// Route is tinted from the start through node index `coloredUpTo`
  /// (fractional while a travel animation runs).
  final double coloredUpTo;
  final bool traveling;
  final double travelT;

  /// 0..1 repeating phase for every ambient motion.
  final double ambient;
  final double scrollOffset;

  double get _wave => math.sin(ambient * math.pi * 2);

  @override
  void paint(Canvas canvas, Size size) {
    _paintBands(canvas, size);
    _paintBridge(canvas, size);
    _paintHills(canvas, size);
    _paintTrees(canvas, size);
    _paintHouses(canvas, size);
    _paintRoute(canvas, size);
    _paintClouds(canvas, size);
    _paintFog(canvas, size);
  }

  void _paintBands(Canvas canvas, Size size) {
    // Morning sky → park green → golden hour → soft mist.
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.groundTop,
          Color.lerp(colors.ground, accent, 0.14)!,
          Color.lerp(colors.ground, accent, 0.08)!,
          Color.lerp(colors.ground, colors.gold, 0.14)!,
          Color.lerp(colors.groundTop, colors.surface, 0.35)!,
        ],
        stops: const [0, 0.24, 0.5, 0.72, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradient);

    // Water strip under the bridge at the top.
    final water = Paint()
      ..color = Color.lerp(colors.groundTop, colors.pill, 0.25)!
          .withValues(alpha: 0.5);
    final waterY = size.height * 0.155 + _wave * 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, waterY, size.width, size.height * 0.035),
        const Radius.circular(12),
      ),
      water,
    );
  }

  void _paintBridge(Canvas canvas, Size size) {
    final bridgeColor = Color.lerp(colors.ground, colors.danger, 0.45)!
        .withValues(alpha: 0.75);
    final paint = Paint()
      ..color = bridgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final y = size.height * 0.155;
    final deck = y + 6;
    canvas.drawLine(Offset(0, deck), Offset(size.width, deck), paint);
    // Two towers + draped cables.
    for (final tx in [size.width * 0.3, size.width * 0.72]) {
      canvas.drawLine(Offset(tx, deck + 4), Offset(tx, deck - 34), paint);
      canvas.drawLine(
          Offset(tx - 7, deck - 26), Offset(tx + 7, deck - 26), paint);
    }
    final cable = Path()
      ..moveTo(0, deck - 18)
      ..quadraticBezierTo(size.width * 0.15, deck + 2, size.width * 0.3,
          deck - 32)
      ..quadraticBezierTo(
          size.width * 0.51, deck + 10, size.width * 0.72, deck - 32)
      ..quadraticBezierTo(
          size.width * 0.88, deck + 2, size.width, deck - 18);
    canvas.drawPath(cable, paint..strokeWidth = 2);
  }

  void _paintHills(Canvas canvas, Size size) {
    final drift = scrollOffset * 0.06;
    for (final (frac, tint, amp) in [
      (0.21, 0.16, 40.0),
      (0.44, 0.22, 34.0),
      (0.66, 0.16, 38.0),
    ]) {
      final baseY = size.height * frac + drift;
      final paint = Paint()
        ..color = Color.lerp(colors.ground, accent, tint)!
            .withValues(alpha: 0.8);
      final path = Path()
        ..moveTo(0, baseY)
        ..quadraticBezierTo(size.width * 0.28, baseY - amp,
            size.width * 0.55, baseY - amp * 0.2)
        ..quadraticBezierTo(size.width * 0.8, baseY + amp * 0.4,
            size.width, baseY - amp * 0.7)
        ..lineTo(size.width, baseY + size.height * 0.1)
        ..lineTo(0, baseY + size.height * 0.1)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintTrees(Canvas canvas, Size size) {
    final leaf = Color.lerp(colors.ground, accent, 0.5)!;
    final leafDark = Color.lerp(colors.ground, accent, 0.65)!;
    final trunk = Paint()
      ..color = Color.lerp(colors.ground, colors.goldDeep, 0.55)!;
    // (x, y, scale, round?) — rounds in the park, pines near the mist.
    const specs = [
      (0.08, 0.205, 1.1, true),
      (0.9, 0.23, 0.9, true),
      (0.12, 0.33, 0.85, true),
      (0.88, 0.37, 1.15, true),
      (0.07, 0.47, 1.0, true),
      (0.9, 0.5, 0.8, true),
      (0.1, 0.62, 0.9, true),
      (0.88, 0.65, 1.0, true),
      (0.08, 0.79, 1.0, false),
      (0.2, 0.815, 0.75, false),
      (0.85, 0.8, 0.9, false),
      (0.93, 0.83, 0.7, false),
      (0.3, 0.9, 0.8, false),
      (0.72, 0.915, 0.95, false),
    ];
    for (final (i, (fx, fy, s, round)) in specs.indexed) {
      final x = size.width * fx;
      final y = size.height * fy;
      final sway = math.sin(ambient * math.pi * 2 + i * 1.3) * 0.022;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(sway);
      if (round) {
        canvas.drawRect(Rect.fromLTWH(-2.5 * s, -6 * s, 5 * s, 20 * s), trunk);
        canvas.drawCircle(Offset(0, -20 * s), 15 * s,
            Paint()..color = leafDark.withValues(alpha: 0.9));
        canvas.drawCircle(Offset(-10 * s, -13 * s), 11 * s,
            Paint()..color = leaf.withValues(alpha: 0.9));
        canvas.drawCircle(Offset(10 * s, -13 * s), 11 * s,
            Paint()..color = leaf.withValues(alpha: 0.9));
      } else {
        canvas.drawRect(Rect.fromLTWH(-2 * s, 0, 4 * s, 10 * s), trunk);
        final pine = Paint()..color = leafDark.withValues(alpha: 0.85);
        for (final (dy, w) in [(0.0, 15.0), (-12.0, 12.0), (-22.0, 9.0)]) {
          final p = Path()
            ..moveTo(-w * s, dy * s)
            ..lineTo(w * s, dy * s)
            ..lineTo(0, (dy - 18) * s)
            ..close();
          canvas.drawPath(p, pine);
        }
      }
      canvas.restore();
    }
  }

  void _paintHouses(Canvas canvas, Size size) {
    // A few tiny gabled houses in the golden band.
    final wall = Paint()
      ..color = Color.lerp(colors.card, colors.gold, 0.3)!;
    final roof = Paint()
      ..color = Color.lerp(colors.ground, colors.danger, 0.4)!;
    const spots = [(0.16, 0.695, 1.0), (0.84, 0.71, 0.85), (0.2, 0.74, 0.7)];
    for (final (fx, fy, s) in spots) {
      final x = size.width * fx;
      final y = size.height * fy;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(x, y), width: 34 * s, height: 26 * s),
            const Radius.circular(3)),
        wall,
      );
      final r = Path()
        ..moveTo(x - 20 * s, y - 13 * s)
        ..lineTo(x + 20 * s, y - 13 * s)
        ..lineTo(x, y - 30 * s)
        ..close();
      canvas.drawPath(r, roof);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(x, y + 2 * s), width: 7 * s, height: 10 * s),
          Paint()..color = colors.pill.withValues(alpha: 0.5));
    }
  }

  /// Builds the segment paths: an intro lead-in, node-to-node curves,
  /// then a final curve to the stamp badge.
  List<Path> _segments(Size size) {
    final segs = <Path>[];
    final startPoint = Offset(nodes.first.dx, nodes.first.dy - 110);
    segs.add(Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..quadraticBezierTo(startPoint.dx - 14, (startPoint.dy + nodes.first.dy) / 2,
          nodes.first.dx, nodes.first.dy));
    var prev = nodes.first;
    for (final node in nodes.skip(1).followedBy([finish])) {
      final mid = Offset((prev.dx + node.dx) / 2, (prev.dy + node.dy) / 2);
      final bulge = (node.dx > prev.dx ? -1 : 1) * size.width * 0.16;
      segs.add(Path()
        ..moveTo(prev.dx, prev.dy)
        ..quadraticBezierTo(mid.dx + bulge, mid.dy, node.dx, node.dy));
      prev = node;
    }
    return segs;
  }

  void _paintRoute(Canvas canvas, Size size) {
    final segs = _segments(size);
    final roadOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(colors.card, colors.goldDeep, 0.2)!;
    final roadInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 23
      ..strokeCap = StrokeCap.round
      ..color = colors.card;
    for (final seg in segs) {
      canvas.drawPath(seg, roadOuter);
    }
    for (final seg in segs) {
      canvas.drawPath(seg, roadInner);
    }

    // Traveled tint: segments [0 .. coloredUpTo+1) — seg 0 is the intro.
    final traveled = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 23
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.4);
    final fullSegs = (coloredUpTo + 1).floor().clamp(0, segs.length);
    final partial = (coloredUpTo + 1) - fullSegs;
    for (var i = 0; i < fullSegs; i++) {
      canvas.drawPath(segs[i], traveled);
    }
    Offset? tip;
    if (partial > 0 && fullSegs < segs.length) {
      final metric = segs[fullSegs].computeMetrics().first;
      final sub = metric.extractPath(0, metric.length * partial);
      canvas.drawPath(sub, traveled);
      tip = metric
          .getTangentForOffset(metric.length * partial)
          ?.position;
    }

    // White dashes on top.
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = colors.surface.withValues(alpha: 0.85);
    for (final seg in segs) {
      for (final metric in seg.computeMetrics()) {
        var d = 4.0;
        while (d < metric.length) {
          canvas.drawPath(
              metric.extractPath(d, math.min(d + 8, metric.length)), dash);
          d += 20;
        }
      }
    }

    // Glow dot at the traveling tip.
    if (traveling && tip != null) {
      canvas.drawCircle(
          tip,
          11,
          Paint()
            ..color = accent.withValues(alpha: 0.35)
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(tip, 6, Paint()..color = accent);
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.surface.withValues(alpha: 0.7);
    const specs = [
      (0.16, 0.035, 1.0, 0.0),
      (0.75, 0.07, 1.25, 2.1),
      (0.3, 0.3, 0.8, 4.2),
      (0.82, 0.46, 1.0, 1.1),
      (0.2, 0.55, 0.9, 3.0),
    ];
    final parallax = scrollOffset * 0.18;
    for (final (fx, fy, s, phase) in specs) {
      final drift = math.sin(ambient * math.pi * 2 + phase) * 10;
      final center = Offset(
          size.width * fx + drift, size.height * fy + parallax);
      canvas.drawCircle(center, 22 * s, paint);
      canvas.drawCircle(center.translate(20 * s, 4), 16 * s, paint);
      canvas.drawCircle(center.translate(-20 * s, 5), 15 * s, paint);
    }
  }

  void _paintFog(Canvas canvas, Size size) {
    // Soft mist banks toward the bottom of the scene, slowly breathing.
    final breathe = 0.5 + 0.5 * math.sin(ambient * math.pi * 2);
    const banks = [
      (0.86, 0.55, 1.6, 0.0),
      (0.9, 0.3, 2.2, 1.6),
      (0.95, 0.75, 2.8, 3.1),
      (0.985, 0.5, 3.4, 0.8),
    ];
    for (final (fy, fx, s, phase) in banks) {
      final drift = math.sin(ambient * math.pi * 2 + phase) * 16;
      final paint = Paint()
        ..color = colors.surface
            .withValues(alpha: 0.28 + 0.1 * breathe)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawOval(
        Rect.fromCenter(
          center:
              Offset(size.width * fx + drift, size.height * fy),
          width: size.width * 0.75 * s,
          height: 70 * s,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrailScenePainter old) =>
      old.scrollOffset != scrollOffset ||
      old.ambient != ambient ||
      old.coloredUpTo != coloredUpTo ||
      old.travelT != travelT ||
      old.colors != colors;
}
