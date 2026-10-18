import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// Spoiler-safe preview: slowly drifting illustrated journey map.
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
          child: Column(
            children: [
              const SizedBox(height: AppSpace.s),
              ScreenHeader(
                title: 'Adventure Preview',
                subtitle: 'Here\'s a sneak peek\nof your journey!',
                onBack: () => context.go('/customize'),
              ),
              const SizedBox(height: AppSpace.xl - 2),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card + 2),
                    boxShadow: [
                      BoxShadow(
                          color: c.shadow(0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card + 2),
                    // The interim map asset carries baked stop cards; the
                    // production target (widget stop cards popping in over
                    // a clean map) returns when that asset lands.
                    child: KenBurns(
                      child: Image.asset(
                        'assets/images/preview/map_full.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
              PrimaryButton(
                label: 'Start Adventure',
                sfx: Sfx.success,
                onTap: () {
                  AppScope.read(context).resetAdventure();
                  context.go('/adventure');
                },
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

