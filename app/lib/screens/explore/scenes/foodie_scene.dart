import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Foodie Adventure — "Market morning": a street market under a soft
/// morning sky. Three stalls with striped scalloped awnings (bread, fruit,
/// a noodle pot) flank a bakery whose window glow breathes. Lantern
/// strings swing overhead, awning fringes ripple, steam curls rise from
/// the pot and bowls, little food icons pop up from the stalls and float
/// away, and a tiny cart rolls along the street. All motion is integer
/// multiples of the 40s loop so it repeats seamlessly.
class FoodieScenePainter extends CustomPainter {
  FoodieScenePainter(this.t, BuildContext context)
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

  Color get _cream => colors.onDark;
  Color get _wood => Color.lerp(colors.goldDeep, colors.pill, 0.35)!;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final streetTop = visibleBottom - 24;
    final counterTop = streetTop - 28;
    final awningTop = counterTop - 52;

    _sky(canvas, w, streetTop);
    _rooftops(canvas, w, awningTop + 6);

    // Street.
    final street = Rect.fromLTWH(0, streetTop, w, h - streetTop);
    canvas.drawRect(
      street,
      Paint()..color = Color.lerp(colors.ground, colors.goldDeep, 0.22)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, streetTop, w, 3),
      Paint()..color = Color.lerp(colors.ground, colors.goldDeep, 0.45)!,
    );
    final cobble = Paint()
      ..color = Color.lerp(colors.ground, colors.goldDeep, 0.38)!
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var row = 0; row < 2; row++) {
      final y = streetTop + 9 + row * 8.0;
      for (var x = (row.isEven ? 6.0 : 16.0); x < w; x += 22) {
        canvas.drawLine(Offset(x, y), Offset(x + 9, y), cobble);
      }
    }

    // Stalls + bakery, left to right.
    final stalls = [
      (8.0, 104.0, accents.artistic, 0),
      (206.0, 300.0, accents.stories, 1),
      (304.0, 394.0, accents.peaceful, 2),
    ];
    for (final (x0, x1, c, _) in stalls) {
      _stallBody(canvas, x0, x1, awningTop, counterTop, streetTop, c);
    }
    _bakery(canvas, 108, 202, awningTop - 22, counterTop, streetTop);

    // Goods on the counters.
    _breads(canvas, 8, 104, counterTop);
    _fruit(canvas, 206, 300, counterTop);
    final potAt = Offset(334, counterTop);
    _potAndBowls(canvas, potAt, counterTop);

    // Awnings drawn last so their fringe overlaps the stall tops.
    for (final (x0, x1, c, i) in stalls) {
      _awning(canvas, x0, x1, awningTop, c, i * 2.1);
    }

    // Steam from the pot and the two bowls.
    _steam(canvas, potAt.translate(0, -20), 3, 30, 1.0, 0);
    _steam(canvas, Offset(372, counterTop - 8), 2, 22, 0.7, 1.3);
    _steam(canvas, Offset(312, counterTop - 8), 2, 22, 0.7, 2.6);

    // Lantern strings between two poles and the bakery gable.
    final poleL = Offset(66, awningTop - 30);
    final poleR = Offset(338, awningTop - 30);
    final gable = Offset(155, awningTop - 40);
    final pole = Paint()
      ..color = _wood
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(poleL, Offset(poleL.dx, awningTop + 4), pole);
    canvas.drawLine(poleR, Offset(poleR.dx, awningTop + 4), pole);
    _lanternString(canvas, poleL, gable, 4, 0);
    _lanternString(canvas, gable, poleR, 6, 4);

    // Food icons popping up from the stalls and floating away.
    _foodIcons(canvas, counterTop);

    // Tiny cart rolling along the street (twice per loop).
    _cart(canvas, w, streetTop, visibleBottom);
  }

  // ---------------------------------------------------------------- sky

  void _sky(Canvas canvas, double w, double bottom) {
    final skyTop = HSLColor.fromColor(colors.groundTop)
        .withSaturation(0.45)
        .withLightness(0.82)
        .toColor();
    final morning = Color.lerp(colors.ground, colors.gold, 0.3)!;
    final rect = Rect.fromLTWH(0, 0, w, bottom);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, morning],
        ).createShader(rect),
    );

    // Soft morning sun, breathing halo.
    final pulse = math.sin(t * _tau * 5);
    final sun = Offset(w * 0.72, topPadding + 20);
    canvas.drawCircle(
      sun,
      34 + 2 * pulse,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      sun,
      23 + 1.5 * pulse,
      Paint()..color = colors.gold.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      sun,
      15,
      Paint()..color = Color.lerp(colors.gold, Colors.white, 0.25)!,
    );

    final cloud = Colors.white.withValues(alpha: 0.8);
    _cloud(
      canvas,
      Offset(w * 0.3 + math.sin(t * _tau) * 14, topPadding + 18),
      10,
      cloud,
    );
    _cloud(
      canvas,
      Offset(w * 0.56 + math.sin(t * _tau + 2) * 10, topPadding + 4),
      7,
      cloud.withValues(alpha: 0.6),
    );
  }

  void _rooftops(Canvas canvas, double w, double base) {
    final far = Color.lerp(colors.groundTop, colors.ink, 0.14)!;
    final near = Color.lerp(colors.groundTop, colors.ink, 0.24)!;
    final win = Color.lerp(
      colors.gold,
      Colors.white,
      0.4,
    )!.withValues(alpha: 0.7);
    final farPaint = Paint()..color = far;
    final nearPaint = Paint()..color = near;
    final winPaint = Paint()..color = win;
    // (x, width, height, pitched?)
    for (final (x, bw, bh, pitched) in const [
      (-6.0, 46.0, 26.0, false),
      (36.0, 40.0, 44.0, true),
      (214.0, 36.0, 50.0, false),
      (246.0, 44.0, 36.0, true),
      (288.0, 40.0, 46.0, false),
      (326.0, 42.0, 30.0, true),
      (364.0, 46.0, 24.0, false),
    ]) {
      final paint = pitched ? nearPaint : farPaint;
      canvas.drawRect(Rect.fromLTWH(x, base - bh, bw, bh + 2), paint);
      if (pitched) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 3, base - bh)
            ..lineTo(x + bw / 2, base - bh - 12)
            ..lineTo(x + bw + 3, base - bh)
            ..close(),
          paint,
        );
      }
      for (var wy = base - bh + 7; wy < base - 8; wy += 11) {
        for (var wx = x + 7; wx < x + bw - 8; wx += 12) {
          canvas.drawRect(Rect.fromLTWH(wx, wy, 4, 5), winPaint);
        }
      }
    }
  }

  // -------------------------------------------------------------- stalls

  void _stallBody(
    Canvas canvas,
    double x0,
    double x1,
    double awningTop,
    double counterTop,
    double streetTop,
    Color c,
  ) {
    // Shaded back wall under the awning.
    canvas.drawRect(
      Rect.fromLTRB(x0 + 3, awningTop + 10, x1 - 3, counterTop),
      Paint()..color = Color.lerp(colors.pill, c, 0.22)!,
    );
    // Posts.
    final post = Paint()..color = _wood;
    canvas.drawRect(
      Rect.fromLTRB(x0 + 3, awningTop + 8, x0 + 6, counterTop),
      post,
    );
    canvas.drawRect(
      Rect.fromLTRB(x1 - 6, awningTop + 8, x1 - 3, counterTop),
      post,
    );
    // Counter: cream front panel with a colored skirt band.
    final front = Rect.fromLTRB(x0, counterTop, x1, streetTop + 1);
    canvas.drawRect(
      front,
      Paint()..color = Color.lerp(_cream, colors.goldDeep, 0.18)!,
    );
    canvas.drawRect(
      Rect.fromLTRB(x0, counterTop + 9, x1, counterTop + 15),
      Paint()..color = Color.lerp(c, _cream, 0.15)!,
    );
    canvas.drawRect(
      Rect.fromLTRB(x0 - 2, counterTop - 3, x1 + 2, counterTop + 2),
      Paint()..color = _wood,
    );
  }

  void _awning(
    Canvas canvas,
    double x0,
    double x1,
    double top,
    Color c,
    double phase,
  ) {
    const stripes = 7;
    const depth = 16.0;
    final bottom = top + depth;
    final stripeW = (x1 - x0 + 8) / stripes;
    final cream = Paint()..color = _cream;
    final color = Paint()..color = c;
    final shade = Paint()..color = Color.lerp(c, colors.pill, 0.25)!;
    final creamShade = Paint()..color = Color.lerp(_cream, c, 0.2)!;

    // Scalloped fringe first so the canopy edge sits on top of it.
    for (var i = 0; i < stripes; i++) {
      final cx = x0 - 4 + stripeW * (i + 0.5);
      final wave = math.sin(t * _tau * 12 - i * 0.9 + phase);
      final r = stripeW / 2;
      final rect = Rect.fromCenter(
        center: Offset(cx + wave * 0.8, bottom),
        width: stripeW,
        height: r * 2 * (1.05 + 0.14 * wave),
      );
      canvas.drawArc(rect, 0, math.pi, true, i.isEven ? shade : creamShade);
    }
    // Sloped canopy: narrower at the top, stripes fanning outward.
    for (var i = 0; i < stripes; i++) {
      final bl = x0 - 4 + stripeW * i;
      final br = bl + stripeW;
      final tl = x0 + 6 + (x1 - x0 - 12) * i / stripes;
      final tr = x0 + 6 + (x1 - x0 - 12) * (i + 1) / stripes;
      canvas.drawPath(
        Path()
          ..moveTo(tl, top)
          ..lineTo(tr, top)
          ..lineTo(br, bottom)
          ..lineTo(bl, bottom)
          ..close(),
        i.isEven ? color : cream,
      );
    }
    // Rail along the top.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x0 + 3, top - 3, x1 - 3, top + 1.5),
        const Radius.circular(2),
      ),
      Paint()..color = _wood,
    );
  }

  // -------------------------------------------------------------- bakery

  void _bakery(
    Canvas canvas,
    double x0,
    double x1,
    double top,
    double counterTop,
    double streetTop,
  ) {
    final cx = (x0 + x1) / 2;
    final facade = Color.lerp(colors.card, colors.goldDeep, 0.3)!;
    final trim = Color.lerp(colors.pill, colors.goldDeep, 0.25)!;

    // Facade + gable.
    canvas.drawRect(
      Rect.fromLTRB(x0, top, x1, streetTop + 1),
      Paint()..color = facade,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x0 - 5, top + 1)
        ..lineTo(cx, top - 18)
        ..lineTo(x1 + 5, top + 1)
        ..close(),
      Paint()..color = trim,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x0 + 6, top - 1)
        ..lineTo(cx, top - 13)
        ..lineTo(x1 - 6, top - 1)
        ..close(),
      Paint()..color = facade,
    );

    // Breathing window glow.
    final breathe = 0.5 + 0.5 * math.sin(t * _tau * 4);
    final win = Rect.fromLTRB(x0 + 14, top + 22, x1 - 14, counterTop + 2);
    final glowRect = win.inflate(10 + 5 * breathe);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glowRect, Radius.circular(glowRect.width / 2)),
      Paint()
        ..color = colors.gold.withValues(alpha: 0.18 + 0.16 * breathe)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    final arch = RRect.fromRectAndCorners(
      win,
      topLeft: Radius.circular(win.width / 2),
      topRight: Radius.circular(win.width / 2),
    );
    canvas.drawRRect(arch.inflate(3.5), Paint()..color = trim);
    canvas.drawRRect(
      arch,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.3),
          radius: 0.9,
          colors: [
            Color.lerp(colors.gold, Colors.white, 0.55 + 0.2 * breathe)!,
            Color.lerp(colors.gold, colors.goldDeep, 0.3 - 0.2 * breathe)!,
          ],
        ).createShader(win),
    );
    // Shelves of loaves inside.
    final shelf = Paint()..color = trim.withValues(alpha: 0.55);
    final loaf = Paint()..color = Color.lerp(colors.goldDeep, trim, 0.25)!;
    for (final (row, y) in [(0, win.top + 30), (1, win.bottom - 8)]) {
      canvas.drawRect(
        Rect.fromLTRB(win.left + 3, y, win.right - 3, y + 2.5),
        shelf,
      );
      for (var k = 0; k < (row == 0 ? 3 : 4); k++) {
        final n = row == 0 ? 3 : 4;
        final lx = win.left + (k + 0.5) * win.width / n;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(lx, y - 3.5), width: 11, height: 7),
          loaf,
        );
      }
    }
    // Mullions.
    final mullion = Paint()
      ..color = trim
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx, win.top), Offset(cx, win.bottom), mullion);

    // Sill + flower box.
    canvas.drawRect(
      Rect.fromLTRB(
        win.left - 6,
        counterTop - 1,
        win.right + 6,
        counterTop + 6,
      ),
      Paint()..color = trim,
    );
    final leaf = Paint()
      ..color = Color.lerp(accents.peaceful, colors.pill, 0.1)!;
    final bloom = Paint()..color = colors.heart;
    for (var k = 0; k < 6; k++) {
      final fx = win.left - 2 + k * (win.width + 4) / 5;
      canvas.drawCircle(Offset(fx, counterTop - 2), 3.4, leaf);
      if (k.isOdd) canvas.drawCircle(Offset(fx, counterTop - 4), 2, bloom);
    }
    // Brick plinth lines.
    final brick = Paint()
      ..color = trim.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var y = counterTop + 12; y < streetTop; y += 7) {
      canvas.drawLine(Offset(x0, y), Offset(x1, y), brick);
    }
  }

  // --------------------------------------------------------------- goods

  void _breads(Canvas canvas, double x0, double x1, double top) {
    final crust = Paint()..color = colors.goldDeep;
    final light = Paint()..color = Color.lerp(colors.gold, Colors.white, 0.2)!;
    final score = Paint()
      ..color = Color.lerp(colors.gold, Colors.white, 0.55)!
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    // Baguettes leaning in a basket.
    final basket = Paint()..color = _wood;
    for (var k = 0; k < 3; k++) {
      canvas.save();
      canvas.translate(x0 + 20 + k * 5, top - 4);
      canvas.rotate(-0.35 + k * 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-3, -30, 6, 30),
          const Radius.circular(3),
        ),
        k.isEven ? crust : light,
      );
      canvas.restore();
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x0 + 12, top - 11, 24, 11),
        const Radius.circular(3),
      ),
      basket,
    );
    // Round boules and an oval loaf.
    for (final (dx, r) in const [(50.0, 9.0), (68.0, 8.0)]) {
      final c = Offset(x0 + dx, top - r + 1);
      canvas.drawCircle(c, r, crust);
      canvas.drawCircle(c.translate(-2, -2), r * 0.6, light);
      canvas.drawLine(c.translate(-3, -2), c.translate(3, 2), score);
    }
    final loaf = Rect.fromCenter(
      center: Offset(x0 + 85, top - 6),
      width: 24,
      height: 12,
    );
    canvas.drawOval(loaf, crust);
    for (var k = -1; k <= 1; k++) {
      canvas.drawLine(
        loaf.center.translate(k * 6 - 2, -3),
        loaf.center.translate(k * 6 + 2, 1),
        score,
      );
    }
  }

  void _fruit(Canvas canvas, double x0, double x1, double top) {
    final crate = Paint()..color = _wood;
    final shine = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final piles = [
      (x0 + 24, accents.artistic),
      (x0 + 47, accents.stories),
      (x0 + 70, Color.lerp(accents.peaceful, colors.gold, 0.35)!),
    ];
    for (final (cx, c) in piles) {
      canvas.drawRect(Rect.fromLTWH(cx - 11, top - 6, 22, 6), crate);
      final p = Paint()..color = c;
      const r = 4.2;
      for (var row = 0; row < 3; row++) {
        final n = 3 - row;
        for (var k = 0; k < n; k++) {
          final o = Offset(
            cx + (k - (n - 1) / 2) * r * 2,
            top - 6 - r - row * r * 1.7,
          );
          canvas.drawCircle(o, r, p);
          canvas.drawCircle(o.translate(-1.3, -1.3), 1.1, shine);
        }
      }
    }
    // A bunch of bananas at the end.
    final banana = Paint()
      ..color = Color.lerp(colors.gold, Colors.white, 0.15)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 3; k++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x1 - 13 + k * 2.0, top - 10),
          width: 14,
          height: 14,
        ),
        0.3,
        2.2,
        false,
        banana,
      );
    }
  }

  void _potAndBowls(Canvas canvas, Offset base, double top) {
    final iron = Paint()..color = Color.lerp(colors.pill, colors.ink, 0.3)!;
    final rim = Paint()..color = Color.lerp(colors.ink, colors.muted, 0.4)!;
    // Little stove block, pot body and rim.
    canvas.drawRect(
      Rect.fromCenter(center: base.translate(0, -3), width: 20, height: 6),
      Paint()..color = _wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(center: base.translate(0, -12), width: 26, height: 14),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
      iron,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: base.translate(0, -19), width: 30, height: 4),
        const Radius.circular(2),
      ),
      rim,
    );
    // Flame flicker under the pot.
    final flick = 0.5 + 0.5 * math.sin(t * _tau * 30);
    canvas.drawOval(
      Rect.fromCenter(
        center: base.translate(0, -6),
        width: 12,
        height: 3 + flick * 1.5,
      ),
      Paint()..color = accents.artistic.withValues(alpha: 0.85),
    );
    // Noodle bowls either side.
    for (final bx in [base.dx - 22, base.dx + 38]) {
      _bowl(canvas, Offset(bx, top - 1), 1.0);
    }
  }

  /// A noodle bowl whose rim sits at [rim.dy - 7 * s].
  void _bowl(Canvas canvas, Offset base, double s) {
    final rimY = base.dy - 7 * s;
    final noodle = Paint()
      ..color = Color.lerp(colors.gold, Colors.white, 0.45)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round;
    final waves = Path();
    for (var k = 0; k < 3; k++) {
      final y = rimY - 1.2 * s - k * 1.6 * s;
      waves.moveTo(base.dx - 6 * s, y);
      for (var j = 0; j < 4; j++) {
        waves.relativeQuadraticBezierTo(1.5 * s, -2 * s, 3 * s, 0);
      }
    }
    canvas.drawPath(waves, noodle);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(base.dx, rimY),
        width: 18 * s,
        height: 14 * s,
      ),
      0,
      math.pi,
      true,
      Paint()..color = colors.surface,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(base.dx, rimY + 2.6 * s),
        width: 15 * s,
        height: 1.6 * s,
      ),
      Paint()..color = colors.danger,
    );
    final sticks = Paint()
      ..color = _wood
      ..strokeWidth = 1.3 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(base.dx + 2 * s, rimY - 2 * s),
      Offset(base.dx + 9 * s, rimY - 11 * s),
      sticks,
    );
    canvas.drawLine(
      Offset(base.dx + 4 * s, rimY - 1.5 * s),
      Offset(base.dx + 11 * s, rimY - 9.5 * s),
      sticks,
    );
  }

  /// Wavy translucent curls rising from [origin] and fading.
  void _steam(
    Canvas canvas,
    Offset origin,
    int curls,
    double rise,
    double scale,
    double phase,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2 * scale;
    for (var k = 0; k < curls; k++) {
      final p = (t * 16 + k / curls + phase) % 1.0;
      final y0 = origin.dy - p * rise;
      final xOff = (k - (curls - 1) / 2) * 6 * scale;
      final alpha = 0.7 * math.sin(p * math.pi);
      paint.color = Colors.white.withValues(alpha: alpha);
      final path = Path();
      const seg = 7;
      for (var j = 0; j <= seg; j++) {
        final q = j / seg;
        final y = y0 - q * 12 * scale;
        final x =
            origin.dx +
            xOff +
            math.sin(q * _tau + p * _tau + k) * 2.6 * scale +
            p * 3 * scale;
        j == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  // ------------------------------------------------------------ lanterns

  Offset _quad(Offset a, Offset c, Offset b, double s) {
    final u = 1 - s;
    return a * (u * u) + c * (2 * u * s) + b * (s * s);
  }

  void _lanternString(
    Canvas canvas,
    Offset a,
    Offset b,
    int count,
    int offset,
  ) {
    final sag = 14 + 1.5 * math.sin(t * _tau * 4 + offset);
    final ctrl = Offset((a.dx + b.dx) / 2, math.max(a.dy, b.dy) + sag * 2);
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy),
      Paint()
        ..color = _wood
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final palette = [colors.gold, accents.artistic, accents.stories];
    final cap = Paint()..color = _wood;
    final rib = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final cord = Paint()
      ..color = _wood
      ..strokeWidth = 1;
    for (var i = 0; i < count; i++) {
      final s = (i + 0.5) / count;
      final anchor = _quad(a, ctrl, b, s);
      final idx = i + offset;
      final swing = math.sin(t * _tau * 6 + idx * 0.9) * 0.2;
      final c = palette[idx % palette.length];
      const r = 6.0;
      canvas.save();
      canvas.translate(anchor.dx, anchor.dy);
      canvas.rotate(swing);
      canvas.drawLine(Offset.zero, const Offset(0, 4), cord);
      final body = Offset(0, 4 + r);
      canvas.drawCircle(
        body,
        r + 3,
        Paint()..color = c.withValues(alpha: 0.18),
      );
      canvas.drawOval(
        Rect.fromCenter(center: body, width: r * 2.2, height: r * 2),
        Paint()..color = c,
      );
      rib.color = Color.lerp(c, colors.pill, 0.3)!;
      canvas.drawOval(
        Rect.fromCenter(center: body, width: r * 1.0, height: r * 2),
        rib,
      );
      canvas.drawCircle(
        body.translate(-2.4, -2),
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, 4.5), width: 5, height: 2),
        cap,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, 4 + r * 2), width: 5, height: 2),
        cap,
      );
      canvas.restore();
    }
  }

  // ---------------------------------------------------------- food icons

  void _foodIcons(Canvas canvas, double counterTop) {
    // Each track pops 6 times per loop; type and origin rotate through 3
    // so the loop seam lines up (6 % 3 == 0).
    const origins = [(60.0, 18.0), (252.0, -10.0), (338.0, -30.0)];
    final bubble = Paint();
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var k = 0; k < 3; k++) {
      final phase = t * 6 + k / 3;
      final p = phase % 1.0;
      if (p > 0.55) continue;
      final cycle = phase.floor();
      final type = (cycle + k) % 3;
      final (ox, drift) = origins[(cycle * 2 + k) % 3];
      final q = p / 0.55;
      final pop = q < 0.18 ? Curves.easeOutBack.transform(q / 0.18) : 1.0;
      final alpha = q < 0.6 ? 1.0 : 1 - (q - 0.6) / 0.4;
      final pos = Offset(
        ox + drift * q + math.sin(q * _tau) * 4,
        counterTop - 20 - q * 62,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.scale(pop * 0.95);
      canvas.rotate(math.sin(q * _tau) * 0.15);
      bubble.color = Color.lerp(
        colors.surface,
        accents.artistic,
        0.2,
      )!.withValues(alpha: 0.92 * alpha);
      canvas.drawCircle(Offset.zero, 14, bubble);
      ring.color = accents.artistic.withValues(alpha: 0.6 * alpha);
      canvas.drawCircle(Offset.zero, 14, ring);
      switch (type) {
        case 0:
          _croissant(canvas, alpha);
        case 1:
          _bowl(canvas, const Offset(-1, 6), 0.7);
        default:
          _strawberry(canvas, alpha);
      }
      canvas.restore();
    }
  }

  void _croissant(Canvas canvas, double alpha) {
    // Crescent: a disc with a lower bite taken out, horns pointing down.
    final crescent = Path()
      ..moveTo(-10, 6)
      ..quadraticBezierTo(-11, -8, 0, -8)
      ..quadraticBezierTo(11, -8, 10, 6)
      ..quadraticBezierTo(6, -1, 0, -1)
      ..quadraticBezierTo(-6, -1, -10, 6)
      ..close();
    canvas.drawPath(
      crescent,
      Paint()..color = colors.gold.withValues(alpha: alpha),
    );
    final score = Paint()
      ..color = colors.goldDeep.withValues(alpha: alpha)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (final x in const [-4.5, 0.0, 4.5]) {
      canvas.drawLine(Offset(x * 1.1, -7.5), Offset(x * 1.3, -1.5), score);
    }
    canvas.drawCircle(
      const Offset(-3, -5.5),
      1.4,
      Paint()..color = Colors.white.withValues(alpha: 0.5 * alpha),
    );
  }

  void _strawberry(Canvas canvas, double alpha) {
    final red = Paint()..color = accents.stories.withValues(alpha: alpha);
    canvas.drawPath(
      Path()
        ..moveTo(-7, -3)
        ..quadraticBezierTo(-8, 3, 0, 9)
        ..quadraticBezierTo(8, 3, 7, -3)
        ..quadraticBezierTo(0, -6, -7, -3)
        ..close(),
      red,
    );
    final seed = Paint()
      ..color = Color.lerp(
        colors.gold,
        Colors.white,
        0.4,
      )!.withValues(alpha: alpha);
    for (final o in const [
      Offset(-3, 0),
      Offset(2, -1),
      Offset(0, 3),
      Offset(4, 3),
      Offset(-2, 5),
    ]) {
      canvas.drawCircle(o, 0.8, seed);
    }
    final leaf = Paint()..color = accents.peaceful.withValues(alpha: alpha);
    for (final a in const [-0.9, 0.0, 0.9]) {
      canvas.save();
      canvas.translate(0, -4);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -2), width: 3, height: 6),
        leaf,
      );
      canvas.restore();
    }
  }

  // ---------------------------------------------------------------- cart

  void _cart(Canvas canvas, double w, double streetTop, double visibleBottom) {
    final p = (t * 2) % 1.0;
    final x = -60 + p * (w + 120);
    final wheelR = 5.0;
    final wheelY = visibleBottom - 2 - wheelR;
    final bob = math.sin(t * _tau * 60).abs() * 0.8;
    final bodyTop = wheelY - 14 - bob;

    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, visibleBottom - 1.5),
        width: 44,
        height: 4,
      ),
      Paint()..color = colors.shadow(0.15),
    );
    // Canopy on two poles.
    final pole = Paint()
      ..color = _wood
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(x - 13, bodyTop),
      Offset(x - 13, bodyTop - 14),
      pole,
    );
    canvas.drawLine(
      Offset(x + 13, bodyTop),
      Offset(x + 13, bodyTop - 14),
      pole,
    );
    for (var i = 0; i < 4; i++) {
      final l = x - 18 + i * 9.0;
      canvas.drawPath(
        Path()
          ..moveTo(x - 12 + i * 6.0, bodyTop - 21)
          ..lineTo(x - 6 + i * 6.0, bodyTop - 21)
          ..lineTo(l + 9, bodyTop - 14)
          ..lineTo(l, bodyTop - 14)
          ..close(),
        Paint()..color = i.isEven ? accents.artistic : _cream,
      );
    }
    // Body with a gold band, plus a handle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 17, bodyTop, 34, 11),
        const Radius.circular(2.5),
      ),
      Paint()..color = Color.lerp(accents.artistic, colors.pill, 0.15)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(x - 17, bodyTop + 4, 34, 2.5),
      Paint()..color = colors.gold,
    );
    canvas.drawLine(
      Offset(x - 17, bodyTop + 3),
      Offset(x - 26, bodyTop - 3),
      pole..strokeWidth = 1.8,
    );
    // Goods peeking over the top: two tiny buns.
    final bun = Paint()..color = colors.goldDeep;
    canvas.drawCircle(Offset(x - 5, bodyTop - 1), 3.5, bun);
    canvas.drawCircle(Offset(x + 4, bodyTop - 1), 3.2, bun);
    // Wheels rolling with the distance travelled.
    final spin = x / wheelR;
    final tyre = Paint()..color = colors.pill;
    final hub = Paint()
      ..color = _cream
      ..strokeWidth = 1.1;
    for (final wx in [x - 10, x + 10]) {
      final c = Offset(wx, wheelY);
      canvas.drawCircle(c, wheelR, tyre);
      for (var s = 0; s < 3; s++) {
        final a = spin + s * math.pi / 3;
        final d = Offset(math.cos(a), math.sin(a)) * (wheelR - 1.5);
        canvas.drawLine(c - d, c + d, hub);
      }
    }
  }

  void _cloud(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(r * 0.95, r * 0.18), r * 0.78, paint);
    canvas.drawCircle(center.translate(-r * 0.95, r * 0.22), r * 0.72, paint);
    canvas.drawCircle(center.translate(r * 0.2, -r * 0.4), r * 0.6, paint);
  }

  @override
  bool shouldRepaint(FoodieScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.accents != accents ||
      old.topPadding != topPadding;
}
