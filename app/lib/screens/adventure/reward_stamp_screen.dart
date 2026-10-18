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

/// Stamp slams in with rotation + scale settle and a thud
/// (reference: 18_reward_stamp.png).
class RewardStampScreen extends StatefulWidget {
  const RewardStampScreen({super.key});

  @override
  State<RewardStampScreen> createState() => _RewardStampScreenState();
}

class _RewardStampScreenState extends State<RewardStampScreen> {
  @override
  void initState() {
    super.initState();
    // Thud lands when the stamp pop animation peaks.
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) {
        SoundService.instance.play(Sfx.stamp, haptic: Haptic.heavy);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final chapter = state.activeChapter;
    // In the trail workflow the stamp is the adventure finale.
    final finale = state.adventureComplete;
    final title = finale ? Fixtures.activeAdventureTitle : chapter.venueName;
    final story = finale
        ? 'You explored all ${Fixtures.places.length} stops of ${Fixtures.activeAdventureTitle}.'
        : chapter.venueStory;
    final image = finale ? Fixtures.activeAdventureImage : chapter.image;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.prefsGutter),
              child: Column(
                children: [
                  const SizedBox(height: AppSpace.xl),
                  FadeRiseIn(
                    child: AppText('You Earned a Stamp!',
                        AppType.screenTitle,
                        align: TextAlign.center),
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Polaroid-style venue photo.
                      Container(
                        padding: const EdgeInsets.all(AppSpace.m),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.small),
                          boxShadow: [
                            BoxShadow(
                                color: c.shadow(0.18),
                                blurRadius: 20,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.tail),
                          child: Image.asset(image,
                              width: 230, height: 230, fit: BoxFit.cover),
                        ),
                      ),
                      // The stamp seal slams in over the photo corner.
                      Positioned(
                        right: 0,
                        bottom: -10,
                        child: PopIn(
                          delay: const Duration(milliseconds: 450),
                          peak: 1.35,
                          withRotation: true,
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    c.surface.withValues(alpha: 0.9),
                                border: Border.all(
                                    color: c.danger.withValues(alpha: 0.75),
                                    width: 3.5),
                              ),
                              padding: const EdgeInsets.all(AppSpace.s),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  AppText(
                                      Fixtures.activeAdventureCity
                                          .toUpperCase(),
                                      AppType.caption,
                                      color: c.danger),
                                  Icon(Icons.location_city_rounded,
                                      color: c.danger, size: 34),
                                  AppText('2026', AppType.caption,
                                      color: c.danger),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppText(title, AppType.detailTitle),
                  const SizedBox(height: 2),
                  AppText(Fixtures.activeAdventureCity, AppType.body,
                      color: c.muted),
                  const SizedBox(height: AppSpace.m),
                  AppText('"$story"', AppType.body,
                      color: c.muted, align: TextAlign.center),
                  const SizedBox(height: AppSpace.xl),
                  PrimaryButton(
                    label: 'Continue',
                    onTap: () => context.pushReplacement(
                        finale ? '/journey/complete' : '/chapter/complete'),
                  ),
                  const SizedBox(height: AppSpace.m),
                  Pressable(
                    onTap: () {
                      context.go('/passport');
                    },
                    child: AppText('View My Passport', AppType.itemTitle,
                        color: c.muted),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: ConfettiBurst(pieces: 30)),
        ],
      ),
    );
  }
}
