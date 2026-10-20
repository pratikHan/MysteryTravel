import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'buttons.dart';

/// The ☰ that opens the Side Menu (`/menu`). Shared by every tab screen
/// so the menu is reachable from anywhere in the shell; ☰ always means
/// this menu (screen-local option sheets use ⋯ instead).
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) => CircleIconButton(
        icon: Icons.menu_rounded,
        onDark: onDark,
        semanticLabel: 'Open menu',
        onTap: () => context.push('/menu'),
      );
}
