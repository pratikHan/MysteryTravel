# Mystery City — design assets v2 (9 single-screen concepts)

Unzip at your Flutter project root; it merges with the v1 bundle
(same assets/ layout). Source screens are 852px wide (~2.2x of 390pt),
so these crops are retina-quality.

assets/images/
- onboarding/  splash_mascot, welcome_mascot (text-free; render titles + CTA as live widgets)
- interests/   6 interest tiles + footer mascot scene
- cities/      6 city card illustrations (Amsterdam, Paris, London, New York, Barcelona, Tokyo)
- mode/        Choose Mystery Mode hero + 3 mode card illustrations
- customize/   hero, 3 adventure-mode row strips, 4 travel-style avatars
- preview/     full map painting, 4 stop vignettes, mascot corner
- home/        hero scene, 2 featured-card illustrations
- foodie/      Foodie Trail hero + 4 gallery thumbs
- icons/       question, scales, pin, puzzle, gift, walk, compass (SVG, currentColor)

design/reference/  the 9 full screens, numbered in flow order — keep in the
repo so a terminal build session can compare its UI against them.

Known bakes (replace with live widgets, art behind):
- home/hero contains the speech-bubble text
- preview stop vignettes carry their numbered badges
- preview/map_full includes the baked stop cards (reference-grade; the real
  screen composes cards over a clean map)
All titles, buttons, chips and radio rows are NOT in these crops on purpose —
build them as widgets from tokens.

Note: this screen set uses a navy ink (~#27406E) over cream, where the
Explore set used near-black brown (#27211A). Pick one ink token before
building, or they will read as two different apps.
