import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Peaceful Retreat — "Morning by the lake": dawn sky with a rising sun,
/// layered hills, round trees swaying, a duck family gliding across the
/// lake with ripples, breathing mist, drifting leaves, swaying reeds and
/// a fish that jumps every ~8s. All motion is integer multiples of the
/// 40s loop so it repeats seamlessly.
class PeacefulScenePainter extends CustomPainter {
  PeacefulScenePainter(this.t, BuildContext context)
    : colors = context.colors,
      green = context.accents.peaceful,
      topPadding = MediaQuery.paddingOf(context).top;

  final double t;
  final AppColors colors;
  final Color green;
  final double topPadding;

  static const _tau = math.pi * 2;

  /// The detail sheet overlaps the header's bottom by its corner radius.
  static const _sheetOverlap = AppRadius.sheet;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final lakeTop = visibleBottom - 64;

    // Dawn palette from tokens.
    final skyTop = HSLColor.fromColor(colors.groundTop)
        .withSaturation(0.5)
        .withLightness(0.78)
        .toColor();
    final dawn = Color.lerp(colors.ground, colors.gold, 0.35)!;
    final hillFar = Color.lerp(green, colors.groundTop, 0.7)!;
    final hillMid = Color.lerp(green, colors.groundTop, 0.45)!;
    final hillNear = Color.lerp(green, colors.ground, 0.2)!;
    final water = Color.lerp(colors.groundTop, green, 0.28)!;
    final waterDeep = Color.lerp(colors.pill, green, 0.55)!;

    // Sky.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, lakeTop),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, dawn],
        ).createShader(Rect.fromLTWH(0, 0, w, lakeTop)),
    );

    // Rising sun with a breathing halo, half behind the far hills.
    final pulse = math.sin(t * _tau * 5);
    final sun = Offset(w * 0.62, lakeTop - 38);
    canvas.drawCircle(
      sun,
      54 + 3 * pulse,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      sun,
      36 + 2 * pulse,
      Paint()..color = colors.gold.withValues(alpha: 0.3),
    );
    canvas.drawCircle(sun, 22, Paint()..color = colors.gold);

    // Soft clouds.
    final cloud = Colors.white.withValues(alpha: 0.8);
    _cloud(
      canvas,
      Offset(w * 0.22 + math.sin(t * _tau) * 14, topPadding + 44),
      16,
      cloud,
    );
    _cloud(
      canvas,
      Offset(w * 0.84 + math.sin(t * _tau + 2) * 10, topPadding + 30),
      12,
      cloud.withValues(alpha: 0.55),
    );

    // Hills: far, mid, near (near carries the trees).
    _hill(canvas, w, lakeTop, 52, const [0.0, 0.35, 0.8], hillFar);
    _hill(canvas, w, lakeTop, 34, const [0.15, 0.55, 1.0], hillMid);
    final nearHill = Path()
      ..moveTo(-10, lakeTop + 2)
      ..lineTo(-10, lakeTop - 16)
      ..quadraticBezierTo(w * 0.14, lakeTop - 30, w * 0.3, lakeTop - 10)
      ..quadraticBezierTo(w * 0.38, lakeTop - 2, w * 0.46, lakeTop + 2)
      ..close();
    canvas.drawPath(nearHill, Paint()..color = hillNear);
    final nearHillR = Path()
      ..moveTo(w * 0.62, lakeTop + 2)
      ..quadraticBezierTo(w * 0.72, lakeTop - 4, w * 0.8, lakeTop - 14)
      ..quadraticBezierTo(w * 0.92, lakeTop - 26, w + 10, lakeTop - 18)
      ..lineTo(w + 10, lakeTop + 2)
      ..close();
    canvas.drawPath(nearHillR, Paint()..color = hillNear);

    // Round trees swaying from their trunk base — kept low so their
    // crowns stay clear of the back / favourite buttons.
    for (final (i, (fx, base, r)) in const [
      (0.08, -14.0, 10.0),
      (0.17, -20.0, 12.0),
      (0.27, -10.0, 8.0),
      (0.8, -10.0, 9.0),
      (0.9, -18.0, 11.0),
    ].indexed) {
      _tree(
        canvas,
        Offset(w * fx, lakeTop + base),
        r,
        math.sin(t * _tau * 8 + i * 1.3) * 0.05,
        green,
      );
    }

    // Lake.
    final lake = Rect.fromLTWH(0, lakeTop, w, h - lakeTop);
    canvas.drawRect(
      lake,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [water, waterDeep],
        ).createShader(lake),
    );

    // Sun reflection: broken gold streaks under the sun.
    final glint = Paint()
      ..color = colors.gold.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 4; row++) {
      final y = lakeTop + 8 + row * 9.0;
      final dx = math.sin(t * _tau * 6 + row * 1.7) * 5;
      final half = 22.0 - row * 4;
      canvas.drawLine(
        Offset(sun.dx - half + dx, y),
        Offset(sun.dx + half + dx, y),
        glint,
      );
    }

    // Gentle drifting ripple dashes.
    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 3; row++) {
      final y = lakeTop + 14 + row * 16.0;
      for (var k = 0; k < 4; k++) {
        final x =
            ((k / 4 + t * 2 * (row.isEven ? 1 : -1) + row * 0.2) % 1.0) *
                (w + 30) -
            15;
        canvas.drawLine(Offset(x, y), Offset(x + 12, y), ripple);
      }
    }

    // Fish jump every 8s (5 per loop): arc out of the water, then rings.
    final jump = (t * 5) % 1.0;
    final jumpAt = Offset(
      w * (0.2 + 0.12 * ((t * 5).floor() % 3)),
      lakeTop + 30,
    );
    if (jump < 0.06) {
      final p = jump / 0.06;
      final pos = Offset(
        jumpAt.dx + (p - 0.5) * 26,
        jumpAt.dy - math.sin(p * math.pi) * 22,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate((p - 0.5) * 1.6);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 13, height: 6),
        Paint()..color = colors.goldDeep,
      );
      canvas.drawPath(
        Path()
          ..moveTo(-6, 0)
          ..lineTo(-11, -4)
          ..lineTo(-11, 4)
          ..close(),
        Paint()..color = colors.goldDeep,
      );
      canvas.restore();
    } else if (jump < 0.3) {
      final p = (jump - 0.06) / 0.24;
      final ring = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * (1 - p))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      for (final s in [1.0, 0.6]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: jumpAt.translate(13, 0),
            width: 10 + 44 * p * s,
            height: 4 + 12 * p * s,
          ),
          ring,
        );
      }
    }

    // Duck family gliding left → right once per loop, with a V wake.
    final duckX = -70 + t * (w + 140);
    final duckY = lakeTop + 22;
    for (final (i, (dx, scale)) in const [
      (0.0, 1.0),
      (-24.0, 0.6),
      (-40.0, 0.6),
      (-56.0, 0.6),
    ].indexed) {
      final bob = math.sin(t * _tau * 20 + i * 1.1) * 1.2;
      _duck(canvas, Offset(duckX + dx, duckY + bob), scale, i == 0);
    }

    // Breathing mist bands across the hill line.
    final breathe = 0.5 + 0.5 * math.sin(t * _tau * 2);
    final mist = Paint()
      ..color = Colors.white.withValues(alpha: 0.16 + 0.14 * breathe);
    for (final (fx, dy, mw) in const [(0.15, -6.0, 0.5), (0.6, 2.0, 0.6)]) {
      final drift = math.sin(t * _tau + fx * 6) * 18;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * fx + drift, lakeTop + dy),
          width: w * mw,
          height: 16,
        ),
        mist,
      );
    }

    // Reeds swaying at the bottom-left shore.
    final reed = Paint()
      ..color = Color.lerp(green, colors.pill, 0.3)!
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cattail = Paint()..color = colors.goldDeep;
    for (var i = 0; i < 5; i++) {
      final base = Offset(6 + i * 7.0, visibleBottom + 4);
      final sway = math.sin(t * _tau * 6 + i * 0.8) * 5;
      final tip = base.translate(sway + (i - 2) * 3, -34 - (i % 3) * 8.0);
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(base.dx, (base.dy + tip.dy) / 2, tip.dx, tip.dy),
        reed,
      );
      if (i.isOdd) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: tip.translate(0, 5), width: 4, height: 11),
            const Radius.circular(2),
          ),
          cattail,
        );
      }
    }

    // Leaves drifting down with a side-to-side sway (3 falls per loop).
    final leaf = Paint();
    for (var i = 0; i < 6; i++) {
      final p = (t * 3 + i / 6) % 1.0;
      final y = topPadding + p * (visibleBottom - topPadding);
      final x = w * (0.1 + 0.16 * i) + math.sin(p * _tau * 2 + i) * 14;
      leaf.color = (i.isEven ? green : colors.gold).withValues(
        alpha: 0.75 * math.sin(p * math.pi),
      );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.sin(p * _tau * 2 + i) * 0.9);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8, height: 4),
        leaf,
      );
      canvas.restore();
    }
  }

  void _hill(
    Canvas canvas,
    double w,
    double base,
    double peak,
    List<double> crests,
    Color color,
  ) {
    final path = Path()..moveTo(-10, base);
    var prevX = -10.0;
    for (final c in crests) {
      final x = w * c;
      path.quadraticBezierTo(
        (prevX + x) / 2,
        base - peak * 1.6,
        x + w * 0.12,
        base - peak * 0.4,
      );
      prevX = x + w * 0.12;
    }
    path
      ..quadraticBezierTo(w, base - peak * 0.3, w + 10, base)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _tree(Canvas canvas, Offset base, double r, double sway, Color green) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(sway);
    canvas.drawRect(
      Rect.fromLTWH(-1.5, -r * 0.9, 3, r * 0.9 + 2),
      Paint()..color = Color.lerp(colors.goldDeep, colors.pill, 0.4)!,
    );
    final crown = Paint()..color = Color.lerp(green, colors.pill, 0.12)!;
    canvas.drawCircle(Offset(0, -r * 1.5), r, crown);
    canvas.drawCircle(
      Offset(-r * 0.3, -r * 1.75),
      r * 0.45,
      Paint()..color = Color.lerp(green, Colors.white, 0.25)!,
    );
    canvas.restore();
  }

  void _duck(Canvas canvas, Offset c, double s, bool parent) {
    final body = Paint()
      ..color = parent
          ? colors.surface
          : Color.lerp(colors.gold, Colors.white, 0.35)!;
    // Wake.
    final wake = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      c.translate(-10 * s, 4 * s),
      c.translate(-22 * s, 8 * s),
      wake,
    );
    canvas.drawLine(
      c.translate(-10 * s, 5 * s),
      c.translate(-20 * s, 1 * s),
      wake,
    );
    // Body + tail.
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 22 * s, height: 10 * s),
      body,
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 9 * s, c.dy - 1 * s)
        ..lineTo(c.dx - 14 * s, c.dy - 6 * s)
        ..lineTo(c.dx - 6 * s, c.dy - 3 * s)
        ..close(),
      body,
    );
    // Head (mallard green on the parent), beak, eye.
    final head = c.translate(8 * s, -7 * s);
    canvas.drawCircle(
      head,
      5 * s,
      parent ? (Paint()..color = Color.lerp(green, colors.pill, 0.3)!) : body,
    );
    canvas.drawPath(
      Path()
        ..moveTo(head.dx + 4 * s, head.dy - 1 * s)
        ..lineTo(head.dx + 9 * s, head.dy + 0.5 * s)
        ..lineTo(head.dx + 4 * s, head.dy + 2 * s)
        ..close(),
      Paint()..color = colors.goldDeep,
    );
    canvas.drawCircle(
      head.translate(1.5 * s, -1 * s),
      1 * s,
      Paint()..color = colors.pill,
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
  bool shouldRepaint(PeacefulScenePainter old) =>
      old.t != t || old.colors != colors || old.green != green;
}
