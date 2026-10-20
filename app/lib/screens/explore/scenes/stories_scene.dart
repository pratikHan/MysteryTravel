import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Real Stories — "Old town in sepia": an old-photograph town square with
/// a clock tower, a columned courthouse, gabled houses and a cobbled
/// square lit by a gas lamp. The lamp flickers, the clock's minute hand
/// ticks round once per loop, dust motes drift, a soft storyteller's
/// spotlight sweeps the facades, faint film grain and scratches play over
/// it all, and twice per loop a sealed letter flutters across. All motion
/// is integer multiples of the 40s loop so it repeats seamlessly.
class StoriesScenePainter extends CustomPainter {
  StoriesScenePainter(this.t, BuildContext context)
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

  /// A sepia tone at lightness [l], hue taken from the theme's deep gold.
  Color _sepia(double l, [double s = 0.34]) =>
      HSLColor.fromColor(colors.goldDeep)
          .withSaturation(s)
          .withLightness(l)
          .toColor();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final groundY = visibleBottom - 42;

    final paper = Color.lerp(colors.ground, colors.goldDeep, 0.1)!;
    final skyLow = Color.lerp(colors.ground, colors.goldDeep, 0.42)!;
    final far = _sepia(0.7, 0.3);
    final mid = _sepia(0.52);
    final midDark = _sepia(0.42);
    final dark = _sepia(0.26, 0.3);
    final stone = _sepia(0.77, 0.36);
    final stoneShade = _sepia(0.64, 0.32);
    final vintageRed = Color.lerp(red, colors.goldDeep, 0.3)!;
    final glowGold = Color.lerp(colors.gold, colors.surface, 0.25)!;

    // Lamp flicker: integer-frequency shimmer plus a brief sputter 7×/loop.
    final sputter = (t * 7) % 1.0;
    final flicker =
        (0.86 +
            0.06 * math.sin(t * _tau * 53) +
            0.05 * math.sin(t * _tau * 97 + 1.3) +
            0.03 * math.sin(t * _tau * 211)) *
        (sputter < 0.025 ? 0.55 + 0.45 * (sputter / 0.025) : 1.0);

    // Sky — pale paper fading to warm sepia at the horizon.
    final skyRect = Rect.fromLTWH(0, 0, w, groundY);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [paper, skyLow],
        ).createShader(skyRect),
    );

    // Hazy low sun behind the town and a couple of faded clouds.
    canvas.drawCircle(
      Offset(w * 0.6, groundY - 70),
      46,
      Paint()..color = colors.surface.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      Offset(w * 0.6, groundY - 70),
      26,
      Paint()..color = colors.surface.withValues(alpha: 0.3),
    );
    final cloud = paper.withValues(alpha: 0.7);
    _cloud(
      canvas,
      Offset(w * 0.2 + math.sin(t * _tau) * 12, topPadding + 30),
      11,
      cloud,
    );
    _cloud(
      canvas,
      Offset(w * 0.78 + math.sin(t * _tau + 2) * 10, topPadding + 18),
      9,
      cloud.withValues(alpha: 0.5),
    );

    // Far skyline: roofs, chimneys and a small dome, kept low at corners.
    final skyline = Path();
    for (final (x0, x1, top, kind) in const [
      (-0.02, 0.1, 40.0, 0),
      (0.1, 0.19, 52.0, 1),
      (0.19, 0.27, 46.0, 0),
      (0.43, 0.52, 58.0, 1),
      (0.86, 0.94, 44.0, 0),
      (0.94, 1.02, 36.0, 1),
    ]) {
      final l = w * x0;
      final r = w * x1;
      final y = groundY - top;
      skyline.addRect(Rect.fromLTRB(l, y, r, groundY));
      if (kind == 0) {
        skyline.addPolygon([
          Offset(l - 2, y),
          Offset((l + r) / 2, y - 12),
          Offset(r + 2, y),
        ], true);
      } else {
        skyline.addRect(Rect.fromLTWH(r - 10, y - 9, 4, 9));
      }
    }
    skyline.addOval(
      Rect.fromCenter(
        center: Offset(w * 0.475, groundY - 58),
        width: 22,
        height: 22,
      ),
    );
    skyline.addRect(Rect.fromLTWH(w * 0.475 - 1, groundY - 76, 2, 8));
    canvas.drawPath(skyline, Paint()..color = far);

    // Gabled houses on the left with lit windows and a red awning.
    _house(canvas, -8, 46, groundY, 30, 16, mid, dark, flicker);
    _house(canvas, 40, 96, groundY, 48, 20, midDark, dark, flicker);
    _awning(canvas, 46, 90, groundY - 22, vintageRed, paper);

    // Clock tower.
    final towerX = w * 0.37;
    _clockTower(canvas, towerX, groundY, stone, stoneShade, dark, paper);

    // Courthouse with columns and a pediment.
    _courthouse(canvas, w * 0.53, w * 0.87, groundY, stone, stoneShade, dark);

    // Low house to the right of the courthouse.
    _house(canvas, w * 0.87, w + 8, groundY, 34, 14, mid, dark, flicker);

    // Cobbled square.
    final squareRect = Rect.fromLTRB(0, groundY, w, h);
    canvas.drawRect(
      squareRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_sepia(0.5), _sepia(0.4)],
        ).createShader(squareRect),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, w, 3),
      Paint()..color = dark.withValues(alpha: 0.35),
    );
    final cobbles = Path();
    var y = groundY + 5;
    for (var row = 0; row < 9; row++) {
      final ch = 2.2 + row * 0.75;
      final cw = 7.0 + row * 2.2;
      final offset = row.isEven ? 0.0 : cw * 0.55;
      for (var x = -cw + offset; x < w + cw; x += cw + 2) {
        cobbles.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, cw, ch),
            Radius.circular(ch / 2),
          ),
        );
      }
      y += ch + 1.6;
    }
    canvas.drawPath(cobbles, Paint()..color = _sepia(0.6, 0.3));

    // Gas street lamp with a flickering warm glow and a pool of light.
    final lampX = w * 0.22;
    final lampBase = groundY + 24;
    final lampHead = Offset(lampX, groundY - 50);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(lampX, lampBase - 2),
        width: 140 * flicker,
        height: 26 * flicker,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                glowGold.withValues(alpha: 0.7 * flicker),
                glowGold.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset(lampX, lampBase - 2),
                width: 140,
                height: 26,
              ),
            ),
    );
    final glowR = 52 * flicker;
    canvas.drawCircle(
      lampHead,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowGold.withValues(alpha: 0.8 * flicker),
            glowGold.withValues(alpha: 0.28 * flicker),
            glowGold.withValues(alpha: 0),
          ],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromCircle(center: lampHead, radius: glowR)),
    );
    _lamp(canvas, lampX, lampBase, lampHead, dark, glowGold, flicker);

    // Storyteller's spotlight sweeping slowly over the facades.
    final spot = Offset(w * (0.52 + 0.3 * math.sin(t * _tau)), groundY - 44);
    final spotRect = Rect.fromCenter(center: spot, width: 190, height: 160);
    canvas.drawOval(
      spotRect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            colors.surface.withValues(alpha: 0.5),
            colors.surface.withValues(alpha: 0),
          ],
        ).createShader(spotRect),
    );

    // Dust motes drifting up through the light.
    final mote = Paint();
    for (var i = 0; i < 16; i++) {
      final p = (t * (2 + i % 3) + i / 16) % 1.0;
      final my = visibleBottom - p * (visibleBottom - topPadding - 20);
      final mx =
          (w * ((i * 0.618) % 1.0) + math.sin(p * _tau * 2 + i) * 16) % w;
      final near = (1 - ((mx - spot.dx).abs() / 120)).clamp(0.0, 1.0);
      mote.color = colors.surface.withValues(
        alpha: (0.25 + 0.55 * near) * math.sin(p * math.pi),
      );
      canvas.drawCircle(Offset(mx, my), 1 + (i % 3) * 0.5, mote);
    }

    // Letter fluttering across, twice per loop.
    final lp = (t * 2) % 1.0;
    if (lp < 0.42) {
      final q = lp / 0.42;
      final pos = Offset(
        -30 + q * (w + 60),
        groundY - 56 + math.sin(q * _tau * 2) * 14 - q * 8,
      );
      _letter(
        canvas,
        pos,
        math.sin(q * _tau * 3) * 0.45,
        math.cos(q * _tau * 5),
        paper,
        dark,
        vintageRed,
      );
    }

    // Vignette, like the edges of an old print.
    final full = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 0.95,
          colors: [
            dark.withValues(alpha: 0),
            dark.withValues(alpha: 0.08),
            dark.withValues(alpha: 0.34),
          ],
          stops: const [0.45, 0.75, 1],
        ).createShader(full),
    );

    // Film grain + the occasional scratch (re-rolled ~15×/s).
    final frame = (t * 600).floor();
    final grain = <Offset>[];
    for (var i = 0; i < 60; i++) {
      grain.add(
        Offset(
          _rand(frame * 131 + i * 2) * w,
          _rand(frame * 131 + i * 2 + 1) * h,
        ),
      );
    }
    canvas.drawPoints(
      PointMode.points,
      grain,
      Paint()
        ..color = dark.withValues(alpha: 0.22)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    final scratchRoll = _rand(frame * 7 + 3);
    if (scratchRoll < 0.35) {
      final sx = _rand(frame * 7 + 4) * w;
      final sy = _rand(frame * 7 + 5) * h * 0.5;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + 2, sy + 60 + 80 * _rand(frame * 7 + 6)),
        Paint()
          ..color = (scratchRoll < 0.18 ? paper : dark).withValues(alpha: 0.28)
          ..strokeWidth = 0.8,
      );
    }
  }

  /// Deterministic 0..1 hash so the grain is identical every loop.
  double _rand(int n) {
    var x = (n * 374761393 + 668265263) & 0x7fffffff;
    x = ((x ^ (x >> 13)) * 1274126177) & 0x7fffffff;
    x = x ^ (x >> 16);
    return x / 0x7fffffff;
  }

  void _house(
    Canvas canvas,
    double l,
    double r,
    double groundY,
    double wallH,
    double roofH,
    Color wall,
    Color dark,
    double flicker,
  ) {
    final top = groundY - wallH;
    canvas.drawRect(Rect.fromLTRB(l, top, r, groundY), Paint()..color = wall);
    canvas.drawPath(
      Path()..addPolygon([
        Offset(l - 3, top),
        Offset((l + r) / 2, top - roofH),
        Offset(r + 3, top),
      ], true),
      Paint()..color = dark,
    );
    // Chimney.
    canvas.drawRect(
      Rect.fromLTWH(r - (r - l) * 0.3, top - roofH * 0.8, 5, roofH * 0.5),
      Paint()..color = dark,
    );
    // Windows: an upper row, warmly lit.
    final lit = Paint()
      ..color = colors.gold.withValues(alpha: 0.55 + 0.2 * flicker);
    final unlit = Paint()..color = dark.withValues(alpha: 0.55);
    final count = ((r - l) / 16).floor().clamp(1, 4);
    final gap = (r - l) / count;
    for (var i = 0; i < count; i++) {
      final cx = l + gap * (i + 0.5);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(center: Offset(cx, top + 9), width: 6, height: 9),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        (i + l.round()).isEven ? lit : unlit,
      );
    }
  }

  void _awning(
    Canvas canvas,
    double l,
    double r,
    double y,
    Color red,
    Color stripe,
  ) {
    final path = Path()
      ..moveTo(l, y)
      ..lineTo(r, y)
      ..lineTo(r + 4, y + 9)
      ..lineTo(l - 4, y + 9)
      ..close();
    canvas.drawPath(path, Paint()..color = red);
    final s = Paint()..color = stripe.withValues(alpha: 0.75);
    final n = 6;
    final sw = (r - l + 8) / (n * 2);
    for (var i = 0; i < n; i++) {
      final x0 = l - 4 + sw * (i * 2 + 1);
      canvas.drawRect(Rect.fromLTWH(x0, y + 2, sw, 7), s);
    }
    // Scalloped edge.
    final edge = Paint()..color = red;
    for (var x = l - 2.0; x <= r + 2; x += 6) {
      canvas.drawCircle(Offset(x + 1, y + 9), 3, edge);
    }
    // Doorway under the awning.
    canvas.drawRect(
      Rect.fromLTWH((l + r) / 2 - 6, y + 11, 12, 11),
      Paint()..color = colors.gold.withValues(alpha: 0.45),
    );
  }

  void _clockTower(
    Canvas canvas,
    double cx,
    double groundY,
    Color stone,
    Color shade,
    Color dark,
    Color face,
  ) {
    const halfW = 17.0;
    final bodyTop = groundY - 80;
    final body = Rect.fromLTRB(cx - halfW, bodyTop, cx + halfW, groundY);
    canvas.drawRect(body, Paint()..color = stone);
    canvas.drawRect(
      Rect.fromLTRB(cx + halfW - 7, bodyTop, cx + halfW, groundY),
      Paint()..color = shade,
    );
    // Cornices.
    final ledge = Paint()..color = shade;
    canvas.drawRect(
      Rect.fromLTRB(cx - halfW - 3, bodyTop - 3, cx + halfW + 3, bodyTop + 2),
      ledge,
    );
    canvas.drawRect(
      Rect.fromLTRB(cx - halfW - 2, bodyTop + 38, cx + halfW + 2, bodyTop + 41),
      ledge,
    );
    // Arched door and slit window.
    final arch = Paint()..color = dark.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(cx - 6, groundY - 18, cx + 6, groundY),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      arch,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(cx - 2.5, bodyTop + 48, cx + 2.5, bodyTop + 60),
        topLeft: const Radius.circular(2.5),
        topRight: const Radius.circular(2.5),
      ),
      arch,
    );

    // Belfry with arched openings, then the spire.
    final belfryTop = bodyTop - 20;
    canvas.drawRect(
      Rect.fromLTRB(cx - 13, belfryTop, cx + 13, bodyTop - 3),
      Paint()..color = stone,
    );
    for (final dx in const [-6.5, 6.5]) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
            center: Offset(cx + dx, belfryTop + 9),
            width: 7,
            height: 12,
          ),
          topLeft: const Radius.circular(3.5),
          topRight: const Radius.circular(3.5),
        ),
        arch,
      );
    }
    canvas.drawPath(
      Path()..addPolygon([
        Offset(cx - 17, belfryTop + 1),
        Offset(cx, belfryTop - 30),
        Offset(cx + 17, belfryTop + 1),
      ], true),
      Paint()..color = dark,
    );
    canvas.drawLine(
      Offset(cx, belfryTop - 30),
      Offset(cx, belfryTop - 38),
      Paint()
        ..color = dark
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(Offset(cx, belfryTop - 39), 2, Paint()..color = dark);

    // Clock face.
    final c = Offset(cx, bodyTop + 18);
    const r = 12.0;
    canvas.drawCircle(c, r + 2.2, Paint()..color = dark);
    canvas.drawCircle(c, r, Paint()..color = face);
    final tick = Paint()
      ..color = dark
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * _tau;
      final len = i % 3 == 0 ? 3.0 : 1.6;
      final dir = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(c + dir * (r - 1.5), c + dir * (r - 1.5 - len), tick);
    }
    // Minute hand: 60 eased ticks = one revolution per loop. The hour hand
    // stays put (any fraction of a turn would jump at the loop seam).
    final steps = t * 60;
    final base = steps.floor();
    final frac = ((steps - base) / 0.12).clamp(0.0, 1.0);
    final minute = (base + Curves.easeOutBack.transform(frac)) / 60 * _tau;
    final hand = Paint()
      ..color = dark
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      c,
      c + Offset(math.sin(_tau * 4 / 12), -math.cos(_tau * 4 / 12)) * 6.5,
      hand..strokeWidth = 2.2,
    );
    canvas.drawLine(
      c,
      c + Offset(math.sin(minute), -math.cos(minute)) * 9.5,
      hand..strokeWidth = 1.4,
    );
    canvas.drawCircle(c, 1.6, Paint()..color = red);
  }

  void _courthouse(
    Canvas canvas,
    double l,
    double r,
    double groundY,
    Color stone,
    Color shade,
    Color dark,
  ) {
    final width = r - l;
    // Steps.
    final stepPaint = Paint()..color = stone;
    final stepShade = Paint()..color = shade;
    for (var i = 0; i < 3; i++) {
      final inset = i * 4.0;
      final rect = Rect.fromLTRB(
        l - 6 + inset,
        groundY - 4 - i * 4,
        r + 6 - inset,
        groundY - i * 4,
      );
      canvas.drawRect(rect, stepPaint);
      canvas.drawRect(
        Rect.fromLTRB(rect.left, rect.bottom - 1, rect.right, rect.bottom),
        stepShade,
      );
    }
    final floor = groundY - 12;
    final colTop = floor - 42;
    // Recessed back wall in shadow, then the columns over it.
    canvas.drawRect(
      Rect.fromLTRB(l + 4, colTop, r - 4, floor),
      Paint()..color = _sepia(0.4, 0.28),
    );
    // Door in the middle bay.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset((l + r) / 2, floor - 11),
          width: 13,
          height: 22,
        ),
        topLeft: const Radius.circular(6.5),
        topRight: const Radius.circular(6.5),
      ),
      Paint()..color = dark.withValues(alpha: 0.75),
    );
    const cols = 6;
    final gap = (width - 16) / (cols - 1);
    for (var i = 0; i < cols; i++) {
      final x = l + 8 + gap * i;
      canvas.drawRect(Rect.fromLTRB(x - 4, colTop, x + 4, floor), stepPaint);
      canvas.drawRect(Rect.fromLTRB(x + 1.5, colTop, x + 4, floor), stepShade);
      // Capital and base.
      canvas.drawRect(
        Rect.fromLTRB(x - 6, colTop, x + 6, colTop + 3),
        stepPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(x - 5.5, floor - 3, x + 5.5, floor),
        stepPaint,
      );
    }
    // Entablature.
    final entTop = colTop - 10;
    canvas.drawRect(Rect.fromLTRB(l - 2, entTop, r + 2, colTop), stepPaint);
    canvas.drawRect(Rect.fromLTRB(l - 2, colTop - 2, r + 2, colTop), stepShade);
    // Pediment with an emblem in the tympanum.
    final peak = entTop - 26;
    canvas.drawPath(
      Path()..addPolygon([
        Offset(l - 5, entTop),
        Offset((l + r) / 2, peak),
        Offset(r + 5, entTop),
      ], true),
      Paint()..color = shade,
    );
    canvas.drawPath(
      Path()..addPolygon([
        Offset(l + 8, entTop - 2),
        Offset((l + r) / 2, peak + 7),
        Offset(r - 8, entTop - 2),
      ], true),
      stepPaint,
    );
    final emblem = Offset((l + r) / 2, entTop - 8);
    canvas.drawCircle(emblem, 4.5, Paint()..color = shade);
    canvas.drawCircle(emblem, 2, Paint()..color = red.withValues(alpha: 0.7));
  }

  void _lamp(
    Canvas canvas,
    double x,
    double base,
    Offset head,
    Color dark,
    Color glow,
    double flicker,
  ) {
    final post = Paint()..color = dark;
    canvas.drawRect(Rect.fromLTRB(x - 4, base - 6, x + 4, base), post);
    canvas.drawRect(
      Rect.fromLTRB(x - 2.2, head.dy + 8, x + 2.2, base - 6),
      post,
    );
    canvas.drawRect(
      Rect.fromLTRB(x - 3, head.dy + 7, x + 3, head.dy + 10),
      post,
    );
    // Lantern: tapered glass box with a cap and finial.
    final glass = Path()
      ..moveTo(head.dx - 4, head.dy + 7)
      ..lineTo(head.dx + 4, head.dy + 7)
      ..lineTo(head.dx + 7.5, head.dy - 8)
      ..lineTo(head.dx - 7.5, head.dy - 8)
      ..close();
    canvas.drawPath(
      glass,
      Paint()..color = Color.lerp(colors.gold, glow, flicker)!,
    );
    canvas.drawCircle(
      head,
      3 * flicker,
      Paint()..color = colors.surface.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      Path()..addPolygon([
        Offset(head.dx - 8.5, head.dy - 7),
        Offset(head.dx, head.dy - 14),
        Offset(head.dx + 8.5, head.dy - 7),
      ], true),
      post,
    );
    canvas.drawCircle(Offset(head.dx, head.dy - 15), 1.8, post);
    canvas.drawLine(
      Offset(head.dx, head.dy - 7),
      Offset(head.dx, head.dy + 7),
      post..strokeWidth = 1,
    );
  }

  void _letter(
    Canvas canvas,
    Offset pos,
    double rot,
    double flap,
    Color paper,
    Color dark,
    Color seal,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(rot);
    // Folding flutter: squash vertically as it tumbles.
    canvas.scale(1, 0.45 + 0.55 * flap.abs());
    final body = Rect.fromCenter(center: Offset.zero, width: 22, height: 14);
    canvas.drawRect(
      body.shift(const Offset(1.5, 2)),
      Paint()..color = dark.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      body,
      Paint()..color = flap >= 0 ? paper : Color.lerp(paper, dark, 0.12)!,
    );
    canvas.drawPath(
      Path()
        ..moveTo(body.left, body.top)
        ..lineTo(0, 1.5)
        ..lineTo(body.right, body.top),
      Paint()
        ..color = dark.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawCircle(const Offset(0, 1.5), 2.8, Paint()..color = seal);
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(r * 0.95, r * 0.18), r * 0.78, paint);
    canvas.drawCircle(center.translate(-r * 0.95, r * 0.22), r * 0.72, paint);
    canvas.drawCircle(center.translate(r * 0.2, -r * 0.4), r * 0.6, paint);
  }

  @override
  bool shouldRepaint(StoriesScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.red != red ||
      old.topPadding != topPadding;
}
