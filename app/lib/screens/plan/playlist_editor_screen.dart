import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/plan_models.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Playlist Editor — reorder / remove stops (min 1), then save.
/// SKELETON: functional ReorderableListView; full design in Slice 4.
class PlaylistEditorScreen extends StatelessWidget {
  const PlaylistEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final playlist = state.workingPlaylist;
    final mystery = state.plan.mode == ExplorationMode.mystery;
    if (playlist == null) {
      // Deep-linked here without picking — send back to the suggestions.
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.go('/curated'));
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                  AppSpace.l, AppSpace.screenGutter, 0),
              child: ScreenHeader(
                title: playlist.title,
                subtitle: 'Drag to reorder · swipe nothing — use ✕ to remove',
                onBack: () => context.go('/curated'),
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(AppSpace.screenGutter),
                itemCount: playlist.items.length,
                // newIndex arrives pre-adjusted for the removed item.
                onReorderItem: state.reorderPlaylistItem,
                proxyDecorator: (child, index, animation) =>
                    Material(color: Colors.transparent, child: child),
                itemBuilder: (context, i) {
                  final item = playlist.items[i];
                  return Padding(
                    key: ValueKey('${item.place.id}-$i'),
                    padding: const EdgeInsets.only(bottom: AppSpace.m),
                    child: _ItemRow(
                      index: i,
                      item: item,
                      mystery: mystery,
                      onRemove: () {
                        final ok = state.removePlaylistItem(i);
                        if (!ok) {
                          SoundService.instance
                              .play(Sfx.wrong, haptic: Haptic.warning);
                          showAppToast(context,
                              'Every adventure needs at least one stop!');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.screenGutter),
              child: PrimaryButton(
                label: 'Save Adventure',
                sfx: Sfx.success,
                onTap: () {
                  state.saveAdventure();
                  showAppToast(context,
                      'Adventure saved! It opens on your adventure day.');
                  context.go('/home');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.index,
    required this.item,
    required this.mystery,
    required this.onRemove,
  });

  final int index;
  final PlaylistItem item;
  final bool mystery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpace.m),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.row),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator_rounded, color: c.muted, size: 20),
          const SizedBox(width: AppSpace.s),
          Container(
            width: 26,
            height: 26,
            decoration:
                BoxDecoration(color: c.pill, shape: BoxShape.circle),
            child: Center(
                child: AppText('${index + 1}', AppType.meta,
                    color: c.onDark)),
          ),
          const SizedBox(width: AppSpace.m),
          if (mystery)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.lockedFill,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(Icons.help_outline_rounded,
                  color: c.muted, size: 20),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(item.place.image,
                  width: 44, height: 44, fit: BoxFit.cover),
            ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  mystery ? item.mysteryTitle : item.place.name,
                  AppType.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppText(
                  mystery
                      ? '~${item.distanceMiles} mi away · ${item.suggestedTime}'
                      : '${item.place.category} · ${item.suggestedTime}',
                  AppType.metaSub,
                  color: c.muted,
                ),
              ],
            ),
          ),
          Pressable(
            onTap: onRemove,
            sfx: Sfx.tap,
            child: Icon(Icons.close_rounded, color: c.muted, size: 20),
          ),
        ],
      ),
    );
  }
}
