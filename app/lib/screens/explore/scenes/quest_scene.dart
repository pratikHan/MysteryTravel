import 'package:flutter/material.dart';

import '../../../core/motion.dart';
import 'artistic_scene.dart';
import 'family_scene.dart';
import 'foodie_scene.dart';
import 'night_scene.dart';
import 'peaceful_scene.dart';
import 'stories_scene.dart';

/// Animated header backgrounds for Quest Detail, one painter per quest.
/// Returns null when a quest has no scene yet — the header then keeps
/// its static hero image, so scenes can roll out one at a time.
Widget? questSceneFor(String questId) => switch (questId) {
  'peaceful' => const LoopingScene(painter: PeacefulScenePainter.new),
  'night' => const LoopingScene(painter: NightScenePainter.new),
  'artistic' => const LoopingScene(painter: ArtisticScenePainter.new),
  'stories' => const LoopingScene(painter: StoriesScenePainter.new),
  'foodie' => const LoopingScene(painter: FoodieScenePainter.new),
  'family' => const LoopingScene(painter: FamilyScenePainter.new),
  _ => null,
};

/// Scenes dark enough that the status bar needs light icons.
bool questSceneIsDark(String questId) => questId == 'night';

typedef ScenePainterBuilder = CustomPainter Function(
  double t,
  BuildContext context,
);

/// Hosts a looping scene: one slow controller whose value `t` (0→1)
/// drives every motion in the painter. Frozen at a pleasant frame under
/// reduced motion.
class LoopingScene extends StatefulWidget {
  const LoopingScene({
    super.key,
    required this.painter,
    this.period = const Duration(seconds: 40),
  });

  final ScenePainterBuilder painter;
  final Duration period;

  @override
  State<LoopingScene> createState() => _LoopingSceneState();
}

class _LoopingSceneState extends State<LoopingScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MotionSettings.reduced(context)) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: widget.painter(
          MotionSettings.reduced(context) ? 0.3 : _c.value,
          context,
        ),
      ),
    ),
  );
}
