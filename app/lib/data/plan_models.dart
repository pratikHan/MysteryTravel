import 'package:flutter/material.dart';

import 'models.dart';

/// Models for the Mystery AI planning flow (branch: mystery-ai).
/// Everything is dummy-data-driven for now; the "recommendation engine"
/// is a pure function over fixtures.

enum ExplorationMode { planned, mystery }

/// One of the 12 selectable interest categories on Plan Setup.
class AdventureCategory {
  const AdventureCategory({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;
}

/// A selectable mood on the Mood Builder screen.
class Mood {
  const Mood({required this.id, required this.label, required this.emoji});

  final String id;
  final String label;
  final String emoji;
}

/// Everything the user enters on the Plan Setup (Mood Builder) screen.
/// Mutable working state, owned by AppState.
class PlanRequest {
  String city = '';
  DateTime? date;
  TimeOfDay? startTime;
  String? moodId;
  final Set<String> categoryIds = {};
  String wishText = '';
  ExplorationMode mode = ExplorationMode.planned;

  static const maxCategories = 5;

  bool get isComplete =>
      city.trim().isNotEmpty &&
      date != null &&
      startTime != null &&
      categoryIds.isNotEmpty;

  void reset() {
    city = '';
    date = null;
    startTime = null;
    moodId = null;
    categoryIds.clear();
    wishText = '';
    mode = ExplorationMode.planned;
  }
}

/// One stop inside an adventure playlist. Wraps the rich [Place] so the
/// trail and Place Detail screens keep working unchanged; carries the
/// masked presentation for Mystery mode.
class PlaylistItem {
  const PlaylistItem({
    required this.place,
    required this.mysteryTitle,
    required this.distanceMiles,
    required this.suggestedTime,
  });

  final Place place;

  /// Spoiler-safe teaser, e.g. "A nature park nearby".
  final String mysteryTitle;

  /// Shown in Mystery mode instead of the address/photo.
  final double distanceMiles;
  final String suggestedTime;

  /// What to display for a given mode.
  String titleFor(ExplorationMode mode) =>
      mode == ExplorationMode.mystery ? mysteryTitle : place.name;
}

/// A curated adventure suggestion from the (dummy) recommendation
/// engine; becomes editable once the user picks it.
class AdventurePlaylist {
  const AdventurePlaylist({
    required this.id,
    required this.title,
    required this.tagline,
    required this.heroImage,
    required this.categoryIds,
    required this.duration,
    required this.items,
  });

  final String id;
  final String title;
  final String tagline;
  final String heroImage;
  final List<String> categoryIds;
  final String duration;
  final List<PlaylistItem> items;

  AdventurePlaylist copyWithItems(List<PlaylistItem> newItems) =>
      AdventurePlaylist(
        id: id,
        title: title,
        tagline: tagline,
        heroImage: heroImage,
        categoryIds: categoryIds,
        duration: duration,
        items: newItems,
      );
}

/// The user's single saved adventure (stage scope: one at a time).
class SavedAdventure {
  const SavedAdventure({
    required this.playlist,
    required this.city,
    required this.openOn,
    required this.startTime,
    required this.mode,
  });

  final AdventurePlaylist playlist;
  final String city;
  final DateTime openOn;
  final TimeOfDay startTime;
  final ExplorationMode mode;

  /// Demo rule (user decision): show the countdown, but starting is
  /// always allowed regardless of today's date.
  bool get opensToday {
    final now = DateTime.now();
    return openOn.year == now.year &&
        openOn.month == now.month &&
        openOn.day == now.day;
  }
}
