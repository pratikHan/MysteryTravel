import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Chapter intro with the rising clue card (reference: 12_chapter_start.png).
class ChapterStartScreen extends StatelessWidget {
  const ChapterStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chapter = AppScope.of(context).activeChapter;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.4],
            colors: [c.groundTop, c.ground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
            child: Column(
              children: [
                const SizedBox(height: AppSpace.s),
                Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.chevron_left_rounded,
                      semanticLabel: 'Back to path',
                      onTap: () => context.pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AppText('Chapter ${chapter.number}', AppType.meta,
                              color: c.muted),
                          AppText(chapter.lockedTitle, AppType.detailTitle,
                              align: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSize.iconButton),
                  ],
                ),
                const SizedBox(height: AppSpace.s),
                AppText(
                  'Solve the clue to find your next location\nand continue your adventure!',
                  AppType.body,
                  color: c.muted,
                  align: TextAlign.center,
                ),
                const SizedBox(height: AppSpace.l),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card + 2),
                    child: KenBurns(
                      // Bottom-anchored: the placeholder asset has baked
                      // mockup text along its top edge.
                      child: Image.asset(
                        'assets/images/chapter/chapter_hero.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                FadeRiseIn(
                  delay: AppMotion.base,
                  offset: 32,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpace.xl),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card + 4),
                      boxShadow: [
                        BoxShadow(
                            color: c.shadow(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded,
                                color: c.gold, size: 22),
                            const SizedBox(width: AppSpace.s),
                            AppText('Your Clue', AppType.sectionHeader),
                          ],
                        ),
                        const SizedBox(height: AppSpace.m),
                        AppText(chapter.clue, AppType.body,
                            align: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                PrimaryButton(
                  label: 'Let\'s Solve It!',
                  onTap: () => context.push('/chapter/clue'),
                ),
                const SizedBox(height: AppSpace.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
