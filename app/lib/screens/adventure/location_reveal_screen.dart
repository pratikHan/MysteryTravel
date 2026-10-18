import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/confetti.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Confetti + haptic on entry, venue card slides up
/// (reference: 14_location_reveal.png).
class LocationRevealScreen extends StatefulWidget {
  const LocationRevealScreen({super.key});

  @override
  State<LocationRevealScreen> createState() => _LocationRevealScreenState();
}

class _LocationRevealScreenState extends State<LocationRevealScreen> {
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
    final chapter = AppScope.of(context).activeChapter;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screenGutter),
              child: Column(
                children: [
                  const SizedBox(height: AppSpace.l),
                  FadeRiseIn(
                    child: AppText('You Found It!', AppType.screenTitle,
                        align: TextAlign.center),
                  ),
                  const SizedBox(height: AppSpace.s),
                  const Mascot(MascotState.celebrating, size: 190),
                  const SizedBox(height: AppSpace.l),
                  Expanded(
                    child: FadeRiseIn(
                      delay: AppMotion.base,
                      offset: 40,
                      child: Container(
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
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.thumb),
                                    child: Image.asset(chapter.image,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: AppSpace.l),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(chapter.venueName,
                                            AppType.sectionHeader),
                                        const SizedBox(height: AppSpace.s),
                                        for (final (icon, label)
                                            in chapter.venueTags) ...[
                                          _VenueTag(
                                              icon: icon, label: label),
                                          const SizedBox(
                                              height: AppSpace.xs + 2),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpace.l),
                              Center(
                                child: AppText(
                                  chapter.venueStory,
                                  AppType.body,
                                  color: c.muted,
                                  align: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  // Quizzes moved to the place-detail page; the legacy
                  // chapter flow goes straight to the stamp.
                  PrimaryButton(
                    label: 'Continue Adventure',
                    onTap: () => context.pushReplacement('/chapter/stamp'),
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

class _VenueTag extends StatelessWidget {
  const _VenueTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.m - 2, vertical: AppSpace.xs),
      decoration: BoxDecoration(
        color: c.cardAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.goldDeep),
          const SizedBox(width: AppSpace.xs + 1),
          AppText(label, AppType.caption),
        ],
      ),
    );
  }
}
