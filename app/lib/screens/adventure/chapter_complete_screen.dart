import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/confetti.dart';
import '../../widgets/motion_widgets.dart';

/// Star coin drops with bounce, checklist ticks in sequence
/// (reference: 15_chapter_complete.png).
class ChapterCompleteScreen extends StatefulWidget {
  const ChapterCompleteScreen({super.key});

  @override
  State<ChapterCompleteScreen> createState() =>
      _ChapterCompleteScreenState();
}

class _ChapterCompleteScreenState extends State<ChapterCompleteScreen> {
  static const _checklist = [
    'Found the location',
    'Learned a fun story',
    'Earned a stamp',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.instance.play(Sfx.fanfare, haptic: Haptic.success);
    });
  }

  void _next() {
    final state = AppScope.read(context);
    final wasLast = state.currentChapter >= Fixtures.chapters.length - 1;
    state.completeCurrentChapter();
    if (wasLast) {
      context.pushReplacement('/journey/complete');
    } else {
      context.go('/adventure');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chapter = AppScope.of(context).activeChapter;
    final isLast = chapter.number >= Fixtures.chapters.length;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.5],
                colors: [c.groundTop, c.ground],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.prefsGutter),
              child: Column(
                children: [
                  const SizedBox(height: AppSpace.xl),
                  FadeRiseIn(
                    child: AppText('Chapter ${chapter.number} Complete!',
                        AppType.screenTitle,
                        align: TextAlign.center),
                  ),
                  const SizedBox(height: AppSpace.s),
                  AppText(
                      'Great job! You solved the clue\nand found an amazing place.',
                      AppType.body,
                      color: c.muted,
                      align: TextAlign.center),
                  const Spacer(),
                  // Star coin drops in with a bounce.
                  // The star asset already includes the celebrating
                  // mascot, so it is the single hero of this screen.
                  PopIn(
                    delay: const Duration(milliseconds: 250),
                    peak: 1.3,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surface, width: 5),
                        boxShadow: [
                          BoxShadow(
                              color: c.gold.withValues(alpha: 0.45),
                              blurRadius: 30,
                              spreadRadius: 4),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/chapter/complete_star.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpace.xl),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.card + 4),
                      boxShadow: [
                        BoxShadow(
                            color: c.shadow(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final (i, item) in _checklist.indexed) ...[
                          Row(
                            children: [
                              PopIn(
                                delay: Duration(
                                    milliseconds: 500 + 280 * i),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                      color: c.success,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                              const SizedBox(width: AppSpace.m),
                              AppText(item, AppType.rowTitle),
                            ],
                          ),
                          if (i != _checklist.length - 1)
                            const SizedBox(height: AppSpace.m + 2),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  PrimaryButton(
                    label: isLast ? 'Finish Adventure' : 'Next Chapter',
                    sfx: Sfx.success,
                    onTap: _next,
                  ),
                  const SizedBox(height: AppSpace.xxl),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: ConfettiBurst()),
        ],
      ),
    );
  }
}
