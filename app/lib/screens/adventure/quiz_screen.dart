import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Optional fun-fact quiz — always skippable, never blocks progress
/// (reference: 17_quiz.png).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _picked;

  bool get _answered => _picked != null;

  void _pick(int i, int correct) {
    if (_answered) return;
    setState(() => _picked = i);
    if (i == correct) {
      SoundService.instance.play(Sfx.success, haptic: Haptic.success);
    } else {
      SoundService.instance.play(Sfx.wrong, haptic: Haptic.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chapter = AppScope.of(context).activeChapter;
    final correct = chapter.quizAnswerIndex;
    final gotIt = _picked == correct;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.l),
              AppText('Test Your Knowledge', AppType.pageTitle),
              const SizedBox(height: AppSpace.xs),
              AppText(chapter.quizQuestion, AppType.body,
                  color: c.muted, align: TextAlign.center),
              const SizedBox(height: AppSpace.l),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Image.asset('assets/images/chapter/quiz_bakery.png',
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: AppSpace.xl),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (final (i, option)
                        in chapter.quizOptions.indexed) ...[
                      _QuizOption(
                        label: option,
                        state: !_answered
                            ? _QuizOptionState.idle
                            : i == correct
                                ? _QuizOptionState.correct
                                : i == _picked
                                    ? _QuizOptionState.wrong
                                    : _QuizOptionState.dimmed,
                        onTap: () => _pick(i, correct),
                      ),
                      const SizedBox(height: AppSpace.m),
                    ],
                    AnimatedSize(
                      duration: AppMotion.base,
                      curve: AppMotion.easeOut,
                      child: _answered
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: AppSpace.xs),
                              padding: const EdgeInsets.all(AppSpace.l),
                              decoration: BoxDecoration(
                                color: c.cardAlt,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.card),
                                border: Border.all(
                                    color: gotIt ? c.success : c.border,
                                    width: 2),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Mascot(MascotState.curious,
                                      size: 64, float: false),
                                  const SizedBox(width: AppSpace.m),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                            gotIt
                                                ? 'Correct!'
                                                : 'Good try!',
                                            AppType.itemTitle,
                                            color: gotIt
                                                ? c.success
                                                : c.goldDeep),
                                        const SizedBox(height: 3),
                                        AppText(chapter.quizFact,
                                            AppType.body,
                                            color: c.muted),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s),
              PrimaryButton(
                label: _answered ? 'Continue' : 'Skip for now',
                onTap: () => context.pushReplacement('/chapter/stamp'),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

enum _QuizOptionState { idle, correct, wrong, dimmed }

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _QuizOptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fill, borderColor, textColor) = switch (state) {
      _QuizOptionState.idle => (c.surface, c.border, c.ink),
      _QuizOptionState.correct => (c.success, c.success, Colors.white),
      _QuizOptionState.wrong => (
          c.danger.withValues(alpha: 0.12),
          c.danger,
          c.danger
        ),
      _QuizOptionState.dimmed => (
          c.surface,
          c.border,
          c.muted.withValues(alpha: 0.6)
        ),
    };
    return Pressable(
      onTap: onTap,
      sfx: null,
      child: AnimatedContainer(
        duration: AppMotion.base,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.xl - 2, vertical: AppSpace.m + 1),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            if (state == _QuizOptionState.correct)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 19)
            else if (state == _QuizOptionState.wrong)
              Icon(Icons.cancel_rounded, color: c.danger, size: 19)
            else
              Icon(Icons.circle_outlined,
                  color: c.muted.withValues(alpha: 0.5), size: 19),
            const SizedBox(width: AppSpace.m),
            AppText(label, AppType.rowTitle, color: textColor),
          ],
        ),
      ),
    );
  }
}
