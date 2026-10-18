import 'package:flutter/material.dart';

/// Reduced-motion rule from tokens.json: "all loops stop under
/// reduced-motion". Combines the OS setting with the in-app toggle.
class MotionSettings {
  static final ValueNotifier<bool> appReduceMotion = ValueNotifier(false);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true ||
      appReduceMotion.value;
}
