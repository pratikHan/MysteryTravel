import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Explore grid with chip filters (source: explore.dc.html).
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final visible = Fixtures.quests
        .where((q) => _filter == 'all' || q.categories.contains(_filter))
        .toList();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.l, AppSpace.screenGutter, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SpeechBubble(
                      'What kind of adventure are you in the mood for?'),
                  const Spacer(),
                  CircleIconButton(
                    icon: Icons.settings_outlined,
                    semanticLabel: 'Settings',
                    onTap: () => context.go('/profile/settings'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.m, AppSpace.screenGutter, 0),
              child: Floaty(
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card + 2),
                    boxShadow: [
                      BoxShadow(
                          color: c.shadow(0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card + 2),
                    child: Image.asset('assets/images/heroes/hero_explore.png',
                        fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.xl - 2, AppSpace.screenGutter, 0),
              child: AppText('Explore Adventures', AppType.screenTitle),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.screenGutter, AppSpace.xs, AppSpace.screenGutter, 0),
              child: AppText(
                  'Different themes, unique experiences, and unforgettable discoveries.',
                  AppType.body,
                  color: c.muted),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.screenGutter, AppSpace.l, AppSpace.screenGutter, 0),
              child: Wrap(
                spacing: AppSpace.s,
                runSpacing: AppSpace.s,
                children: [
                  for (final (id, label) in Fixtures.exploreChips)
                    FilterChipPill(
                      label: label,
                      selected: _filter == id,
                      onTap: () => setState(() => _filter = id),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.xl - 2, AppSpace.screenGutter, 0),
              child: AnimatedSwitcher(
                duration: AppMotion.base,
                child: GridView.count(
                  key: ValueKey(_filter),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpace.m,
                  crossAxisSpacing: AppSpace.m,
                  childAspectRatio: 171 / 155,
                  children: [
                    for (final quest in visible)
                      _QuestCard(
                        quest: quest,
                        onTap: () {
                          if (quest.available) {
                            context.go('/explore/quest/${quest.id}');
                          } else {
                            SoundService.instance
                                .play(Sfx.wrong, haptic: Haptic.light);
                            showAppToast(context,
                                '${quest.title} is coming soon!');
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest, required this.onTap});

  final Quest quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
                color: c.shadow(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Hero(
            tag: 'quest-${quest.id}',
            child: Image.asset(quest.cardImage, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
