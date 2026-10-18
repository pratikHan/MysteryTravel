import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Spot-the-detail puzzle: wrong answers shake, right answer reveals the
/// location (reference: 13_solving_clue.png).
class SolvingClueScreen extends StatefulWidget {
  const SolvingClueScreen({super.key});

  @override
  State<SolvingClueScreen> createState() => _SolvingClueScreenState();
}

class _SolvingClueScreenState extends State<SolvingClueScreen> {
  int? _picked;
  final _shakerKey = GlobalKey<ShakerState>();

  void _check() {
    final chapter = AppScope.read(context).activeChapter;
    if (_picked == chapter.correctOption) {
      SoundService.instance.play(Sfx.success, haptic: Haptic.success);
      context.pushReplacement('/chapter/reveal');
    } else {
      SoundService.instance.play(Sfx.wrong, haptic: Haptic.warning);
      _shakerKey.currentState?.shake();
      showAppToast(context, 'Not quite — look closer at the clue!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chapter = AppScope.of(context).activeChapter;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.s),
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.chevron_left_rounded,
                    semanticLabel: 'Back',
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        AppText('Look Around', AppType.pageTitle),
                        const SizedBox(height: 2),
                        AppText(
                            'Can you spot the detail\nthat matches the clue?',
                            AppType.chip,
                            color: c.muted,
                            align: TextAlign.center),
                      ],
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.question_mark_rounded,
                    semanticLabel: 'Hint',
                    onTap: () =>
                        showAppToast(context, 'Hint: ${chapter.clue}'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.l),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card + 2),
                  child: KenBurns(
                    // Bottom-anchored: the placeholder asset has baked
                    // mockup text along its top edge.
                    child: Image.asset(
                      'assets/images/chapter/clue_scene.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.l),
              Shaker(
                key: _shakerKey,
                child: Row(
                  children: [
                    for (final (i, option)
                        in chapter.clueOptions.indexed) ...[
                      Expanded(
                        child: _OptionCard(
                          option: option,
                          selected: _picked == i,
                          onTap: () => setState(() => _picked = i),
                        ),
                      ),
                      if (i != chapter.clueOptions.length - 1)
                        const SizedBox(width: AppSpace.m),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              PrimaryButton(
                label: 'Check Answer',
                enabled: _picked != null,
                sfx: null,
                onTap: _check,
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final dynamic option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.pop,
      child: AnimatedContainer(
        duration: AppMotion.base,
        padding: const EdgeInsets.all(AppSpace.s),
        decoration: BoxDecoration(
          color: selected ? c.surface : c.cardAlt,
          borderRadius: BorderRadius.circular(AppRadius.row),
          border: Border.all(
              color: selected ? c.ink : c.border, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: c.shadow(0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 5)),
                ]
              : null,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(option.image,
                  height: 72, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: AppSpace.s - 2),
            AppText(option.label, AppType.chip),
          ],
        ),
      ),
    );
  }
}
