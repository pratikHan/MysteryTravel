import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Live mid-adventure recap with Locations / Photos / Stories tabs;
/// locked rows stay greyed (reference: 19_adventure_summary.png).
class AdventureSummaryScreen extends StatefulWidget {
  const AdventureSummaryScreen({super.key});

  @override
  State<AdventureSummaryScreen> createState() =>
      _AdventureSummaryScreenState();
}

class _AdventureSummaryScreenState extends State<AdventureSummaryScreen> {
  int _tab = 0;

  static const _tabs = ['Locations', 'Photos', 'Stories'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final remaining = Fixtures.chapters.length - state.doneCount;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.l, AppSpace.screenGutter, 0),
              child: ScreenHeader(
                title: 'Your Adventure So Far',
                onBack: () => context.pop(),
              ),
            ),
            const SizedBox(height: AppSpace.l),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screenGutter),
              child: Row(
                children: [
                  for (final (i, label) in _tabs.indexed) ...[
                    Expanded(
                      child: Pressable(
                        onTap: () => setState(() => _tab = i),
                        sfx: Sfx.pop,
                        child: AnimatedContainer(
                          duration: AppMotion.base,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _tab == i ? c.pill : c.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: _tab == i ? c.pill : c.border,
                                width: 1.5),
                          ),
                          child: Center(
                            child: AppText(label, AppType.chip,
                                color: _tab == i ? c.onDark : c.ink),
                          ),
                        ),
                      ),
                    ),
                    if (i != _tabs.length - 1)
                      const SizedBox(width: AppSpace.s),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpace.l),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.base,
                child: switch (_tab) {
                  0 => _LocationsTab(key: const ValueKey(0), state: state),
                  1 => _PhotosTab(key: const ValueKey(1), state: state),
                  _ => _StoriesTab(key: const ValueKey(2), state: state),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.screenGutter),
              child: Container(
                padding: const EdgeInsets.all(AppSpace.l),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    const Mascot(MascotState.idle, size: 72),
                    const SizedBox(width: AppSpace.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Keep exploring!', AppType.rowTitle),
                          const SizedBox(height: 2),
                          AppText(
                            remaining > 0
                                ? '$remaining amazing ${remaining == 1 ? 'stop is' : 'stops are'} still waiting.'
                                : 'You discovered every stop!',
                            AppType.chip,
                            color: c.muted,
                          ),
                        ],
                      ),
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

class _LocationsTab extends StatelessWidget {
  const _LocationsTab({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
      physics: const BouncingScrollPhysics(),
      children: [
        for (final (i, chapter) in Fixtures.chapters.indexed)
          _LocationRow(
            chapter: chapter,
            status: state.chapterStatus(i),
          ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.chapter, required this.status});

  final Chapter chapter;
  final ChapterStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hidden = status == ChapterStatus.locked;
    final numberColor = switch (status) {
      ChapterStatus.done => c.success,
      ChapterStatus.current => c.gold,
      ChapterStatus.locked => c.muted,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.m),
      child: Opacity(
        opacity: hidden ? 0.65 : 1,
        child: Container(
          padding: const EdgeInsets.all(AppSpace.m),
          decoration: BoxDecoration(
            color: hidden ? c.cardAlt : c.surface,
            borderRadius: BorderRadius.circular(AppRadius.row),
            border: Border.all(color: c.border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: numberColor, shape: BoxShape.circle),
                child: Center(
                    child: AppText('${chapter.number}', AppType.meta,
                        color: Colors.white)),
              ),
              const SizedBox(width: AppSpace.m),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: hidden
                    ? Container(
                        width: 44,
                        height: 44,
                        color: c.lockedFill,
                        child: Icon(Icons.cloud_rounded,
                            color: c.muted.withValues(alpha: 0.6),
                            size: 20),
                      )
                    : Image.asset(chapter.image,
                        width: 44, height: 44, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                        hidden ? chapter.lockedTitle : chapter.venueName,
                        AppType.itemTitle,
                        color: hidden ? c.muted : c.ink),
                    AppText(
                        hidden ? 'To be discovered' : chapter.venueStory,
                        AppType.metaSub,
                        color: c.muted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = state.doneCount;
    if (done == 0) {
      return Center(
        child: AppText('Complete a chapter to collect photos!',
            AppType.body,
            color: c.muted),
      );
    }
    return GridView.count(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpace.m,
      crossAxisSpacing: AppSpace.m,
      physics: const BouncingScrollPhysics(),
      children: [
        for (var i = 0; i < done; i++)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.thumb),
            child: Image.asset(Fixtures.moments[i].image,
                fit: BoxFit.cover),
          ),
      ],
    );
  }
}

class _StoriesTab extends StatelessWidget {
  const _StoriesTab({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = state.doneCount;
    if (done == 0) {
      return Center(
        child: AppText('Stories unlock as you explore!', AppType.body,
            color: c.muted),
      );
    }
    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
      physics: const BouncingScrollPhysics(),
      children: [
        for (var i = 0; i < done; i++)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpace.m),
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: c.border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(Fixtures.chapters[i].venueName, AppType.itemTitle),
                const SizedBox(height: AppSpace.xs),
                AppText(Fixtures.chapters[i].quizFact, AppType.body,
                    color: c.muted),
              ],
            ),
          ),
      ],
    );
  }
}
