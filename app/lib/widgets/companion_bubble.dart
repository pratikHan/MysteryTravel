import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../theme/tokens.dart';
import 'app_text.dart';
import 'mascot.dart';

/// Companion speech bubble (interactions.png #6): when the message
/// changes, the mascot "types" (three bouncing dots) for a beat, then
/// the new message fades in. Under reduced motion the text just swaps.
class CompanionBubble extends StatefulWidget {
  const CompanionBubble({
    super.key,
    required this.message,
    this.mascotState = MascotState.idle,
    this.mascotSize = 64,
    this.typingDelay = const Duration(milliseconds: 650),
  });

  final String message;
  final MascotState mascotState;
  final double mascotSize;
  final Duration typingDelay;

  @override
  State<CompanionBubble> createState() => _CompanionBubbleState();
}

class _CompanionBubbleState extends State<CompanionBubble> {
  String _shown = '';
  bool _typing = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _shown = widget.message;
  }

  @override
  void didUpdateWidget(CompanionBubble old) {
    super.didUpdateWidget(old);
    if (old.message != widget.message) {
      if (MotionSettings.reduced(context)) {
        setState(() => _shown = widget.message);
        return;
      }
      final gen = ++_generation;
      setState(() => _typing = true);
      Future.delayed(widget.typingDelay, () {
        if (!mounted || gen != _generation) return;
        setState(() {
          _typing = false;
          _shown = widget.message;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // mascotSize 0 renders a bare bubble (caller shows its own mascot).
        if (widget.mascotSize > 0) ...[
          Mascot(widget.mascotState, size: widget.mascotSize),
          const SizedBox(width: AppSpace.m),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.l, vertical: AppSpace.m),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.tail),
                topRight: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
                bottomRight: Radius.circular(AppRadius.card),
              ),
              boxShadow: [
                BoxShadow(
                    color: c.shadow(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.base,
              child: _typing
                  ? const _TypingDots(key: ValueKey('dots'))
                  : AppText(_shown, AppType.body, key: ValueKey(_shown)),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots({super.key});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 20,
      width: 44,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7,
                height: 7,
                transform: Matrix4.translationValues(
                    0,
                    -3 *
                        math.sin((_c.value * math.pi * 2) - i * 0.9)
                            .clamp(0.0, 1.0),
                    0),
                decoration: BoxDecoration(
                    color: c.muted.withValues(alpha: 0.6),
                    shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
