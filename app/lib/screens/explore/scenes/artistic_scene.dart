import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Artistic Quest — "A painting that paints itself": a cream paper canvas
/// holding a watercolour city view (sky washes, a gold sun, rooftops and a
/// garden). The painting is always complete and gently alive — pigments
/// bleed through slow hue shifts and a wet sheen glides across — while a
/// brush re-paints one region every 5s, paint splats pop in, birds flick
/// past and a palette bobs in the lower-right. All motion uses integer
/// multiples of the 40s loop so it repeats seamlessly.
class ArtisticScenePainter extends CustomPainter {
  ArtisticScenePainter(this.t, BuildContext context)
    : colors = context.colors,
      orange = context.accents.artistic,
      green = context.accents.peaceful,
      topPadding = MediaQuery.paddingOf(context).top;

  final double t;
  final AppColors colors;
  final Color orange;
  final Color green;
  final double topPadding;

  static const _tau = math.pi * 2;

  /// The detail sheet overlaps the header's bottom by its corner radius.
  static const _sheetOverlap = AppRadius.sheet;

  /// Repaint events per loop (one every 5s) and the share of each event
  /// window spent lifting the old paint and brushing the fresh stroke.
  static const _events = 8;
  static const _lift = 0.06;
  static const _reveal = 0.42;

  // ── Painting layout ────────────────────────────────────────────────

  /// Sky washes: (x0, y0, x1, y1, width, tone, bow). x as width fraction,
  /// y offset from the top of the header.
  static const _sky = [
    (-0.06, 18.0, 0.64, 14.0, 44.0, 0, 5.0),
    (0.34, 30.0, 1.06, 38.0, 44.0, 1, -5.0),
    (-0.06, 60.0, 0.56, 70.0, 38.0, 1, 6.0),
    (0.44, 70.0, 1.06, 62.0, 38.0, 2, -4.0),
    (-0.06, 104.0, 0.72, 98.0, 36.0, 3, 6.0),
    (0.30, 132.0, 1.06, 126.0, 40.0, 4, -5.0),
    (-0.06, 150.0, 0.52, 158.0, 34.0, 3, 4.0),
  ];

  /// Buildings: (centre x fraction, width, height, roof, tone).
  /// roof: 0 flat, 1 gable, 2 spire, 3 dome.
  static const _buildings = [
    (0.07, 34.0, 44.0, 1, 0),
    (0.17, 30.0, 62.0, 0, 2),
    (0.275, 40.0, 50.0, 1, 1),
    (0.395, 34.0, 78.0, 2, 3),
    (0.52, 52.0, 56.0, 3, 4),
    (0.64, 30.0, 70.0, 0, 0),
    (0.735, 38.0, 46.0, 1, 2),
    (0.835, 34.0, 60.0, 0, 5),
    (0.94, 30.0, 42.0, 1, 1),
  ];

  /// Garden: hedge washes (x0, y0, x1, y1, width, tone, bow), y offset
  /// from the skyline base.
  static const _hedges = [
    (-0.06, 6.0, 0.52, 2.0, 30.0, 0, 3.0),
    (0.40, 10.0, 1.06, 5.0, 30.0, 1, -3.0),
    (-0.06, 30.0, 1.06, 32.0, 34.0, 2, 2.0),
  ];

  /// Round garden trees: (x fraction, crown centre y offset from the
  /// skyline base, radius).
  static const _trees = [
    (0.115, -12.0, 15.0),
    (0.335, -8.0, 12.0),
    (0.585, -11.0, 14.0),
    (0.775, -6.0, 11.0),
  ];

  /// Which element each repaint event re-brushes (indexes into the
  /// combined element list: sky, sun, buildings, hedges, trees).
  static const _targets = [1, 11, 17, 4, 7, 12, 20, 9];

  static int get _skyCount => _sky.length;
  static int get _sunIndex => _sky.length;
  static int get _buildingStart => _sky.length + 1;
  static int get _hedgeStart => _buildingStart + _buildings.length;
  static int get _treeStart => _hedgeStart + _hedges.length;
  static int get _elementCount => _treeStart + _trees.length;

  late double _w;
  late double _base;

  @override
  void paint(Canvas canvas, Size size) {
    _w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    _base = visibleBottom - 30;

    // Cream paper with a faint warm vignette and pigment speckles.
    final paper = Color.lerp(colors.ground, colors.cardAlt, 0.5)!;
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 0.9,
          colors: [
            paper.withValues(alpha: 0),
            colors.card.withValues(alpha: 0.55),
          ],
        ).createShader(Offset.zero & size),
    );
    final speck = Paint()..color = colors.goldDeep.withValues(alpha: 0.12);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(_rand(i * 3 + 1) * _w, _rand(i * 7 + 2) * h),
        0.6 + _rand(i * 11) * 0.9,
        speck,
      );
    }

    // Current repaint event.
    final eventPos = t * _events;
    final event = eventPos.floor() % _events;
    final window = eventPos % 1.0;
    final target = _targets[event];
    final lifting = window < _reveal;
    final ghost = 1 - 0.78 * (window / _lift).clamp(0.0, 1.0);
    final reveal = Curves.easeInOut.transform(
      ((window - _lift) / (_reveal - _lift)).clamp(0.0, 1.0),
    );

    Offset? brushTip;
    Color brushColor = orange;
    for (var i = 0; i < _elementCount; i++) {
      if (i == target && lifting) {
        final b = _bounds(i);
        // Old paint lifted (ghost) …
        canvas.saveLayer(
          b.inflate(30),
          Paint()..color = Color.fromRGBO(0, 0, 0, ghost),
        );
        _drawElement(canvas, i);
        canvas.restore();
        // … and the fresh stroke behind the brush.
        if (reveal > 0) {
          final edge = b.left - 22 + (b.width + 44) * reveal;
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(-40, -40, edge, h + 40));
          _drawElement(canvas, i);
          canvas.restore();
        }
        final edge = b.left - 22 + (b.width + 44) * reveal;
        brushTip = Offset(edge, _brushY(i, b, edge, reveal));
        brushColor = _elementColor(i);
      } else {
        _drawElement(canvas, i);
      }
    }

    // Garden flowers: dabs that nod along the hedges.
    final flowerTones = [colors.heart, colors.gold, colors.surface, orange];
    for (var i = 0; i < 14; i++) {
      final x = _w * (0.03 + i * 0.07) + _rand(i + 40) * 8;
      if (x > _w * 0.78) continue; // keep the palette area tidy
      final y = _base + 8 + _rand(i + 60) * 12;
      final nod = 1 + 0.18 * math.sin(t * _tau * 6 + i * 1.9);
      canvas.drawCircle(
        Offset(x, y),
        2.6 * nod,
        Paint()..color = flowerTones[i % 4].withValues(alpha: 0.85),
      );
    }

    // Birds: brush-tick "v"s flicking across, below the button row.
    final bird = Paint()
      ..color = colors.pill.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final p = (t * 2 + i * 0.07) % 1.0;
      final x = -30 + p * (_w + 60);
      final y = topPadding + 66 + i * 7 + math.sin(p * _tau * 3 + i) * 4;
      final flap = math.sin(t * _tau * 60 + i * 2.1) * 3.2;
      final s = 1 - i * 0.18;
      canvas.drawPath(
        Path()
          ..moveTo(x - 7 * s, y - 2 * s + flap * s)
          ..quadraticBezierTo(x - 3 * s, y - 4 * s, x, y)
          ..quadraticBezierTo(
            x + 3 * s,
            y - 4 * s,
            x + 7 * s,
            y - 2 * s + flap * s,
          ),
        bird,
      );
    }

    // Paint splats popping in around the painting, five rounds per loop.
    final splatTones = [orange, colors.gold, green, colors.heart, _skyBlue];
    for (var i = 0; i < 4; i++) {
      final phase = t * 5 + i / 4;
      final p = phase % 1.0;
      if (p > 0.5) continue;
      final round = phase.floor() % 5;
      final seed = i * 31 + round * 7;
      final at = Offset(
        _w * (0.1 + 0.62 * _rand(seed)),
        topPadding + 62 + 70 * _rand(seed + 3),
      );
      final pop = Curves.elasticOut.transform((p / 0.12).clamp(0.0, 1.0));
      final fade = 1 - ((p - 0.32) / 0.18).clamp(0.0, 1.0);
      _splat(canvas, at, 6 * pop, splatTones[(i + round) % 5], fade, seed);
    }

    // Wet sheen: a soft diagonal glint gliding across twice per loop.
    final sx = ((t * 2) % 1.0) * (_w + 260) - 130;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _w, visibleBottom),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(sx - 50, 0),
          Offset(sx + 30, 70),
          [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0),
          ],
          const [0, 0.5, 1],
          TileMode.clamp,
        ),
    );

    // Floating palette in the lower-right, clear of the sheet overlap.
    final bob = math.sin(t * _tau * 8) * 3;
    final paletteC = Offset(_w - 52, visibleBottom - 30 + bob);
    _palette(canvas, paletteC, math.sin(t * _tau * 4) * 0.06, bob);

    // The brush: out painting during a repaint, resting on the palette
    // otherwise; it fades between the two.
    final out = lifting
        ? math.min(
            (window / _lift).clamp(0.0, 1.0),
            ((_reveal - window) / _lift).clamp(0.0, 1.0),
          )
        : 0.0;
    if (out < 1) {
      _brush(
        canvas,
        paletteC.translate(-14, 2),
        -0.55 + math.sin(t * _tau * 4) * 0.06,
        orange,
        1 - out,
      );
    }
    if (brushTip != null && out > 0) {
      final dip = math.sin(reveal * _tau * 4) * 0.08;
      _brush(canvas, brushTip, -0.78 + dip, brushColor, out);
    }
  }

  // ── Elements ───────────────────────────────────────────────────────

  Color get _skyBlue =>
      HSLColor.fromColor(colors.groundTop)
          .withSaturation(0.55)
          .withLightness(0.74)
          .toColor();

  /// Slow pigment bleed: each element's hue and lightness drift a little.
  Color _live(Color c, int i) {
    final hsl = HSLColor.fromColor(c);
    final hue = (hsl.hue + 7 * math.sin(t * _tau * 2 + i * 0.9)) % 360;
    final light = (hsl.lightness + 0.025 * math.sin(t * _tau * 3 + i * 1.3))
        .clamp(0.0, 1.0);
    return hsl.withHue(hue).withLightness(light).toColor();
  }

  Color _skyTone(int tone) => switch (tone) {
    0 => Color.lerp(_skyBlue, colors.ink, 0.12)!,
    1 => _skyBlue,
    2 => Color.lerp(_skyBlue, colors.surface, 0.35)!,
    3 => Color.lerp(orange, colors.ground, 0.55)!,
    _ => Color.lerp(colors.gold, colors.ground, 0.35)!,
  };

  Color _buildingTone(int tone) => switch (tone) {
    0 => orange,
    1 => colors.gold,
    2 => Color.lerp(colors.pill, _skyBlue, 0.35)!,
    3 => Color.lerp(colors.heart, orange, 0.35)!,
    4 => Color.lerp(_skyBlue, colors.pill, 0.25)!,
    _ => Color.lerp(green, colors.gold, 0.25)!,
  };

  Color _hedgeTone(int tone) => switch (tone) {
    0 => green,
    1 => Color.lerp(green, colors.gold, 0.3)!,
    _ => Color.lerp(green, colors.pill, 0.25)!,
  };

  Color _elementColor(int i) {
    if (i < _skyCount) return _live(_skyTone(_sky[i].$6), i);
    if (i == _sunIndex) return colors.gold;
    if (i < _hedgeStart) {
      return _live(_buildingTone(_buildings[i - _buildingStart].$5), i);
    }
    if (i < _treeStart) {
      return _live(_hedgeTone(_hedges[i - _hedgeStart].$6), i);
    }
    return _live(Color.lerp(green, colors.pill, 0.1)!, i);
  }

  Offset get _sun => Offset(_w * 0.63, topPadding + 34);

  Rect _bounds(int i) {
    if (i < _skyCount) {
      final s = _sky[i];
      return Rect.fromLTRB(
        _w * s.$1,
        math.min(s.$2, s.$4) - s.$5 / 2,
        _w * s.$3,
        math.max(s.$2, s.$4) + s.$5 / 2,
      );
    }
    if (i == _sunIndex) return Rect.fromCircle(center: _sun, radius: 26);
    if (i < _hedgeStart) {
      final b = _buildings[i - _buildingStart];
      final cx = _w * b.$1;
      return Rect.fromLTRB(
        cx - b.$2 / 2,
        _base - b.$3 - 26,
        cx + b.$2 / 2,
        _base,
      );
    }
    if (i < _treeStart) {
      final s = _hedges[i - _hedgeStart];
      return Rect.fromLTRB(
        _w * s.$1,
        _base + math.min(s.$2, s.$4) - s.$5 / 2,
        _w * s.$3,
        _base + math.max(s.$2, s.$4) + s.$5 / 2,
      );
    }
    final tr = _trees[i - _treeStart];
    final c = Offset(_w * tr.$1, _base + tr.$2);
    return Rect.fromCircle(center: c, radius: tr.$3 + 2);
  }

  /// Where the brush tip sits while sweeping across element [i].
  double _brushY(int i, Rect b, double x, double p) {
    if (i < _skyCount || (i >= _hedgeStart && i < _treeStart)) {
      final s = i < _skyCount ? _sky[i] : _hedges[i - _hedgeStart];
      final y0 = i < _skyCount ? 0.0 : _base;
      final f = ((x / _w - s.$1) / (s.$3 - s.$1)).clamp(0.0, 1.0);
      return y0 +
          s.$2 +
          (s.$4 - s.$2) * f +
          math.sin(p * _tau * 3) * s.$5 * 0.2;
    }
    return b.top + b.height * (0.5 + 0.38 * math.sin(p * _tau * 4));
  }

  void _drawElement(Canvas canvas, int i) {
    if (i < _skyCount) {
      final s = _sky[i];
      _wash(
        canvas,
        Offset(_w * s.$1, s.$2),
        Offset(_w * s.$3, s.$4),
        s.$5,
        _elementColor(i),
        s.$7,
        i,
      );
    } else if (i == _sunIndex) {
      final pulse = math.sin(t * _tau * 5);
      final sun = _sun;
      canvas.drawCircle(
        sun,
        34 + 2 * pulse,
        Paint()..color = colors.gold.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        sun.translate(1.5, -1),
        23,
        Paint()..color = colors.gold.withValues(alpha: 0.55),
      );
      canvas.drawCircle(
        sun.translate(-1.5, 1),
        21,
        Paint()
          ..color = Color.lerp(
            colors.gold,
            orange,
            0.2,
          )!.withValues(alpha: 0.6),
      );
      canvas.drawCircle(
        sun.translate(-6, -6),
        8,
        Paint()..color = colors.surface.withValues(alpha: 0.35),
      );
    } else if (i < _hedgeStart) {
      _building(canvas, i - _buildingStart, _elementColor(i));
    } else if (i < _treeStart) {
      final k = i - _hedgeStart;
      final s = _hedges[k];
      final color = _elementColor(i);
      _wash(
        canvas,
        Offset(_w * s.$1, _base + s.$2),
        Offset(_w * s.$3, _base + s.$4),
        s.$5,
        color,
        s.$7,
        i,
      );
      if (k < 2) {
        // Bushy top edge: overlapping round dabs along the hedge.
        final bush = Paint()..color = color.withValues(alpha: 0.42);
        final x0 = _w * math.max(0, s.$1);
        final x1 = _w * math.min(1, s.$3);
        for (var x = x0 + 6; x < x1 - 4; x += 15) {
          final f = (x / _w - s.$1) / (s.$3 - s.$1);
          final y = _base + s.$2 + (s.$4 - s.$2) * f - s.$5 * 0.32;
          final r = 7 + _rand(x.round() + k * 97) * 5;
          canvas.drawCircle(Offset(x, y), r, bush);
        }
      }
    } else {
      _tree(canvas, i - _treeStart, _elementColor(i));
    }
  }

  /// A watercolour stroke: overlapping translucent passes with jittered
  /// ends and a darker pigment rim along the edges.
  void _wash(
    Canvas canvas,
    Offset a,
    Offset b,
    double width,
    Color color,
    double bow,
    int seed,
  ) {
    final d = b - a;
    final n = Offset(-d.dy, d.dx) / d.distance;
    Path pass(double off, double ja, double jb, double bowMul) {
      final a2 = a + n * off + d * ja;
      final b2 = b + n * off - d * jb;
      final m = (a2 + b2) / 2 + n * bow * bowMul;
      return Path()
        ..moveTo(a2.dx, a2.dy)
        ..quadraticBezierTo(m.dx, m.dy, b2.dx, b2.dy);
    }

    final r1 = _rand(seed * 5 + 1) * 0.05;
    final r2 = _rand(seed * 5 + 2) * 0.06;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      pass(0, 0, 0, 1),
      stroke
        ..strokeWidth = width
        ..color = color.withValues(alpha: 0.5),
    );
    canvas.drawPath(
      pass(width * 0.2, r1, -r2, 1.4),
      stroke
        ..strokeWidth = width * 0.62
        ..color = color.withValues(alpha: 0.32),
    );
    canvas.drawPath(
      pass(-width * 0.24, -r2 * 0.5, r1 + 0.03, 0.6),
      stroke
        ..strokeWidth = width * 0.5
        ..color = color.withValues(alpha: 0.28),
    );
    final rim = Color.lerp(color, colors.pill, 0.25)!;
    canvas.drawPath(
      pass(width * 0.46, r2, r1, 1),
      stroke
        ..strokeWidth = 1.6
        ..color = rim.withValues(alpha: 0.26),
    );
    canvas.drawPath(
      pass(-width * 0.45, r1, r2, 1),
      stroke
        ..strokeWidth = 1.2
        ..color = rim.withValues(alpha: 0.16),
    );
  }

  void _building(Canvas canvas, int k, Color color) {
    final (fx, bw, bh, roof, _) = _buildings[k];
    final cx = _w * fx;
    final l = cx - bw / 2;
    final r = cx + bw / 2;
    final top = _base - bh;
    final path = Path()
      ..moveTo(l, _base + 6)
      ..lineTo(l, top);
    switch (roof) {
      case 1:
        path
          ..lineTo(l - 3, top)
          ..lineTo(cx, top - 15)
          ..lineTo(r + 3, top)
          ..lineTo(r, top);
      case 2:
        path
          ..lineTo(cx - 3, top - 26)
          ..lineTo(cx + 3, top - 26)
          ..lineTo(r, top);
      case 3:
        path.arcToPoint(Offset(r, top), radius: Radius.circular(bw / 2));
      default:
        path
          ..lineTo(l - 2, top)
          ..lineTo(l - 2, top - 4)
          ..lineTo(r + 2, top - 4)
          ..lineTo(r + 2, top)
          ..lineTo(r, top);
    }
    path
      ..lineTo(r, _base + 6)
      ..close();

    final deep = Color.lerp(color, colors.pill, 0.3)!;
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.72));
    canvas.drawPath(
      path.shift(const Offset(2, -1.5)),
      Paint()..color = deep.withValues(alpha: 0.16),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeJoin = StrokeJoin.round
        ..color = deep.withValues(alpha: 0.4),
    );
    if (roof == 3) {
      // Dome finial.
      canvas.drawLine(
        Offset(cx, top - bw / 2 + 1),
        Offset(cx, top - bw / 2 - 7),
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = deep.withValues(alpha: 0.7),
      );
      canvas.drawCircle(
        Offset(cx, top - bw / 2 - 8),
        2.2,
        Paint()..color = colors.gold,
      );
    }

    // Window dabs.
    final win = Paint()..color = colors.pill.withValues(alpha: 0.45);
    final lit = Paint()..color = colors.cardAlt.withValues(alpha: 0.85);
    final cols = math.max(1, (bw / 11).floor());
    final rows = math.max(1, ((bh - 18) / 14).floor());
    final gap = bw / cols;
    for (var row = 0; row < rows; row++) {
      for (var c = 0; c < cols; c++) {
        final seed = k * 50 + row * 7 + c;
        if (_rand(seed) > 0.78) continue;
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(l + gap * (c + 0.5), top + 10 + row * 14),
            width: 4.5,
            height: 6.5,
          ),
          const Radius.circular(1.5),
        );
        canvas.drawRRect(rect, _rand(seed + 9) > 0.8 ? lit : win);
      }
    }
  }

  void _tree(Canvas canvas, int k, Color color) {
    final (fx, dy, r) = _trees[k];
    final sway = math.sin(t * _tau * 8 + k * 1.4) * 1.6;
    final c = Offset(_w * fx + sway, _base + dy);
    canvas.drawLine(
      Offset(_w * fx, _base + 12),
      c.translate(0, r * 0.4),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(colors.goldDeep, colors.pill, 0.45)!,
    );
    canvas.drawCircle(c, r, Paint()..color = color.withValues(alpha: 0.68));
    canvas.drawCircle(
      c.translate(r * 0.25, r * 0.2),
      r * 0.7,
      Paint()
        ..color = Color.lerp(color, colors.pill, 0.2)!.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      c.translate(-r * 0.3, -r * 0.32),
      r * 0.45,
      Paint()
        ..color = Color.lerp(
          color,
          colors.surface,
          0.4,
        )!.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Color.lerp(color, colors.pill, 0.3)!.withValues(alpha: 0.35),
    );
  }

  void _splat(
    Canvas canvas,
    Offset at,
    double r,
    Color color,
    double alpha,
    int seed,
  ) {
    if (r <= 0 || alpha <= 0) return;
    final paint = Paint()..color = color.withValues(alpha: 0.8 * alpha);
    canvas.drawCircle(at, r, paint);
    canvas.drawCircle(at.translate(r * 0.3, -r * 0.2), r * 0.75, paint);
    for (var j = 0; j < 4; j++) {
      final a = _rand(seed + j * 13) * _tau;
      final dist = r * (1.5 + _rand(seed + j * 17) * 0.9);
      canvas.drawCircle(
        at + Offset(math.cos(a), math.sin(a)) * dist,
        r * (0.16 + 0.18 * _rand(seed + j * 19)),
        paint,
      );
    }
  }

  void _palette(Canvas canvas, Offset c, double tilt, double bob) {
    // Soft shadow that tightens as the palette rises.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy - bob + 24),
        width: 54 + bob * 2,
        height: 7,
      ),
      Paint()..color = colors.shadow(0.12),
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.12 + tilt);
    final board = Path.combine(
      PathOperation.difference,
      Path()
        ..addOval(Rect.fromCenter(center: Offset.zero, width: 66, height: 40)),
      Path()
        ..addOval(
          Rect.fromCenter(center: const Offset(-18, 8), width: 10, height: 8),
        )
        ..addOval(
          Rect.fromCenter(center: const Offset(-35, 12), width: 16, height: 14),
        ),
    );
    final wood = Color.lerp(colors.gold, colors.cardAlt, 0.55)!;
    canvas.drawPath(board, Paint()..color = wood);
    canvas.drawPath(
      board,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = colors.goldDeep,
    );
    final wells = [
      (const Offset(-10, -10), orange),
      (const Offset(4, -12), colors.gold),
      (const Offset(17, -7), green),
      (const Offset(21, 6), _skyBlue),
      (const Offset(8, 11), colors.heart),
    ];
    for (final (i, (o, col)) in wells.indexed) {
      final breathe = 1 + 0.08 * math.sin(t * _tau * 4 + i * 1.2);
      canvas.drawCircle(o, 4.6 * breathe, Paint()..color = col);
      canvas.drawCircle(
        o.translate(-1.4, -1.4),
        1.4,
        Paint()..color = colors.surface.withValues(alpha: 0.6),
      );
    }
    canvas.restore();
  }

  /// A paintbrush with its bristle tip at [tip], handle along [angle].
  void _brush(
    Canvas canvas,
    Offset tip,
    double angle,
    Color paintColor,
    double alpha,
  ) {
    if (alpha <= 0) return;
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    canvas.scale(1.2);
    // Handle.
    canvas.drawPath(
      Path()
        ..moveTo(21, -3.4)
        ..lineTo(56, -2.2)
        ..quadraticBezierTo(60, 0, 56, 2.2)
        ..lineTo(21, 3.4)
        ..close(),
      Paint()..color = colors.pill.withValues(alpha: alpha),
    );
    canvas.drawLine(
      const Offset(24, -1.4),
      const Offset(52, -1),
      Paint()
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..color = colors.onDark.withValues(alpha: 0.35 * alpha),
    );
    // Ferrule.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(13, -4, 22, 4),
        const Radius.circular(1.5),
      ),
      Paint()
        ..color = Color.lerp(
          colors.surface,
          colors.muted,
          0.35,
        )!.withValues(alpha: alpha),
    );
    // Bristles, loaded with paint at the tip.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(4, -4.6, 13.5, -3.6)
        ..lineTo(13.5, 3.6)
        ..quadraticBezierTo(4, 4.6, 0, 0)
        ..close(),
      Paint()..color = colors.goldDeep.withValues(alpha: alpha),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(2.5, -3.6, 7, -3.4)
        ..lineTo(7, 3.4)
        ..quadraticBezierTo(2.5, 3.6, 0, 0)
        ..close(),
      Paint()..color = paintColor.withValues(alpha: alpha),
    );
    canvas.restore();
  }

  /// Deterministic pseudo-random in [0, 1).
  static double _rand(int n) {
    final v = math.sin(n * 12.9898 + 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  bool shouldRepaint(ArtisticScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.orange != orange ||
      old.green != green ||
      old.topPadding != topPadding;
}
