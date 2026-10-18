# Screen index

Reference paths assume the v2/v3 zips are unzipped at the repo root; the
6 canvas-built screens also exist as `source/*.dc.html` (authoritative)
and should be exported as PNGs from the canvas (Share → Export) into
design/reference/. "Baked" = text/badges burned into the asset on purpose
or pending final art.

| # | Screen | Reference | Assets | Source file | Behavior and motion |
| --- | --- | --- | --- | --- | --- |
| 01 | Splash | design/reference/01_splash.png | images/onboarding/splash_mascot | — | Logo title + tagline fade-stagger in; Get Started → 02. Background drifts (kenburns). |
| 02 | Welcome | design/reference/02_welcome.png | images/onboarding/welcome_mascot | — | Intro copy; Continue → 03. Mascot floats gently. |
| 03 | Interests | design/reference/03_interests.png | images/interests/* | — | Multi-select 6 tiles (see 04 for the pattern); Continue enabled at 1+. |
| 04 | Set Preferences (simple variant of 03) | export from canvas | assets/prefs_icons/* | source/set_preferences.dc.html | Multi-select tiles: toggle border+tint+check pop (motion.pop); Continue dims at 0 selections, shows count. |
| 05 | Pick Your City | design/reference/04_cities.png + canvas export | images/cities/* | source/select_city.dc.html | Live search filters grid (empty state when no match); tap selects card (accent ring + check pop); "Explore {city}" button rises in; tap again deselects. |
| 06 | Choose Mystery Mode | design/reference/05_mystery_mode.png | images/mode/* | — | Single-select 3 rows (radio semantics); Continue → 07. Selected row ring in accent. |
| 07 | Customize Adventure | design/reference/06_customize.png + canvas export | images/customize/* | source/customize_adventure.dc.html | Radio group (Classic/Challenging/Relaxed, dot pops in) + single-select travel style tiles; Preview → 08. Source has a tweak swapping flat glyph tiles for the illustrated bird avatars (customize/style_*). |
| 08 | Adventure Preview | design/reference/07_adventure_preview.png + canvas export | images/preview/*, assets/preview_map.png (interior baked: thumbs, badges, mascot) | source/adventure_preview.dc.html | Map drifts (kenburns); Start Adventure → 11. Production target: compose stop cards as widgets over a clean map so they can pop in staggered; the source's single-image map is the interim. |
| 09 | Home | design/reference/08_home.png | images/home/* (hero has baked bubble text) | — | Speech bubble floats; featured cards lift on press, heart toggles; tab bar, Home active. |
| 10 | Explore + 4 quest details | export from canvas | images/heroes, cards, expect, stops (v1) | source/explore.dc.html, source/quest_detail_*.dc.html | Chip filter re-flows grid; card → detail is the signature zoom/Hero transition; detail: kenburns hero, heart pop, CTA press. One parameterized detail screen, accent per theme. |
| — | Foodie Trail detail | design/reference/09_foodie_detail.png | images/foodie/* | — | Same template as quest detail; proof it reskins from fixtures alone. |
| 11 | Adventure Path (centerpiece) | design/reference/11_adventure_path.png | images/path/path_scene_full (whole concept) | — | Vertical scrolling trail; nodes locked/active/done; parallax scene layers; mascot walks with scroll; node tap → 12. Hardest screen: build as a spike first. |
| 12 | Chapter Start | design/reference/12_chapter_start.png | images/chapter/chapter_hero | — | Clue card rises (sheet); Let's Solve It → 13. |
| 13 | Solving a Clue | design/reference/13_solving_clue.png | images/chapter/clue_scene, clue_* thumbs | — | Pick one of 3 options; Check Answer validates; wrong = shake, right → 14. |
| 14 | Location Reveal | design/reference/14_location_reveal.png | images/chapter/reveal_mascot, reveal_bakery | — | Confetti burst + haptic on entry; venue card flips/slides up; Continue → 15. |
| 15 | Chapter Complete | design/reference/15_chapter_complete.png | images/chapter/complete_star | — | Star coin drops with bounce; checklist items tick in sequence; Next Chapter → 11 (next node). |
| 16 | Next Chapters | design/reference/16_next_chapters.png | path scene reuse | — | Chapter list: done/current/locked states; locked rows shake on tap. |
| 17 | Quiz / Fun Fact | design/reference/17_quiz.png | images/chapter/quiz_bakery, quiz_mascot | — | Multiple choice; correct = green fill + fact panel expands; always skippable. |
| 18 | Reward / Stamp | design/reference/18_reward_stamp.png | rewards/stamp_de_bakkerij | — | Stamp slams in with rotation + scale settle (motion.pop, stronger); View My Passport → 23. |
| 19 | Adventure Summary (live) | design/reference/19_adventure_summary.png | thumbs from chapter assets | — | Tabs Locations/Photos/Stories; locked rows greyed. |
| 20 | Pause | design/reference/20_pause.png | images/chapter/pause_mascot | — | Modal over dimmed path; Pause/End/Keep Exploring; End asks to confirm. |
| 21 | Adventure Complete | design/reference/21_adventure_complete.png | images/complete/adventure_hero | — | Confetti; 4 stat tiles count up from 0; View My Adventure → 22. |
| 22 | Trip Summary | design/reference/22_trip_summary.png | images/complete/moment_* | — | Places list with chevrons; moments strip horizontally scrollable; Save to Passport → 23. |
| 23 | Passport | design/reference/23_passport.png | rewards/stamp_* (labels baked: collectible design) | — | Stamps/Cities tabs; earned stamps full color, unearned dashed placeholder; stamp tap zooms. |
| 24 | Profile | design/reference/24_profile.png + canvas export | assets/avatar.png (baked edit badge), images/profile/header_avatar | source/profile.dc.html | Avatar, name, stats row (12/8/5); menu rows lift on press; Achievements and Settings rows navigate to those screens; XP bar (richer variant) animates on entry. |
| 25 | Settings | design/reference/25_settings.png + canvas export | images/profile/settings_footer | source/settings.dc.html | Grouped list with dividers; back → Profile; Log Out is destructive red and swaps inline to a confirm row (Log Out / Cancel). |
| 26 | Achievements | canvas export | — (medal is an inline SVG) | source/achievements.dc.html | Back → Profile; progress bar fills on entry; unlocked row carries green check, locked rows dimmed with padlock and shake on tap. |
