import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Night Party — "Neon street at midnight": a deep purple sky with a
/// glowing crescent moon and twinkling stars, two spotlight beams sweeping
/// overhead, and a street of silhouetted buildings wearing neon signs (a
/// music note, a cocktail, a microphone and an OPEN sign) that hum and
/// flicker — the OPEN sign stutters every few seconds. Windows pulse to a
/// 120 bpm beat, music notes drift up out of the club doorway and the wet
/// street mirrors the neon. All motion is integer multiples of the 40s
/// loop so it repeats seamlessly.
class NightScenePainter extends CustomPainter {
  NightScenePainter(this.t, BuildContext context)
    : colors = context.colors,
      purple = context.accents.night,
      topPadding = MediaQuery.paddingOf(context).top;

  final double t;
  final AppColors colors;
  final Color purple;
  final double topPadding;

  static const _tau = math.pi * 2;

  /// The detail sheet overlaps the header's bottom by its corner radius.
  static const _sheetOverlap = AppRadius.sheet;

  // Front-row buildings: (left, right, height above the street) as
  // fractions of width / points.
  static const _front = [
    (0.0, 0.17, 60.0),
    (0.17, 0.37, 50.0),
    (0.37, 0.61, 74.0),
    (0.61, 0.81, 56.0),
    (0.81, 1.0, 64.0),
  ];

  // Back-row buildings, peeking above the front row.
  static const _back = [
    (-0.02, 0.1, 84.0),
    (0.12, 0.24, 72.0),
    (0.27, 0.36, 92.0),
    (0.55, 0.66, 86.0),
    (0.7, 0.79, 76.0),
    (0.86, 1.02, 80.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final street = visibleBottom - 30;

    // Night palette from tokens.
    final skyTop = Color.lerp(colors.pill, purple, 0.18)!;
    final skyMid = Color.lerp(colors.pill, purple, 0.45)!;
    final skyLow = Color.lerp(purple, colors.heart, 0.35)!;
    final backBld = Color.lerp(colors.pill, purple, 0.32)!;
    final frontBld = Color.lerp(colors.pill, purple, 0.12)!;
    final asphalt = Color.lerp(colors.pill, purple, 0.2)!;
    final pink = colors.heart;
    final cyan = HSLColor.fromColor(colors.groundTop)
        .withSaturation(0.9)
        .withLightness(0.64)
        .toColor();
    final lilac = Color.lerp(purple, Colors.white, 0.4)!;
    final gold = colors.gold;

    // Sky.
    final skyRect = Rect.fromLTWH(0, 0, w, street);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyLow],
          stops: const [0, 0.6, 1],
        ).createShader(skyRect),
    );

    // Stars twinkling at their own integer rates.
    final star = Paint()..color = colors.onDark;
    for (var i = 0; i < 30; i++) {
      final x = (_hash(i * 3.1) * 1.04 - 0.02) * w;
      final y = 6 + _hash(i * 7.7 + 1) * (street - 96);
      final tw = 0.5 + 0.5 * math.sin(t * _tau * (3 + i % 5) + i * 1.9);
      star.color = colors.onDark.withValues(alpha: 0.25 + 0.65 * tw);
      final r = 0.7 + (i % 3) * 0.35 + 0.3 * tw;
      canvas.drawCircle(Offset(x, y), r, star);
      if (i % 7 == 0 && tw > 0.6) {
        // A few bright ones flash a tiny cross.
        final arm = 3.5 * tw;
        final cross = Paint()
          ..color = star.color
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(x - arm, y), Offset(x + arm, y), cross);
        canvas.drawLine(Offset(x, y - arm), Offset(x, y + arm), cross);
      }
    }

    // Crescent moon with a breathing glow.
    final moon = Offset(w * 0.66, topPadding + 22);
    final breathe = math.sin(t * _tau * 4);
    canvas.drawCircle(
      moon,
      34 + 2 * breathe,
      Paint()..color = lilac.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      moon,
      23 + 1.5 * breathe,
      Paint()..color = colors.onDark.withValues(alpha: 0.14),
    );
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: moon, radius: 14)),
      Path()..addOval(Rect.fromCircle(center: moon.translate(7, -4), radius: 12)),
    );
    canvas.drawPath(crescent, Paint()..color = colors.onDark);

    // Spotlight beams sweeping from behind the buildings.
    for (final (fx, phase, tint) in [
      (0.3, 0.0, lilac),
      (0.76, 2.4, cyan),
    ]) {
      final origin = Offset(w * fx, street - 40);
      final angle = 0.55 * math.sin(t * _tau * 2 + phase) + (fx < 0.5 ? 0.15 : -0.15);
      _beam(canvas, origin, angle, 250, tint);
    }

    // Back row of buildings with sparse dim windows.
    final backPaint = Paint()..color = backBld;
    final dimWin = Paint();
    for (final (i, (l, r, bh)) in _back.indexed) {
      final rect = Rect.fromLTRB(w * l, street - bh, w * r, street);
      canvas.drawRect(rect, backPaint);
      for (var row = 0; row < 2; row++) {
        for (var col = 0; col < 3; col++) {
          if ((i + row * 2 + col) % 3 == 0) continue;
          final cx = rect.left + rect.width * (col + 1) / 4;
          final cy = rect.top + 8 + row * 11.0;
          dimWin.color = gold.withValues(alpha: 0.28);
          canvas.drawRect(
            Rect.fromCenter(center: Offset(cx, cy), width: 3, height: 5),
            dimWin,
          );
        }
      }
    }
    // A little antenna with a blinking red light on the tallest one.
    final antennaBase = Offset(w * 0.315, street - 92);
    canvas.drawLine(
      antennaBase,
      antennaBase.translate(0, -12),
      Paint()
        ..color = Color.lerp(backBld, lilac, 0.35)!
        ..strokeWidth = 1.6,
    );
    final blink = (t * 20) % 1.0 < 0.5 ? 1.0 : 0.25;
    canvas.drawCircle(
      antennaBase.translate(0, -13),
      3.5,
      Paint()
        ..color = colors.danger.withValues(alpha: 0.35 * blink)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      antennaBase.translate(0, -13),
      1.4,
      Paint()..color = Color.lerp(colors.danger, colors.heart, blink)!,
    );

    // Neon signs: (centre, intensity), shared by facade and reflection.
    final noteAt = Offset(w * 0.27, street - 26);
    final glassAt = Offset(w * 0.71, street - 28);
    final micAt = Offset(w * 0.905, street - 30);
    final openAt = Offset(w * 0.49, street - 44);
    final noteOn = _hum(1);
    final glassOn = _hum(2) * _glitch(3, 0.55, 0.025);
    final micOn = _hum(3);
    final openOn = _hum(4) * _stutter();

    // Front row.
    final frontPaint = Paint()..color = frontBld;
    final beat = math.pow(1 - (t * 80) % 1.0, 3).toDouble();
    final win = Paint();
    final signBoxes = [
      Rect.fromCenter(center: noteAt, width: 36, height: 34),
      Rect.fromCenter(center: glassAt, width: 32, height: 36),
      Rect.fromCenter(center: micAt, width: 26, height: 40),
      Rect.fromCenter(center: openAt.translate(0, 18), width: 50, height: 60),
    ];
    for (final (i, (l, r, bh)) in _front.indexed) {
      final rect = Rect.fromLTRB(w * l, street - bh, w * r + 0.5, street);
      canvas.drawRect(rect, frontPaint);
      // Rooftop ledge.
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width, 3),
        Paint()..color = backBld,
      );
      final cols = (rect.width / 13).floor();
      final rows = ((bh - 12) / 12).floor();
      for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
          final c = Offset(
            rect.left + rect.width * (col + 0.5) / cols,
            rect.top + 10 + row * 12.0,
          );
          final box = Rect.fromCenter(center: c, width: 5, height: 6);
          if (signBoxes.any((s) => s.overlaps(box))) continue;
          final seed = (i * 31 + row * 7 + col * 13) % 9;
          if (seed == 0) continue; // dark window
          final dancing = seed % 3 == 0;
          final tint = seed == 4
              ? pink
              : seed == 7
              ? lilac
              : gold;
          win.color = tint.withValues(
            alpha: dancing ? 0.35 + 0.6 * beat : 0.55,
          );
          canvas.drawRect(box, win);
        }
      }
    }

    // Club doorway in the tall middle building, spilling warm light.
    final door = Rect.fromCenter(
      center: Offset(openAt.dx, street - 13),
      width: 16,
      height: 26,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: door.bottomCenter,
        width: 60,
        height: 14 + 4 * beat,
      ),
      Paint()
        ..color = pink.withValues(alpha: 0.25 + 0.2 * beat)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        door,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(gold, pink, 0.5 + 0.3 * beat)!,
            gold,
          ],
        ).createShader(door),
    );
    // Little awning over the door.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: door.topCenter.translate(0, -3), width: 26, height: 4),
        const Radius.circular(2),
      ),
      Paint()..color = Color.lerp(pink, colors.pill, 0.35)!,
    );

    void signs(double fade) {
      _neon(canvas, _notePath(noteAt), lilac, noteOn * fade);
      _neon(canvas, _glassPath(glassAt), cyan, glassOn * fade);
      _neon(canvas, _micPath(micAt), gold, micOn * fade);
      _neon(
        canvas,
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: openAt, width: 40, height: 16),
            const Radius.circular(4),
          ),
        ),
        cyan,
        _hum(5) * fade,
        width: 1.4,
      );
      _neon(canvas, _openPath(openAt), pink, openOn * fade, width: 1.5);
    }

    signs(1);

    // Music notes floating up from the doorway (5 per loop each).
    for (var i = 0; i < 5; i++) {
      final p = (t * 5 + i / 5) % 1.0;
      final x = door.center.dx + (i - 2) * 6 + math.sin(p * _tau + i * 1.7) * 12;
      final y = door.top - 4 - p * 74;
      final a = math.sin(p * math.pi) * (p < 0.15 ? p / 0.15 : 1);
      _floatingNote(
        canvas,
        Offset(x, y),
        i.isEven ? pink : gold,
        a.clamp(0, 1).toDouble(),
        i % 3 == 0,
      );
    }

    // Street, kerb and wet reflection.
    final streetRect = Rect.fromLTRB(0, street, w, h);
    canvas.drawRect(
      streetRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [asphalt, colors.pill],
        ).createShader(streetRect),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, street, w, 2.5),
      Paint()..color = backBld,
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, street + 2.5, w, h));
    canvas.translate(0, street);
    canvas.scale(1, -0.6);
    canvas.translate(0, -street);
    signs(0.38);
    canvas.restore();

    // Puddle shimmer: drifting light dashes on the wet street.
    final shimmer = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 3; row++) {
      final y = street + 7 + row * 6.0;
      for (var k = 0; k < 5; k++) {
        final x =
            ((k / 5 + t * 3 * (row.isEven ? 1 : -1) + row * 0.13) % 1.0) *
                (w + 30) -
            15;
        final tint = [pink, cyan, gold, lilac][(k + row) % 4];
        shimmer.color = tint.withValues(alpha: 0.22 + 0.15 * beat);
        canvas.drawLine(Offset(x, y), Offset(x + 10 - row * 2.0, y), shimmer);
      }
    }
  }

  // ── Neon helpers ─────────────────────────────────────────────

  /// Steady neon hum: a faint fast shimmer around full brightness.
  double _hum(int id) =>
      0.9 + 0.1 * math.sin(t * _tau * (90 + id * 17) + id);

  /// The OPEN sign stutters roughly every 6.7s (6 times per loop).
  double _stutter() {
    final phase = (t * 6) % 1.0;
    if (phase > 0.07) return 1;
    final tick = (t * 1200).floor();
    return const [1.0, 0.1, 0.9, 0.05, 0.1, 1.0, 0.2, 0.0][tick % 8];
  }

  /// A rarer, briefer dip for another sign (`n` times per loop).
  double _glitch(int n, double offset, double length) {
    final phase = (t * n + offset) % 1.0;
    if (phase > length) return 1;
    return (t * 900).floor().isEven ? 0.15 : 0.8;
  }

  void _neon(Canvas canvas, Path path, Color c, double on, {double width = 2}) {
    // Unlit glass tube, always faintly visible.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Color.lerp(c, colors.pill, 0.55)!.withValues(alpha: 0.8 * _a(on)),
    );
    if (on < 0.05) return;
    final a = on.clamp(0.0, 1.0);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 5
        ..strokeCap = StrokeCap.round
        ..color = c.withValues(alpha: 0.45 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = c.withValues(alpha: 0.9 * a),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Color.lerp(c, Colors.white, 0.7)!.withValues(alpha: a),
    );
  }

  /// Fade for the unlit tube: reflections pass a smaller "on" scale.
  double _a(double on) => on > 0.45 ? 1 : (on / 0.45).clamp(0.3, 1.0);

  Path _notePath(Offset c) {
    // Beamed pair of eighth notes.
    final p = Path()
      ..addOval(Rect.fromCenter(center: c.translate(-7, 8), width: 8, height: 6))
      ..addOval(Rect.fromCenter(center: c.translate(7, 5), width: 8, height: 6))
      ..moveTo(c.dx - 3.2, c.dy + 7)
      ..lineTo(c.dx - 3.2, c.dy - 9)
      ..lineTo(c.dx + 10.8, c.dy - 12)
      ..lineTo(c.dx + 10.8, c.dy + 4)
      ..moveTo(c.dx - 3.2, c.dy - 5)
      ..lineTo(c.dx + 10.8, c.dy - 8);
    return p;
  }

  Path _glassPath(Offset c) => Path()
    // Martini bowl.
    ..moveTo(c.dx - 11, c.dy - 10)
    ..lineTo(c.dx + 11, c.dy - 10)
    ..lineTo(c.dx, c.dy + 2)
    ..close()
    // Stem + foot.
    ..moveTo(c.dx, c.dy + 2)
    ..lineTo(c.dx, c.dy + 12)
    ..moveTo(c.dx - 6, c.dy + 13)
    ..lineTo(c.dx + 6, c.dy + 13)
    // Olive on a pick.
    ..moveTo(c.dx + 8, c.dy - 16)
    ..lineTo(c.dx - 2, c.dy - 5)
    ..addOval(Rect.fromCircle(center: c.translate(1.5, -8.5), radius: 2.4));

  Path _micPath(Offset c) => Path()
    // Capsule head.
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, -9), width: 10, height: 15),
        const Radius.circular(5),
      ),
    )
    ..moveTo(c.dx - 5, c.dy - 9)
    ..lineTo(c.dx + 5, c.dy - 9)
    // Cradle.
    ..moveTo(c.dx - 8, c.dy - 6)
    ..quadraticBezierTo(c.dx - 8, c.dy + 6, c.dx, c.dy + 6)
    ..quadraticBezierTo(c.dx + 8, c.dy + 6, c.dx + 8, c.dy - 6)
    // Stand.
    ..moveTo(c.dx, c.dy + 6)
    ..lineTo(c.dx, c.dy + 13)
    ..moveTo(c.dx - 6, c.dy + 14)
    ..lineTo(c.dx + 6, c.dy + 14);

  /// "OPEN" spelled with plain strokes (no text rendering).
  Path _openPath(Offset c) {
    const lh = 7.0; // letter height
    const lw = 5.0; // letter width
    const gap = 3.0;
    final top = c.dy - lh / 2;
    final bot = c.dy + lh / 2;
    var x = c.dx - (lw * 4 + gap * 3) / 2;
    final p = Path()
      // O
      ..addOval(Rect.fromLTRB(x, top, x + lw, bot));
    x += lw + gap;
    p
      // P
      ..moveTo(x, bot)
      ..lineTo(x, top)
      ..lineTo(x + lw * 0.6, top)
      ..arcToPoint(
        Offset(x + lw * 0.6, c.dy),
        radius: const Radius.circular(lh / 4),
      )
      ..lineTo(x, c.dy);
    x += lw + gap;
    p
      // E
      ..moveTo(x + lw, top)
      ..lineTo(x, top)
      ..lineTo(x, bot)
      ..lineTo(x + lw, bot)
      ..moveTo(x, c.dy)
      ..lineTo(x + lw * 0.8, c.dy);
    x += lw + gap;
    p
      // N
      ..moveTo(x, bot)
      ..lineTo(x, top)
      ..lineTo(x + lw, bot)
      ..lineTo(x + lw, top);
    return p;
  }

  void _beam(Canvas canvas, Offset origin, double angle, double len, Color c) {
    const half = 0.075;
    final a1 = -math.pi / 2 + angle - half;
    final a2 = -math.pi / 2 + angle + half;
    final p1 = origin + Offset(math.cos(a1), math.sin(a1)) * len;
    final p2 = origin + Offset(math.cos(a2), math.sin(a2)) * len;
    final tip = origin + Offset(math.cos(-math.pi / 2 + angle), math.sin(-math.pi / 2 + angle)) * len;
    final path = Path()
      ..moveTo(origin.dx - 2, origin.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(origin.dx + 2, origin.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          origin,
          tip,
          [
            c.withValues(alpha: 0.34),
            c.withValues(alpha: 0.12),
            c.withValues(alpha: 0),
          ],
          const [0, 0.55, 1],
        ),
    );
  }

  void _floatingNote(Canvas canvas, Offset c, Color color, double a, bool beamed) {
    if (a <= 0.01) return;
    final paint = Paint()..color = color.withValues(alpha: a);
    final stroke = Paint()
      ..color = color.withValues(alpha: a)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      c,
      6,
      Paint()
        ..color = color.withValues(alpha: 0.25 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    if (beamed) {
      canvas.drawOval(Rect.fromCenter(center: c.translate(-3, 3), width: 4.4, height: 3.4), paint);
      canvas.drawOval(Rect.fromCenter(center: c.translate(4, 2), width: 4.4, height: 3.4), paint);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - 1, c.dy + 3)
          ..lineTo(c.dx - 1, c.dy - 5)
          ..lineTo(c.dx + 6, c.dy - 6)
          ..lineTo(c.dx + 6, c.dy + 2),
        stroke,
      );
    } else {
      canvas.drawOval(Rect.fromCenter(center: c.translate(-1, 3), width: 4.6, height: 3.6), paint);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + 1.2, c.dy + 3)
          ..lineTo(c.dx + 1.2, c.dy - 6)
          ..quadraticBezierTo(c.dx + 2, c.dy - 2, c.dx + 5, c.dy - 1),
        stroke,
      );
    }
  }

  /// Cheap deterministic 0→1 hash for star placement.
  static double _hash(double v) {
    final s = math.sin(v * 12.9898) * 43758.5453;
    return s - s.floorToDouble();
  }

  @override
  bool shouldRepaint(NightScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.purple != purple ||
      old.topPadding != topPadding;
}
