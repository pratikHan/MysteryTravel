import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.ground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.groundTop, c.ground],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTopEdge(
              child: KenBurns(
                child: Image.asset(
                  'assets/images/onboarding/splash_mascot.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.prefsGutter),
              child: Column(
                children: [
                  const SizedBox(height: AppSpace.xxl + AppSpace.s),
                  FadeRiseIn(
                    child: AppText(
                      'Mystery City\nAdventures',
                      AppType.screenTitle,
                      align: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  FadeRiseIn(
                    delay: AppMotion.base,
                    child: AppText(
                      'Real Places.\nHidden Stories.\nYour Next Adventure.',
                      AppType.sectionHeader,
                      color: c.muted,
                      align: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  FadeRiseIn(
                    delay: AppMotion.entrance,
                    child: PrimaryButton(
                      label: 'Get Started',
                      trailingArrow: true,
                      onTap: () => context.go('/welcome'),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
