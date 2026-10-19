import 'package:flutter/material.dart';

import '../data/fixtures.dart';
import '../data/models.dart';
import '../data/plan_fixtures.dart';
import '../data/plan_models.dart';
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

  // -------------------------------------------------------------
  // Mystery AI planning flow
  // -------------------------------------------------------------

  /// What the user is entering across Path Choice + Plan Setup.
  final PlanRequest plan = PlanRequest();

  /// Editable copy of the playlist picked on Curated Adventures.
  AdventurePlaylist? workingPlaylist;

  /// Saved adventures, most recent first (seeded with upcoming
  /// dummies; new saves land on top and drive the Home hero card).
  final List<SavedAdventure> savedAdventures = [
    ...PlanFixtures.seedAdventures,
  ];

  SavedAdventure? get savedAdventure =>
      savedAdventures.isEmpty ? null : savedAdventures.first;

  void setExplorationMode(ExplorationMode mode) {
    plan.mode = mode;
    notifyListeners();
  }

  void setMood(String? id) {
    plan.moodId = (plan.moodId == id) ? null : id;
    notifyListeners();
  }

  void updatePlan({
    String? city,
    DateTime? date,
    TimeOfDay? startTime,
    String? wishText,
  }) {
    if (city != null) plan.city = city;
    if (date != null) plan.date = date;
    if (startTime != null) plan.startTime = startTime;
    if (wishText != null) plan.wishText = wishText;
    notifyListeners();
  }

  /// Returns false when the 5-category cap blocks the toggle.
  bool togglePlanCategory(String id) {
    if (plan.categoryIds.contains(id)) {
      plan.categoryIds.remove(id);
    } else {
      if (plan.categoryIds.length >= PlanRequest.maxCategories) return false;
      plan.categoryIds.add(id);
    }
    notifyListeners();
    return true;
  }

  void pickPlaylist(AdventurePlaylist playlist) {
    workingPlaylist = playlist.copyWithItems([...playlist.items]);
    notifyListeners();
  }

  /// [to] arrives already adjusted for the removed item
  /// (ReorderableListView.onReorderItem semantics).
  void reorderPlaylistItem(int from, int to) {
    final p = workingPlaylist;
    if (p == null) return;
    final items = [...p.items];
    final item = items.removeAt(from);
    items.insert(to.clamp(0, items.length), item);
    workingPlaylist = p.copyWithItems(items);
    notifyListeners();
  }

  /// Returns false when removal would empty the playlist (min 1 stop).
  bool removePlaylistItem(int index) {
    final p = workingPlaylist;
    if (p == null || p.items.length <= 1) return false;
    workingPlaylist =
        p.copyWithItems([...p.items]..removeAt(index));
    notifyListeners();
    return true;
  }

  void saveAdventure() {
    final p = workingPlaylist;
    if (p == null) return;
    savedAdventures.insert(
      0,
      SavedAdventure(
        playlist: p,
        city: plan.city,
        openOn: plan.date ?? DateTime.now(),
        startTime: plan.startTime ?? const TimeOfDay(hour: 10, minute: 0),
        mode: plan.mode,
      ),
    );
    notifyListeners();
  }

  /// Demo rule: starting is always allowed; the date is informational.
  void startSavedAdventure() {
    resetAdventure();
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
