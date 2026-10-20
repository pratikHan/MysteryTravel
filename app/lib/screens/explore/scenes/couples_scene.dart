import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Couples Escape — "Sunset by the water": a pink → peach → gold sky with
/// a big low sun and its broken reflection, pink-tinted clouds drifting,
/// a distant city silhouette, and a riverside promenade with a railing,
/// a bench and twinkling string lights. A rowboat carrying two tiny
/// figures drifts across, bobbing, while little hearts float up from it.
/// Fireflies blink along the promenade, the first stars come out and a
/// pair of birds flies by. All motion is integer multiples of the 40s
/// loop so it repeats seamlessly.
class CouplesScenePainter extends CustomPainter {
  CouplesScenePainter(this.t, BuildContext context)
    : colors = context.colors,
      red = context.accents.stories,
      topPadding = MediaQuery.paddingOf(context).top;

  final double t;
  final AppColors colors;
  final Color red;
  final double topPadding;

  static const _tau = math.pi * 2;

  /// The detail sheet overlaps the header's bottom by its corner radius.
  static const _sheetOverlap = AppRadius.sheet;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final waterTop = visibleBottom - 80;
    final railTop = visibleBottom - 34;
    final deckTop = visibleBottom - 16;

    // Sunset palette from tokens.
    final heart = colors.heart;
    final dusk = Color.lerp(Color.lerp(heart, colors.pill, 0.42)!, red, 0.12)!;
    final rose = Color.lerp(heart, colors.surface, 0.12)!;
    final peach = Color.lerp(
      Color.lerp(heart, colors.gold, 0.55)!,
      colors.surface,
      0.18,
    )!;
    final glow = Color.lerp(colors.gold, colors.surface, 0.42)!;
    final city = Color.lerp(red, colors.pill, 0.5)!.withValues(alpha: 0.55);
    final cityNear = Color.lerp(red, colors.pill, 0.62)!;
    final waterHi = Color.lerp(peach, colors.gold, 0.2)!;
    final waterLo = Color.lerp(red, colors.pill, 0.45)!;
    final silhouette = Color.lerp(colors.pill, red, 0.22)!;
    final deck = Color.lerp(colors.pill, red, 0.35)!;

    // Sky.
    final sky = Rect.fromLTWH(0, 0, w, waterTop);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [dusk, rose, peach, glow],
          stops: const [0.0, 0.42, 0.74, 1.0],
        ).createShader(sky),
    );

    // First stars blinking in across the upper sky (clear of the buttons).
    for (final (i, (fx, fy, r)) in const [
      (0.22, 10.0, 1.4),
      (0.31, 26.0, 1.0),
      (0.42, 6.0, 1.2),
      (0.5, 30.0, 0.9),
      (0.6, 14.0, 1.5),
      (0.7, 4.0, 1.0),
      (0.77, 24.0, 1.2),
      (0.36, 42.0, 0.8),
    ].indexed) {
      final tw = 0.5 + 0.5 * math.sin(t * _tau * (3 + i % 4) + i * 2.1);
      final c = Offset(w * fx, topPadding + fy);
      final paint = Paint()
        ..color = colors.onDark.withValues(alpha: 0.25 + 0.7 * tw);
      canvas.drawCircle(c, r * (0.8 + 0.4 * tw), paint);
      if (i % 3 == 0) {
        final arm = r * 3.2 * tw;
        final s = Paint()
          ..color = colors.onDark.withValues(alpha: 0.5 * tw)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(c.translate(-arm, 0), c.translate(arm, 0), s);
        canvas.drawLine(c.translate(0, -arm), c.translate(0, arm), s);
      }
    }

    // Big low sun with a breathing glow, setting into the horizon.
    final breathe = math.sin(t * _tau * 4);
    final sun = Offset(w * 0.56, waterTop - 4);
    canvas.save();
    canvas.clipRect(sky);
    canvas.drawCircle(
      sun,
      78 + 5 * breathe,
      Paint()..color = colors.gold.withValues(alpha: 0.12 + 0.04 * breathe),
    );
    canvas.drawCircle(
      sun,
      54 + 4 * breathe,
      Paint()..color = colors.surface.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      sun,
      38 + 2 * breathe,
      Paint()..color = colors.gold.withValues(alpha: 0.32),
    );
    canvas.drawCircle(
      sun,
      28,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(colors.gold, colors.surface, 0.55)!, colors.gold],
        ).createShader(Rect.fromCircle(center: sun, radius: 28)),
    );
    canvas.restore();

    // Soft pink-tinted clouds with a gold-lit underside, drifting.
    for (final (i, (fx, fy, r, a)) in const [
      (0.3, 44.0, 9.0, 0.9),
      (0.8, 52.0, 7.5, 0.75),
      (0.62, 30.0, 6.0, 0.55),
    ].indexed) {
      final drift = math.sin(t * _tau + i * 2.2) * 16;
      _cloud(
        canvas,
        Offset(w * fx + drift, topPadding + fy),
        r,
        Color.lerp(heart, colors.surface, 0.55)!.withValues(alpha: a),
        Color.lerp(colors.gold, colors.surface, 0.3)!.withValues(alpha: a),
      );
    }

    // Pair of birds flying together, right → left twice per loop.
    final birdP = (t * 2) % 1.0;
    final birdX = w + 30 - birdP * (w + 60);
    final birdY = topPadding + 66 + math.sin(birdP * _tau) * 6;
    for (final (i, (dx, dy)) in const [(0.0, 0.0), (13.0, -5.0)].indexed) {
      final flap = math.sin(t * _tau * 90 + i * 1.4);
      _bird(
        canvas,
        Offset(birdX + dx, birdY + dy),
        5.0 - i * 0.6,
        flap,
        silhouette.withValues(alpha: 0.75),
      );
    }

    // Distant city skyline on the far bank.
    _skyline(canvas, w, waterTop, city, const [
      (0.0, 0.05, 16.0),
      (0.05, 0.04, 26.0),
      (0.09, 0.05, 20.0),
      (0.14, 0.03, 34.0),
      (0.17, 0.06, 22.0),
      (0.23, 0.04, 14.0),
      (0.27, 0.05, 18.0),
      (0.72, 0.05, 15.0),
      (0.77, 0.03, 28.0),
      (0.8, 0.06, 20.0),
      (0.86, 0.04, 32.0),
      (0.9, 0.05, 18.0),
      (0.95, 0.06, 24.0),
    ]);
    _skyline(canvas, w, waterTop, cityNear, const [
      (0.0, 0.08, 9.0),
      (0.08, 0.06, 13.0),
      (0.14, 0.09, 7.0),
      (0.23, 0.07, 10.0),
      (0.3, 0.05, 5.0),
      (0.7, 0.08, 8.0),
      (0.78, 0.07, 12.0),
      (0.85, 0.09, 9.0),
      (0.94, 0.07, 14.0),
    ]);
    // Lit windows in the near skyline, flickering slowly.
    final window = Paint()..color = colors.gold.withValues(alpha: 0.8);
    for (var i = 0; i < 9; i++) {
      final on = math.sin(t * _tau * (2 + i % 3) + i * 1.7) > -0.4;
      if (!on) continue;
      final fx = const [0.02, 0.05, 0.1, 0.11, 0.25, 0.73, 0.8, 0.88, 0.96][i];
      final fy = const [5.0, 3.0, 8.0, 4.0, 5.0, 4.0, 8.0, 5.0, 9.0][i];
      canvas.drawRect(Rect.fromLTWH(w * fx, waterTop - fy, 1.8, 1.8), window);
    }

    // River.
    final river = Rect.fromLTWH(0, waterTop, w, h - waterTop);
    canvas.drawRect(
      river,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [waterHi, Color.lerp(waterHi, waterLo, 0.55)!, waterLo],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(river),
    );
    canvas.drawLine(
      Offset(0, waterTop + 0.5),
      Offset(w, waterTop + 0.5),
      Paint()
        ..color = glow.withValues(alpha: 0.8)
        ..strokeWidth = 1,
    );

    // Sun reflection: a column of broken gold streaks that shimmer.
    final glint = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 6; row++) {
      final y = waterTop + 4 + row * 6.0;
      final dx = math.sin(t * _tau * 6 + row * 1.7) * 4;
      final half = 26.0 - row * 3.6;
      final shimmer = 0.5 + 0.5 * math.sin(t * _tau * 9 + row * 2.3);
      glint.color = Color.lerp(
        colors.gold,
        colors.surface,
        0.35,
      )!.withValues(alpha: 0.6 + 0.35 * shimmer);
      canvas.drawLine(
        Offset(sun.dx - half + dx, y),
        Offset(sun.dx - half * 0.2 + dx, y),
        glint,
      );
      canvas.drawLine(
        Offset(sun.dx + half * 0.1 + dx, y),
        Offset(sun.dx + half + dx, y),
        glint,
      );
    }

    // Gentle drifting water shimmer dashes.
    final ripple = Paint()
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 4; row++) {
      final y = waterTop + 9 + row * 9.0;
      for (var k = 0; k < 5; k++) {
        final x =
            ((k / 5 + t * 2 * (row.isEven ? 1 : -1) + row * 0.17) % 1.0) *
                (w + 30) -
            15;
        final a = 0.5 + 0.5 * math.sin(t * _tau * 5 + k * 1.3 + row);
        ripple.color = colors.surface.withValues(alpha: 0.18 + 0.25 * a);
        canvas.drawLine(Offset(x, y), Offset(x + 9 + row * 2.0, y), ripple);
      }
    }

    // Rowboat drifting left → right once per loop, bobbing gently.
    final boatX = -50 + t * (w + 100);
    final bob = math.sin(t * _tau * 16) * 1.3;
    final tilt = math.sin(t * _tau * 16 + 0.8) * 0.035;
    final boat = Offset(boatX, waterTop + 26 + bob);
    _boat(canvas, boat, tilt, silhouette);

    // Little hearts floating up from the boat and fading.
    for (var i = 0; i < 4; i++) {
      final p = (t * 10 + i / 4) % 1.0;
      final x =
          boat.dx +
          2 +
          math.sin(p * _tau + i * 1.9) * 6 +
          (i.isEven ? -3 : 4) * p;
      final y = boat.dy - 20 - p * 46;
      final a = math.sin(p * math.pi) * (p < 0.15 ? p / 0.15 : 1.0);
      _heart(
        canvas,
        Offset(x, y),
        4.0 + 2.2 * p,
        (i.isEven ? heart : Color.lerp(heart, colors.surface, 0.35)!)
            .withValues(alpha: 0.9 * a),
      );
    }

    // Promenade deck.
    final deckRect = Rect.fromLTWH(0, deckTop, w, h - deckTop);
    canvas.drawRect(deckRect, Paint()..color = deck);
    canvas.drawRect(
      Rect.fromLTWH(0, deckTop, w, 2.5),
      Paint()..color = Color.lerp(deck, colors.gold, 0.35)!,
    );

    // Railing: top + mid rail with thin balusters and stout posts.
    final railPaint = Paint()..color = silhouette;
    final baluster = Paint()
      ..color = silhouette
      ..strokeWidth = 1.4;
    final postGap = w / 8;
    for (var x = 4.0; x < w; x += 9) {
      canvas.drawLine(Offset(x, railTop + 2), Offset(x, deckTop), baluster);
    }
    for (var i = 0; i <= 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * postGap - 2.5, railTop - 2, 5, deckTop - railTop + 2),
        railPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, railTop - 1, w, 3.5),
        const Radius.circular(2),
      ),
      railPaint,
    );
    canvas.drawRect(Rect.fromLTWH(0, railTop + 11, w, 1.8), railPaint);
    canvas.drawLine(
      Offset(0, railTop - 0.5),
      Offset(w, railTop - 0.5),
      Paint()
        ..color = colors.gold.withValues(alpha: 0.55)
        ..strokeWidth = 0.8,
    );

    // Lamp posts holding the string lights.
    final lampXs = [w * 0.22, w * 0.79];
    final lampTop = waterTop - 18;
    for (final x in lampXs) {
      canvas.drawRect(
        Rect.fromLTWH(x - 1.5, lampTop, 3, deckTop - lampTop),
        railPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, lampTop - 3), width: 7, height: 8),
          const Radius.circular(2),
        ),
        railPaint,
      );
      final lampGlow = 0.5 + 0.5 * math.sin(t * _tau * 3 + x);
      canvas.drawCircle(
        Offset(x, lampTop - 3),
        9 + 2 * lampGlow,
        Paint()..color = colors.gold.withValues(alpha: 0.18 + 0.1 * lampGlow),
      );
      canvas.drawCircle(
        Offset(x, lampTop - 3),
        2.2,
        Paint()..color = Color.lerp(colors.gold, colors.surface, 0.5)!,
      );
    }

    // String lights swagging between the posts (and off both edges).
    final anchors = [
      Offset(-12, lampTop + 2),
      for (final x in lampXs) Offset(x, lampTop),
      Offset(w + 12, lampTop + 2),
    ];
    final wire = Paint()
      ..color = silhouette.withValues(alpha: 0.85)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    var bulbIndex = 0;
    for (var s = 0; s < anchors.length - 1; s++) {
      final a = anchors[s];
      final b = anchors[s + 1];
      final span = b.dx - a.dx;
      final sag = 6 + span * 0.07;
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(
            (a.dx + b.dx) / 2,
            (a.dy + b.dy) / 2 + sag * 2,
            b.dx,
            b.dy,
          ),
        wire,
      );
      final n = math.max(2, (span / 19).round());
      for (var k = 1; k < n; k++) {
        final u = k / n;
        final p = Offset(
          a.dx + span * u,
          a.dy + (b.dy - a.dy) * u + 4 * sag * u * (1 - u),
        );
        if (p.dx < -4 || p.dx > w + 4) continue;
        _bulb(canvas, p, bulbIndex++);
      }
    }

    // Bench on the promenade, seen from behind, facing the water.
    _bench(canvas, Offset(w * 0.17, deckTop + 12), silhouette);

    // Fireflies blinking along the promenade and the near water.
    for (var i = 0; i < 7; i++) {
      final p = (t * (3 + i % 3) + i * 0.37) % 1.0;
      final blink = p < 0.4 ? math.sin(p / 0.4 * math.pi) : 0.0;
      if (blink <= 0.02) continue;
      final fx = const [0.06, 0.27, 0.44, 0.66, 0.74, 0.9, 0.97][i];
      final base = Offset(w * fx, railTop - 8 - (i % 3) * 7.0);
      final c = base.translate(
        math.sin(t * _tau * (2 + i % 2) + i) * 8,
        math.cos(t * _tau * 3 + i * 1.3) * 4,
      );
      canvas.drawCircle(
        c,
        4.5,
        Paint()..color = colors.gold.withValues(alpha: 0.28 * blink),
      );
      canvas.drawCircle(
        c,
        1.5,
        Paint()
          ..color = Color.lerp(
            colors.gold,
            colors.surface,
            0.55,
          )!.withValues(alpha: blink),
      );
    }
  }

  void _skyline(
    Canvas canvas,
    double w,
    double base,
    Color color,
    List<(double, double, double)> blocks,
  ) {
    final paint = Paint()..color = color;
    for (final (fx, fw, bh) in blocks) {
      canvas.drawRect(
        Rect.fromLTWH(w * fx, base - bh, w * fw + 0.5, bh),
        paint,
      );
    }
  }

  void _bulb(Canvas canvas, Offset p, int i) {
    final tw = 0.5 + 0.5 * math.sin(t * _tau * (4 + i % 5) + i * 2.4);
    final warm = i % 3 == 1
        ? Color.lerp(colors.heart, colors.gold, 0.45)!
        : Color.lerp(colors.gold, colors.surface, 0.3)!;
    canvas.drawLine(
      p,
      p.translate(0, 2.5),
      Paint()
        ..color = colors.pill
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      p.translate(0, 5),
      5 + 2 * tw,
      Paint()..color = warm.withValues(alpha: 0.12 + 0.22 * tw),
    );
    canvas.drawCircle(
      p.translate(0, 5),
      2.3,
      Paint()..color = Color.lerp(warm, colors.surface, 0.2 + 0.5 * tw)!,
    );
  }

  void _boat(Canvas canvas, Offset c, double tilt, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    final paint = Paint()..color = color;

    // Reflection of the boat on the water.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 6), width: 40, height: 4),
      Paint()..color = color.withValues(alpha: 0.25),
    );

    // Figures: two silhouettes leaning towards each other.
    for (final (dx, lean, r) in const [(-6.0, 0.18, 3.0), (5.0, -0.2, 2.7)]) {
      canvas.save();
      canvas.translate(dx, -3);
      canvas.rotate(lean);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-3.2, -10, 6.4, 10),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        paint,
      );
      canvas.drawCircle(Offset(0, -12.5), r, paint);
      canvas.restore();
    }

    // Oar resting in the water.
    canvas.drawLine(
      const Offset(-2, -6),
      const Offset(-20, 5),
      Paint()
        ..color = color
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );

    // Hull.
    canvas.drawPath(
      Path()
        ..moveTo(-21, -3)
        ..lineTo(21, -3)
        ..quadraticBezierTo(18, 4, 10, 4.5)
        ..lineTo(-12, 4.5)
        ..quadraticBezierTo(-18, 3.5, -21, -3)
        ..close(),
      paint,
    );
    canvas.drawLine(
      const Offset(-19, -3),
      const Offset(19.5, -3),
      Paint()
        ..color = colors.gold.withValues(alpha: 0.6)
        ..strokeWidth = 0.8,
    );
    canvas.restore();
  }

  void _bench(Canvas canvas, Offset c, Color color) {
    final paint = Paint()..color = color;
    // Legs.
    for (final dx in const [-15.0, 15.0]) {
      canvas.drawRect(Rect.fromLTWH(c.dx + dx - 1.5, c.dy - 10, 3, 10), paint);
    }
    // Seat + two backrest slats with posts.
    canvas.drawRect(Rect.fromLTWH(c.dx - 20, c.dy - 11, 40, 3), paint);
    canvas.drawRect(Rect.fromLTWH(c.dx - 18, c.dy - 22, 2.5, 12), paint);
    canvas.drawRect(Rect.fromLTWH(c.dx + 15.5, c.dy - 22, 2.5, 12), paint);
    for (final dy in const [-22.0, -17.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(c.dx - 21, c.dy + dy, 42, 3),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
    // Warm rim light along the top slat.
    canvas.drawLine(
      Offset(c.dx - 20, c.dy - 22),
      Offset(c.dx + 20, c.dy - 22),
      Paint()
        ..color = colors.gold.withValues(alpha: 0.6)
        ..strokeWidth = 0.8,
    );
  }

  void _bird(Canvas canvas, Offset c, double s, double flap, Color color) {
    final wing = s * (0.15 + 0.55 * flap);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - s, c.dy - wing)
        ..quadraticBezierTo(c.dx - s * 0.4, c.dy - wing * 0.2, c.dx, c.dy)
        ..quadraticBezierTo(
          c.dx + s * 0.4,
          c.dy - wing * 0.2,
          c.dx + s,
          c.dy - wing,
        ),
      Paint()
        ..color = color
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _heart(Canvas canvas, Offset c, double s, Color color) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy + s * 0.9)
        ..cubicTo(
          c.dx - s * 1.6,
          c.dy - s * 0.1,
          c.dx - s * 0.9,
          c.dy - s * 1.3,
          c.dx,
          c.dy - s * 0.45,
        )
        ..cubicTo(
          c.dx + s * 0.9,
          c.dy - s * 1.3,
          c.dx + s * 1.6,
          c.dy - s * 0.1,
          c.dx,
          c.dy + s * 0.9,
        )
        ..close(),
      Paint()..color = color,
    );
  }

  void _cloud(Canvas canvas, Offset c, double r, Color color, Color under) {
    // Gold-lit underside first, then the pink body offset upward.
    final lit = Paint()..color = under;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(0, r * 0.55),
          width: r * 6,
          height: r * 1.1,
        ),
        Radius.circular(r),
      ),
      lit,
    );
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(0, r * 0.25),
          width: r * 5.6,
          height: r * 1.2,
        ),
        Radius.circular(r),
      ),
      paint,
    );
    canvas.drawCircle(c.translate(-r * 0.9, -r * 0.1), r * 0.85, paint);
    canvas.drawCircle(c.translate(r * 0.4, -r * 0.4), r, paint);
    canvas.drawCircle(c.translate(r * 1.6, 0), r * 0.6, paint);
  }

  @override
  bool shouldRepaint(CouplesScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.red != red ||
      old.topPadding != topPadding;
}
