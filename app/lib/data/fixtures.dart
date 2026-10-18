import 'package:flutter/material.dart';

import 'models.dart';

/// All dummy data for the stage-1 shell lives here, never inside widgets.
abstract final class Fixtures {
  static const cities = [
    City(id: 'amsterdam', name: 'Amsterdam', image: 'assets/images/cities/amsterdam.png'),
    City(id: 'paris', name: 'Paris', image: 'assets/images/cities/paris.png'),
    City(id: 'london', name: 'London', image: 'assets/images/cities/london.png'),
    City(id: 'newyork', name: 'New York', image: 'assets/images/cities/new_york.png'),
    City(id: 'barcelona', name: 'Barcelona', image: 'assets/images/cities/barcelona.png'),
    City(id: 'tokyo', name: 'Tokyo', image: 'assets/images/cities/tokyo.png'),
  ];

  static const interests = [
    Interest(id: 'food', label: 'Food & Drinks', icon: 'assets/images/prefs/icon_food.png'),
    Interest(id: 'history', label: 'History', icon: 'assets/images/prefs/icon_history.png'),
    Interest(id: 'art', label: 'Art & Culture', icon: 'assets/images/prefs/icon_art.png'),
    Interest(id: 'nature', label: 'Nature', icon: 'assets/images/prefs/icon_nature.png'),
    Interest(id: 'gems', label: 'Hidden Gems', icon: 'assets/images/prefs/icon_gems.png'),
    Interest(id: 'night', label: 'Nightlife', icon: 'assets/images/prefs/icon_nightlife.png'),
  ];

  static const mysteryModes = [
    MysteryMode(
      id: 'full',
      title: 'Full Mystery',
      subtitle: 'Maximum surprise, locations hidden until reveal.',
      image: 'assets/images/mode/full_mystery.png',
      badgeColor: Color(0xFFE4554E),
      badgeIcon: Icons.question_mark_rounded,
    ),
    MysteryMode(
      id: 'balanced',
      title: 'Balanced Mystery',
      subtitle: 'Activity types shown, locations revealed chapter by chapter.',
      image: 'assets/images/mode/balanced_mystery.png',
      badgeColor: Color(0xFFE8A73C),
      badgeIcon: Icons.balance_rounded,
    ),
    MysteryMode(
      id: 'open',
      title: 'Open Explorer',
      subtitle: 'All stops visible upfront for flexible planning.',
      image: 'assets/images/mode/open_explorer.png',
      badgeColor: Color(0xFF32A862),
      badgeIcon: Icons.map_rounded,
    ),
  ];

  static const adventureModes = [
    ('classic', 'Classic', 'Balanced clues'),
    ('challenging', 'Challenging', 'Fewer hints'),
    ('relaxed', 'Relaxed', 'More guidance'),
  ];

  static const travelStyles = [
    ('solo', 'Solo', 'assets/images/customize/style_solo.png'),
    ('couple', 'Couple', 'assets/images/customize/style_couple.png'),
    ('friends', 'Friends', 'assets/images/customize/style_friends.png'),
    ('family', 'Family', 'assets/images/customize/style_family.png'),
  ];

  static const exploreChips = [
    ('all', 'All'),
    ('popular', 'Popular'),
    ('food', 'Food'),
    ('culture', 'Culture'),
    ('nightlife', 'Nightlife'),
  ];

  static const quests = [
    Quest(
      id: 'peaceful',
      title: 'Peaceful Retreat',
      tagline: 'Relaxing places, nature, cozy cafés',
      description:
          'Slow down, breathe and discover serene spots that refresh your mind.',
      theme: QuestTheme.peaceful,
      cardImage: 'assets/images/cards/card_peaceful.png',
      heroImage: 'assets/images/heroes/hero_peaceful.png',
      tags: ['Nature', 'Parks', 'Scenic Views', 'Cozy Cafés'],
      categories: ['popular', 'food'],
      duration: '3–4 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Nearby route',
      travelSub: '5–10 min between',
      audienceLabel: 'All ages',
      audienceSub: 'Solo or group',
      expect: [
        ExpectItem(label: 'Beautiful parks', image: 'assets/images/expect/expect_peaceful_1.png'),
        ExpectItem(label: 'Scenic viewpoints', image: 'assets/images/expect/expect_peaceful_2.png'),
        ExpectItem(label: 'Calm cafés', image: 'assets/images/expect/expect_peaceful_3.png'),
        ExpectItem(label: 'Hidden gardens', image: 'assets/images/expect/expect_peaceful_4.png'),
      ],
      stops: [
        SampleStop(title: 'Lakeside Park', subtitle: 'Peaceful walking trails with stunning city views.', image: 'assets/images/stops/stop_peaceful_1.png'),
        SampleStop(title: 'Garden Café', subtitle: 'A cozy café surrounded by greenery.', image: 'assets/images/stops/stop_peaceful_2.png'),
        SampleStop(title: 'Botanical Garden', subtitle: 'Explore beautiful plant collections.', image: 'assets/images/stops/stop_peaceful_3.png'),
        SampleStop(title: 'Sunset Viewpoint', subtitle: 'End with a breathtaking view of the city.', image: 'assets/images/stops/stop_peaceful_4.png'),
      ],
    ),
    Quest(
      id: 'night',
      title: 'Night Party Quest',
      tagline: 'Bars, games, karaoke, hidden nightlife',
      description:
          'Light up the evening with playful bars, karaoke dens and secret doors.',
      theme: QuestTheme.night,
      cardImage: 'assets/images/cards/card_night.png',
      heroImage: 'assets/images/heroes/hero_night.png',
      tags: ['Bars', 'Games', 'Karaoke', 'Hidden Spots'],
      categories: ['popular', 'nightlife'],
      duration: '4–5 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Walkable route',
      travelSub: '5–10 min between',
      audienceLabel: 'Adults',
      audienceSub: 'Friends & groups',
      expect: [
        ExpectItem(label: 'Playful bars', image: 'assets/images/expect/expect_night_1.png'),
        ExpectItem(label: 'Game lounges', image: 'assets/images/expect/expect_night_2.png'),
        ExpectItem(label: 'Karaoke rooms', image: 'assets/images/expect/expect_night_3.png'),
        ExpectItem(label: 'Secret doors', image: 'assets/images/expect/expect_night_4.png'),
      ],
      stops: [
        SampleStop(title: 'The Arcade Tap', subtitle: 'Retro games and local brews to start the night.', image: 'assets/images/stops/stop_night_1.png'),
        SampleStop(title: 'Neon Alley', subtitle: 'A glowing lane of tiny bars and big laughs.', image: 'assets/images/stops/stop_night_2.png'),
        SampleStop(title: 'Karaoke Hideout', subtitle: 'Sing your heart out in a hidden lounge.', image: 'assets/images/stops/stop_night_3.png'),
        SampleStop(title: 'The Secret Door', subtitle: 'End behind an unmarked door — if you can find it.', image: 'assets/images/stops/stop_night_4.png'),
      ],
    ),
    Quest(
      id: 'artistic',
      title: 'Artistic Quest',
      tagline: 'Museums, art, history, creative spaces',
      description:
          'Wander through galleries, murals and studios that spark your imagination.',
      theme: QuestTheme.artistic,
      cardImage: 'assets/images/cards/card_artistic.png',
      heroImage: 'assets/images/heroes/hero_artistic.png',
      tags: ['Museums', 'Street Art', 'Studios', 'History'],
      categories: ['popular', 'culture'],
      duration: '3–4 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Nearby route',
      travelSub: '5–10 min between',
      audienceLabel: 'All ages',
      audienceSub: 'Solo or group',
      expect: [
        ExpectItem(label: 'Small museums', image: 'assets/images/expect/expect_artistic_1.png'),
        ExpectItem(label: 'Bold murals', image: 'assets/images/expect/expect_artistic_2.png'),
        ExpectItem(label: 'Artist studios', image: 'assets/images/expect/expect_artistic_3.png'),
        ExpectItem(label: 'Sculpture corners', image: 'assets/images/expect/expect_artistic_4.png'),
      ],
      stops: [
        SampleStop(title: 'The Little Gallery', subtitle: 'An intimate museum with surprising treasures.', image: 'assets/images/stops/stop_artistic_1.png'),
        SampleStop(title: 'Mural Lane', subtitle: 'An open-air canvas painted by local artists.', image: 'assets/images/stops/stop_artistic_2.png'),
        SampleStop(title: 'Makers Studio', subtitle: 'Watch craft come alive in a working studio.', image: 'assets/images/stops/stop_artistic_3.png'),
        SampleStop(title: 'Sculpture Garden', subtitle: 'Finish among art under the open sky.', image: 'assets/images/stops/stop_artistic_4.png'),
      ],
    ),
    Quest(
      id: 'stories',
      title: 'Real Stories Quest',
      tagline: 'Places with fascinating true stories',
      description:
          'Walk through real history — every stop hides a true tale worth telling.',
      theme: QuestTheme.stories,
      cardImage: 'assets/images/cards/card_stories.png',
      heroImage: 'assets/images/heroes/hero_stories.png',
      tags: ['True Stories', 'History', 'Legends', 'Local Lore'],
      categories: ['culture'],
      duration: '3–4 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Nearby route',
      travelSub: '5–10 min between',
      audienceLabel: 'All ages',
      audienceSub: 'Solo or group',
      expect: [
        ExpectItem(label: 'Historic halls', image: 'assets/images/expect/expect_stories_1.png'),
        ExpectItem(label: 'Old passages', image: 'assets/images/expect/expect_stories_2.png'),
        ExpectItem(label: 'Storied squares', image: 'assets/images/expect/expect_stories_3.png'),
        ExpectItem(label: 'Legendary spots', image: 'assets/images/expect/expect_stories_4.png'),
      ],
      stops: [
        SampleStop(title: 'The Old Courthouse', subtitle: 'Where a famous trial changed the city.', image: 'assets/images/stops/stop_stories_1.png'),
        SampleStop(title: 'Whisper Passage', subtitle: 'A corridor that carried secret messages.', image: 'assets/images/stops/stop_stories_2.png'),
        SampleStop(title: 'Liberty Square', subtitle: 'The square where history took a turn.', image: 'assets/images/stops/stop_stories_3.png'),
        SampleStop(title: 'The Keeper\'s House', subtitle: 'Home of the city\'s most curious legend.', image: 'assets/images/stops/stop_stories_4.png'),
      ],
    ),
    Quest(
      id: 'foodie',
      title: 'Foodie Adventure',
      tagline: 'Unique dining, local flavors, hidden gems',
      description:
          'Taste your way through local flavors, hidden gems and unforgettable bites.',
      theme: QuestTheme.artistic,
      cardImage: 'assets/images/cards/card_foodie.png',
      heroImage: 'assets/images/foodie/hero.png',
      tags: ['Food', 'Local Cafés', 'Markets'],
      categories: ['popular', 'food'],
      duration: '3–4 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Walkable route',
      travelSub: '5–10 min between',
      audienceLabel: 'All ages',
      audienceSub: 'Solo or group',
      expect: [
        ExpectItem(label: 'Local markets', image: 'assets/images/foodie/gallery_1.png'),
        ExpectItem(label: 'Hidden cafés', image: 'assets/images/foodie/gallery_2.png'),
        ExpectItem(label: 'Street flavors', image: 'assets/images/foodie/gallery_3.png'),
        ExpectItem(label: 'Sweet finales', image: 'assets/images/foodie/gallery_4.png'),
      ],
      stops: [
        SampleStop(title: 'Morning Market', subtitle: 'Start where the city shops for breakfast.', image: 'assets/images/foodie/gallery_1.png'),
        SampleStop(title: 'The Corner Café', subtitle: 'A beloved café with a secret menu.', image: 'assets/images/foodie/gallery_2.png'),
        SampleStop(title: 'Street Food Lane', subtitle: 'Three bites you won\'t find anywhere else.', image: 'assets/images/foodie/gallery_3.png'),
        SampleStop(title: 'Dessert Atelier', subtitle: 'End on the city\'s sweetest note.', image: 'assets/images/foodie/gallery_4.png'),
      ],
    ),
    Quest(
      id: 'family',
      title: 'Family Fun Quest',
      tagline: 'Kid-friendly, interactive and playful stops',
      description: 'Playful discoveries the whole crew will love.',
      theme: QuestTheme.peaceful,
      cardImage: 'assets/images/cards/card_family.png',
      heroImage: 'assets/images/cards/card_family.png',
      tags: ['Family', 'Playful', 'Interactive'],
      categories: [],
      duration: '2–3 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Gentle pace',
      travelSub: 'Short walks',
      audienceLabel: 'Families',
      audienceSub: 'All ages',
      expect: [],
      stops: [],
      available: false,
    ),
    Quest(
      id: 'couples',
      title: 'Couples Escape',
      tagline: 'Romantic spots, scenic views, intimate experiences',
      description: 'A date the two of you will keep retelling.',
      theme: QuestTheme.stories,
      cardImage: 'assets/images/cards/card_couples.png',
      heroImage: 'assets/images/cards/card_couples.png',
      tags: ['Romance', 'Views', 'Food'],
      categories: ['nightlife'],
      duration: '3–4 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Nearby route',
      travelSub: '5–10 min between',
      audienceLabel: 'Couples',
      audienceSub: 'Date night',
      expect: [],
      stops: [],
      available: false,
    ),
    Quest(
      id: 'secrets',
      title: 'Local Secrets',
      tagline: 'Offbeat places, unique neighborhoods, hidden gems',
      description: 'The city only locals know — until today.',
      theme: QuestTheme.night,
      cardImage: 'assets/images/cards/card_secrets.png',
      heroImage: 'assets/images/cards/card_secrets.png',
      tags: ['Hidden Gems', 'Local Life'],
      categories: ['culture', 'food'],
      duration: '3–4 hours',
      stopsLabel: '4 stops',
      travelLabel: 'Nearby route',
      travelSub: '5–10 min between',
      audienceLabel: 'All ages',
      audienceSub: 'Solo or group',
      expect: [],
      stops: [],
      available: false,
    ),
  ];

  static Quest questById(String id) =>
      quests.firstWhere((q) => q.id == id, orElse: () => quests.first);

  /// Featured cards on Home.
  static const featuredHome = [
    (
      questId: 'foodie',
      title: 'The Foodie Trail',
      blurb:
          'Taste your way through local flavors, hidden gems and unforgettable bites.',
      image: 'assets/images/home/card_foodie.png',
      icon: Icons.restaurant_rounded,
      iconColor: Color(0xFFE8862B),
      chips: ['Food', 'Local Cafés', 'Markets'],
    ),
    (
      questId: 'artistic',
      title: 'Art & Soul',
      blurb:
          'Explore art, culture and history through the city\'s most inspiring places.',
      image: 'assets/images/home/card_art_soul.png',
      icon: Icons.palette_rounded,
      iconColor: Color(0xFF8A4FD3),
      chips: ['Museums', 'Historic Sites', 'Local Artists'],
    ),
  ];

  /// The active adventure driving the Adventure tab and trail flow.
  static const activeAdventureTitle = 'Peaceful Retreat';
  static const activeAdventureCity = 'Amsterdam';
  static const activeAdventureDuration = '3–4 hours';
  static const activeAdventureMeta = '4 stops · Nearby & walk-friendly';
  static const activeAdventureImage = 'assets/images/cards/card_peaceful.png';
  static const activeAdventureWelcome =
      'Welcome! Let\'s find your\nnext peaceful escape!';

  /// Stops of the active trail, fully revealed as places.
  static const places = [
    Place(
      id: 'lakeside',
      name: 'Lakeside Park',
      category: 'Park & Trails',
      time: '10:00 AM',
      image: 'assets/images/stops/stop_peaceful_1.png',
      description:
          'Quiet waterside trails that open onto wide skyline views — the gentlest possible start to a slow morning.',
      specialty: 'Waterside trails with skyline views',
      rating: 4.8,
      reviewsLabel: '2,314 Google reviews',
      popularity: 'Calm mornings · livelier after lunch',
      highlightsTitle: 'Don\'t miss',
      highlights: [
        ('🌿', 'Willow pier', null),
        ('🌹', 'Rose garden loop', null),
        ('🦆', 'Duck pond benches', null),
      ],
      reviews: [
        ('Maya K.', 5, 'The calmest spot in the city. I come every Sunday with a book and lose track of time.'),
        ('Jeroen V.', 5, 'The willow pier at opening time is pure magic — mist on the water and total silence.'),
      ],
      funFact:
          'Herons nest in the tall poplars here every spring — locals name them each year.',
      offer: 'Free guided nature walk every Sunday at 10:30 AM',
      quizQuestion: 'What returns to Lakeside Park every spring?',
      quizOptions: ['Swans', 'Herons', 'Beavers', 'Storks'],
      quizAnswer: 1,
      quizFact: 'A heron colony has nested in the same poplars for 20 years.',
    ),
    Place(
      id: 'gardencafe',
      name: 'Garden Café',
      category: 'Cozy Café',
      time: '11:30 AM',
      image: 'assets/images/stops/stop_peaceful_2.png',
      description:
          'A tucked-away café wrapped in greenery, where the tables sit between planters and the pace slows right down.',
      specialty: 'Herbal teas under a living green roof',
      rating: 4.7,
      reviewsLabel: '1,086 Google reviews',
      popularity: 'Quiet before noon · cozy-busy afternoons',
      highlightsTitle: 'Top rated items',
      highlights: [
        ('🍵', 'House herbal tea', '€4.50'),
        ('🥕', 'Carrot cake', '€5.00'),
        ('🥐', 'Garden breakfast', '€12.00'),
      ],
      reviews: [
        ('Sofia L.', 5, 'The carrot cake is legendary and the courtyard feels like a secret garden.'),
        ('Tom B.', 4, 'Lovely calm spot. Service is slow — but honestly, that\'s the point here.'),
      ],
      funFact:
          'The café began as a flower shop in 1952 — the original counter is still the bar.',
      offer: '10% off herbal teas before noon',
      quizQuestion: 'What was Garden Café before it served tea?',
      quizOptions: ['A bakery', 'A bookshop', 'A flower shop', 'A pharmacy'],
      quizAnswer: 2,
      quizFact: 'It opened as a flower shop in 1952 — hence the planters everywhere.',
    ),
    Place(
      id: 'botanical',
      name: 'Botanical Garden',
      category: 'Historic Gardens',
      time: '1:30 PM',
      image: 'assets/images/stops/stop_peaceful_3.png',
      description:
          'Winding glasshouses and plant collections gathered over 150 years — warm, green and wonderfully quiet midweek.',
      specialty: 'A butterfly house inside a historic greenhouse',
      rating: 4.9,
      reviewsLabel: '3,502 Google reviews',
      popularity: 'Peaceful on weekdays · busy weekend afternoons',
      highlightsTitle: 'Don\'t miss',
      highlights: [
        ('🦋', 'Butterfly house', null),
        ('🌴', 'Palm greenhouse', null),
        ('🪷', 'Lily pond', null),
      ],
      reviews: [
        ('Anouk D.', 5, 'The butterfly house alone is worth the ticket. Went for an hour, stayed three.'),
        ('Liam P.', 5, 'The old palm greenhouse smells like another century — in the best way.'),
      ],
      funFact:
          'The palm greenhouse (1865) is the oldest in the city and still uses its original iron frame.',
      offer: 'Students 30% off all week',
      quizQuestion: 'When was the palm greenhouse built?',
      quizOptions: ['1823', '1865', '1902', '1931'],
      quizAnswer: 1,
      quizFact: 'Built in 1865, it\'s the oldest greenhouse in the city.',
    ),
    Place(
      id: 'sunset',
      name: 'Sunset Viewpoint',
      category: 'Scenic Overlook',
      time: '6:00 PM',
      image: 'assets/images/stops/stop_peaceful_4.png',
      description:
          'The city\'s favorite goodbye-to-the-day spot — a west-facing deck where the skyline slowly turns gold.',
      specialty: 'The best golden-hour view in the city',
      rating: 4.9,
      reviewsLabel: '1,764 Google reviews',
      popularity: 'Busiest at golden hour · serene at dusk',
      highlightsTitle: 'Don\'t miss',
      highlights: [
        ('🌇', 'West deck rail', null),
        ('📸', 'Photo ledge', null),
        ('🫖', 'Tea cart (summer)', null),
      ],
      reviews: [
        ('Elena R.', 5, 'Arrive 30 minutes before sunset and thank me later. Unreal light.'),
        ('Daan M.', 5, 'Proposed here last June. The view said yes before she did.'),
      ],
      funFact:
          'Photographers call the half hour before sunset here "the amber window".',
      offer: null,
      quizQuestion: 'Which direction does the viewing deck face?',
      quizOptions: ['North', 'East', 'South', 'West'],
      quizAnswer: 3,
      quizFact: 'It faces due west — straight into the setting sun.',
    ),
  ];

  static const chapters = [
    Chapter(
      number: 1,
      title: 'Lakeside Park',
      lockedTitle: 'A Gentle Start',
      clue: 'Find the pier where willows\nlean over still water...',
      venueName: 'Lakeside Park',
      venueTags: [
        (Icons.park_rounded, 'Park & Trails'),
        (Icons.favorite_rounded, 'Local Favorite'),
      ],
      venueStory: 'Quiet waterside trails with wide skyline views.',
      image: 'assets/images/stops/stop_peaceful_1.png',
      clueOptions: [
        ClueOption(label: 'Old Sign', image: 'assets/images/chapter/clue_old_sign.png'),
        ClueOption(label: 'Bicycle', image: 'assets/images/chapter/clue_bicycle.png'),
        ClueOption(label: 'Windmill', image: 'assets/images/chapter/clue_windmill.png'),
      ],
      correctOption: 2,
      quizQuestion: 'What returns to Lakeside Park every spring?',
      quizOptions: ['Swans', 'Herons', 'Beavers', 'Storks'],
      quizAnswerIndex: 1,
      quizFact: 'A heron colony has nested in the same poplars for 20 years.',
      stampImage: 'assets/images/rewards/stamp_amsterdam.png',
    ),
    Chapter(
      number: 2,
      title: 'Garden Café',
      lockedTitle: 'A Green Hideaway',
      clue: 'Where flowers once were sold,\ntea now steams between the planters...',
      venueName: 'Garden Café',
      venueTags: [
        (Icons.local_cafe_rounded, 'Cozy Café'),
        (Icons.favorite_rounded, 'Local Favorite'),
      ],
      venueStory: 'A tucked-away café wrapped in greenery since 1952.',
      image: 'assets/images/stops/stop_peaceful_2.png',
      clueOptions: [
        ClueOption(label: 'Old Sign', image: 'assets/images/chapter/clue_old_sign.png'),
        ClueOption(label: 'Bicycle', image: 'assets/images/chapter/clue_bicycle.png'),
        ClueOption(label: 'Windmill', image: 'assets/images/chapter/clue_windmill.png'),
      ],
      correctOption: 0,
      quizQuestion: 'What was Garden Café before it served tea?',
      quizOptions: ['A bakery', 'A bookshop', 'A flower shop', 'A pharmacy'],
      quizAnswerIndex: 2,
      quizFact: 'It opened as a flower shop in 1952.',
      stampImage: 'assets/images/rewards/stamp_de_bakkerij.png',
    ),
    Chapter(
      number: 3,
      title: 'Botanical Garden',
      lockedTitle: 'A Living Treasure',
      clue: 'Behind iron and glass,\nsummer never ends...',
      venueName: 'Botanical Garden',
      venueTags: [
        (Icons.local_florist_rounded, 'Historic Gardens'),
        (Icons.favorite_rounded, 'Local Favorite'),
      ],
      venueStory: 'Glasshouses and plant collections gathered over 150 years.',
      image: 'assets/images/stops/stop_peaceful_3.png',
      clueOptions: [
        ClueOption(label: 'Old Sign', image: 'assets/images/chapter/clue_old_sign.png'),
        ClueOption(label: 'Bicycle', image: 'assets/images/chapter/clue_bicycle.png'),
        ClueOption(label: 'Windmill', image: 'assets/images/chapter/clue_windmill.png'),
      ],
      correctOption: 1,
      quizQuestion: 'When was the palm greenhouse built?',
      quizOptions: ['1823', '1865', '1902', '1931'],
      quizAnswerIndex: 1,
      quizFact: 'Built in 1865, it\'s the oldest greenhouse in the city.',
      stampImage: 'assets/images/rewards/stamp_barcelona.png',
    ),
    Chapter(
      number: 4,
      title: 'Sunset Viewpoint',
      lockedTitle: 'The Golden Finale',
      clue: 'Face the west as the day\nturns to amber...',
      venueName: 'Sunset Viewpoint',
      venueTags: [
        (Icons.wb_twilight_rounded, 'Scenic Overlook'),
        (Icons.favorite_rounded, 'Local Favorite'),
      ],
      venueStory: 'The city\'s favorite goodbye-to-the-day spot.',
      image: 'assets/images/stops/stop_peaceful_4.png',
      clueOptions: [
        ClueOption(label: 'Old Sign', image: 'assets/images/chapter/clue_old_sign.png'),
        ClueOption(label: 'Bicycle', image: 'assets/images/chapter/clue_bicycle.png'),
        ClueOption(label: 'Windmill', image: 'assets/images/chapter/clue_windmill.png'),
      ],
      correctOption: 2,
      quizQuestion: 'Which direction does the viewing deck face?',
      quizOptions: ['North', 'East', 'South', 'West'],
      quizAnswerIndex: 3,
      quizFact: 'It faces due west — straight into the setting sun.',
      stampImage: 'assets/images/rewards/stamp_tokyo.png',
    ),
  ];

  static const moments = [
    Moment(image: 'assets/images/expect/expect_peaceful_1.png', label: 'Morning trails'),
    Moment(image: 'assets/images/expect/expect_peaceful_2.png', label: 'Skyline views'),
    Moment(image: 'assets/images/expect/expect_peaceful_3.png', label: 'Tea break'),
    Moment(image: 'assets/images/expect/expect_peaceful_4.png', label: 'Hidden gardens'),
  ];

  static const achievements = [
    Achievement(title: 'First Adventure', subtitle: 'Complete your first adventure', done: true),
    Achievement(title: 'Foodie Explorer', subtitle: 'Complete 3 food adventures', done: false),
    Achievement(title: 'Culture Seeker', subtitle: 'Visit 5 cultural locations', done: false),
    Achievement(title: 'Stamp Collector', subtitle: 'Collect 10 stamps', done: false),
    Achievement(title: 'City Hopper', subtitle: 'Explore 3 different cities', done: false),
  ];

  static const achievementsUnlocked = 6;
  static const achievementsTotal = 20;

  static const stamps = [
    Stamp(id: 'amsterdam', label: 'Amsterdam', image: 'assets/images/rewards/stamp_amsterdam.png', frameColor: Color(0xFFE8A73C)),
    Stamp(id: 'paris', label: 'Paris', image: 'assets/images/rewards/stamp_paris.png', frameColor: Color(0xFFE48B8B)),
    Stamp(id: 'london', label: 'London', image: 'assets/images/rewards/stamp_london.png', frameColor: Color(0xFF4A7FC9)),
    Stamp(id: 'barcelona', label: 'Barcelona', image: 'assets/images/rewards/stamp_barcelona.png', frameColor: Color(0xFF8A4FD3)),
    Stamp(id: 'tokyo', label: 'Tokyo', image: 'assets/images/rewards/stamp_tokyo.png', frameColor: Color(0xFFD94F4F)),
    Stamp(id: 'newyork', label: 'New York', image: 'assets/images/rewards/stamp_coming_soon.png', frameColor: Color(0xFFB9BFCB), earned: false),
  ];

  static const profileName = 'Alex';
  static const profileStats = [
    ('12', 'Locations'),
    ('8', 'Stamps'),
    ('5', 'Cities'),
  ];
  static const profileLevel = 4;
  static const profileXpProgress = 0.65;
}
