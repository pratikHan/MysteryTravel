import 'fixtures.dart';
import 'models.dart';
import 'plan_models.dart';

/// Dummy data for the Mystery AI planning flow. The recommendation
/// engine is [recommendPlaylists] — a pure function over these
/// fixtures, swappable for a real engine later without touching UI.
abstract final class PlanFixtures {
  static const categories = [
    AdventureCategory(id: 'food', label: 'Food & Drinks', emoji: '🍜'),
    AdventureCategory(id: 'nature', label: 'Nature & Parks', emoji: '🌳'),
    AdventureCategory(id: 'art', label: 'Art & Culture', emoji: '🎨'),
    AdventureCategory(id: 'scenic', label: 'Scenic & Photography', emoji: '📸'),
    AdventureCategory(id: 'shopping', label: 'Shopping & Markets', emoji: '🛍️'),
    AdventureCategory(id: 'social', label: 'Social & Family', emoji: '👨‍👩‍👧'),
    AdventureCategory(id: 'nightlife', label: 'Bars & Nightlife', emoji: '🍸'),
    AdventureCategory(id: 'outdoors', label: 'Adventures & Outdoors', emoji: '🥾'),
    AdventureCategory(id: 'entertainment', label: 'Entertainment', emoji: '🎭'),
    AdventureCategory(id: 'wellness', label: 'Wellness & Relaxation', emoji: '🧘'),
    AdventureCategory(id: 'hidden', label: 'Hidden Gems & Mystery', emoji: '🗝️'),
    AdventureCategory(id: 'learning', label: 'Experiences & Learning', emoji: '🔬'),
  ];

  static AdventureCategory categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  static const moods = [
    Mood(id: 'calm', label: 'Calm', emoji: '☀️'),
    Mood(id: 'curious', label: 'Curious', emoji: '❤️'),
    Mood(id: 'adventurous', label: 'Adventurous', emoji: '🍃'),
    Mood(id: 'inspired', label: 'Inspired', emoji: '✨'),
    Mood(id: 'social', label: 'Social', emoji: '👥'),
  ];

  /// Popular US cities offered by the city picker sheet (free text is
  /// still allowed).
  static const usCities = [
    'San Francisco', 'New York', 'Chicago', 'Los Angeles', 'Seattle',
    'Austin', 'Boston', 'Portland', 'Denver', 'New Orleans',
    'Nashville', 'Miami',
  ];

  /// The mascot's canned reaction for the Mood Builder companion bubble.
  static String companionReaction(PlanRequest plan) {
    if (plan.categoryIds.isEmpty && plan.moodId == null) {
      return 'Tell me your vibe and I\'ll build something magical!';
    }
    final mood = plan.moodId == null
        ? null
        : moods.firstWhere((m) => m.id == plan.moodId).label.toLowerCase();
    final picks = plan.categoryIds.take(2).map((id) {
      final c = categoryById(id);
      return c.label.split(' ').first.toLowerCase();
    }).toList();
    final pickText = picks.isEmpty
        ? 'a few surprises'
        : '${picks.join(', ')}, and a few surprises';
    final opener = switch (mood) {
      'calm' => 'A slow, cozy day — love it!',
      'curious' => 'Ooh, a day of discoveries!',
      'adventurous' => 'Now THAT\'s an adventure brewing!',
      'inspired' => 'Creative energy — my favorite!',
      'social' => 'A day with your people — the best kind!',
      _ => 'This sounds like a wonderful day!',
    };
    return '$opener $pickText? You\'ve got great taste! 🌿';
  }

  /// Lightweight dummy [Place] builder so every playlist item can open
  /// the rich Place Detail screen.
  static Place _place({
    required String id,
    required String name,
    required String category,
    required String time,
    required String image,
    required String specialty,
    required String fact,
    double rating = 4.7,
    String reviews = '1,120 Google reviews',
    String? offer,
  }) =>
      Place(
        id: id,
        name: name,
        category: category,
        time: time,
        image: image,
        description:
            '$specialty — a local favorite worth lingering at on your adventure day.',
        specialty: specialty,
        rating: rating,
        reviewsLabel: reviews,
        popularity: 'Calm early · lively later',
        highlightsTitle: 'Don\'t miss',
        highlights: const [
          ('⭐', 'Local favorite', null),
          ('📍', 'Easy to reach', null),
          ('📷', 'Photo moment', null),
        ],
        reviews: const [
          ('Jamie R.', 5, 'Exactly the kind of spot that makes a day feel like a trip.'),
          ('Priya S.', 4, 'Charming, easygoing, and never too crowded if you time it right.'),
        ],
        funFact: fact,
        offer: offer,
        quizQuestion: 'What is $name best known for?',
        quizOptions: const ['Its history', 'Its views', 'Its locals', 'All of it'],
        quizAnswer: 3,
        quizFact: fact,
      );

  // ---------------------------------------------------------------
  // The curated playlists the dummy engine picks from.
  // ---------------------------------------------------------------

  static final playlists = <AdventurePlaylist>[
    AdventurePlaylist(
      id: 'lazy_sunday',
      title: 'Lazy Sunday Reset',
      tagline: 'A slow loop of green spaces and great coffee.',
      heroImage: 'assets/images/cards/card_peaceful.png',
      categoryIds: const ['nature', 'food', 'wellness'],
      duration: '4–5 hours',
      items: [
        PlaylistItem(
          place: Fixtures.places[0], // Lakeside Park
          mysteryTitle: 'A waterside park where herons nest',
          distanceMiles: 0.8,
          suggestedTime: '10:00 AM',
          points: 60,
          emoji: '🌳',
        ),
        PlaylistItem(
          place: Fixtures.places[1], // Garden Café
          mysteryTitle: 'A café hiding under a living green roof',
          distanceMiles: 1.2,
          suggestedTime: '11:30 AM',
          points: 80,
          emoji: '☕',
        ),
        PlaylistItem(
          place: Fixtures.places[2], // Botanical Garden
          mysteryTitle: 'Summer that never ends, behind iron and glass',
          distanceMiles: 1.9,
          suggestedTime: '1:30 PM',
          points: 70,
          emoji: '🦋',
        ),
        PlaylistItem(
          place: Fixtures.places[3], // Sunset Viewpoint
          mysteryTitle: 'The city\'s favorite goodbye-to-the-day spot',
          distanceMiles: 2.6,
          suggestedTime: '6:00 PM',
          points: 90,
          emoji: '🌇',
        ),
      ],
    ),
    AdventurePlaylist(
      id: 'canvas_coffee',
      title: 'Canvas & Coffee',
      tagline: 'Small galleries, bold murals, strong espresso.',
      heroImage: 'assets/images/cards/card_artistic.png',
      categoryIds: const ['art', 'food', 'learning'],
      duration: '3–4 hours',
      items: [
        PlaylistItem(
          place: _place(
            id: 'little_gallery',
            name: 'The Little Gallery',
            category: 'Art Museum',
            time: '10:30 AM',
            image: 'assets/images/stops/stop_artistic_1.png',
            specialty: 'An intimate museum with surprising treasures',
            fact: 'The whole collection fits in six rooms — and still sells out.',
            rating: 4.8,
            reviews: '980 Google reviews',
          ),
          mysteryTitle: 'Six small rooms full of surprising treasures',
          distanceMiles: 0.6,
          suggestedTime: '10:30 AM',
          points: 70,
          emoji: '🖼️',
        ),
        PlaylistItem(
          place: _place(
            id: 'mural_lane',
            name: 'Mural Lane',
            category: 'Street Art',
            time: '12:00 PM',
            image: 'assets/images/stops/stop_artistic_2.png',
            specialty: 'An open-air canvas painted by local artists',
            fact: 'The murals change every season — no two visits match.',
          ),
          mysteryTitle: 'An open-air canvas that repaints itself',
          distanceMiles: 1.1,
          suggestedTime: '12:00 PM',
          points: 60,
          emoji: '🎨',
        ),
        PlaylistItem(
          place: _place(
            id: 'makers_studio',
            name: 'Makers Studio',
            category: 'Working Studio',
            time: '2:00 PM',
            image: 'assets/images/stops/stop_artistic_3.png',
            specialty: 'Watch craft come alive in a working studio',
            fact: 'Visitors can throw a pot on Fridays.',
            offer: 'Free gallery espresso with studio tour',
          ),
          mysteryTitle: 'Where craft comes alive before your eyes',
          distanceMiles: 1.7,
          suggestedTime: '2:00 PM',
          points: 80,
          emoji: '🏺',
        ),
      ],
    ),
    AdventurePlaylist(
      id: 'neon_nights',
      title: 'Neon Nights Out',
      tagline: 'Playful bars, retro games and one secret door.',
      heroImage: 'assets/images/cards/card_night.png',
      categoryIds: const ['nightlife', 'entertainment', 'social'],
      duration: '4–5 hours',
      items: [
        PlaylistItem(
          place: _place(
            id: 'arcade_tap',
            name: 'The Arcade Tap',
            category: 'Game Bar',
            time: '7:00 PM',
            image: 'assets/images/stops/stop_night_1.png',
            specialty: 'Retro games and local brews to start the night',
            fact: 'The pinball machine by the door is from 1978 and still undefeated.',
          ),
          mysteryTitle: 'Where 1978 still beats everyone at pinball',
          distanceMiles: 0.9,
          suggestedTime: '7:00 PM',
          points: 80,
          emoji: '🕹️',
        ),
        PlaylistItem(
          place: _place(
            id: 'karaoke_hideout',
            name: 'Karaoke Hideout',
            category: 'Karaoke Lounge',
            time: '9:00 PM',
            image: 'assets/images/stops/stop_night_3.png',
            specialty: 'Sing your heart out in a hidden lounge',
            fact: 'Regulars say the back room has the best acoustics in town.',
            offer: 'First song free before 9:30 PM',
          ),
          mysteryTitle: 'A hidden room built for loud hearts',
          distanceMiles: 1.4,
          suggestedTime: '9:00 PM',
          points: 70,
          emoji: '🎤',
        ),
        PlaylistItem(
          place: _place(
            id: 'secret_door',
            name: 'The Secret Door',
            category: 'Speakeasy',
            time: '11:00 PM',
            image: 'assets/images/stops/stop_night_4.png',
            specialty: 'End behind an unmarked door — if you can find it',
            fact: 'There is no sign. There has never been a sign.',
            rating: 4.9,
          ),
          mysteryTitle: 'An unmarked door with no sign — ever',
          distanceMiles: 1.8,
          suggestedTime: '11:00 PM',
          points: 90,
          emoji: '🚪',
        ),
      ],
    ),
    AdventurePlaylist(
      id: 'storybook_streets',
      title: 'Storybook Streets',
      tagline: 'True tales, old passages and local legends.',
      heroImage: 'assets/images/cards/card_stories.png',
      categoryIds: const ['hidden', 'learning', 'art'],
      duration: '3–4 hours',
      items: [
        PlaylistItem(
          place: _place(
            id: 'old_courthouse',
            name: 'The Old Courthouse',
            category: 'Historic Site',
            time: '11:00 AM',
            image: 'assets/images/stops/stop_stories_1.png',
            specialty: 'Where a famous trial changed the city',
            fact: 'The verdict bell still rings every year on the anniversary.',
          ),
          mysteryTitle: 'Where one verdict changed everything',
          distanceMiles: 0.7,
          suggestedTime: '11:00 AM',
          points: 60,
          emoji: '⚖️',
        ),
        PlaylistItem(
          place: _place(
            id: 'whisper_passage',
            name: 'Whisper Passage',
            category: 'Hidden Passage',
            time: '12:30 PM',
            image: 'assets/images/stops/stop_stories_2.png',
            specialty: 'A corridor that carried secret messages',
            fact: 'Stand at either end and whisper — the arch carries it perfectly.',
          ),
          mysteryTitle: 'A corridor that carries whispers end to end',
          distanceMiles: 1.3,
          suggestedTime: '12:30 PM',
          points: 70,
          emoji: '🤫',
        ),
        PlaylistItem(
          place: _place(
            id: 'keepers_house',
            name: 'The Keeper\'s House',
            category: 'Local Legend',
            time: '2:30 PM',
            image: 'assets/images/stops/stop_stories_4.png',
            specialty: 'Home of the city\'s most curious legend',
            fact: 'The lights were seen burning for 40 years. Nobody lived there.',
            rating: 4.6,
          ),
          mysteryTitle: 'The house whose lights nobody lit',
          distanceMiles: 2.1,
          suggestedTime: '2:30 PM',
          points: 80,
          emoji: '🏚️',
        ),
      ],
    ),
    AdventurePlaylist(
      id: 'market_feast',
      title: 'Market Morning Feast',
      tagline: 'Taste your way from market stalls to dessert.',
      heroImage: 'assets/images/cards/card_foodie.png',
      categoryIds: const ['food', 'shopping', 'social'],
      duration: '3–4 hours',
      items: [
        PlaylistItem(
          place: _place(
            id: 'morning_market',
            name: 'Morning Market',
            category: 'Food Market',
            time: '9:30 AM',
            image: 'assets/images/foodie/gallery_1.png',
            specialty: 'Start where the city shops for breakfast',
            fact: 'The cheese stall has had the same family behind it for 70 years.',
          ),
          mysteryTitle: 'Where the city buys its breakfast',
          distanceMiles: 0.5,
          suggestedTime: '9:30 AM',
          points: 60,
          emoji: '🧺',
        ),
        PlaylistItem(
          place: _place(
            id: 'corner_cafe',
            name: 'The Corner Café',
            category: 'Café',
            time: '11:00 AM',
            image: 'assets/images/foodie/gallery_2.png',
            specialty: 'A beloved café with a secret menu',
            fact: 'Ask for "the usual" and see what happens.',
            offer: 'Secret-menu item free with any coffee, weekdays',
          ),
          mysteryTitle: 'A café where "the usual" is a password',
          distanceMiles: 0.9,
          suggestedTime: '11:00 AM',
          points: 70,
          emoji: '☕',
        ),
        PlaylistItem(
          place: _place(
            id: 'street_food_lane',
            name: 'Street Food Lane',
            category: 'Street Food',
            time: '12:30 PM',
            image: 'assets/images/foodie/gallery_3.png',
            specialty: 'Three bites you won\'t find anywhere else',
            fact: 'The dumpling cart moved here from a famous night market.',
          ),
          mysteryTitle: 'Three bites that exist nowhere else',
          distanceMiles: 1.3,
          suggestedTime: '12:30 PM',
          points: 60,
          emoji: '🥟',
        ),
        PlaylistItem(
          place: _place(
            id: 'dessert_atelier',
            name: 'Dessert Atelier',
            category: 'Pâtisserie',
            time: '2:00 PM',
            image: 'assets/images/foodie/gallery_4.png',
            specialty: 'End on the city\'s sweetest note',
            fact: 'The pastry chef trained in Lyon and names cakes after regulars.',
            rating: 4.9,
          ),
          mysteryTitle: 'Where cakes are named after regulars',
          distanceMiles: 1.6,
          suggestedTime: '2:00 PM',
          points: 80,
          emoji: '🍰',
        ),
      ],
    ),
    AdventurePlaylist(
      id: 'golden_hour',
      title: 'Golden Hour Wander',
      tagline: 'Chase the light from park paths to the skyline.',
      heroImage: 'assets/images/heroes/hero_peaceful.png',
      categoryIds: const ['scenic', 'nature', 'outdoors'],
      duration: '3 hours',
      items: [
        PlaylistItem(
          place: Fixtures.places[0], // Lakeside Park
          mysteryTitle: 'Trails where the water mirrors the sky',
          distanceMiles: 0.8,
          suggestedTime: '4:00 PM',
          points: 70,
          emoji: '🌅',
        ),
        PlaylistItem(
          place: _place(
            id: 'mural_lane_gold',
            name: 'Mural Lane',
            category: 'Street Art',
            time: '5:30 PM',
            image: 'assets/images/stops/stop_artistic_2.png',
            specialty: 'Murals that glow warmest at golden hour',
            fact: 'Photographers queue here for the 6 PM light.',
          ),
          mysteryTitle: 'Walls that catch fire at six o\'clock',
          distanceMiles: 1.5,
          suggestedTime: '5:30 PM',
          points: 60,
          emoji: '🎨',
        ),
        PlaylistItem(
          place: Fixtures.places[3], // Sunset Viewpoint
          mysteryTitle: 'A west-facing deck inside "the amber window"',
          distanceMiles: 2.2,
          suggestedTime: '6:30 PM',
          points: 90,
          emoji: '🌇',
        ),
      ],
    ),
  ];

  /// The dummy recommendation engine: scores playlists by category
  /// overlap with the request and returns the best 4–5. Deterministic,
  /// pure, and trivially replaceable by a real engine later.
  static List<AdventurePlaylist> recommendPlaylists(PlanRequest request) {
    final scored = playlists
        .map((p) => (
              playlist: p,
              score: p.categoryIds
                  .where(request.categoryIds.contains)
                  .length,
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return [for (final s in scored.take(5)) s.playlist];
  }
}
