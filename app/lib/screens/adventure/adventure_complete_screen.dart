import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/confetti.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Grand finale: confetti and four stat tiles counting up from zero
/// (reference: 21_adventure_complete.png).
class AdventureCompleteScreen extends StatefulWidget {
  const AdventureCompleteScreen({super.key});

  @override
  State<AdventureCompleteScreen> createState() =>
      _AdventureCompleteScreenState();
}

class _AdventureCompleteScreenState extends State<AdventureCompleteScreen> {
  static const _stats = [
    (4, 'Chapters', 'Completed', Icons.auto_stories_rounded),
    (5, 'Locations', 'Explored', Icons.place_rounded),
    (3, 'Stories', 'Discovered', Icons.menu_book_rounded),
    (1, 'Stamp', 'Earned', Icons.workspace_premium_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.instance.play(Sfx.fanfare, haptic: Haptic.heavy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/complete/adventure_hero.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.35, 0.7],
                  colors: [
                    c.groundTop.withValues(alpha: 0.9),
                    c.groundTop.withValues(alpha: 0.3),
                    c.ground.withValues(alpha: 0.96),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screenGutter),
              child: Column(
                children: [
                  const SizedBox(height: AppSpace.l),
                  FadeRiseIn(
                    child: AppText('Adventure\nComplete!',
                        AppType.screenTitle,
                        align: TextAlign.center),
                  ),
                  const SizedBox(height: AppSpace.s),
                  AppText(
                      'You uncovered all the hidden gems\non ${Fixtures.activeAdventureTitle}!',
                      AppType.body,
                      color: c.muted,
                      align: TextAlign.center),
                  const Spacer(),
                  const Mascot(MascotState.celebrating, size: 180),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(AppSpace.l),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.card + 4),
                      boxShadow: [
                        BoxShadow(
                            color: c.shadow(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpace.m,
                      crossAxisSpacing: AppSpace.m,
                      childAspectRatio: 2.1,
                      children: [
                        for (final (value, label, sub, icon) in _stats)
                          Row(
                            children: [
                              Icon(icon, color: c.goldDeep, size: 26),
                              const SizedBox(width: AppSpace.m),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  CountUp(value, AppType.statNumber),
                                  AppText('$label $sub', AppType.metaSub,
                                      color: c.muted),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  Row(
                    children: [
                      const Mascot(MascotState.idle, size: 56),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpace.l),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(
                                AppRadius.card),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText('Amazing job!', AppType.itemTitle),
                              AppText(
                                  'You explored, solved, and discovered something truly special!',
                                  AppType.chip,
                                  color: c.muted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xl),
                  PrimaryButton(
                    label: 'View My Adventure',
                    onTap: () => context.pushReplacement('/journey/trip'),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: ConfettiBurst(pieces: 56)),
        ],
      ),
    );
  }
}
