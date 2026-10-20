import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../theme/tokens.dart';

/// Explore's full-bleed animated city scene — the urban sibling of
/// Home's sky scene: golden-hour sky, drifting clouds, birds flapping
/// across, a two-layer skyline with twinkling windows, and a suspension
/// bridge over a shimmering river with a little boat. One slow
/// controller drives everything; all motion stops under reduced motion.
///
/// [child] is laid over the scene (the speech bubble + settings row).
class CityScene extends StatefulWidget {
  const CityScene({super.key, required this.height, this.child});

  /// Scene height below the status bar.
  final double height;
  final Widget? child;

  @override
  State<CityScene> createState() => _CitySceneState();
}

class _CitySceneState extends State<CityScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  );

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
    final top = MediaQuery.paddingOf(context).top;
    final colors = context.colors;
    final accents = context.accents;
    return SizedBox(
      height: top + widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _CityPainter(
                  t: MotionSettings.reduced(context) ? 0.3 : _c.value,
                  colors: colors,
                  bridge: accents.stories,
                  topPadding: top,
                ),
              ),
            ),
          ),
          if (widget.child != null)
            Positioned(left: 0, right: 0, top: top, child: widget.child!),
        ],
      ),
    );
  }
}

/// (x as fraction of width, width px, height px, has spire)
typedef _Tower = (double, double, double, bool);

const _farSkyline = <_Tower>[
  (-0.02, 46, 92, false),
  (0.09, 30, 128, true),
  (0.17, 52, 104, false),
  (0.31, 36, 150, true),
  (0.41, 48, 116, false),
  (0.55, 34, 138, false),
  (0.64, 56, 96, false),
  (0.78, 30, 160, true),
  (0.87, 50, 112, false),
  (0.97, 40, 130, false),
];

const _nearSkyline = <_Tower>[
  (0.0, 54, 70, false),
  (0.13, 40, 104, false),
  (0.24, 58, 82, false),
  (0.46, 44, 118, true),
  (0.58, 60, 76, false),
  (0.72, 42, 96, false),
  (0.84, 56, 120, false),
];

class _CityPainter extends CustomPainter {
  _CityPainter({
    required this.t,
    required this.colors,
    required this.bridge,
    required this.topPadding,
  });

  final double t;
  final AppColors colors;
  final Color bridge;
  final double topPadding;

  static const _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Golden-hour palette derived from tokens.
    final skyHsl = HSLColor.fromColor(colors.groundTop);
    final skyTop = skyHsl.withSaturation(0.55).withLightness(0.74).toColor();
    final horizon = Color.lerp(colors.ground, colors.gold, 0.32)!;
    final farTone = Color.lerp(colors.pill, colors.groundTop, 0.62)!;
    final nearTone = Color.lerp(colors.pill, colors.groundTop, 0.3)!;
    final water = Color.lerp(colors.pill, colors.groundTop, 0.5)!;
    final waterLow = Color.lerp(colors.pill, colors.groundTop, 0.68)!;
    final windowLit = Color.lerp(colors.gold, Colors.white, 0.25)!;

    final riverTop = h - 78;

    // Sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, horizon],
          stops: const [0.25, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, riverTop)),
    );

    // Low sun glowing behind the towers.
    final pulse = math.sin(t * _tau * 6);
    final sun = Offset(w * 0.68, riverTop - 118);
    canvas.drawCircle(
      sun,
      58 + 3 * pulse,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      sun,
      38 + 2 * pulse,
      Paint()..color = colors.gold.withValues(alpha: 0.28),
    );
    canvas.drawCircle(sun, 22, Paint()..color = colors.gold);

    // Clouds.
    final cloud = Colors.white.withValues(alpha: 0.85);
    final cloudSoft = Colors.white.withValues(alpha: 0.5);
    _cloud(
      canvas,
      Offset(w * 0.2 + math.sin(t * _tau) * 16, topPadding + 92),
      26,
      cloud,
    );
    _cloud(
      canvas,
      Offset(w * 0.86 + math.sin(t * _tau + 2) * 12, topPadding + 62),
      20,
      cloudSoft,
    );
    final crossX = -60 + ((t * 2) % 1.0) * (w + 120);
    _cloud(canvas, Offset(crossX, topPadding + 136), 12, cloudSoft);

    // Skyline: far layer (flat) then near layer (with windows).
    for (final tower in _farSkyline) {
      _tower(canvas, w, riverTop + 4, tower, farTone);
    }
    for (final (i, tower) in _nearSkyline.indexed) {
      final rect = _tower(canvas, w, riverTop + 4, tower, nearTone);
      _windows(canvas, rect, i, windowLit);
    }

    // Birds — integer speeds so the loop is seamless.
    final birdColor = colors.pill.withValues(alpha: 0.85);
    for (final (speed, phase, y, s) in const [
      (1, 0.0, 104.0, 10.0),
      (1, 0.05, 118.0, 8.0),
      (1, 0.1, 96.0, 7.0),
      (2, 0.5, 150.0, 9.0),
      (2, 0.55, 140.0, 7.0),
    ]) {
      final p = (t * speed + phase) % 1.0;
      final x = -30 + p * (w + 60);
      final bobY = math.sin(p * _tau * 3) * 6;
      final flap = math.sin(t * _tau * 90 + phase * 40);
      _bird(canvas, Offset(x, topPadding + y + bobY), s, flap, birdColor);
    }

    // River.
    final riverRect = Rect.fromLTWH(0, riverTop, w, h - riverTop);
    canvas.drawRect(
      riverRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [water, waterLow],
        ).createShader(riverRect),
    );
    // Sun reflection + drifting shimmer dashes.
    final shimmer = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final glint = Paint()
      ..color = colors.gold.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 4; row++) {
      final y = riverTop + 12 + row * 13.0;
      final gx = sun.dx + math.sin(t * _tau * 4 + row) * 6;
      final gw = 26.0 - row * 4;
      canvas.drawLine(Offset(gx - gw, y), Offset(gx + gw, y), glint);
      for (var k = 0; k < 5; k++) {
        final dir = row.isEven ? 1 : -1;
        final x = ((k / 5 + dir * t * 3 + row * 0.13) % 1.0) * (w + 40) - 20;
        canvas.drawLine(Offset(x, y + 5), Offset(x + 14, y + 5), shimmer);
      }
    }

    // Little boat crossing the river.
    final boatX = -40 + ((t * 1) % 1.0) * (w + 80);
    final boatY = riverTop + 40 + math.sin(t * _tau * 10) * 1.5;
    _boat(canvas, Offset(boatX, boatY));

    _bridge(canvas, w, riverTop);

    // Embankment the content column sits on (blends into the page).
    final bank = Path()
      ..moveTo(0, h - 16)
      ..quadraticBezierTo(w * 0.5, h - 30, w, h - 16)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bank, Paint()..color = colors.ground);
  }

  Rect _tower(Canvas canvas, double w, double base, _Tower tower, Color color) {
    final (fx, bw, bh, spire) = tower;
    final rect = Rect.fromLTWH(w * fx, base - bh, bw, bh);
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      paint,
    );
    if (spire) {
      final cx = rect.center.dx;
      canvas.drawRect(
        Rect.fromLTWH(cx - bw * 0.2, rect.top - 10, bw * 0.4, 10),
        paint,
      );
      canvas.drawLine(
        Offset(cx, rect.top - 10),
        Offset(cx, rect.top - 26),
        paint..strokeWidth = 2,
      );
    }
    return rect;
  }

  void _windows(Canvas canvas, Rect r, int seed, Color lit) {
    const cell = 9.0;
    const win = 4.0;
    final cols = ((r.width - 8) / cell).floor();
    final rows = ((r.height - 12) / cell).floor();
    final x0 = r.left + (r.width - cols * cell) / 2 + (cell - win) / 2;
    final y0 = r.top + 8;
    final paint = Paint();
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final hash = (seed * 73 + row * 31 + col * 17) % 11;
        if (hash > 4) continue; // dark window
        // A few windows twinkle on and off.
        final twinkle = hash == 0
            ? (math.sin(t * _tau * 8 + row + col * 2.0 + seed) > 0.2)
            : true;
        if (!twinkle) continue;
        paint.color = lit.withValues(alpha: hash.isEven ? 0.85 : 0.55);
        canvas.drawRect(
          Rect.fromLTWH(x0 + col * cell, y0 + row * cell, win, win + 1),
          paint,
        );
      }
    }
  }

  void _bridge(Canvas canvas, double w, double riverTop) {
    final deckY = riverTop + 22;
    final towerTop = riverTop - 58;
    final towers = [w * 0.24, w * 0.76];
    final body = Paint()..color = bridge;
    final cable = Paint()
      ..color = bridge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final hanger = Paint()
      ..color = bridge.withValues(alpha: 0.75)
      ..strokeWidth = 1.2;

    // Main cables: shore → tower → sag → tower → shore.
    final main = Path()
      ..moveTo(-10, deckY - 4)
      ..quadraticBezierTo(towers[0] * 0.6, deckY - 14, towers[0], towerTop + 6)
      ..quadraticBezierTo(w * 0.5, deckY + 8, towers[1], towerTop + 6)
      ..quadraticBezierTo(
        towers[1] + (w - towers[1]) * 0.4,
        deckY - 14,
        w + 10,
        deckY - 4,
      );
    canvas.drawPath(main, cable);

    // Vertical hangers from the centre span cable to the deck.
    for (var i = 1; i < 14; i++) {
      final f = i / 14;
      final x = towers[0] + (towers[1] - towers[0]) * f;
      // Quadratic through (t0, top) → (mid, control) → (t1, top).
      final y =
          (1 - f) * (1 - f) * (towerTop + 6) +
          2 * f * (1 - f) * (deckY + 8) +
          f * f * (towerTop + 6);
      canvas.drawLine(Offset(x, y), Offset(x, deckY), hanger);
    }

    // Towers with two cross-beams.
    for (final x in towers) {
      for (final dx in [-6.0, 4.0]) {
        canvas.drawRect(
          Rect.fromLTWH(x + dx, towerTop, 3.5, deckY - towerTop + 26),
          body,
        );
      }
      for (final y in [towerTop + 4, towerTop + 26]) {
        canvas.drawRect(Rect.fromLTWH(x - 6, y, 13.5, 3.5), body);
      }
    }

    // Deck.
    canvas.drawRect(Rect.fromLTWH(-10, deckY, w + 20, 5), body);
    canvas.drawRect(
      Rect.fromLTWH(-10, deckY + 5, w + 20, 2),
      Paint()..color = Color.lerp(bridge, colors.pill, 0.45)!,
    );
  }

  void _boat(Canvas canvas, Offset at) {
    final hull = Path()
      ..moveTo(at.dx - 16, at.dy)
      ..lineTo(at.dx + 16, at.dy)
      ..lineTo(at.dx + 11, at.dy + 6)
      ..lineTo(at.dx - 11, at.dy + 6)
      ..close();
    canvas.drawPath(hull, Paint()..color = colors.surface);
    canvas.drawRect(
      Rect.fromLTWH(at.dx - 7, at.dy - 7, 12, 7),
      Paint()..color = colors.gold,
    );
    // Wake.
    canvas.drawLine(
      Offset(at.dx - 30, at.dy + 6),
      Offset(at.dx - 16, at.dy + 6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _bird(Canvas canvas, Offset c, double s, double flap, Color color) {
    final wingY = c.dy - s * 0.55 * flap;
    final path = Path()
      ..moveTo(c.dx - s, wingY)
      ..quadraticBezierTo(c.dx - s * 0.45, c.dy - s * 0.2, c.dx, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.45, c.dy - s * 0.2, c.dx + s, wingY);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _cloud(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(r * 0.95, r * 0.18), r * 0.78, paint);
    canvas.drawCircle(center.translate(-r * 0.95, r * 0.22), r * 0.72, paint);
    canvas.drawCircle(center.translate(r * 0.2, -r * 0.4), r * 0.6, paint);
  }

  @override
  bool shouldRepaint(_CityPainter old) =>
      old.t != t || old.colors != colors || old.bridge != bridge;
}
