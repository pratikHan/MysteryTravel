import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'motion_widgets.dart';

/// The five production mascot states from the product plan. Today each
/// maps to a static placeholder PNG; later the whole widget body swaps to
/// one Rive rig driven by this same enum — callers never change.
enum MascotState {
  idle('assets/images/interests/footer_mascot.png'),
  curious('assets/images/chapter/quiz_mascot.png'),
  walking('assets/images/preview/mascot_corner.png'),
  celebrating('assets/images/chapter/reveal_mascot.png'),
  resting('assets/images/chapter/pause_mascot.png');

  const MascotState(this.placeholderAsset);
  final String placeholderAsset;
}

/// Swappable mascot slot. Keep ALL mascot rendering behind this widget.
///
/// The placeholder art is square scene crops (no transparency), so it
/// renders as a circular sticker with a ring + shadow; the Rive rig will
/// replace the sticker with a true cutout animation.
class Mascot extends StatelessWidget {
  const Mascot(
    this.state, {
    super.key,
    this.size = 120,
    this.float = true,
    this.asset,
  });

  final MascotState state;
  final double size;
  final bool float;

  /// Optional art override while screens still use scene-specific
  /// placeholder images; goes away once the Rive rig lands.
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sticker = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.surface, width: size * 0.035),
        boxShadow: [
          BoxShadow(
            color: c.shadow(0.18),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.04),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          asset ?? state.placeholderAsset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
    return float ? Floaty(child: sticker) : sticker;
  }
}
