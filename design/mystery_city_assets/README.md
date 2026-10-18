# Mystery City — design assets

Drop the `assets/` folder into the root of your Flutter project and merge
PUBSPEC_SNIPPET.yaml into pubspec.yaml.

- images/heroes   — screen hero illustrations (explore + 4 quests)
- images/cards    — the 8 Explore category cards (titles baked in; concept-resolution placeholders)
- images/expect   — "What to expect" thumbnails, 4 per quest
- images/stops    — "Sample stops" thumbnails, 4 per quest
- icons           — UI icon set as SVG, stroke=currentColor (tint with flutter_svg ColorFilter)

Naming: <kind>_<theme>_<n>.png, themes: peaceful | night | artistic | stories.

Note: raster images are cropped from the concept board (~1x). Fine for
development; replace with 2x/3x exports of final art before release.
UI components (chips, buttons, cards, stop rows) are NOT images — build
them as widgets from the token values so they stay crisp, themeable and
animatable.
