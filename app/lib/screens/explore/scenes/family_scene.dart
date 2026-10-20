import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Family Fun — "Fair day": a sunny fairground with a big Ferris wheel
/// turning slowly (cabins stay upright and swing), a striped carousel
/// with bobbing horses, waving bunting, cotton-candy clouds, balloons
/// floating up and away, and an occasional confetti sprinkle. All motion
/// is integer multiples of the 40s loop so it repeats seamlessly.
class FamilyScenePainter extends CustomPainter {
  FamilyScenePainter(this.t, BuildContext context)
    : colors = context.colors,
      accents = context.accents,
      topPadding = MediaQuery.paddingOf(context).top;

  final double t;
  final AppColors colors;
  final QuestAccents accents;
  final double topPadding;

  static const _tau = math.pi * 2;

  /// The detail sheet overlaps the header's bottom by its corner radius.
  static const _sheetOverlap = AppRadius.sheet;

  List<Color> get _festive => [
    colors.heart,
    colors.gold,
    accents.peaceful,
    accents.night,
    accents.artistic,
    accents.stories,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final groundY = visibleBottom - 30;

    // Bright sunny palette from tokens.
    final skyTop = HSLColor.fromColor(colors.groundTop)
        .withSaturation(0.62)
        .withLightness(0.72)
        .toColor();
    final skyLow = Color.lerp(colors.groundTop, colors.ground, 0.55)!;
    final green = accents.peaceful;
    final grassFar = Color.lerp(green, colors.groundTop, 0.55)!;
    final grass = Color.lerp(green, colors.gold, 0.22)!;
    final grassLight = Color.lerp(grass, Colors.white, 0.18)!;
    final candyPink = Color.lerp(colors.heart, Colors.white, 0.62)!;

    // Sky.
    final skyRect = Rect.fromLTWH(0, 0, w, groundY + 4);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyLow],
        ).createShader(skyRect),
    );

    // Sun with slowly turning rays, upper-left of centre (clear of the
    // back button).
    final sun = Offset(w * 0.3, topPadding + 34);
    final rays = Paint()
      ..color = colors.gold.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final spin = t * _tau;
    for (var i = 0; i < 10; i++) {
      final a = spin + i * _tau / 10;
      final len = 30 + 3 * math.sin(t * _tau * 6 + i);
      canvas.drawLine(
        sun + Offset(math.cos(a), math.sin(a)) * 23,
        sun + Offset(math.cos(a), math.sin(a)) * len,
        rays,
      );
    }
    canvas.drawCircle(
      sun,
      21,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawCircle(sun, 17, Paint()..color = colors.gold);
    canvas.drawCircle(
      sun.translate(-5, -5),
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // Cotton-candy clouds drifting right, wrapping around.
    for (final (i, (speed, y, r, pink)) in const [
      (1, 0.0, 13.0, true),
      (2, 26.0, 9.0, false),
      (1, 14.0, 11.0, false),
      (2, 40.0, 8.0, true),
    ].indexed) {
      final span = w + 120;
      final x = ((t * speed + i * 0.27) % 1.0) * span - 60;
      _cloud(
        canvas,
        Offset(x, topPadding + 8 + y),
        r,
        (pink ? candyPink : Colors.white).withValues(alpha: 0.92),
      );
    }

    // Distant rolling hills behind the fair.
    final hills = Path()
      ..moveTo(0, groundY)
      ..lineTo(0, groundY - 14)
      ..quadraticBezierTo(w * 0.18, groundY - 30, w * 0.38, groundY - 12)
      ..quadraticBezierTo(w * 0.62, groundY - 30, w * 0.8, groundY - 16)
      ..quadraticBezierTo(w * 0.92, groundY - 22, w, groundY - 14)
      ..lineTo(w, groundY)
      ..close();
    canvas.drawPath(hills, Paint()..color = grassFar);

    // Ferris wheel hub, right of centre; its top stays below the status
    // bar / dynamic island.
    final hub = Offset(w * 0.64, groundY - 66);
    const radius = 54.0;

    // Bunting strung from the carousel peak across to the wheel and on
    // to a pole at the right edge (drawn behind the wheel).
    final tentX = w * 0.2;
    final peak = Offset(tentX, groundY - 82);
    final leftPole = Offset(6, groundY - 52);
    final rightPole = Offset(w - 6, groundY - 54);
    final pole = Paint()
      ..color = Color.lerp(colors.pill, colors.muted, 0.3)!
      ..strokeWidth = 2.5;
    canvas.drawLine(leftPole, Offset(leftPole.dx, groundY + 2), pole);
    canvas.drawLine(rightPole, Offset(rightPole.dx, groundY + 2), pole);

    // Carousel.
    _carousel(canvas, Offset(tentX, groundY), peak);

    _bunting(canvas, leftPole, peak, 14, 0);
    _bunting(canvas, peak, hub, 26, 3);
    _bunting(canvas, hub, rightPole, 20, 9);

    _ferrisWheel(canvas, hub, radius, groundY);

    // Ground: grassy field with a sandy path and tufts.
    final field = Path()
      ..moveTo(0, groundY + 2)
      ..quadraticBezierTo(w * 0.5, groundY - 6, w, groundY + 2)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(field, Paint()..color = grass);
    final pathPaint = Paint()
      ..color = Color.lerp(colors.ground, colors.gold, 0.25)!;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.4, groundY + 1)
        ..quadraticBezierTo(w * 0.42, groundY + 20, w * 0.3, h)
        ..lineTo(w * 0.58, h)
        ..quadraticBezierTo(w * 0.5, groundY + 20, w * 0.48, groundY)
        ..close(),
      pathPaint,
    );
    final tuft = Paint()
      ..color = grassLight
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final x = w * (0.05 + i * 0.112);
      final y = groundY + 10 + (i % 3) * 6.0;
      final sway = math.sin(t * _tau * 8 + i) * 1.5;
      canvas.drawLine(Offset(x, y), Offset(x - 3 + sway, y - 6), tuft);
      canvas.drawLine(Offset(x, y), Offset(x + sway, y - 8), tuft);
      canvas.drawLine(Offset(x, y), Offset(x + 3 + sway, y - 6), tuft);
    }

    // Little round bushes and a candy-floss stand on the right.
    final bush = Paint()..color = Color.lerp(green, colors.pill, 0.1)!;
    for (final (fx, r) in const [(0.37, 7.0), (0.41, 9.0), (0.93, 8.0)]) {
      canvas.drawCircle(Offset(w * fx, groundY + 1), r, bush);
    }
    _candyStand(canvas, Offset(w * 0.86, groundY + 4), candyPink);

    // Balloons floating up and off the top, re-spawning at the bottom.
    for (var i = 0; i < 6; i++) {
      final speed = 2 + i % 2;
      final p = (t * speed + i / 6) % 1.0;
      final startX = w * (0.08 + 0.17 * i);
      final y = groundY + 10 - p * (groundY + 60);
      final x = startX + math.sin(p * _tau + i) * 12 + p * 18;
      _balloon(canvas, Offset(x, y), _festive[i], p, i);
    }

    // Confetti sprinkle: four soft showers per loop.
    final shower = (t * 4) % 1.0;
    if (shower < 0.4) {
      final p = shower / 0.4;
      final fade = math.sin(p * math.pi);
      final bit = Paint();
      for (var i = 0; i < 22; i++) {
        final delay = (i * 7 % 22) / 22 * 0.35;
        final q = ((p - delay) / 0.65).clamp(0.0, 1.0);
        if (q <= 0 || q >= 1) continue;
        final x =
            w * ((i * 0.137 + (t * 4).floor() * 0.31) % 1.0) +
            math.sin(q * _tau * 2 + i) * 8;
        final y = topPadding - 6 + q * (groundY - topPadding);
        bit.color = _festive[i % 6].withValues(alpha: 0.9 * fade);
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(q * _tau * 2 + i);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 5, height: 2.6),
          bit,
        );
        canvas.restore();
      }
    }
  }

  void _ferrisWheel(Canvas canvas, Offset hub, double r, double groundY) {
    final frame = Color.lerp(colors.pill, colors.muted, 0.15)!;
    final rimColor = colors.surface;

    // A-frame legs.
    final leg = Paint()
      ..color = frame
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(hub, Offset(hub.dx - 34, groundY + 2), leg);
    canvas.drawLine(hub, Offset(hub.dx + 34, groundY + 2), leg);
    leg.strokeWidth = 2;
    canvas.drawLine(
      Offset(hub.dx - 20, groundY - 30),
      Offset(hub.dx + 20, groundY - 30),
      leg,
    );

    final angle = t * _tau * 2;

    // Rim (double ring) and spokes.
    final rim = Paint()
      ..color = rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(hub, r, rim);
    rim
      ..strokeWidth = 1.5
      ..color = rimColor.withValues(alpha: 0.85);
    canvas.drawCircle(hub, r - 8, rim);
    final spoke = Paint()
      ..color = rimColor.withValues(alpha: 0.9)
      ..strokeWidth = 1.4;
    for (var i = 0; i < 16; i++) {
      final a = angle + i * _tau / 16;
      canvas.drawLine(
        hub,
        hub + Offset(math.cos(a), math.sin(a)) * r,
        spoke,
      );
    }
    // Twinkling rim lights.
    final bulb = Paint();
    for (var i = 0; i < 16; i++) {
      final a = angle + (i + 0.5) * _tau / 16;
      final on = (i + (t * 40).floor()) % 3 == 0;
      bulb.color = on ? colors.gold : Color.lerp(colors.gold, Colors.white, 0.6)!;
      canvas.drawCircle(hub + Offset(math.cos(a), math.sin(a)) * r, 1.8, bulb);
    }

    // Cabins hang from the rim, upright, with a gentle swing.
    const cabinCount = 8;
    final cabinPaint = Paint();
    final roof = Paint();
    final window = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final hanger = Paint()
      ..color = frame
      ..strokeWidth = 1.4;
    for (var i = 0; i < cabinCount; i++) {
      final a = angle + i * _tau / cabinCount;
      final pivot = hub + Offset(math.cos(a), math.sin(a)) * r;
      final swing = math.sin(t * _tau * 12 + i * 1.7) * 0.14;
      final color = _festive[(i + 1) % 6];
      cabinPaint.color = color;
      roof.color = Color.lerp(color, colors.pill, 0.25)!;
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(swing);
      canvas.drawLine(Offset.zero, const Offset(0, 5), hanger);
      final body = RRect.fromRectAndCorners(
        const Rect.fromLTWH(-7.5, 5, 15, 12),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      );
      canvas.drawRRect(body, cabinPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-9, 3, 18, 4),
          const Radius.circular(2),
        ),
        roof,
      );
      canvas.drawRect(const Rect.fromLTWH(-5, 8.5, 10, 3.5), window);
      canvas.restore();
    }

    // Hub cap.
    canvas.drawCircle(hub, 6, Paint()..color = frame);
    canvas.drawCircle(hub, 2.6, Paint()..color = colors.gold);
  }

  void _carousel(Canvas canvas, Offset base, Offset peak) {
    final stripeA = accents.stories;
    final stripeB = colors.surface;
    const halfW = 44.0;
    final roofBase = base.dy - 50;

    // Platform / base drum.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(base.dx - halfW, base.dy - 10, base.dx + halfW, base.dy + 2),
        const Radius.circular(3),
      ),
      Paint()..color = Color.lerp(colors.gold, colors.goldDeep, 0.4)!,
    );
    // Back wall in shadow.
    canvas.drawRect(
      Rect.fromLTRB(base.dx - halfW + 4, roofBase, base.dx + halfW - 4, base.dy - 10),
      Paint()..color = Color.lerp(accents.stories, colors.pill, 0.45)!,
    );

    // Poles with bobbing horses.
    final polePaint = Paint()
      ..color = colors.gold
      ..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      final x = base.dx - 30 + i * 20.0;
      canvas.drawLine(Offset(x, roofBase), Offset(x, base.dy - 10), polePaint);
      final bob = math.sin(t * _tau * 10 + i * math.pi / 2) * 4;
      _horse(
        canvas,
        Offset(x, base.dy - 24 + bob),
        _festive[(i + 2) % 6],
        i.isEven,
      );
    }

    // Striped conical roof with a scalloped valance.
    final roof = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(base.dx + halfW + 6, roofBase)
      ..lineTo(base.dx - halfW - 6, roofBase)
      ..close();
    canvas.drawPath(roof, Paint()..color = stripeB);
    final stripe = Paint()..color = stripeA;
    const stripes = 6;
    final left = base.dx - halfW - 6;
    final step = (halfW + 6) * 2 / stripes;
    for (var i = 0; i < stripes; i += 2) {
      canvas.drawPath(
        Path()
          ..moveTo(peak.dx, peak.dy)
          ..lineTo(left + step * (i + 1), roofBase)
          ..lineTo(left + step * i, roofBase)
          ..close(),
        stripe,
      );
    }
    for (var i = 0; i < stripes; i++) {
      canvas.drawCircle(
        Offset(left + step * (i + 0.5), roofBase),
        step / 2,
        Paint()..color = i.isEven ? stripeA : stripeB,
      );
    }

    // Pennant on the peak.
    final flagWave = math.sin(t * _tau * 10) * 3;
    canvas.drawLine(
      peak,
      peak.translate(0, -12),
      Paint()
        ..color = colors.pill
        ..strokeWidth = 1.6,
    );
    canvas.drawPath(
      Path()
        ..moveTo(peak.dx, peak.dy - 12)
        ..quadraticBezierTo(
          peak.dx + 6,
          peak.dy - 12 + flagWave,
          peak.dx + 11,
          peak.dy - 9 + flagWave,
        )
        ..lineTo(peak.dx, peak.dy - 6)
        ..close(),
      Paint()..color = colors.gold,
    );
    canvas.drawCircle(peak, 2.5, Paint()..color = colors.gold);
  }

  void _horse(Canvas canvas, Offset c, Color saddle, bool facingRight) {
    final body = Paint()..color = colors.surface;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (!facingRight) canvas.scale(-1, 1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 7),
        const Radius.circular(3.5),
      ),
      body,
    );
    // Neck + head.
    canvas.drawPath(
      Path()
        ..moveTo(4, -2)
        ..lineTo(8, -9)
        ..lineTo(11, -7)
        ..lineTo(8, 0)
        ..close(),
      body,
    );
    // Legs.
    final leg = Paint()
      ..color = colors.surface
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-5, 3), const Offset(-7, 7), leg);
    canvas.drawLine(const Offset(5, 3), const Offset(7, 7), leg);
    canvas.drawRect(const Rect.fromLTWH(-3, -4, 6, 3), Paint()..color = saddle);
    canvas.restore();
  }

  void _bunting(Canvas canvas, Offset a, Offset b, double sag, int seed) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + sag);
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(mid.dx, mid.dy + sag, b.dx, b.dy),
      Paint()
        ..color = colors.pill.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final count = ((b - a).distance / 13).floor();
    final flag = Paint();
    for (var i = 1; i < count; i++) {
      final s = i / count;
      // Point on the quadratic curve (control point = mid + sag).
      final cx = mid.dx;
      final cy = mid.dy + sag;
      final x = (1 - s) * (1 - s) * a.dx + 2 * (1 - s) * s * cx + s * s * b.dx;
      final y = (1 - s) * (1 - s) * a.dy + 2 * (1 - s) * s * cy + s * s * b.dy;
      final wave = math.sin(t * _tau * 14 + (i + seed) * 0.9) * 0.28;
      flag.color = _festive[(i + seed) % 6];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(wave);
      canvas.drawPath(
        Path()
          ..moveTo(-4.5, 0)
          ..lineTo(4.5, 0)
          ..lineTo(0, 9)
          ..close(),
        flag,
      );
      canvas.restore();
    }
  }

  void _candyStand(Canvas canvas, Offset base, Color candyPink) {
    // Cart.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 14, base.dy - 18, 28, 16),
        const Radius.circular(3),
      ),
      Paint()..color = colors.surface,
    );
    canvas.drawRect(
      Rect.fromLTWH(base.dx - 14, base.dy - 12, 28, 3),
      Paint()..color = colors.heart,
    );
    canvas.drawCircle(
      Offset(base.dx - 8, base.dy - 1),
      3,
      Paint()..color = colors.pill,
    );
    canvas.drawCircle(
      Offset(base.dx + 8, base.dy - 1),
      3,
      Paint()..color = colors.pill,
    );
    // Striped awning.
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(base.dx - 16 + i * 8, base.dy - 30, 8, 7),
        Paint()..color = i.isEven ? colors.heart : colors.surface,
      );
    }
    final post = Paint()
      ..color = colors.pill
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(base.dx - 13, base.dy - 23),
      Offset(base.dx - 13, base.dy - 18),
      post,
    );
    canvas.drawLine(
      Offset(base.dx + 13, base.dy - 23),
      Offset(base.dx + 13, base.dy - 18),
      post,
    );
    // Cotton-candy puff on a stick.
    canvas.drawLine(
      Offset(base.dx + 4, base.dy - 18),
      Offset(base.dx + 4, base.dy - 21),
      post,
    );
    final puff = Paint()..color = candyPink;
    canvas.drawCircle(Offset(base.dx + 4, base.dy - 21), 3, puff);
  }

  void _balloon(Canvas canvas, Offset c, Color color, double p, int i) {
    final sway = math.sin(p * _tau * 2 + i) * 0.12;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(sway);
    // String with a lazy curl.
    canvas.drawPath(
      Path()
        ..moveTo(0, 9)
        ..quadraticBezierTo(-4, 16, 1, 22)
        ..quadraticBezierTo(4, 27, -1, 32),
      Paint()
        ..color = colors.pill.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 15, height: 18),
      Paint()..color = color,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-2, 8.5)
        ..lineTo(2, 8.5)
        ..lineTo(0, 11)
        ..close(),
      Paint()..color = Color.lerp(color, colors.pill, 0.2)!,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-3, -4), width: 4, height: 6),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(r * 0.95, r * 0.18), r * 0.78, paint);
    canvas.drawCircle(center.translate(-r * 0.95, r * 0.22), r * 0.72, paint);
    canvas.drawCircle(center.translate(r * 0.2, -r * 0.5), r * 0.68, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          center.dx - r * 1.6,
          center.dy,
          center.dx + r * 1.7,
          center.dy + r * 0.9,
        ),
        Radius.circular(r * 0.45),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(FamilyScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.accents != accents ||
      old.topPadding != topPadding;
}
