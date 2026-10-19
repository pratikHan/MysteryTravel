import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
import '../../data/plan_fixtures.dart';
import '../../data/plan_models.dart';
import '../../state/app_state.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Playlist Editor — "Your Itinerary"
/// (reference: design1001/list of adventure places.png).
///
/// Postal theme: each stop is a pastel ticket with a perforated postage
/// stamp thumbnail, a points seal, and a ✕; drag wobbles the ticket
/// (interactions #5) and snaps it into place. A Lottie confetti burst
/// celebrates saving the adventure.
class PlaylistEditorScreen extends StatefulWidget {
  const PlaylistEditorScreen({super.key});

  @override
  State<PlaylistEditorScreen> createState() => _PlaylistEditorScreenState();
}

class _PlaylistEditorScreenState extends State<PlaylistEditorScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Debug-only: booting straight into /playlist (screenshot runs)
    // seeds a sample playlist instead of redirecting.
    if (kDebugMode) {
      final state = AppScope.read(context);
      if (state.workingPlaylist == null) {
        state.plan
          ..mode = ExplorationMode.mystery
          ..date = DateTime(2026, 10, 25)
          ..startTime = const TimeOfDay(hour: 10, minute: 0);
        state.pickPlaylist(PlanFixtures.playlists.first);
      }
    }
  }

  static const _wd = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Future<void> _save() async {
    if (_saving) return;
    final state = AppScope.read(context);
    setState(() => _saving = true);
    SoundService.instance.play(Sfx.fanfare, haptic: Haptic.success);
    if (!MotionSettings.reduced(context)) {
      await Future.delayed(const Duration(milliseconds: 1400));
    }
    if (!mounted) return;
    state.saveAdventure();
    showAppToast(context, 'Adventure saved! It opens on your adventure day.');
    context.go('/home');
  }

  void _remove(int index) {
    final ok = AppScope.read(context).removePlaylistItem(index);
    if (ok) {
      SoundService.instance.play(Sfx.swoosh, haptic: Haptic.light);
    } else {
      SoundService.instance.play(Sfx.wrong, haptic: Haptic.warning);
      showAppToast(context, 'Every adventure needs at least one stop!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final playlist = state.workingPlaylist;
    final plan = state.plan;
    final mystery = plan.mode == ExplorationMode.mystery;
    if (playlist == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go('/curated'));
      return const Scaffold(body: SizedBox.shrink());
    }
    final totalMiles = playlist.items
        .fold<double>(0, (sum, item) => sum + item.distanceMiles);
    final totalPoints =
        playlist.items.fold<int>(0, (sum, item) => sum + item.points);
    final date = plan.date;
    final modeLabel = mystery ? '🔮 Mystery mode' : '🗺️ Planned mode';
    final dateLabel = date == null
        ? ''
        : ' · ${_wd[date.weekday - 1].substring(0, 3)}, ${_mo[date.month - 1]} ${date.day}';
    final timeLabel =
        plan.startTime == null ? '' : ' · ${plan.startTime!.format(context)}';

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ---- Header with postmark decoration ----
                Stack(
                  children: [
                    Positioned(
                      right: AppSpace.m,
                      top: 0,
                      child: _Postmark(color: c.gold.withValues(alpha: 0.4)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpace.screenGutter,
                          AppSpace.s,
                          AppSpace.screenGutter,
                          0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleIconButton(
                            icon: Icons.chevron_left_rounded,
                            semanticLabel: 'Back to Curated Adventures',
                            onTap: () => context.go('/curated'),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                AppText(playlist.title, AppType.pageTitle,
                                    align: TextAlign.center),
                                const SizedBox(height: 2),
                                AppText('$modeLabel$dateLabel$timeLabel',
                                    AppType.chip,
                                    color: c.muted),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSize.iconButton),
                        ],
                      ),
                    ),
                  ],
                ),
                // ---- Tape label + reorder hint ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                      AppSpace.l, AppSpace.screenGutter, AppSpace.s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Transform.rotate(
                        angle: -0.03,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.l,
                              vertical: AppSpace.s),
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius:
                                BorderRadius.circular(AppRadius.tail),
                            boxShadow: [
                              BoxShadow(
                                  color: c.shadow(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📍',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: AppSpace.s),
                              Text(
                                'Your Itinerary',
                                style: GoogleFonts.caveat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: c.ink,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xs),
                        child: Row(
                          children: [
                            AppText('Drag ', AppType.chip, color: c.muted),
                            Icon(Icons.drag_indicator_rounded,
                                size: 14, color: c.muted),
                            AppText(' to reorder', AppType.chip,
                                color: c.muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ---- Tickets ----
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                        AppSpace.s, AppSpace.screenGutter, AppSpace.s),
                    itemCount: playlist.items.length,
                    onReorderItem: (from, to) {
                      state.reorderPlaylistItem(from, to);
                      SoundService.instance
                          .play(Sfx.pop, haptic: Haptic.medium);
                    },
                    proxyDecorator: (child, index, animation) =>
                        _WobbleLift(child: child),
                    itemBuilder: (context, i) => Padding(
                      key: ValueKey(
                          '${playlist.items[i].place.id}-${playlist.items[i].mysteryTitle}'),
                      padding: const EdgeInsets.only(bottom: AppSpace.m),
                      child: _TicketRow(
                        index: i,
                        isLast: i == playlist.items.length - 1,
                        item: playlist.items[i],
                        mystery: mystery,
                        onRemove: () => _remove(i),
                      ),
                    ),
                  ),
                ),
                // ---- Summary + CTA ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter, 0,
                      AppSpace.screenGutter, AppSpace.l),
                  child: Column(
                    children: [
                      _SummaryCard(
                        stops: playlist.items.length,
                        miles: totalMiles,
                        points: totalPoints,
                      ),
                      const SizedBox(height: AppSpace.l),
                      BouncyPressable(
                        onTap: _save,
                        sfx: null,
                        haptic: null,
                        child: Container(
                          height: AppSize.cta,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: c.pill,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            boxShadow: [
                              BoxShadow(
                                  color: c.shadow(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Center(
                            child: AppText('Save Adventure 🎒', AppType.cta,
                                color: c.onDark),
                          ),
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(height: AppSpace.s + 2),
                        AppText(
                          'Opens ${_wd[date.weekday - 1]}, ${_mo[date.month - 1]} ${date.day} — we\'ll have everything ready',
                          AppType.caption,
                          color: c.muted,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ---- Save celebration (Lottie confetti) ----
          if (_saving)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ticket row
// ---------------------------------------------------------------------------

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.index,
    required this.isLast,
    required this.item,
    required this.mystery,
    required this.onRemove,
  });

  final int index;
  final bool isLast;
  final PlaylistItem item;
  final bool mystery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final a = context.accents;
    // Four rotating pastel ticket tints with matching number colors.
    final tints = [
      (a.peaceful.softFill, c.success),
      (c.gold.softFill, c.gold),
      (Color.lerp(c.groundTop, c.surface, 0.25)!,
          Color.lerp(c.groundTop, c.pill, 0.45)!),
      (a.stories.softFill, a.stories),
    ];
    final (tint, numColor) = tints[index % tints.length];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      // Left rail: drag dots + colored number + dashed connector.
        Column(
          children: [
            Icon(Icons.drag_indicator_rounded, size: 16, color: c.muted),
            const SizedBox(height: AppSpace.xs),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: numColor,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 2.5),
                boxShadow: [
                  BoxShadow(
                      color: c.shadow(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Center(
                child: AppText('${index + 1}', AppType.itemTitle,
                    color: Colors.white),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22,
                margin: const EdgeInsets.only(top: AppSpace.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      c.goldDeep.withValues(alpha: 0.5),
                      c.goldDeep.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpace.s + 2),
        // The ticket.
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpace.m - 2),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                  color: numColor.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              children: [
                _PostageStamp(
                  holeColor: tint,
                  child: mystery
                      ? Container(
                          color: c.surface,
                          child: Center(
                            child: Text(item.emoji,
                                style: const TextStyle(fontSize: 26)),
                          ),
                        )
                      : Image.asset(item.place.image, fit: BoxFit.cover),
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        mystery ? item.mysteryTitle : item.place.name,
                        AppType.itemTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpace.xs + 2),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: c.muted),
                          const SizedBox(width: 3),
                          AppText(item.suggestedTime, AppType.caption,
                              color: c.muted),
                          const SizedBox(width: AppSpace.s),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.s + 1, vertical: 2),
                              decoration: BoxDecoration(
                                color: c.surface.withValues(alpha: 0.85),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.place_rounded,
                                      size: 11, color: a.stories),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: AppText(
                                        '~${item.distanceMiles} mi',
                                        AppType.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.xs + 2),
                _PointsSeal(points: item.points, color: numColor),
                const SizedBox(width: AppSpace.xs + 2),
                Pressable(
                  onTap: onRemove,
                  sfx: null,
                  haptic: null,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.border, width: 1.5),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 14, color: c.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Perforated postage-stamp frame around a thumbnail.
class _PostageStamp extends StatelessWidget {
  const _PostageStamp({required this.child, required this.holeColor});

  final Widget child;
  final Color holeColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _PerforationPainter(holeColor: holeColor),
      child: Container(
        width: 54,
        height: 54,
        padding: const EdgeInsets.all(4),
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.holeColor});

  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = holeColor;
    const r = 2.6;
    const gap = 8.0;
    for (double x = gap / 2; x <= size.width; x += gap) {
      canvas.drawCircle(Offset(x, 0), r, paint);
      canvas.drawCircle(Offset(x, size.height), r, paint);
    }
    for (double y = gap / 2; y <= size.height; y += gap) {
      canvas.drawCircle(Offset(0, y), r, paint);
      canvas.drawCircle(Offset(size.width, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.holeColor != holeColor;
}

/// Star-edged rosette seal showing the stop's points.
class _PointsSeal extends StatelessWidget {
  const _PointsSeal({required this.points, required this.color});

  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PopIn(
      child: CustomPaint(
        painter: _SealPainter(color: color),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded,
                  size: 11, color: Colors.white),
              AppText('+$points', AppType.caption, color: Colors.white),
              Text('pts',
                  style: AppType.caption
                      .style(Colors.white)
                      .copyWith(fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  _SealPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    final inner = outer * 0.88;
    const spikes = 14;
    final path = Path();
    for (var i = 0; i < spikes * 2; i++) {
      final r = i.isEven ? outer : inner;
      final angle = i * math.pi / spikes - math.pi / 2;
      final p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawShadow(path, Colors.black26, 2, false);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
        center,
        inner * 0.92,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_SealPainter old) => old.color != color;
}

/// The lifted ticket while dragging: gentle continuous wobble + shadow
/// (interactions #5).
class _WobbleLift extends StatefulWidget {
  const _WobbleLift({required this.child});

  final Widget child;

  @override
  State<_WobbleLift> createState() => _WobbleLiftState();
}

class _WobbleLiftState extends State<_WobbleLift>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MotionSettings.reduced(context)) {
        _c.repeat();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.rotate(
        angle: 0.022 * math.sin(_c.value * math.pi * 2),
        child: Transform.scale(scale: 1.04, child: child),
      ),
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                  color: context.colors.shadow(0.3),
                  blurRadius: 22,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.stops,
    required this.miles,
    required this.points,
  });

  final int stops;
  final double miles;
  final int points;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.l, vertical: AppSpace.m),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Mascot(MascotState.celebrating, size: 56),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🧭',
                                  style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 4),
                              AppText('$stops stops', AppType.itemTitle),
                            ],
                          ),
                          AppText('~${miles.toStringAsFixed(1)} mi total',
                              AppType.caption,
                              color: c.muted),
                        ],
                      ),
                    ),
                    Container(
                        width: 1.5, height: 34, color: c.border),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏵️',
                                  style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 4),
                              CountUp(points, AppType.sectionHeader),
                            ],
                          ),
                          AppText('stamp points', AppType.caption,
                              color: c.muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Another day of good places awaits!',
            style: GoogleFonts.caveat(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: context.colors.goldDeep,
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint rotated airmail postmark decorating the header.
class _Postmark extends StatelessWidget {
  const _Postmark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.25,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Transform.rotate(
            angle: -0.25,
            child: Text('✈️',
                style: TextStyle(
                    fontSize: 20, color: color.withValues(alpha: 0.8))),
          ),
        ),
      ),
    );
  }
}
