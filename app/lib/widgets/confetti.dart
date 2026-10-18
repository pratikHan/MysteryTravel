import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';

/// Lightweight confetti burst painted in code — no package, theme-free
/// festive palette. Plays once on mount; renders nothing under reduced
/// motion.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.pieces = 44, this.duration});

  final int pieces;
  final Duration? duration;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiPiece {
  _ConfettiPiece(math.Random r)
      : x = r.nextDouble(),
        vy = 0.35 + r.nextDouble() * 0.5,
        drift = (r.nextDouble() - 0.5) * 0.35,
        size = 5 + r.nextDouble() * 6,
        spin = (r.nextDouble() - 0.5) * 10,
        delay = r.nextDouble() * 0.35,
        color = _palette[r.nextInt(_palette.length)],
        rect = r.nextBool();

  static const _palette = [
    Color(0xFFF5A623),
    Color(0xFF4A90D9),
    Color(0xFFE4554E),
    Color(0xFF5BA85F),
    Color(0xFF8A4FD3),
    Color(0xFFF2C94C),
  ];

  final double x, vy, drift, size, spin, delay;
  final Color color;
  final bool rect;
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 2200))
    ..forward();
  late final List<_ConfettiPiece> _pieces =
      List.generate(widget.pieces, (_) => _ConfettiPiece(math.Random()));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduced(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _c.value),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_ConfettiPiece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final fade = local > 0.75 ? (1 - local) / 0.25 : 1.0;
      paint.color = p.color.withValues(alpha: fade);
      final dx = (p.x + p.drift * local) * size.width;
      final dy = (-0.05 + p.vy * local) * size.height;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * local);
      if (p.rect) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 0.65),
              const Radius.circular(1.5)),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.42, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
