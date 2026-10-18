import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Chapter list with done / current / locked states; locked rows shake
/// (reference: 16_next_chapters.png).
class NextChaptersScreen extends StatelessWidget {
  const NextChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.l, AppSpace.screenGutter, 0),
              child: ScreenHeader(
                title: 'Your Journey Continues',
                subtitle: 'More exciting places are waiting!',
                onBack: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.screenGutter),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (final (i, chapter) in Fixtures.chapters.indexed)
                    FadeRiseIn(
                      delay: Duration(milliseconds: 70 * i),
                      child: _ChapterRow(
                        chapter: chapter,
                        status: state.chapterStatus(i),
                        isLastRow: i == Fixtures.chapters.length - 1,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterRow extends StatefulWidget {
  const _ChapterRow({
    required this.chapter,
    required this.status,
    required this.isLastRow,
  });

  final Chapter chapter;
  final ChapterStatus status;
  final bool isLastRow;

  @override
  State<_ChapterRow> createState() => _ChapterRowState();
}

class _ChapterRowState extends State<_ChapterRow> {
  final _shakerKey = GlobalKey<ShakerState>();

  void _onTap() {
    switch (widget.status) {
      case ChapterStatus.done:
        SoundService.instance.play(Sfx.tap, haptic: Haptic.light);
        showAppToast(context, '${widget.chapter.venueName} — completed!');
      case ChapterStatus.current:
        SoundService.instance.play(Sfx.pop, haptic: Haptic.medium);
        context.push('/stop/${widget.chapter.number - 1}');
      case ChapterStatus.locked:
        SoundService.instance.play(Sfx.wrong, haptic: Haptic.warning);
        _shakerKey.currentState?.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chapter = widget.chapter;
    final status = widget.status;
    final locked = status == ChapterStatus.locked;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              switch (status) {
                ChapterStatus.done => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: c.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 22),
                  ),
                ChapterStatus.current => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: c.gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surface, width: 3)),
                    child: Center(
                        child: AppText('${chapter.number}',
                            AppType.sectionHeader,
                            color: Colors.white)),
                  ),
                ChapterStatus.locked => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: c.lockedFill, shape: BoxShape.circle),
                    child:
                        Icon(Icons.lock_rounded, color: c.muted, size: 18),
                  ),
              },
              if (!widget.isLastRow)
                Container(
                  width: 3,
                  height: 34,
                  margin: const EdgeInsets.only(top: AppSpace.xs),
                  decoration: BoxDecoration(
                    color: status == ChapterStatus.done
                        ? c.gold.withValues(alpha: 0.6)
                        : c.lockedFill,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Shaker(
              key: _shakerKey,
              child: Pressable(
                onTap: _onTap,
                sfx: null,
                haptic: null,
                child: Container(
                  padding: const EdgeInsets.all(AppSpace.m),
                  decoration: BoxDecoration(
                    color: locked
                        ? c.cardAlt.withValues(alpha: 0.7)
                        : c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.row),
                    border: Border.all(
                        color: status == ChapterStatus.current
                            ? c.gold
                            : c.border,
                        width: 2),
                    boxShadow: locked
                        ? null
                        : [
                            BoxShadow(
                                color: c.shadow(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3)),
                          ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.small),
                        child: locked
                            ? Container(
                                width: 48,
                                height: 48,
                                color: c.lockedFill,
                                child: Icon(Icons.cloud_rounded,
                                    color: c.muted.withValues(alpha: 0.6),
                                    size: 24),
                              )
                            : Image.asset(chapter.image,
                                width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText('Chapter ${chapter.number}',
                                AppType.caption,
                                color: c.muted),
                            AppText(
                              locked
                                  ? chapter.lockedTitle
                                  : chapter.venueName,
                              AppType.itemTitle,
                              color: locked ? c.muted : c.ink,
                            ),
                            if (locked)
                              AppText(
                                  'Complete chapter ${chapter.number - 1} to unlock',
                                  AppType.metaSub,
                                  color:
                                      c.muted.withValues(alpha: 0.7)),
                          ],
                        ),
                      ),
                      if (status == ChapterStatus.current)
                        Icon(Icons.arrow_forward_rounded,
                            color: c.goldDeep, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
