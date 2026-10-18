# Mystery City Adventures — Flutter app

Stage 1 shell: all 26 screens from `../design/design-handoff/SCREENS.md`
with dummy data, working navigation, animations, sounds and haptics.
Runs on iOS and Android. Product plan: `../design/Mystery_City_Adventures_Product_Plan (1).docx`.

## Commands

```sh
flutter run                                   # normal boot (splash flow)
flutter run --dart-define=INITIAL_ROUTE=/home # boot straight into any route
flutter analyze && flutter test
```

## Architecture rules (from the design handoff — keep them)

- **Tokens only.** No color/size/spacing/radius/duration literals in
  screens. Everything comes from `lib/theme/tokens.dart` (generated from
  `design-handoff/tokens.json`) via `context.colors`, `AppType.*`,
  `AppSpace.*`, `AppRadius.*`, `AppSize.*`, `AppMotion.*`.
- **Theme switching.** `lib/theme/themes.dart` defines two full token
  bundles: `voyage` (navy, default) and `expedition` (warm brown). Adding
  a theme = adding one `AppTokens` instance. Settings → Theme switches live.
- **Quest accents.** One parameterized quest detail screen; the accent
  color comes from the quest's `QuestTheme` (peaceful/night/artistic/
  stories). Soft fills derive via `accent.softFill` / `.softBorder`
  (the accentSoftRule) — never new hexes.
- **Mascot slot.** ALL mascot rendering goes through `widgets/mascot.dart`
  (`Mascot(MascotState.idle)`). It currently shows circular-sticker
  placeholder PNGs; the planned Rive rig (5 states: idle, curious,
  walking, celebrating, resting) replaces the widget body only.
- **Sounds/haptics.** Only through `SoundService.instance.play(Sfx.x,
  haptic: Haptic.y)` (`lib/core/sounds.dart`). Placeholder WAVs live in
  `assets/audio/` — regenerate or replace at will; the `Sfx` enum is the
  contract.
- **Reduced motion.** Every loop/entrance checks
  `MotionSettings.reduced(context)` (OS setting OR the in-app Settings
  toggle). New animated widgets must do the same — prefer reusing
  `widgets/motion_widgets.dart` (Floaty, KenBurns, FadeRiseIn, PopIn,
  Shaker, CountUp, Pressable), which already comply.
- **Dummy data** lives only in `lib/data/fixtures.dart`; screens render
  whatever fixtures provide. `lib/state/app_state.dart` (ChangeNotifier
  via `AppScope.of(context)`) holds selections, favorites and the active
  adventure's chapter progress.

## The adventure trail (reference: ../design/new_adv_path.png)

The Adventure tab is one long scrollable illustrated scene
(`adventure_path_screen.dart`): painted sky/bridge → park greens →
golden band → mist, with a winding route through four fully-revealed
place cards (no mystery/locks in this version). Driven by
`Fixtures.places` (rich `Place` model: rating, reviews, highlights,
offer, fun fact, quiz).

Workflow: card tap → fullscreen `/stop/:index` detail (ratings,
Google-style reviews, top items, offer ticket, fun fact, and the mini
quiz — quizzes live HERE, not on the trail). "Mark Stop as Done" (or the
card's Done button) → confetti + the route tints to the next stop with a
traveling glow dot, then auto-scrolls there. After the last stop →
`/chapter/stamp` (adventure finale variant) → `/journey/complete` →
`/journey/trip` → passport.

Motion: one repeating `_ambient` controller phases clouds, tree sway,
fog breathing and the node pulse; scenery parallaxes against scroll; a
`_travel` controller animates segment coloring. All stop under reduced
motion. Dev hooks: `--dart-define=INITIAL_ROUTE=/x` and
`--dart-define=TRAIL_SCROLL=<0-100>` (boots the trail pre-scrolled).

## Navigation map (go_router, `lib/navigation/router.dart`)

- Onboarding: `/splash → /welcome → /interests → /city → /mode →
  /customize → /preview` → Adventure tab.
- Shell tabs: `/home /explore /adventure /passport /profile`
  (`StatefulShellRoute`; the tab bar hides on `/explore/quest/:id`,
  `/profile/settings`, `/profile/achievements`).
- Trail: `/stop/:index` place detail (pops `true` when marked done).
- Legacy chapter flow (kept but off the main path): `/chapter/start →
  /chapter/clue → /chapter/reveal → /chapter/stamp → /chapter/complete`.
- Extras: `/journey/chapters` (stop list), `/journey/summary`
  (so-far tabs), pause via the trail's menu sheet.

## Asset notes

- Assets merged from the three design zips + handoff extras into
  `assets/` (declared per-folder in pubspec.yaml).
- Some placeholder art has baked text/scene crops (see SCREENS.md
  "baked"); several screens bottom-anchor or scrim those images — don't
  "fix" that without replacing the asset.
- `preview/map_full.png` carries baked stop cards; the production target
  (widget stop cards popping in over a clean map) returns when a clean
  map asset exists.

## Known deferred items (stage 2+)

- Rive mascot rig; real venue/route data; accounts; saved places;
  notifications; Adventure Path deep-link from quest detail currently
  always starts the fixture Foodie Trail.
