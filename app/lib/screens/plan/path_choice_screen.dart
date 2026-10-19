import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/plan_models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Path Choice — pick Planned vs Mystery exploration.
/// SKELETON: structure + navigation only; full design lands in Slice 1.
class PathChoiceScreen extends StatelessWidget {
  const PathChoiceScreen({super.key});

  void _pick(BuildContext context, ExplorationMode mode) {
    AppScope.read(context).setExplorationMode(mode);
    context.go('/plan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpace.xl),
              Row(
                children: [
                  const Mascot(MascotState.idle, size: 92),
                  const SizedBox(width: AppSpace.m),
                  const Expanded(
                    child: SpeechBubble(
                        'Welcome, explorer!\nHow do you want to discover your city?'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              AppText('Choose Your Path', AppType.screenTitle,
                  align: TextAlign.center),
              const SizedBox(height: AppSpace.xxl),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _PathCard(
                        emoji: '🗺️',
                        title: 'Planned Exploration',
                        subtitle:
                            'See every stop upfront. Curate, reorder and plan your perfect day.',
                        onTap: () =>
                            _pick(context, ExplorationMode.planned),
                      ),
                    ),
                    const SizedBox(height: AppSpace.l),
                    Expanded(
                      child: _PathCard(
                        emoji: '🔮',
                        title: 'Mystery Exploration',
                        subtitle:
                            'Places stay hidden — you get teasers and distances until you arrive.',
                        onTap: () =>
                            _pick(context, ExplorationMode.mystery),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.pop,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.xl),
        decoration: BoxDecoration(
          color: c.cardAlt,
          borderRadius: BorderRadius.circular(AppRadius.card + 2),
          border: Border.all(color: c.border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: AppSpace.m),
            AppText(title, AppType.sectionHeader),
            const SizedBox(height: AppSpace.s),
            AppText(subtitle, AppType.body,
                color: c.muted, align: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
