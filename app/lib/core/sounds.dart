import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Every UI sound in the app. Placeholder WAVs for now; the enum is the
/// contract so final sound design is a drop-in swap.
enum Sfx {
  tap('tap'),
  pop('pop'),
  swoosh('swoosh'),
  success('success'),
  wrong('wrong'),
  stamp('stamp'),
  fanfare('fanfare');

  const Sfx(this.file);
  final String file;
}

enum Haptic { light, medium, heavy, success, warning }

/// Central audio + haptics service. Screens never touch audioplayers
/// directly, so the backend can change without touching UI code.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  // A small pool so rapid taps don't cut each other off.
  final List<AudioPlayer> _pool =
      List.generate(3, (_) => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency));
  int _next = 0;

  Future<void> play(Sfx sfx, {Haptic? haptic}) async {
    if (haptic != null) feel(haptic);
    if (!soundEnabled) return;
    final player = _pool[_next];
    _next = (_next + 1) % _pool.length;
    try {
      await player.stop();
      await player.play(AssetSource('audio/${sfx.file}.wav'));
    } catch (_) {
      // Sounds are decorative; never surface audio errors to the user.
    }
  }

  void feel(Haptic haptic) {
    if (!hapticsEnabled) return;
    switch (haptic) {
      case Haptic.light:
        HapticFeedback.lightImpact();
      case Haptic.medium:
        HapticFeedback.mediumImpact();
      case Haptic.heavy:
        HapticFeedback.heavyImpact();
      case Haptic.success:
        HapticFeedback.mediumImpact();
      case Haptic.warning:
        HapticFeedback.vibrate();
    }
  }
}
