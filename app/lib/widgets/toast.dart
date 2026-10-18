import 'package:flutter/material.dart';

import '../theme/themes.dart';
import '../theme/tokens.dart';

/// Small themed floating toast for stubbed actions ("Coming soon!").
void showAppToast(BuildContext context, String message) {
  final c = context.colors;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.pill,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.row)),
        margin: const EdgeInsets.fromLTRB(
            AppSpace.screenGutter, 0, AppSpace.screenGutter, AppSpace.xxl),
        duration: const Duration(milliseconds: 1600),
        content: Text(message,
            textAlign: TextAlign.center,
            style: AppType.chip.style(c.onDark).copyWith(fontSize: 13)),
      ),
    );
}
