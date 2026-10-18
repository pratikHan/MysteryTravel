import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';

/// The 5-tab scaffold. The tab bar hides itself on nested detail routes
/// (quest detail, settings, achievements) so they read as full screens.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (icon: Icons.home_rounded, outline: Icons.home_outlined, label: 'Home'),
    (icon: Icons.search_rounded, outline: Icons.search_rounded, label: 'Explore'),
    (icon: Icons.explore_rounded, outline: Icons.explore_outlined, label: 'Adventure'),
    (icon: Icons.menu_book_rounded, outline: Icons.menu_book_outlined, label: 'Passport'),
    (icon: Icons.person_rounded, outline: Icons.person_outline_rounded, label: 'Profile'),
  ];

  bool _barHidden(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return location.contains('/quest/') ||
        location.endsWith('/settings') ||
        location.endsWith('/achievements');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hidden = _barHidden(context);
    return Scaffold(
      backgroundColor: c.ground,
      body: shell,
      bottomNavigationBar: hidden
          ? null
          : Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(
                  top: BorderSide(color: c.border, width: 1.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: AppSpace.s, bottom: AppSpace.xs),
                  child: Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(child: _TabButton(shell: shell, index: i)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.shell, required this.index});

  final StatefulNavigationShell shell;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tab = AppShell._tabs[index];
    final active = shell.currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        SoundService.instance.play(Sfx.tap, haptic: Haptic.light);
        shell.goBranch(index, initialLocation: active);
      },
      child: Semantics(
        selected: active,
        button: true,
        label: tab.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.0 : 0.92,
                duration: AppMotion.base,
                curve: AppMotion.overshoot,
                child: Icon(
                  active ? tab.icon : tab.outline,
                  size: 23,
                  color: active ? c.pill : c.muted,
                ),
              ),
              const SizedBox(height: 3),
              AppText(tab.label, AppType.tabLabel,
                  color: active ? c.pill : c.muted),
            ],
          ),
        ),
      ),
    );
  }
}
