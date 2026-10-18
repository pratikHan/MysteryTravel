import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Which of the four quest accent colors a themed screen uses.
enum QuestTheme { peaceful, night, artistic, stories }

extension QuestThemeColor on QuestTheme {
  Color accent(QuestAccents accents) => switch (this) {
        QuestTheme.peaceful => accents.peaceful,
        QuestTheme.night => accents.night,
        QuestTheme.artistic => accents.artistic,
        QuestTheme.stories => accents.stories,
      };
}

class City {
  const City({required this.id, required this.name, required this.image});

  final String id;
  final String name;
  final String image;
}

class Interest {
  const Interest({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final String icon;
}

class MysteryMode {
  const MysteryMode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.badgeColor,
    required this.badgeIcon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final Color badgeColor;
  final IconData badgeIcon;
}

class ExpectItem {
  const ExpectItem({required this.label, required this.image});

  final String label;
  final String image;
}

class SampleStop {
  const SampleStop({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String image;
}

/// A themed adventure package shown on Explore / Home.
class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.theme,
    required this.cardImage,
    required this.heroImage,
    required this.tags,
    required this.categories,
    required this.duration,
    required this.stopsLabel,
    required this.travelLabel,
    required this.travelSub,
    required this.audienceLabel,
    required this.audienceSub,
    required this.expect,
    required this.stops,
    this.available = true,
  });

  final String id;
  final String title;
  final String tagline;
  final String description;
  final QuestTheme theme;
  final String cardImage;
  final String heroImage;
  final List<String> tags;

  /// Explore filter chips this quest matches.
  final List<String> categories;
  final String duration;
  final String stopsLabel;
  final String travelLabel;
  final String travelSub;
  final String audienceLabel;
  final String audienceSub;
  final List<ExpectItem> expect;
  final List<SampleStop> stops;
  final bool available;
}

enum ChapterStatus { done, current, locked }

/// One stop of the active adventure.
class Chapter {
  const Chapter({
    required this.number,
    required this.title,
    required this.lockedTitle,
    required this.clue,
    required this.venueName,
    required this.venueTags,
    required this.venueStory,
    required this.image,
    required this.clueOptions,
    required this.correctOption,
    required this.quizQuestion,
    required this.quizOptions,
    required this.quizAnswerIndex,
    required this.quizFact,
    required this.stampImage,
  });

  final int number;
  final String title;

  /// Shown while the chapter is still locked (spoiler-safe).
  final String lockedTitle;
  final String clue;
  final String venueName;
  final List<(IconData, String)> venueTags;
  final String venueStory;
  final String image;
  final List<ClueOption> clueOptions;
  final int correctOption;
  final String quizQuestion;
  final List<String> quizOptions;
  final int quizAnswerIndex;
  final String quizFact;
  final String stampImage;
}

class ClueOption {
  const ClueOption({required this.label, required this.image});

  final String label;
  final String image;
}

/// A fully-revealed stop on the new adventure trail, rich enough to
/// drive the fullscreen place-detail page (ratings, reviews, offers,
/// quiz). Replaces the mystery Chapter flow on the trail.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.time,
    required this.image,
    required this.description,
    required this.specialty,
    required this.rating,
    required this.reviewsLabel,
    required this.popularity,
    required this.highlightsTitle,
    required this.highlights,
    required this.reviews,
    required this.funFact,
    this.offer,
    required this.quizQuestion,
    required this.quizOptions,
    required this.quizAnswer,
    required this.quizFact,
  });

  final String id;
  final String name;
  final String category;

  /// Suggested arrival time, e.g. "10:00 AM".
  final String time;
  final String image;
  final String description;

  /// One-line "why this spot" shown on the trail card.
  final String specialty;
  final double rating;

  /// e.g. "2,314 Google reviews".
  final String reviewsLabel;

  /// e.g. "Busiest at golden hour · calm mornings".
  final String popularity;

  /// "Top rated items" for a café, "Don't miss" for a park…
  final String highlightsTitle;
  final List<(String, String, String?)> highlights; // (emoji, label, price?)
  final List<(String, int, String)> reviews; // (author, stars, text)
  final String funFact;
  final String? offer;
  final String quizQuestion;
  final List<String> quizOptions;
  final int quizAnswer;
  final String quizFact;
}

class Achievement {
  const Achievement({
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final String title;
  final String subtitle;
  final bool done;
}

class Stamp {
  const Stamp({
    required this.id,
    required this.label,
    required this.image,
    required this.frameColor,
    this.earned = true,
  });

  final String id;
  final String label;
  final String image;
  final Color frameColor;
  final bool earned;
}

class Moment {
  const Moment({required this.image, required this.label});

  final String image;
  final String label;
}
