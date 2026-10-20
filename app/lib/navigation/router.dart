import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/motion.dart';
import '../screens/adventure/adventure_complete_screen.dart';
import '../screens/adventure/adventure_path_screen.dart';
import '../screens/adventure/adventure_summary_screen.dart';
import '../screens/adventure/chapter_complete_screen.dart';
import '../screens/adventure/chapter_start_screen.dart';
import '../screens/adventure/location_reveal_screen.dart';
import '../screens/adventure/next_chapters_screen.dart';
import '../screens/adventure/place_detail_screen.dart';
import '../screens/adventure/quiz_screen.dart';
import '../screens/adventure/reward_stamp_screen.dart';
import '../screens/adventure/solving_clue_screen.dart';
import '../screens/adventure/trip_summary_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/explore/quest_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/side_menu_screen.dart';
import '../screens/onboarding/city_screen.dart';
import '../screens/onboarding/customize_screen.dart';
import '../screens/onboarding/interests_screen.dart';
import '../screens/onboarding/mystery_mode_screen.dart';
import '../screens/onboarding/preview_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/passport/passport_screen.dart';
import '../screens/plan/curated_adventures_screen.dart';
import '../screens/plan/path_choice_screen.dart';
import '../screens/plan/plan_setup_screen.dart';
import '../screens/plan/playlist_editor_screen.dart';
import '../screens/profile/achievements_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/shell/app_shell.dart';

enum PageMotion { slide, slideFromLeft, rise, celebrate, fade }

/// Shared transition builder so every route animates per the token table.
CustomTransitionPage<void> appPage({
  required Widget child,
  required GoRouterState state,
  PageMotion motion = PageMotion.slide,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppPageDurations.of(motion),
    reverseTransitionDuration: AppPageDurations.of(motion),
    transitionsBuilder: (context, animation, secondary, child) {
      if (MotionSettings.reduced(context)) return child;
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      switch (motion) {
        case PageMotion.slide:
          return SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                .animate(curved),
            child: child,
          );
        case PageMotion.slideFromLeft:
          return SlideTransition(
            position: Tween(begin: const Offset(-1, 0), end: Offset.zero)
                .animate(curved),
            child: child,
          );
        case PageMotion.rise:
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                  .animate(curved),
              child: child,
            ),
          );
        case PageMotion.celebrate:
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        case PageMotion.fade:
          return FadeTransition(opacity: curved, child: child);
      }
    },
  );
}

abstract final class AppPageDurations {
  static Duration of(PageMotion motion) => switch (motion) {
        PageMotion.slide || PageMotion.slideFromLeft =>
          const Duration(milliseconds: 300),
        PageMotion.rise => const Duration(milliseconds: 350),
        PageMotion.celebrate => const Duration(milliseconds: 400),
        PageMotion.fade => const Duration(milliseconds: 250),
      };
}

/// Dev hook: `--dart-define=INITIAL_ROUTE=/home` boots straight into a
/// screen for review/screenshots. Debug builds only — release always
/// starts the real splash flow.
const _initialRoute = kDebugMode
    ? String.fromEnvironment('INITIAL_ROUTE', defaultValue: '/splash')
    : '/splash';

final appRouter = GoRouter(
  initialLocation: _initialRoute,
  routes: [
    // ---- Onboarding flow ----
    GoRoute(
      path: '/splash',
      pageBuilder: (c, s) =>
          appPage(child: const SplashScreen(), state: s, motion: PageMotion.fade),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (c, s) =>
          appPage(child: const WelcomeScreen(), state: s, motion: PageMotion.fade),
    ),

    // ---- Mystery AI planning flow ----
    GoRoute(
      path: '/path-choice',
      pageBuilder: (c, s) => appPage(
          child: const PathChoiceScreen(), state: s, motion: PageMotion.fade),
    ),
    GoRoute(
      path: '/plan',
      pageBuilder: (c, s) => appPage(child: const PlanSetupScreen(), state: s),
    ),
    GoRoute(
      path: '/curated',
      pageBuilder: (c, s) =>
          appPage(child: const CuratedAdventuresScreen(), state: s),
    ),
    GoRoute(
      path: '/playlist',
      pageBuilder: (c, s) =>
          appPage(child: const PlaylistEditorScreen(), state: s),
    ),
    GoRoute(
      path: '/interests',
      pageBuilder: (c, s) => appPage(child: const InterestsScreen(), state: s),
    ),
    GoRoute(
      path: '/city',
      pageBuilder: (c, s) => appPage(child: const CityScreen(), state: s),
    ),
    GoRoute(
      path: '/mode',
      pageBuilder: (c, s) => appPage(child: const MysteryModeScreen(), state: s),
    ),
    GoRoute(
      path: '/customize',
      pageBuilder: (c, s) => appPage(child: const CustomizeScreen(), state: s),
    ),
    GoRoute(
      path: '/preview',
      pageBuilder: (c, s) => appPage(child: const PreviewScreen(), state: s),
    ),

    // ---- Main 5-tab shell ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (c, s) =>
                appPage(child: const HomeScreen(), state: s, motion: PageMotion.fade),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/explore',
            pageBuilder: (c, s) =>
                appPage(child: const ExploreScreen(), state: s, motion: PageMotion.fade),
            routes: [
              GoRoute(
                path: 'quest/:id',
                pageBuilder: (c, s) => appPage(
                  child: QuestDetailScreen(questId: s.pathParameters['id']!),
                  state: s,
                  motion: PageMotion.rise,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/adventure',
            pageBuilder: (c, s) => appPage(
                child: const AdventurePathScreen(),
                state: s,
                motion: PageMotion.fade),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/passport',
            pageBuilder: (c, s) => appPage(
                child: const PassportScreen(), state: s, motion: PageMotion.fade),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            pageBuilder: (c, s) => appPage(
                child: const ProfileScreen(), state: s, motion: PageMotion.fade),
            routes: [
              GoRoute(
                path: 'settings',
                pageBuilder: (c, s) =>
                    appPage(child: const SettingsScreen(), state: s),
              ),
              GoRoute(
                path: 'achievements',
                pageBuilder: (c, s) =>
                    appPage(child: const AchievementsScreen(), state: s),
              ),
            ],
          ),
        ]),
      ],
    ),

    // ---- Side Menu (design1001/side_menu1+2.png), over the shell ----
    GoRoute(
      path: '/menu',
      pageBuilder: (c, s) => appPage(
          child: const SideMenuScreen(),
          state: s,
          motion: PageMotion.slideFromLeft),
    ),

    // ---- Place detail (fullscreen expansion of a trail card) ----
    GoRoute(
      path: '/stop/:index',
      pageBuilder: (c, s) => appPage(
        child: PlaceDetailScreen(
            index: int.tryParse(s.pathParameters['index'] ?? '0') ?? 0),
        state: s,
        motion: PageMotion.celebrate,
      ),
    ),

    // ---- Chapter flow (full-screen, over the shell) ----
    GoRoute(
      path: '/chapter/start',
      pageBuilder: (c, s) => appPage(
          child: const ChapterStartScreen(), state: s, motion: PageMotion.rise),
    ),
    GoRoute(
      path: '/chapter/clue',
      pageBuilder: (c, s) => appPage(
          child: const SolvingClueScreen(), state: s, motion: PageMotion.slide),
    ),
    GoRoute(
      path: '/chapter/reveal',
      pageBuilder: (c, s) => appPage(
          child: const LocationRevealScreen(),
          state: s,
          motion: PageMotion.celebrate),
    ),
    GoRoute(
      path: '/chapter/quiz',
      pageBuilder: (c, s) =>
          appPage(child: const QuizScreen(), state: s, motion: PageMotion.rise),
    ),
    GoRoute(
      path: '/chapter/complete',
      pageBuilder: (c, s) => appPage(
          child: const ChapterCompleteScreen(),
          state: s,
          motion: PageMotion.celebrate),
    ),
    GoRoute(
      path: '/chapter/stamp',
      pageBuilder: (c, s) => appPage(
          child: const RewardStampScreen(),
          state: s,
          motion: PageMotion.celebrate),
    ),
    GoRoute(
      path: '/journey/chapters',
      pageBuilder: (c, s) =>
          appPage(child: const NextChaptersScreen(), state: s),
    ),
    GoRoute(
      path: '/journey/summary',
      pageBuilder: (c, s) =>
          appPage(child: const AdventureSummaryScreen(), state: s),
    ),
    GoRoute(
      path: '/journey/complete',
      pageBuilder: (c, s) => appPage(
          child: const AdventureCompleteScreen(),
          state: s,
          motion: PageMotion.celebrate),
    ),
    GoRoute(
      path: '/journey/trip',
      pageBuilder: (c, s) =>
          appPage(child: const TripSummaryScreen(), state: s),
    ),
  ],
);
