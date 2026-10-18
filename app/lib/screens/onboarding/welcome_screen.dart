import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              child: Image.asset(
                'assets/images/onboarding/welcome_mascot.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpace.s),
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Back',
                    onTap: () => context.go('/splash'),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  Center(
                    child: FadeRiseIn(
                      child: AppText(
                        'Welcome\nExplorer!',
                        AppType.screenTitle,
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  Center(
                    child: FadeRiseIn(
                      delay: AppMotion.base,
                      child: AppText(
                        'Let\'s uncover amazing places,\nhidden gems and unforgettable\nstories in real cities.',
                        AppType.body,
                        color: c.muted,
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeRiseIn(
                    delay: AppMotion.entrance,
                    child: PrimaryButton(
                      label: 'Continue',
                      trailingArrow: true,
                      onTap: () => context.go('/interests'),
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
