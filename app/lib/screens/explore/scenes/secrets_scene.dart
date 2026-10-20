import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// The dusk sky and the plum walls at the top corners are dark, so the
/// status bar needs light icons.
const bool secretsSceneIsDark = true;

/// Local Secrets — "The hidden alley at dusk": a narrow cobbled alley
/// between old houses running back to a glowing far end, framed by an
/// ivy-covered stone archway under a purple → peach dusk sky. Lanterns
/// flicker and sway, a string of lights twinkles overhead, a little
/// wooden door creaks open twice per loop spilling warm light onto the
/// cobbles, a cat strolls along the top of the arch (pausing to sit and
/// swish its tail), ivy rustles, fireflies blink, a pinned map corner
/// flutters and a "hidden gem" glint winks from a different secret spot
/// every 8s. All motion is integer multiples of the 40s loop so it
/// repeats seamlessly.
class SecretsScenePainter extends CustomPainter {
  SecretsScenePainter(this.t, BuildContext context)
    : colors = context.colors,
      purple = context.accents.night,
      green = context.accents.peaceful,
      topPadding = MediaQuery.paddingOf(context).top;

  final double t;
  final AppColors colors;
  final Color purple;
  final Color green;
  final double topPadding;

  static const _tau = math.pi * 2;

  /// The detail sheet overlaps the header's bottom by its corner radius.
  static const _sheetOverlap = AppRadius.sheet;

  // Depths (z = 1 is the viewer's plane; bigger is further away).
  static const _zArch = 4.5;
  static const _zEnd = 8.0;

  // House segments per side: (near z, far z, height, tone index).
  static const _leftHouses = [
    (1.0, 2.2, 400.0, 0),
    (2.2, 3.3, 330.0, 1),
    (3.3, _zArch, 420.0, 2),
    (_zArch, 6.0, 460.0, 3),
    (6.0, _zEnd, 380.0, 1),
  ];
  static const _rightHouses = [
    (1.0, 1.9, 380.0, 3),
    (1.9, 3.2, 350.0, 4),
    (3.2, _zArch, 420.0, 0),
    (_zArch, 6.2, 450.0, 2),
    (6.2, _zEnd, 360.0, 4),
  ];

  // Door on the right wall: near edge, hinge (far edge), height.
  static const _doorNear = 2.27;
  static const _doorFar = 2.7;
  static const _doorH = 130.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final visibleBottom = h - _sheetOverlap;
    final ps = _Persp(w * 0.5, visibleBottom - 82, w * 0.75);

    // Dusk palette from tokens.
    final skyTop = Color.lerp(colors.pill, purple, 0.5)!;
    final skyMid = Color.lerp(purple, colors.heart, 0.42)!;
    final peach = Color.lerp(
      Color.lerp(colors.heart, colors.gold, 0.6)!,
      colors.ground,
      0.3,
    )!;
    final warm = Color.lerp(colors.gold, colors.ground, 0.35)!;
    final lilac = Color.lerp(purple, Colors.white, 0.5)!;
    final shadowInk = Color.lerp(colors.pill, purple, 0.15)!;
    final tones = [
      Color.lerp(colors.pill, purple, 0.42)!, // plum
      Color.lerp(Color.lerp(colors.pill, colors.heart, 0.5)!,
          colors.goldDeep, 0.3)!, // terracotta
      Color.lerp(colors.pill, colors.goldDeep, 0.5)!, // ochre
      Color.lerp(colors.pill, colors.heart, 0.36)!, // rose
      Color.lerp(colors.pill, colors.ground, 0.3)!, // stone
    ];

    // ── Sky ────────────────────────────────────────────────────
    final skyRect = Rect.fromLTWH(0, 0, w, ps.vy + 20);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, peach],
          stops: const [0, 0.5, 0.92],
        ).createShader(skyRect),
    );

    // First stars of the evening.
    final star = Paint();
    for (var i = 0; i < 9; i++) {
      final x = w * (0.2 + 0.6 * _hash(i * 4.3 + 2));
      final y = 8 + _hash(i * 9.1 + 5) * (topPadding + 6);
      final tw = 0.5 + 0.5 * math.sin(t * _tau * (3 + i % 4) + i * 2.1);
      star.color = colors.onDark.withValues(alpha: 0.2 + 0.55 * tw);
      canvas.drawCircle(Offset(x, y), 0.7 + 0.5 * tw, star);
    }

    // Thin crescent moon.
    final moon = Offset(w * 0.58, topPadding - 4);
    canvas.drawCircle(
      moon,
      15,
      Paint()..color = colors.onDark.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: moon, radius: 8)),
        Path()
          ..addOval(Rect.fromCircle(center: moon.translate(4, -3), radius: 7)),
      ),
      Paint()..color = colors.onDark,
    );

    // ── Far end: a warm lit street beyond the alley ─────────────
    final endGround = ps.vy + _Persp.eye / _zEnd;
    final endGlow = Offset(ps.cx, endGround - 14);
    canvas.drawCircle(
      endGlow,
      w * 0.3,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.gold.withValues(alpha: 0.75),
            colors.gold.withValues(alpha: 0.25),
            colors.gold.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: endGlow, radius: w * 0.3)),
    );
    // A distant bell tower peeking over everything.
    final towerX = ps.cx + w * 0.075;
    final towerTop = ps.vy - 68;
    final tower = Paint()..color = Color.lerp(purple, colors.pill, 0.35)!;
    canvas.drawRect(
      Rect.fromLTRB(towerX - 6, towerTop, towerX + 6, endGround),
      tower,
    );
    canvas.drawPath(
      Path()
        ..moveTo(towerX - 8, towerTop)
        ..lineTo(towerX, towerTop - 14)
        ..lineTo(towerX + 8, towerTop)
        ..close(),
      tower,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(towerX, towerTop + 7),
          width: 4,
          height: 6,
        ),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      ),
      Paint()..color = colors.gold.withValues(alpha: 0.9),
    );
    // Facade across the far street, lit windows.
    final facade = Rect.fromLTRB(
      ps.cx - w * 0.2,
      ps.vy + (_Persp.eye - 330) / _zEnd,
      ps.cx + w * 0.2,
      endGround,
    );
    canvas.drawRect(
      facade,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(tones[1], warm, 0.45)!, warm],
        ).createShader(facade),
    );
    final farWin = Paint()..color = Color.lerp(colors.gold, Colors.white, 0.45)!;
    for (var i = 0; i < 6; i++) {
      final x = facade.left + facade.width * (i + 0.5) / 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, facade.top + 10 + (i % 2) * 2),
            width: 4,
            height: 6,
          ),
          const Radius.circular(1.5),
        ),
        farWin,
      );
    }

    // ── Cobbled ground ─────────────────────────────────────────
    final groundPath = Path()
      ..moveTo(ps.l(0, _zEnd).dx, endGround)
      ..lineTo(ps.r(0, _zEnd).dx, endGround)
      ..lineTo(ps.r(0, 1.2).dx, ps.r(0, 1.2).dy)
      ..lineTo(ps.l(0, 1.2).dx, ps.l(0, 1.2).dy)
      ..close();
    final groundRect = Rect.fromLTRB(0, endGround, w, h);
    canvas.drawPath(
      groundPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(colors.goldDeep, purple, 0.25)!,
            Color.lerp(colors.pill, purple, 0.28)!,
          ],
          stops: const [0, 0.75],
        ).createShader(groundRect),
    );
    final cobbles = Path();
    var row = 0;
    for (var z = 1.8; z < _zEnd; z *= 1.11, row++) {
      const n = 11;
      final dz = z * 0.11;
      final y = ps.vy + _Persp.eye / (z + dz * 0.5);
      final rowH = _Persp.eye / z - _Persp.eye / (z + dz);
      for (var k = 0; k <= n; k++) {
        final x = -ps.wallX + (k + (row.isEven ? 0.0 : 0.5)) * 2 * ps.wallX / n;
        if (x.abs() > ps.wallX) continue;
        final cw = 2 * ps.wallX / n / z * 0.78;
        cobbles.addOval(
          Rect.fromCenter(
            center: Offset(ps.cx + x / z, y),
            width: cw,
            height: rowH * 0.72,
          ),
        );
      }
    }
    canvas.drawPath(
      cobbles,
      Paint()..color = Color.lerp(colors.gold, colors.ground, 0.5)!
          .withValues(alpha: 0.2),
    );
    // Warm light from the far end running down the cobbles.
    canvas.drawPath(
      Path()
        ..moveTo(ps.cx - w * 0.08, endGround)
        ..lineTo(ps.cx + w * 0.08, endGround)
        ..lineTo(ps.cx + w * 0.22, visibleBottom + 4)
        ..lineTo(ps.cx - w * 0.22, visibleBottom + 4)
        ..close(),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(ps.cx, endGround),
          Offset(ps.cx, visibleBottom),
          [
            colors.gold.withValues(alpha: 0.4),
            colors.gold.withValues(alpha: 0),
          ],
        ),
    );

    // ── Houses beyond the arch ─────────────────────────────────
    for (final side in const [-1.0, 1.0]) {
      final houses = side < 0 ? _leftHouses : _rightHouses;
      for (final hs in houses.reversed) {
        if (hs.$1 >= _zArch) _house(canvas, ps, side, hs, tones, warm);
      }
    }

    // ── Ivy-covered stone archway ──────────────────────────────
    final arch = _archway(canvas, ps, warm, lilac);

    // ── The cat on top of the arch (clipped so it slips behind the
    //    near walls at either end) ─────────────────────────────
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(arch.outer.left, 0, arch.outer.right, h));
    _cat(canvas, arch.outer, shadowInk);
    canvas.restore();

    // ── Houses in front of the arch ────────────────────────────
    for (final side in const [-1.0, 1.0]) {
      final houses = side < 0 ? _leftHouses : _rightHouses;
      for (final hs in houses.reversed) {
        if (hs.$1 < _zArch) _house(canvas, ps, side, hs, tones, warm);
      }
    }

    // Drainpipe on the near right house.
    final pipe = Paint()
      ..color = Color.lerp(colors.pill, purple, 0.2)!
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(ps.r(372, 1.86), ps.r(0, 1.86), pipe);

    // Ivy climbing the walls.
    _wallIvy(canvas, ps, 1, 1.2, 1.85, 170, 60, 1);
    _wallIvy(canvas, ps, -1, 3.35, 4.4, 260, 18, 7);

    // Windows: (side, near z, far z, bottom, top, lit, flower box).
    final sills = <Offset>[];
    for (final (side, z1, z2, y1, y2, lit, box) in const [
      (-1.0, 1.75, 2.05, 210.0, 300.0, false, false),
      (-1.0, 2.9, 3.25, 190.0, 265.0, true, true),
      (-1.0, 3.6, 3.95, 235.0, 290.0, true, false),
      (1.0, 2.35, 2.7, 220.0, 290.0, true, false),
      (1.0, 3.5, 3.9, 200.0, 265.0, true, true),
    ]) {
      sills.add(_window(canvas, ps, side, z1, z2, y1, y2, lit, box));
    }

    // ── The little wooden door ─────────────────────────────────
    final open = _doorOpen();
    _door(canvas, ps, open, warm);

    // ── Potted plants against the walls ────────────────────────
    final potTops = <Offset>[];
    for (final (i, (side, z, big)) in const [
      (-1.0, 2.0, true),
      (-1.0, 3.6, false),
      (1.0, 3.1, false),
      (1.0, 2.05, true),
    ].indexed) {
      potTops.add(_pot(canvas, ps, side, z, big, i));
    }

    // ── Hanging lanterns ───────────────────────────────────────
    _wallLantern(canvas, ps, -1, 2.3, 250, 0);
    _wallLantern(canvas, ps, 1, 3.0, 245, 1);

    // ── String of lights across the alley ──────────────────────
    final a = ps.l(300, 2.2);
    final b = ps.r(300, 2.2);
    final sag = 15 + 2 * math.sin(t * _tau * 3);
    final ctrl = Offset((a.dx + b.dx) / 2, a.dy + sag * 2);
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy),
      Paint()
        ..color = shadowInk
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    for (var i = 1; i < 12; i++) {
      final u = i / 12;
      final p = Offset(
        _quad(a.dx, ctrl.dx, b.dx, u),
        _quad(a.dy, ctrl.dy, b.dy, u) + 2.5,
      );
      final tw = 0.65 + 0.35 * math.sin(t * _tau * (4 + i % 3) + i * 1.3);
      final c = i % 3 == 1 ? colors.heart : colors.gold;
      canvas.drawCircle(
        p,
        5,
        Paint()..color = c.withValues(alpha: 0.22 * tw),
      );
      canvas.drawCircle(
        p,
        1.9,
        Paint()..color = Color.lerp(c, Colors.white, 0.45 * tw)!,
      );
    }

    // ── Fireflies drifting and blinking ────────────────────────
    for (var i = 0; i < 9; i++) {
      final blink = math.pow(
        math.max(0.0, math.sin(t * _tau * (5 + i % 4) + i * 2.3)),
        3,
      ).toDouble();
      if (blink < 0.03) continue;
      final x = w * (0.18 + 0.64 * _hash(i * 3.7 + 1)) +
          math.sin(t * _tau * (2 + i % 3) + i) * 16;
      final y = ps.vy - 10 + _hash(i * 5.3 + 7) * 62 +
          math.cos(t * _tau * (3 + i % 2) + i * 1.7) * 9;
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = colors.gold.withValues(alpha: 0.3 * blink),
      );
      canvas.drawCircle(
        Offset(x, y),
        1.5,
        Paint()
          ..color = Color.lerp(colors.gold, Colors.white, 0.5)!
              .withValues(alpha: blink),
      );
    }

    // ── Hidden-gem glint, hopping between secret spots ─────────
    final spots = [
      potTops[1].translate(-4, -2), // behind the little planter
      arch.keystone, // on the arch keystone
      sills[4], // in the far window box
      ps.p(ps.wallX - 70, 0, 2.6), // between the cobbles by the door
      sills[1], // on the windowsill
    ];
    final slot = t * 5 + 0.85;
    final phase = slot % 1.0;
    if (phase < 0.5) {
      _glint(canvas, spots[slot.floor() % 5], phase / 0.5, lilac);
    }
  }

  // ── Building blocks ──────────────────────────────────────────

  void _house(
    Canvas canvas,
    _Persp ps,
    double side,
    (double, double, double, int) hs,
    List<Color> tones,
    Color warm,
  ) {
    final (z1, z2, top, tone) = hs;
    // Houses nearest us sit in dusk shadow; the far end catches the glow.
    final shade = (0.55 * (1 - (z1 - 1) / 2.6)).clamp(0.0, 0.55);
    final base = Color.lerp(tones[tone], colors.pill, shade)!;
    final x = side * ps.wallX;
    final face = _quad4(
      ps.p(x, 0, z1),
      ps.p(x, top, z1),
      ps.p(x, top, z2),
      ps.p(x, 0, z2),
    );
    // Lit a little warmer towards the glowing far end.
    final glow = (1 / z2) < 0.2 ? 0.45 : 0.28;
    canvas.drawPath(
      face,
      Paint()
        ..shader = ui.Gradient.linear(
          ps.p(x, 0, z1),
          ps.p(x, 0, z2),
          [base, Color.lerp(base, warm, glow)!],
        ),
    );
    // Seam where this house meets the next one back.
    canvas.drawLine(
      ps.p(x, 0, z2),
      ps.p(x, top, z2),
      Paint()
        ..color = colors.pill.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );
    // Eave / roof edge.
    final eave = Color.lerp(colors.pill, purple, 0.12)!;
    canvas.drawPath(
      _quad4(
        ps.p(x * 0.97, top - 6, z1),
        ps.p(x * 0.97, top + 14, z1),
        ps.p(x * 0.97, top + 14, z2),
        ps.p(x * 0.97, top - 6, z2),
      ),
      Paint()..color = eave,
    );
    // Stone plinth along the bottom.
    canvas.drawPath(
      _quad4(
        ps.p(x, 0, z1),
        ps.p(x, 22, z1),
        ps.p(x, 22, z2),
        ps.p(x, 0, z2),
      ),
      Paint()..color = colors.pill.withValues(alpha: 0.22),
    );
  }

  /// Window on a wall; returns the middle of its sill.
  Offset _window(
    Canvas canvas,
    _Persp ps,
    double side,
    double z1,
    double z2,
    double y1,
    double y2,
    bool lit,
    bool box,
  ) {
    final x = side * ps.wallX;
    final frame = Color.lerp(colors.pill, colors.goldDeep, 0.25)!;
    canvas.drawPath(
      _quad4(
        ps.p(x, y1 - 8, z1 - 0.06),
        ps.p(x, y2 + 8, z1 - 0.06),
        ps.p(x, y2 + 8, z2 + 0.06),
        ps.p(x, y1 - 8, z2 + 0.06),
      ),
      Paint()..color = frame,
    );
    final glass = _quad4(
      ps.p(x, y1, z1),
      ps.p(x, y2, z1),
      ps.p(x, y2, z2),
      ps.p(x, y1, z2),
    );
    if (lit) {
      final flick = 0.9 + 0.1 * math.sin(t * _tau * 7 + z1 * 3);
      canvas.drawPath(
        glass,
        Paint()
          ..shader = ui.Gradient.linear(
            ps.p(x, y2, z1),
            ps.p(x, y1, z1),
            [
              Color.lerp(colors.gold, Colors.white, 0.4)!
                  .withValues(alpha: flick),
              colors.gold.withValues(alpha: flick),
            ],
          ),
      );
    } else {
      canvas.drawPath(
        glass,
        Paint()..color = Color.lerp(colors.pill, purple, 0.3)!,
      );
    }
    // Mullions.
    final mullion = Paint()
      ..color = frame
      ..strokeWidth = 1.2 / ((z1 + z2) / 2) * 2;
    final zm = (z1 + z2) / 2;
    final ym = (y1 + y2) / 2;
    canvas.drawLine(ps.p(x, y1, zm), ps.p(x, y2, zm), mullion);
    canvas.drawLine(ps.p(x, ym, z1), ps.p(x, ym, z2), mullion);
    // Open shutters folded back against the wall.
    final shutter = Paint()..color = Color.lerp(purple, colors.pill, 0.45)!;
    final sw = (z2 - z1) * 0.55;
    canvas.drawPath(
      _quad4(
        ps.p(x, y1 - 4, z1 - 0.08 - sw),
        ps.p(x, y2 + 4, z1 - 0.08 - sw),
        ps.p(x, y2 + 4, z1 - 0.08),
        ps.p(x, y1 - 4, z1 - 0.08),
      ),
      shutter,
    );
    canvas.drawPath(
      _quad4(
        ps.p(x, y1 - 4, z2 + 0.08),
        ps.p(x, y2 + 4, z2 + 0.08),
        ps.p(x, y2 + 4, z2 + 0.08 + sw),
        ps.p(x, y1 - 4, z2 + 0.08 + sw),
      ),
      shutter,
    );
    // Sill.
    final sillX = x * 0.96;
    canvas.drawPath(
      _quad4(
        ps.p(sillX, y1 - 14, z1 - 0.1),
        ps.p(sillX, y1 - 6, z1 - 0.1),
        ps.p(sillX, y1 - 6, z2 + 0.1),
        ps.p(sillX, y1 - 14, z2 + 0.1),
      ),
      Paint()..color = Color.lerp(colors.pill, colors.ground, 0.45)!,
    );
    final sill = ps.p(sillX, y1 - 6, zm);
    if (box) {
      final boxX = x * 0.93;
      canvas.drawPath(
        _quad4(
          ps.p(boxX, y1 - 24, z1),
          ps.p(boxX, y1 - 6, z1),
          ps.p(boxX, y1 - 6, z2),
          ps.p(boxX, y1 - 24, z2),
        ),
        Paint()..color = Color.lerp(colors.goldDeep, colors.heart, 0.35)!,
      );
      final leaf = Paint()..color = Color.lerp(green, colors.pill, 0.3)!;
      final bloom = Paint();
      for (var i = 0; i < 4; i++) {
        final z = z1 + (z2 - z1) * (i + 0.5) / 4;
        final c = ps.p(boxX, y1 + 2, z);
        final r = 9 / z;
        canvas.drawCircle(c, r, leaf);
        bloom.color = i.isEven ? colors.heart : colors.onDark;
        canvas.drawCircle(c.translate(0, -r * 0.5), r * 0.45, bloom);
      }
      return ps.p(boxX, y1 + 8, zm);
    }
    return sill;
  }

  /// 0 → 1 → 0 twice per loop, with a little creaky wobble while moving.
  double _doorOpen() {
    final p = (t * 2) % 1.0;
    double v;
    if (p < 0.12) {
      v = 0;
    } else if (p < 0.32) {
      v = Curves.easeInOut.transform((p - 0.12) / 0.2);
      v += 0.04 * math.sin((p - 0.12) / 0.2 * math.pi * 3);
    } else if (p < 0.58) {
      v = 1;
    } else if (p < 0.78) {
      v = 1 - Curves.easeInOut.transform((p - 0.58) / 0.2);
    } else {
      v = 0;
    }
    return v.clamp(0.0, 1.0);
  }

  void _door(Canvas canvas, _Persp ps, double open, Color warm) {
    final x = ps.wallX;
    // Stone surround.
    canvas.drawPath(
      _quad4(
        ps.p(x, 0, _doorNear - 0.07),
        ps.p(x, _doorH + 16, _doorNear - 0.07),
        ps.p(x, _doorH + 16, _doorFar + 0.07),
        ps.p(x, 0, _doorFar + 0.07),
      ),
      Paint()..color = Color.lerp(colors.pill, colors.ground, 0.42)!,
    );
    // Warm interior.
    final inside = _quad4(
      ps.p(x, 0, _doorNear),
      ps.p(x, _doorH, _doorNear),
      ps.p(x, _doorH, _doorFar),
      ps.p(x, 0, _doorFar),
    );
    canvas.drawPath(
      inside,
      Paint()
        ..color = Color.lerp(
          Color.lerp(colors.pill, colors.goldDeep, 0.35)!,
          Color.lerp(colors.gold, Colors.white, 0.3)!,
          open,
        )!,
    );
    if (open > 0.01) {
      // Glow around the doorway.
      final dc = ps.p(x, _doorH * 0.45, (_doorNear + _doorFar) / 2);
      canvas.drawCircle(
        dc,
        46,
        Paint()
          ..shader = RadialGradient(
            colors: [
              colors.gold.withValues(alpha: 0.4 * open),
              colors.gold.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: dc, radius: 46)),
      );
      // Light spilling out across the cobbles.
      final spill = Path()
        ..moveTo(ps.p(x, 0, _doorNear).dx, ps.p(x, 0, _doorNear).dy)
        ..lineTo(ps.p(x, 0, _doorFar).dx, ps.p(x, 0, _doorFar).dy)
        ..lineTo(
          ps.p(x - 190 * open, 0, _doorFar + 0.3).dx,
          ps.p(x - 190 * open, 0, _doorFar + 0.3).dy,
        )
        ..lineTo(
          ps.p(x - 190 * open, 0, _doorNear - 0.35).dx,
          ps.p(x - 190 * open, 0, _doorNear - 0.35).dy,
        )
        ..close();
      final from = ps.p(x, 0, (_doorNear + _doorFar) / 2);
      final to = ps.p(x - 190, 0, (_doorNear + _doorFar) / 2);
      canvas.drawPath(
        spill,
        Paint()
          ..shader = ui.Gradient.linear(from, to, [
            Color.lerp(colors.gold, Colors.white, 0.2)!
                .withValues(alpha: 0.75 * open),
            colors.gold.withValues(alpha: 0),
          ]),
      );
    }
    // Door panel, hinged on its far edge, swinging out towards us.
    final ang = open * 1.25;
    const dw = 64.0; // door width in wall units
    final zFree = _doorFar - (_doorFar - _doorNear) * math.cos(ang);
    final xFree = x - dw * math.sin(ang);
    final wood = Color.lerp(colors.goldDeep, colors.pill, 0.42)!;
    final woodDark = Color.lerp(colors.goldDeep, colors.pill, 0.62)!;
    final hb = ps.p(x, 0, _doorFar);
    final ht = ps.p(x, _doorH, _doorFar);
    final fb = ps.p(xFree, 0, zFree);
    final ft = ps.p(xFree, _doorH, zFree);
    final panel = Path()
      ..moveTo(hb.dx, hb.dy)
      ..lineTo(ht.dx, ht.dy)
      ..quadraticBezierTo(
        (ht.dx + ft.dx) / 2,
        math.min(ht.dy, ft.dy) - 5,
        ft.dx,
        ft.dy,
      )
      ..lineTo(fb.dx, fb.dy)
      ..close();
    canvas.drawPath(panel, Paint()..color = Color.lerp(wood, woodDark, open * 0.5)!);
    // Planks + iron strap + knob.
    final plank = Paint()
      ..color = woodDark
      ..strokeWidth = 0.9;
    for (final u in const [0.33, 0.66]) {
      final b = Offset.lerp(fb, hb, u)!;
      final tp = Offset.lerp(ft, ht, u)!;
      canvas.drawLine(b, tp.translate(0, 2), plank);
    }
    canvas.drawLine(
      Offset.lerp(fb, ft, 0.7)!,
      Offset.lerp(hb, ht, 0.7)!,
      Paint()
        ..color = colors.pill.withValues(alpha: 0.6)
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      Offset.lerp(Offset.lerp(fb, ft, 0.45)!, hb, 0.15)!,
      1.6,
      Paint()..color = colors.gold,
    );
  }

  /// Potted plant at the foot of a wall; returns the top of its foliage.
  Offset _pot(Canvas canvas, _Persp ps, double side, double z, bool big, int i) {
    final x = side * (ps.wallX - 26);
    final base = ps.p(x, 0, z);
    final s = (big ? 1.25 : 1.0) / z;
    final potW = 40 * s;
    final potH = 34 * s;
    final terracotta = Color.lerp(colors.goldDeep, colors.heart, 0.4)!;
    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(center: base, width: potW * 1.5, height: potH * 0.3),
      Paint()..color = colors.pill.withValues(alpha: 0.25),
    );
    // Foliage first so the pot rim sits over it.
    final sway = math.sin(t * _tau * 4 + i * 1.4) * 2 * s;
    final dark = Paint()..color = Color.lerp(green, colors.pill, 0.42)!;
    final mid = Paint()..color = Color.lerp(green, colors.pill, 0.2)!;
    final crownC = base.translate(sway * 0.5, -potH - 16 * s);
    canvas.drawCircle(crownC.translate(-12 * s, 6 * s), 14 * s, dark);
    canvas.drawCircle(crownC.translate(12 * s, 5 * s), 13 * s, dark);
    canvas.drawCircle(crownC.translate(sway, -4 * s), 16 * s, mid);
    canvas.drawCircle(
      crownC.translate(sway - 5 * s, -10 * s),
      6 * s,
      Paint()..color = Color.lerp(green, colors.gold, 0.35)!,
    );
    if (big) {
      final flower = Paint()..color = i.isEven ? colors.heart : colors.gold;
      for (final (dx, dy) in const [(-12.0, -2.0), (8.0, -12.0), (14.0, 4.0)]) {
        canvas.drawCircle(
          crownC.translate(sway + dx * s, dy * s),
          3.2 * s,
          flower,
        );
      }
    }
    // Pot.
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - potW * 0.38, base.dy)
        ..lineTo(base.dx - potW * 0.5, base.dy - potH)
        ..lineTo(base.dx + potW * 0.5, base.dy - potH)
        ..lineTo(base.dx + potW * 0.38, base.dy)
        ..close(),
      Paint()..color = terracotta,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        base.dx - potW * 0.56,
        base.dy - potH - 3 * s,
        potW * 1.12,
        8 * s,
      ),
      Paint()..color = Color.lerp(terracotta, colors.ground, 0.25)!,
    );
    return crownC.translate(0, -16 * s);
  }

  void _wallLantern(
    Canvas canvas,
    _Persp ps,
    double side,
    double z,
    double y,
    int i,
  ) {
    final wall = ps.p(side * ps.wallX, y, z);
    final s = 1.6 / z;
    final hang = wall.translate(-side * 22 * s, 0);
    final flick = _flicker(i);
    // Glow on the wall and the cobbles below.
    canvas.drawCircle(
      hang.translate(0, 18 * s),
      48 * s,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.gold.withValues(alpha: 0.45 * flick),
            colors.gold.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(center: hang.translate(0, 18 * s), radius: 48 * s),
        ),
    );
    final iron = Paint()
      ..color = colors.pill
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(wall.dx, wall.dy)
        ..lineTo(hang.dx, hang.dy)
        ..moveTo(wall.dx, wall.dy + 9 * s)
        ..quadraticBezierTo(
          wall.dx - side * 4 * s,
          wall.dy + 1 * s,
          hang.dx + side * 8 * s,
          hang.dy,
        ),
      iron,
    );
    _lantern(canvas, hang, s, math.sin(t * _tau * 4 + i * 2) * 0.12, flick);
  }

  double _flicker(int i) =>
      0.82 +
      0.1 * math.sin(t * _tau * 37 + i * 1.9) +
      0.08 * math.sin(t * _tau * 61 + i * 3.1);

  void _lantern(
    Canvas canvas,
    Offset hang,
    double s,
    double sway,
    double flick,
  ) {
    canvas.save();
    canvas.translate(hang.dx, hang.dy);
    canvas.rotate(sway);
    final iron = Paint()..color = colors.pill;
    canvas.drawLine(
      Offset.zero,
      Offset(0, 5 * s),
      Paint()
        ..color = colors.pill
        ..strokeWidth = 1.2 * s,
    );
    // Halo.
    canvas.drawCircle(
      Offset(0, 14 * s),
      13 * s,
      Paint()..color = colors.gold.withValues(alpha: 0.28 * flick),
    );
    // Cap.
    canvas.drawPath(
      Path()
        ..moveTo(-6 * s, 8 * s)
        ..lineTo(0, 4 * s)
        ..lineTo(6 * s, 8 * s)
        ..close(),
      iron,
    );
    // Glass.
    final glass = Rect.fromLTRB(-4.5 * s, 8 * s, 4.5 * s, 20 * s);
    canvas.drawRect(
      glass,
      Paint()
        ..color = Color.lerp(colors.goldDeep, colors.gold, flick)!,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, 14.5 * s),
        width: 3 * s,
        height: 6 * s * (0.8 + 0.2 * flick),
      ),
      Paint()
        ..color = Color.lerp(colors.gold, Colors.white, 0.6 * flick)!,
    );
    canvas.drawLine(
      Offset(0, 8 * s),
      Offset(0, 20 * s),
      Paint()
        ..color = colors.pill.withValues(alpha: 0.5)
        ..strokeWidth = 0.8 * s,
    );
    // Base.
    canvas.drawRect(Rect.fromLTRB(-5.5 * s, 20 * s, 5.5 * s, 22.5 * s), iron);
    canvas.restore();
  }

  _Arch _archway(Canvas canvas, _Persp ps, Color warm, Color lilac) {
    final left = ps.l(0, _zArch).dx;
    final right = ps.r(0, _zArch).dx;
    final ground = ps.l(0, _zArch).dy;
    final top = ps.vy + (_Persp.eye - 340) / _zArch;
    final pillar = (right - left) * 0.15;
    final xl = left + pillar;
    final xr = right - pillar;
    final spring = ps.vy + (_Persp.eye - 180) / _zArch;
    final ry = (spring - top) * 0.62;
    final crown = spring - ry;
    final outer = Rect.fromLTRB(left, top, right, ground);

    final opening = Path()
      ..moveTo(xl, ground)
      ..lineTo(xl, spring)
      ..arcToPoint(
        Offset(xr, spring),
        radius: Radius.elliptical((xr - xl) / 2, ry),
      )
      ..lineTo(xr, ground)
      ..close();
    final stone = Color.lerp(
      Color.lerp(colors.ground, colors.goldDeep, 0.4)!,
      colors.pill,
      0.42,
    )!;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(outer),
        opening,
      ),
      Paint()..color = stone,
    );
    // Inner soffit shading + warm rim lit by the far end.
    canvas.drawPath(
      opening,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Color.lerp(stone, colors.gold, 0.45)!,
    );
    // Voussoir joints fanning around the arch.
    final joint = Paint()
      ..color = colors.pill.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    final ac = Offset(ps.cx, spring);
    for (var k = 1; k < 8; k++) {
      final ang = math.pi + math.pi * k / 8;
      final dir = Offset(math.cos(ang), math.sin(ang));
      final inner = ac + Offset(dir.dx * (xr - xl) / 2, dir.dy * ry);
      final out = ac +
          Offset(dir.dx * ((xr - xl) / 2 + 11), dir.dy * (ry + 9));
      canvas.drawLine(inner, out, joint);
    }
    // Keystone.
    final keystone = Offset(ps.cx, crown - 4);
    canvas.drawPath(
      Path()
        ..moveTo(ps.cx - 5, crown - 10)
        ..lineTo(ps.cx + 5, crown - 10)
        ..lineTo(ps.cx + 3.5, crown + 1)
        ..lineTo(ps.cx - 3.5, crown + 1)
        ..close(),
      Paint()..color = Color.lerp(stone, colors.ground, 0.25)!,
    );
    // Coping along the top.
    canvas.drawRect(
      Rect.fromLTRB(left - 2, top - 2, right + 2, top + 3),
      Paint()..color = Color.lerp(stone, colors.pill, 0.35)!,
    );

    // Pinned treasure map on the left pillar, its corner fluttering.
    _map(canvas, Rect.fromLTWH(left + 2.5, spring + 6, pillar - 5, 15));

    // Ivy across the top and trailing down the opening.
    _ivy(canvas, outer, xl, xr, spring, crown);

    // Lantern hanging from the crown.
    final flick = _flicker(2);
    canvas.drawCircle(
      Offset(ps.cx, crown + 14),
      22,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.gold.withValues(alpha: 0.4 * flick),
            colors.gold.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(ps.cx, crown + 14), radius: 22),
        ),
    );
    canvas.drawLine(
      Offset(ps.cx, crown),
      Offset(ps.cx, crown + 3),
      Paint()
        ..color = colors.pill
        ..strokeWidth = 0.8,
    );
    _lantern(
      canvas,
      Offset(ps.cx, crown + 3),
      0.62,
      math.sin(t * _tau * 5 + 1) * 0.1,
      flick,
    );

    return _Arch(outer, keystone);
  }

  void _map(Canvas canvas, Rect r) {
    final paper = Color.lerp(colors.card, colors.goldDeep, 0.2)!;
    // Corner flutters in little gusts (4 gusts per loop).
    final gust = math.pow(0.5 + 0.5 * math.sin(t * _tau * 4), 2).toDouble();
    final lift = (0.25 + 0.75 * gust) *
        (0.6 + 0.4 * math.sin(t * _tau * 40));
    const k = 0.42;
    final c = r.bottomRight;
    final e = Offset(c.dx, c.dy - r.height * k);
    final f = Offset(c.dx - r.width * k * 1.6, c.dy);
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.top)
        ..lineTo(r.right, r.top)
        ..lineTo(e.dx, e.dy)
        ..lineTo(f.dx, f.dy)
        ..lineTo(r.left, r.bottom)
        ..close(),
      Paint()..color = paper,
    );
    // Dotted route and an X marking the spot.
    final ink = Paint()
      ..color = colors.goldDeep
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final p = Offset(r.left + 1.6 + i * 1.8, r.top + 3 + i * 2.6);
      canvas.drawCircle(p, 0.5, ink..style = PaintingStyle.fill);
    }
    final xm = Offset(r.left + r.width * 0.62, r.top + 4);
    final xp = Paint()
      ..color = colors.heart
      ..strokeWidth = 1;
    canvas.drawLine(xm.translate(-1.4, -1.4), xm.translate(1.4, 1.4), xp);
    canvas.drawLine(xm.translate(-1.4, 1.4), xm.translate(1.4, -1.4), xp);
    // Pin.
    canvas.drawCircle(
      Offset(r.center.dx, r.top + 0.6),
      1.2,
      Paint()..color = colors.heart,
    );
    // The lifted flap: the corner reflected across the fold line.
    final mid = Offset.lerp(e, f, 0.5)!;
    final reflected = mid * 2 - c;
    final tip = Offset.lerp(c, Offset.lerp(c, reflected, 0.9)!, lift)!;
    canvas.drawPath(
      Path()
        ..moveTo(e.dx, e.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(f.dx, f.dy)
        ..close(),
      Paint()..color = Color.lerp(paper, colors.goldDeep, 0.3)!,
    );
  }

  void _ivy(
    Canvas canvas,
    Rect outer,
    double xl,
    double xr,
    double spring,
    double crown,
  ) {
    final dark = Path();
    final mid = Path();
    final light = Path();
    final gust = 0.6 + 0.4 * math.sin(t * _tau * 2);
    var i = 0;
    void leaf(Offset c, double size, double base) {
      final a = base +
          0.3 * gust * math.sin(t * _tau * 6 - i * 0.55) +
          0.1 * math.sin(t * _tau * 11 + i);
      final target = switch (i % 3) {
        0 => dark,
        1 => mid,
        _ => light,
      };
      _leafPath(target, c, size, a);
      i++;
    }

    // Along the coping, spilling over both faces.
    final n = ((outer.width) / 5.5).floor();
    for (var k = 0; k <= n; k++) {
      final x = outer.left - 3 + k * (outer.width + 6) / n;
      final droop = 3 + 4 * _hash(k * 1.7 + 3);
      leaf(Offset(x, outer.top + droop), 5.5, math.pi / 2 + (k.isEven ? 0.5 : -0.5));
      if (k % 2 == 0) {
        leaf(Offset(x + 2, outer.top - 2), 4.5, -math.pi / 2 + 0.4 * (k % 4 - 1));
      }
    }
    // Thick clump over the left shoulder, trailing down the pillar.
    for (var k = 0; k < 9; k++) {
      final y = outer.top + 6 + k * 4.2;
      final x = outer.left + 3 + _hash(k * 2.9) * 8;
      leaf(Offset(x, y), 5, math.pi / 2 + (k.isEven ? 0.7 : -0.7));
    }
    // Strands hanging into the opening from the arch.
    final stem = Paint()
      ..color = Color.lerp(green, colors.pill, 0.5)!
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (final (sx, len) in [
      (xl + (xr - xl) * 0.22, 22.0),
      (xl + (xr - xl) * 0.7, 30.0),
      (xr - 3, 34.0),
    ]) {
      final topY = sx > xr - 5 ? spring - 4 : crown + 6 + 8 * _hash(sx);
      final swing = math.sin(t * _tau * 3 + sx) * 2.5 * gust;
      canvas.drawPath(
        Path()
          ..moveTo(sx, topY - 6)
          ..quadraticBezierTo(sx + swing * 0.5, topY + len / 2, sx + swing, topY + len),
        stem,
      );
      for (var k = 0; k < 5; k++) {
        final u = (k + 0.5) / 5;
        leaf(
          Offset(sx + swing * u * u, topY - 6 + (len + 6) * u),
          4.2 - k * 0.3,
          math.pi / 2 + (k.isEven ? 0.8 : -0.8),
        );
      }
    }
    canvas.drawPath(dark, Paint()..color = Color.lerp(green, colors.pill, 0.5)!);
    canvas.drawPath(mid, Paint()..color = Color.lerp(green, colors.pill, 0.25)!);
    canvas.drawPath(light, Paint()..color = Color.lerp(green, colors.gold, 0.3)!);
  }

  /// A patch of ivy growing up a wall, thinning out towards the top.
  void _wallIvy(
    Canvas canvas,
    _Persp ps,
    double side,
    double z1,
    double z2,
    double maxH,
    int count,
    int seed,
  ) {
    final dark = Path();
    final mid = Path();
    final x = side * ps.wallX;
    for (var i = 0; i < count; i++) {
      final u = _hash(i * 1.37 + seed);
      final v = math.pow(_hash(i * 2.71 + seed * 3), 1.6).toDouble();
      final z = z1 + (z2 - z1) * u;
      final c = ps.p(x, v * maxH, z);
      final a = (i.isEven ? 0.6 : 2.4) +
          0.25 * math.sin(t * _tau * 6 - i * 0.6 + seed);
      _leafPath(i % 3 == 0 ? mid : dark, c, 17 / z, a);
    }
    canvas.drawPath(dark, Paint()..color = Color.lerp(green, colors.pill, 0.55)!);
    canvas.drawPath(mid, Paint()..color = Color.lerp(green, colors.pill, 0.3)!);
  }

  void _leafPath(Path path, Offset c, double size, double a) {
    final dir = Offset(math.cos(a), math.sin(a)) * (size / 2);
    final perp = Offset(-dir.dy, dir.dx) * 0.75;
    final tip = c + dir;
    final base = c - dir;
    path
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(c.dx + perp.dx * 1.4, c.dy + perp.dy * 1.4, tip.dx, tip.dy)
      ..quadraticBezierTo(c.dx - perp.dx * 1.4, c.dy - perp.dy * 1.4, base.dx, base.dy)
      ..close();
  }

  /// The cat strolls along the top of the arch once per loop: walk in,
  /// sit and swish its tail, then wander off the other side.
  void _cat(Canvas canvas, Rect arch, Color ink) {
    const walk1 = (0.1, 0.25);
    const walk2 = (0.42, 0.6);
    if (t < walk1.$1 || t > walk2.$2) return;
    final y = arch.top - 2;
    final startX = arch.left - 26;
    final pauseX = arch.center.dx - 14;
    final endX = arch.right + 26;
    final paint = Paint()..color = ink;
    final eye = Paint()..color = colors.gold;

    if (t < walk1.$2 || t > walk2.$1) {
      final double x;
      if (t < walk1.$2) {
        x = startX + (pauseX - startX) * (t - walk1.$1) / (walk1.$2 - walk1.$1);
      } else {
        x = pauseX + (endX - pauseX) * (t - walk2.$1) / (walk2.$2 - walk2.$1);
      }
      final step = t * _tau * 70;
      final bob = math.sin(step * 2).abs() * 0.6;
      // Legs.
      final leg = Paint()
        ..color = ink
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (final (dx, ph) in const [(-6.0, 0.0), (-3.5, math.pi), (4.0, math.pi), (6.5, 0.0)]) {
        final swing = math.sin(step + ph) * 2.2;
        canvas.drawLine(
          Offset(x + dx, y - 5 - bob),
          Offset(x + dx + swing, y),
          leg,
        );
      }
      // Body.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y - 7 - bob), width: 19, height: 7.5),
          const Radius.circular(4),
        ),
        paint,
      );
      // Head + ears.
      final head = Offset(x + 10.5, y - 11 - bob);
      canvas.drawCircle(head, 4, paint);
      canvas.drawPath(
        Path()
          ..moveTo(head.dx - 3.5, head.dy - 1.5)
          ..lineTo(head.dx - 2.4, head.dy - 6.8)
          ..lineTo(head.dx, head.dy - 3)
          ..lineTo(head.dx + 1.6, head.dy - 6.8)
          ..lineTo(head.dx + 3.6, head.dy - 1.5)
          ..close(),
        paint,
      );
      canvas.drawCircle(head.translate(2, -0.6), 0.9, eye);
      // Tail held up in a gentle curve.
      final swish = math.sin(t * _tau * 24) * 2;
      canvas.drawPath(
        Path()
          ..moveTo(x - 9, y - 8 - bob)
          ..quadraticBezierTo(x - 17, y - 9 + swish, x - 15 + swish, y - 19),
        Paint()
          ..color = ink
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      return;
    }

    // Sitting, facing us, tail swishing along the ledge.
    final x = pauseX;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y - 7), width: 13, height: 15),
      paint,
    );
    final head = Offset(x, y - 17);
    canvas.drawCircle(head, 5, paint);
    canvas.drawPath(
      Path()
        ..moveTo(head.dx - 4.8, head.dy - 1)
        ..lineTo(head.dx - 3.8, head.dy - 8)
        ..lineTo(head.dx - 0.8, head.dy - 4.2)
        ..lineTo(head.dx + 0.8, head.dy - 4.2)
        ..lineTo(head.dx + 3.8, head.dy - 8)
        ..lineTo(head.dx + 4.8, head.dy - 1)
        ..close(),
      paint,
    );
    // Eyes, with one slow blink partway through the pause.
    final blink = ((t - 0.33).abs() < 0.004) ? 0.25 : 1.0;
    for (final dx in const [-2.0, 2.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: head.translate(dx, -0.4),
          width: 1.8,
          height: 2.2 * blink,
        ),
        eye,
      );
    }
    final swish = math.sin(t * _tau * 20);
    canvas.drawPath(
      Path()
        ..moveTo(x + 5, y - 1.5)
        ..quadraticBezierTo(x + 13, y - 1, x + 16, y - 4 - 4 * swish)
        ..quadraticBezierTo(
          x + 17 + 1.5 * swish,
          y - 8 - 3 * swish,
          x + 14 + 3 * swish,
          y - 10 - 3 * swish,
        ),
      Paint()
        ..color = ink
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  /// A 4-point "hidden gem" star that blooms, turns and fades (p: 0→1).
  void _glint(Canvas canvas, Offset c, double p, Color lilac) {
    final s = math.sin(p * math.pi);
    if (s < 0.02) return;
    canvas.drawCircle(
      c,
      12 * s,
      Paint()..color = lilac.withValues(alpha: 0.3 * s),
    );
    _star(canvas, c, 7.5 * s, p * 1.2, Colors.white.withValues(alpha: s));
    _star(canvas, c, 3.2 * s, p * 1.2 + math.pi / 4,
        lilac.withValues(alpha: s));
    // A tiny companion twinkle.
    final s2 = math.sin(((p - 0.25).clamp(0.0, 0.75) / 0.75) * math.pi);
    if (s2 > 0.02) {
      _star(canvas, c.translate(8, -7), 3.2 * s2, 0,
          colors.onDark.withValues(alpha: s2));
    }
  }

  void _star(Canvas canvas, Offset c, double r, double rot, Color color) {
    final path = Path();
    for (var k = 0; k < 4; k++) {
      final a = rot + k * math.pi / 2;
      final tip = c + Offset(math.cos(a), math.sin(a)) * r;
      final next = c +
          Offset(math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)) * r;
      if (k == 0) path.moveTo(tip.dx, tip.dy);
      final ctrl = c +
          Offset(math.cos(a + math.pi / 4), math.sin(a + math.pi / 4)) *
              (r * 0.18);
      path.quadraticBezierTo(ctrl.dx, ctrl.dy, next.dx, next.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // ── Helpers ─────────────────────────────────────────────────

  static Path _quad4(Offset a, Offset b, Offset c, Offset d) => Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy)
    ..lineTo(c.dx, c.dy)
    ..lineTo(d.dx, d.dy)
    ..close();

  static double _quad(double a, double c, double b, double u) =>
      (1 - u) * (1 - u) * a + 2 * (1 - u) * u * c + u * u * b;

  /// Cheap deterministic 0→1 hash.
  static double _hash(double v) {
    final s = math.sin(v * 12.9898) * 43758.5453;
    return s - s.floorToDouble();
  }

  @override
  bool shouldRepaint(SecretsScenePainter old) =>
      old.t != t ||
      old.colors != colors ||
      old.purple != purple ||
      old.green != green ||
      old.topPadding != topPadding;
}

/// One-point perspective down the alley. World x is in "near" units
/// (the walls stand at ±[wallX]), heights are in the same units with the
/// ground at 0, and z = 1 is the viewer's plane.
class _Persp {
  const _Persp(this.cx, this.vy, this.wallX);

  final double cx;
  final double vy;
  final double wallX;

  /// Eye height above the ground at z = 1.
  static const eye = 160.0;

  Offset p(double x, double yh, double z) =>
      Offset(cx + x / z, vy + (eye - yh) / z);

  Offset l(double yh, double z) => p(-wallX, yh, z);
  Offset r(double yh, double z) => p(wallX, yh, z);
}

class _Arch {
  const _Arch(this.outer, this.keystone);

  final Rect outer;
  final Offset keystone;
}
