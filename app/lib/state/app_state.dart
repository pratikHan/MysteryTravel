import 'package:flutter/material.dart';

import '../data/fixtures.dart';
import '../data/models.dart';
import '../theme/themes.dart';
import '../theme/tokens.dart';

/// Single source of truth for everything the stage-1 shell remembers.
/// Deliberately a plain [ChangeNotifier] — no state package needed yet.
class AppState extends ChangeNotifier {
  AppTokens theme = AppThemes.voyage;

  // Onboarding selections.
  final Set<String> interests = {};
  String? cityId;
  String mysteryModeId = 'balanced';
  String adventureModeId = 'classic';
  String travelStyleId = 'solo';

  // Favorites (quest ids).
  final Set<String> favorites = {};

  // Active adventure progress: index of the current stop; stops before
  // it are done, after it upcoming.
  int currentChapter = 0;
  bool adventureComplete = false;

  City? get city =>
      cityId == null ? null : Fixtures.cities.firstWhere((c) => c.id == cityId);

  ChapterStatus chapterStatus(int index) {
    if (adventureComplete || index < currentChapter) return ChapterStatus.done;
    if (index == currentChapter) return ChapterStatus.current;
    return ChapterStatus.locked;
  }

  Chapter get activeChapter => Fixtures.chapters[
      currentChapter.clamp(0, Fixtures.chapters.length - 1)];

  int get doneCount =>
      adventureComplete ? Fixtures.chapters.length : currentChapter;

  void setTheme(AppTokens t) {
    theme = t;
    notifyListeners();
  }

  void toggleInterest(String id) {
    interests.contains(id) ? interests.remove(id) : interests.add(id);
    notifyListeners();
  }

  void pickCity(String? id) {
    cityId = (cityId == id) ? null : id;
    notifyListeners();
  }

  void setMysteryMode(String id) {
    mysteryModeId = id;
    notifyListeners();
  }

  void setAdventureMode(String id) {
    adventureModeId = id;
    notifyListeners();
  }

  void setTravelStyle(String id) {
    travelStyleId = id;
    notifyListeners();
  }

  void toggleFavorite(String questId) {
    favorites.contains(questId)
        ? favorites.remove(questId)
        : favorites.add(questId);
    notifyListeners();
  }

  /// Advance past the current chapter after its flow completes.
  void completeCurrentChapter() {
    if (currentChapter >= Fixtures.chapters.length - 1) {
      adventureComplete = true;
    } else {
      currentChapter += 1;
    }
    notifyListeners();
  }

  void resetAdventure() {
    currentChapter = 0;
    adventureComplete = false;
    notifyListeners();
  }
}

/// Inherited access: `AppScope.of(context)` rebuilds on change,
/// `AppScope.read(context)` does not.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
