import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Side Menu (reference: design1001/side_menu1.png + side_menu2.png).
///
/// Finch's layout in our palette: cream ground instead of pale blue,
/// navy promo cards instead of periwinkle, a gold "Mystery Plus" card,
/// white tiles and grouped rows. Opened from the menu button on Home;
/// slides in from the left. Contents are placeholders to refine later.
class SideMenuScreen extends StatefulWidget {
  const SideMenuScreen({super.key});

  @override
  State<SideMenuScreen> createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends State<SideMenuScreen> {
  static const _explorerCode = 'MCA7Q2KMIKU';

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _soon(String what) => showAppToast(context, '$what arrives soon!');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sound = SoundService.instance;
    var i = 0;
    Widget enter(Widget child) => FadeRiseIn(
        delay: Duration(milliseconds: 40 * i++), child: child);

    return Scaffold(
      backgroundColor: c.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
              AppSpace.s, AppSpace.screenGutter, AppSpace.xxl * 2),
          physics: const BouncingScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                onTap: _close,
                child: SizedBox(
                  width: AppSize.touchMin,
                  height: AppSize.touchMin,
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 26, color: c.ink),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.l),

            // ---- Explorer card ----
            enter(_Card(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.xxl, AppSpace.xl, AppSpace.l, AppSpace.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: 'Explorer',
                              style: AppType.pageTitle.style(c.ink)),
                          TextSpan(
                              text: ' & ',
                              style: AppType.pageTitle.style(c.muted)),
                          TextSpan(
                              text: 'Miku',
                              style: AppType.pageTitle.style(c.ink)),
                        ])),
                        const SizedBox(height: AppSpace.xs),
                        Pressable(
                          onTap: () {
                            Clipboard.setData(
                                const ClipboardData(text: _explorerCode));
                            showAppToast(context, 'Explorer code copied');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: AppText(_explorerCode, AppType.body,
                                    color: c.muted, maxLines: 1),
                              ),
                              const SizedBox(width: AppSpace.xs),
                              Icon(Icons.copy_rounded,
                                  size: 16, color: c.muted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Mascot(MascotState.curious, size: 64),
                ],
              ),
            )),
            const SizedBox(height: AppSpace.xxl),

            // ---- Promo cards (navy) ----
            enter(_PromoCard(
              leading: const Mascot(MascotState.celebrating,
                  size: AppSize.menuIcon + 14, float: false),
              title: 'Add the widget',
              body: 'Keep Miku and today\'s quest on your home screen!',
              action: 'Add',
              onTap: () => _soon('The home screen widget'),
            )),
            const SizedBox(height: AppSpace.m),
            enter(_PromoCard(
              leading: const _Emoji('🔔', size: AppSize.menuIcon + 6),
              title: 'Enable notifications',
              body: 'Get a nudge when a mystery stop is ready.',
              action: 'Enable',
              onTap: () => _soon('Notifications'),
            )),
            const SizedBox(height: AppSpace.xxl),

            // ---- Tile grid ----
            enter(_TileGrid(tiles: [
              _Tile('🧭', 'Adventures', () => context.go('/adventure')),
              _Tile('🗺️', 'Explore Quests', () => context.go('/explore')),
              _Tile('🛂', 'My Passport', () => context.go('/passport')),
              _Tile('🏅', 'Stamps & Rewards',
                  () => context.go('/profile/achievements')),
              _Tile('✨', 'Plan My Day', () => context.go('/plan')),
              _Tile('📅', 'History', () => _soon('Adventure history')),
            ])),
            const SizedBox(height: AppSpace.xxl),

            // ---- Mystery Plus (gold) ----
            enter(_PlusCard(onTap: () => _soon('Mystery Plus'))),
            const SizedBox(height: AppSpace.xxl + AppSpace.s),

            // ---- Grouped lists (side_menu2.png) ----
            const _GroupLabel('Community'),
            _Group(children: [
              _Row(
                  emoji: '💌',
                  label: 'Invite friends',
                  onTap: () => _soon('Invites')),
              _Row(
                  emoji: '🤝',
                  label: 'Explore together',
                  onTap: () => _soon('Group adventures')),
            ]),
            const _GroupLabel('Account'),
            _Group(children: [
              _Row(
                  emoji: '🔔',
                  label: 'Notifications',
                  onTap: () => _soon('Notifications')),
              _Row(
                  emoji: '🙂',
                  label: 'Profile',
                  onTap: () => context.go('/profile')),
              _Row(
                  emoji: '🎨',
                  label: 'App theme',
                  badge: 'PLUS',
                  onTap: () => context.go('/profile/settings')),
              _Row(
                  emoji: '📐',
                  label: 'Preferences',
                  onTap: () => context.go('/profile/settings')),
              _ToggleRow(
                emoji: '🔊',
                label: 'Sound effects',
                value: sound.soundEnabled,
                onChanged: (v) => setState(() => sound.soundEnabled = v),
              ),
              _ToggleRow(
                emoji: '🌾',
                label: 'Calm mode',
                subtitle: 'Fewer animations, same adventure.',
                value: MotionSettings.appReduceMotion.value,
                onChanged: (v) =>
                    setState(() => MotionSettings.appReduceMotion.value = v),
              ),
            ]),
            const _GroupLabel('Subscription'),
            _Group(children: [
              _Row(
                  emoji: '🌟',
                  label: 'Mystery Plus',
                  trailingText: 'None',
                  onTap: () => _soon('Mystery Plus')),
              _Row(
                  label: 'Restore Mystery Plus purchase',
                  onTap: () => _soon('Purchases')),
            ]),
            const _GroupLabel('Support'),
            _Group(children: [
              _Row(
                  emoji: '⚙️',
                  label: 'Settings',
                  onTap: () => context.go('/profile/settings')),
              _Row(
                  emoji: '❓',
                  label: 'Help center',
                  onTap: () => _soon('The help center')),
              _Row(
                  emoji: 'ℹ️',
                  label: 'About',
                  onTap: () => showAppToast(
                      context, 'Mystery City Adventures — preview build')),
            ]),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------

/// White rounded card with the soft drop shadow used across the menu.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        border: Border.all(color: c.border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: c.shadow(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _Emoji extends StatelessWidget {
  const _Emoji(this.emoji, {this.size = AppSize.menuIcon});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: FittedBox(child: Text(emoji)),
      );
}

/// Chunky pill button with a darker bottom lip (Finch "Add" button).
class _LipButton extends StatelessWidget {
  const _LipButton({
    required this.label,
    required this.onTap,
    required this.fill,
    required this.lip,
    required this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color fill;
  final Color lip;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return BouncyPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.xl, vertical: AppSpace.m),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadius.row),
          boxShadow: [BoxShadow(color: lip, offset: const Offset(0, 4))],
        ),
        child: AppText(label, AppType.cta, color: textColor),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.leading,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.l + 2),
      decoration: BoxDecoration(
        color: c.pill,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        boxShadow: [
          BoxShadow(
              color: c.shadow(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, AppType.promoTitle, color: c.onDark),
                const SizedBox(height: 2),
                AppText(body, AppType.body,
                    color: c.onDark.withValues(alpha: 0.78)),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.m),
          _LipButton(
            label: action,
            onTap: onTap,
            fill: c.onDark,
            lip: c.gold,
            textColor: c.ink,
          ),
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile(this.emoji, this.label, this.onTap);

  final String emoji;
  final String label;
  final VoidCallback onTap;
}

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.tiles});

  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < tiles.length; r += 2) ...[
          if (r > 0) const SizedBox(height: AppSpace.m),
          Row(
            children: [
              Expanded(child: _TileCard(tile: tiles[r])),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: r + 1 < tiles.length
                    ? _TileCard(tile: tiles[r + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TileCard extends StatelessWidget {
  const _TileCard({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    return BouncyPressable(
      onTap: tile.onTap,
      child: _Card(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
        child: SizedBox(
          height: AppSize.menuTile,
          child: Row(
            children: [
              _Emoji(tile.emoji),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: AppText(tile.label, AppType.rowTitle, maxLines: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlusCard extends StatelessWidget {
  const _PlusCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.xxl, AppSpace.xl, AppSpace.l, AppSpace.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.gold, c.goldDeep],
        ),
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        boxShadow: [
          BoxShadow(
              color: c.goldDeep.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText('Mystery', AppType.screenTitle,
                          color: c.pill, maxLines: 1),
                    ),
                    const SizedBox(width: AppSpace.s),
                    _Badge('PLUS', fill: c.pill, text: c.onDark),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                AppText('Secret routes and bonus stamps from Miku',
                    AppType.body,
                    color: c.pill.withValues(alpha: 0.82)),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.m),
          _LipButton(
            label: 'Try free',
            onTap: onTap,
            fill: c.surface,
            lip: c.pill.withValues(alpha: 0.25),
            textColor: c.pill,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {required this.fill, required this.text});

  final String label;
  final Color fill;
  final Color text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s + 2, vertical: 3),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadius.small - 4),
        ),
        child: AppText(label, AppType.overline, color: text),
      );
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.l + 2, AppSpace.xl, 0, AppSpace.s + 2),
        child: AppText(label.toUpperCase(), AppType.overline,
            color: context.colors.muted),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Card(
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            child,
            if (i != children.length - 1)
              Divider(height: 1.5, thickness: 1.5, color: c.border),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    this.emoji,
    required this.label,
    required this.onTap,
    this.badge,
    this.trailingText,
  });

  final String? emoji;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.xl, vertical: AppSpace.l + 2),
        child: Row(
          children: [
            if (emoji != null) ...[
              _Emoji(emoji!, size: AppSize.menuIcon - 6),
              const SizedBox(width: AppSpace.l),
            ],
            // One Expanded holds label + badge so the trailing chevron
            // always pins to the same right edge.
            Expanded(
              child: Row(
                children: [
                  Flexible(child: AppText(label, AppType.rowTitle)),
                  if (badge != null) ...[
                    const SizedBox(width: AppSpace.s),
                    _Badge(badge!, fill: c.gold, text: c.pill),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s),
            if (trailingText != null)
              AppText(trailingText!, AppType.body, color: c.muted)
            else
              Icon(Icons.chevron_right_rounded, size: 22, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String emoji;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.xl, AppSpace.m, AppSpace.l, AppSpace.m),
      child: Row(
        children: [
          _Emoji(emoji, size: AppSize.menuIcon - 6),
          const SizedBox(width: AppSpace.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, AppType.rowTitle),
                if (subtitle != null)
                  AppText(subtitle!, AppType.metaSub, color: c.muted),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: c.pill,
            onChanged: (v) {
              SoundService.instance.play(Sfx.pop, haptic: Haptic.light);
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
