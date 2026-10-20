import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/sounds.dart';
import '../theme/tokens.dart';

/// Press feedback per tokens.json motion.press: scale 0.97 over 150ms,
/// with an optional tap sound + haptic. The base interactive wrapper.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.sfx = Sfx.tap,
    this.haptic = Haptic.light,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Sfx? sfx;
  final Haptic? haptic;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: widget.enabled ? (_) => setState(() => _down = false) : null,
      onTap: widget.enabled
          ? () {
              if (widget.sfx != null) {
                SoundService.instance.play(widget.sfx!, haptic: widget.haptic);
              } else if (widget.haptic != null) {
                SoundService.instance.feel(widget.haptic!);
              }
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? AppMotion.pressScale : 1.0,
        duration: AppMotion.press,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Press-and-bounce feedback (interactions.png #1): soft press-down,
/// then a playful overshoot bounce on release before firing the tap.
class BouncyPressable extends StatefulWidget {
  const BouncyPressable({
    super.key,
    required this.child,
    this.onTap,
    this.sfx = Sfx.tap,
    this.haptic = Haptic.light,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Sfx? sfx;
  final Haptic? haptic;
  final bool enabled;

  @override
  State<BouncyPressable> createState() => _BouncyPressableState();
}

class _BouncyPressableState extends State<BouncyPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280), value: 1);
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.06), weight: 55),
    TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45),
  ]).animate(_c);

  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _fire() {
    if (widget.sfx != null) {
      SoundService.instance.play(widget.sfx!, haptic: widget.haptic);
    } else if (widget.haptic != null) {
      SoundService.instance.feel(widget.haptic!);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MotionSettings.reduced(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: widget.enabled ? (_) => setState(() => _down = false) : null,
      onTap: widget.enabled
          ? () {
              if (!reduced) _c.forward(from: 0);
              _fire();
            }
          : null,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.scale(
          scale: reduced
              ? 1.0
              : _down
                  ? 0.94
                  : (_c.isAnimating ? _scale.value : 1.0),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Gentle vertical float loop (tokens.json motion.float). Stops under
/// reduced motion.
class Floaty extends StatefulWidget {
  const Floaty({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppMotion.float);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduced(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(
            0,
            AppMotion.floatTranslateY *
                Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Slow alternate zoom on hero imagery (tokens.json motion.kenburns).
class KenBurns extends StatefulWidget {
  const KenBurns({super.key, required this.child});

  final Widget child;

  @override
  State<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: AppMotion.kenburns)
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduced(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.scale(
        scale: 1 +
            (AppMotion.kenburnsScaleTo - 1) *
                Curves.easeInOut.transform(_c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Entrance: fade + rise, with optional stagger. Under reduced motion the
/// child appears immediately.
class FadeRiseIn extends StatefulWidget {
  const FadeRiseIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 18,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<FadeRiseIn> createState() => _FadeRiseInState();
}

class _FadeRiseInState extends State<FadeRiseIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppMotion.entrance);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduced(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = AppMotion.easeOut.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Overshoot pop-in (tokens.json motion.pop), used by check badges,
/// stamps and star coins.
class PopIn extends StatefulWidget {
  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.peak = AppMotion.popPeakScale,
    this.withRotation = false,
  });

  final Widget child;
  final Duration delay;
  final double peak;
  final bool withRotation;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppMotion.pop);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduced(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final v = _c.value;
        // 0 → peak at 70% → settle at 1.
        final scale = v < 0.7
            ? (widget.peak * AppMotion.easeOut.transform(v / 0.7))
            : widget.peak + (1 - widget.peak) * ((v - 0.7) / 0.3);
        return Opacity(
          opacity: v.clamp(0, 0.4) / 0.4,
          child: Transform.rotate(
            angle: widget.withRotation ? (1 - v) * -0.35 : 0,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Fades the top band of a scene image into the background behind it,
/// so bottom-anchored artwork blends with a sky gradient.
class FadeTopEdge extends StatelessWidget {
  const FadeTopEdge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, 0.18],
        colors: [Colors.transparent, Colors.black],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

/// Horizontal shake for wrong answers / locked rows.
class Shaker extends StatefulWidget {
  const Shaker({super.key, required this.child});

  final Widget child;

  @override
  State<Shaker> createState() => ShakerState();
}

class ShakerState extends State<Shaker> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppMotion.shake);

  void shake() {
    if (MotionSettings.reduced(context)) return;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(math.sin(_c.value * math.pi * 4) * 5, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Animated count-up for stat tiles (0 → value on entry).
class CountUp extends StatelessWidget {
  const CountUp(this.value, this.type, {super.key, this.color});

  final int value;
  final TypeStyle type;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduced(context)) {
      return Text('$value',
          style: TextStyle(
              fontSize: type.size,
              fontWeight: type.weight,
              color: color ?? context.colors.ink));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AppMotion.countUp,
      curve: AppMotion.easeOut,
      builder: (context, v, _) => Text(
        '${v.round()}',
        style: TextStyle(
            fontSize: type.size,
            fontWeight: type.weight,
            color: color ?? context.colors.ink),
      ),
    );
  }
}
