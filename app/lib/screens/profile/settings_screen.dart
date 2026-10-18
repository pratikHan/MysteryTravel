import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../core/sounds.dart';
import '../../state/app_state.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Settings: grouped rows, working toggles (sound / haptics / reduced
/// motion), live theme switcher, inline destructive logout confirm
/// (source: settings.dc.html).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _askingLogout = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final sound = SoundService.instance;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.prefsGutter, vertical: AppSpace.l),
          physics: const BouncingScrollPhysics(),
          children: [
            ScreenHeader(
              title: 'Settings',
              onBack: () => context.go('/profile'),
            ),
            const SizedBox(height: AppSpace.xl),
            _GroupCard(children: [
              _NavRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () => showAppToast(
                      context, 'Profile editing arrives in stage 2!')),
              _NavRow(
                  icon: Icons.tune_rounded,
                  label: 'Preferences',
                  onTap: () => context.go('/interests')),
              _NavRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => showAppToast(
                      context, 'Notifications arrive in stage 2!')),
              _NavRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () =>
                      showAppToast(context, 'Support arrives in stage 2!')),
              _NavRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  onTap: () => showAppToast(context,
                      'Mystery City Adventures — stage 1 preview')),
            ]),
            const SizedBox(height: AppSpace.l),
            AppText('Experience', AppType.sectionHeader),
            const SizedBox(height: AppSpace.s + 2),
            _GroupCard(children: [
              _ToggleRow(
                icon: Icons.volume_up_rounded,
                label: 'Sound effects',
                value: sound.soundEnabled,
                onChanged: (v) => setState(() => sound.soundEnabled = v),
              ),
              _ToggleRow(
                icon: Icons.vibration_rounded,
                label: 'Haptics',
                value: sound.hapticsEnabled,
                onChanged: (v) => setState(() => sound.hapticsEnabled = v),
              ),
              _ToggleRow(
                icon: Icons.animation_rounded,
                label: 'Reduce motion',
                value: MotionSettings.appReduceMotion.value,
                onChanged: (v) =>
                    setState(() => MotionSettings.appReduceMotion.value = v),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.xl - 2, AppSpace.m, AppSpace.xl - 2, AppSpace.l),
                child: Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 20, color: c.ink),
                    const SizedBox(width: AppSpace.l),
                    Expanded(child: AppText('Theme', AppType.rowTitle)),
                    for (final theme in AppThemes.all) ...[
                      Pressable(
                        onTap: () => state.setTheme(theme),
                        sfx: Sfx.pop,
                        child: AnimatedContainer(
                          duration: AppMotion.base,
                          margin: const EdgeInsets.only(left: AppSpace.s),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.m, vertical: AppSpace.s - 1),
                          decoration: BoxDecoration(
                            color: state.theme.id == theme.id
                                ? theme.colors.pill
                                : c.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: c.border, width: 1.5),
                          ),
                          child: AppText(
                            theme.id == 'voyage' ? 'Navy' : 'Warm',
                            AppType.chip,
                            color: state.theme.id == theme.id
                                ? theme.colors.onDark
                                : c.ink,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
            const SizedBox(height: AppSpace.l),
            _GroupCard(children: [
              AnimatedSwitcher(
                duration: AppMotion.base,
                child: _askingLogout
                    ? Padding(
                        key: const ValueKey('confirm'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.xl - 2,
                            vertical: AppSpace.l),
                        child: Row(
                          children: [
                            Expanded(
                                child: AppText('Log out of your account?',
                                    AppType.itemTitle)),
                            _ConfirmButton(
                              label: 'Log Out',
                              fill: c.danger,
                              textColor: c.onDark,
                              onTap: () {
                                setState(() => _askingLogout = false);
                                showAppToast(context,
                                    'Accounts arrive in a later stage!');
                              },
                            ),
                            const SizedBox(width: AppSpace.s),
                            _ConfirmButton(
                              label: 'Cancel',
                              fill: c.lockedFill,
                              textColor: c.ink,
                              onTap: () =>
                                  setState(() => _askingLogout = false),
                            ),
                          ],
                        ),
                      )
                    : _NavRow(
                        key: const ValueKey('logout'),
                        icon: Icons.logout_rounded,
                        label: 'Log Out',
                        destructive: true,
                        showChevron: false,
                        onTap: () => setState(() => _askingLogout = true),
                      ),
              ),
            ]),
            const SizedBox(height: AppSpace.xl),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.asset('assets/images/profile/settings_footer.png',
                  height: 120,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter),
            ),
            const SizedBox(height: AppSpace.xl),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            child,
            if (i != children.length - 1)
              Divider(
                  height: 1.5,
                  thickness: 1.5,
                  color: c.border,
                  indent: AppSpace.xl - 2,
                  endIndent: AppSpace.xl - 2),
          ],
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = destructive ? c.danger : c.ink;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.xl - 2, vertical: AppSpace.l + 1),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpace.l),
            Expanded(child: AppText(label, AppType.rowTitle, color: color)),
            if (showChevron)
              Icon(Icons.chevron_right_rounded, size: 18, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.xl - 2, vertical: AppSpace.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c.ink),
          const SizedBox(width: AppSpace.l),
          Expanded(child: AppText(label, AppType.rowTitle)),
          Switch.adaptive(
            value: value,
            activeTrackColor: c.success,
            onChanged: (v) {
              SoundService.instance.play(Sfx.tap, haptic: Haptic.light);
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.fill,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color fill;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.l, vertical: AppSpace.s + 2),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AppText(label, AppType.chip, color: textColor),
      ),
    );
  }
}
