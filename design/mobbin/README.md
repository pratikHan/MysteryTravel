# Mobbin design references — Mystery AI flow

Collected 2026-10-19 by browsing mobbin.com (free account, screenshots
of search-result previews). Resolution is modest — treat these as
pattern references, not pixel specs. Grouped by the target screen from
SCREEN_GUIDE.md.

---

## path_choice/ — for **Path Choice** (Planned vs Mystery)

| File | App | Why it's here |
|---|---|---|
| 01_bitepal_mode_cards_mascot.png | BitePal | The closest match to our screen: mascot asks the question in a bubble, two stacked rounded option cards, selected card gets accent border + a "Recommended" badge. Adopt wholesale. |
| 02_bumble_two_mode_choice.png | Bumble | Two-mode choice as radio cards with a reassurance footnote ("You'll only be shown…"). The footnote idea fits us: "You can switch modes later." |
| 03_public_detailed_option_cards.png | Public | Option cards with bulleted detail lists — useful if we want each path card to list 2–3 concrete differences. |
| 04_ahead_journey_cards_match.png | Ahead | Playful illustrated journey cards with "% match" labels and Added/Add buttons — the gamified feel. |
| 05_stardust_choose_journey_dark.png | Stardust | 2×2 illustrated "choose your journey" grid — shows how strong per-card artwork carries the screen with almost no text. |

**Design take:** BitePal's structure + our mascot + two tall illustrated
cards (map art for Planned, crystal-ball/fog art for Mystery), selected
state with accent ring, "You can switch modes later" footnote.

## plan_setup/ — for **Plan Setup**

| File | App | Why it's here |
|---|---|---|
| 01_mindtrip_personalized_suggestions.png | Mindtrip | AI-travel onboarding end-state with suggestion chips written as wishes ("Plan a weekend in Vancouver") — exactly the tone for our wish textbox placeholder. |
| 02_tripadvisor_create_trip.png | Tripadvisor | "Create a trip" bottom sheet: single name field + big CTA. Pattern for keeping entry friction tiny. |
| 03_structured_planning_onboarding.png | Structured | "Let's get started by planning today…" — warm illustrated planning intro with progress dots; a mood reference for the top of our form. |
| 04_mindtrip_travel_style_chips.png | Mindtrip | Multi-question single-scroll form made entirely of chip groups — our city/date/time + categories can read this clean. |
| 05_tripadvisor_interest_chips.png | Tripadvisor | THE category-picker reference: "How do you want to spend your time? Choose as many as you'd like" with filled accent chips. Ours adds the 5-cap counter. |
| 06_bumble_max5_interests.png | Bumble | Interest picker with a hard cap — "You've chosen all 5 interests. They sound great!" Grouped sections + outlined selected chips + celebratory cap message instead of an error. |

**Design take:** one scrollable form; Tripadvisor-style filled chips
with emoji; Bumble's positive cap copy ("All 5 picked — great mix!");
Mindtrip-style wish placeholder text.

## adventure_trail/ — for **Adventure Trail** (redesign pass)

| File | App | Why it's here |
|---|---|---|
| 01_ahead_winding_node_path.png | Ahead | Vertical winding path, oversized numbered nodes, current node in accent, mascot with speech bubble, gift-box reward node mid-path. Closest spiritual match to our trail. |
| 02_duolingo_unit_path.png | Duolingo | The canonical gamified path: section banner header, ring highlight around the current node, treasure chest rewards, greyed future nodes, stats top bar. |
| 03_tolan_your_path_narrative.png | Tolan | Narrative "Your path" — progress told as journal entries + focus-area progress bars; a calmer alternative voice for Mystery mode reveals. |
| 04_ahead_path_scene_mascot.png | Ahead | Fuller scene: landscape layers, water, trees, encouragement labels along the path ("Stop caring what people think" → ours: stop teasers). |
| 05_corner_place_cards_annotations.png | corner | Place cards with handwritten-style annotations: "BECAUSE YOU LIKE AESTHETIC…", "#1 IN YOUR AREA", check badges. Steal this: our trail cards can say "Because you picked 🌳 Nature & Parks". |
| 06_noom_milestone_journey.png | Noom | Dashed milestone path with illustrated circular waypoints — a lighter-weight trail style, good for the Mystery mode where art must not reveal the place. |

**Design take:** keep our painted scene; upgrade nodes toward
Ahead/Duolingo (bigger, ring-highlighted current, reward node at the
end = our stamp); add corner-style "because you picked…" annotations
tying stops to the user's chosen categories; consider gift/chest nodes
between stops for surprise bonuses in Mystery mode.

---

## Cross-cutting design themes for Mystery AI

1. **Mascot as narrator** — every reference that charms (BitePal,
   Ahead, Duolingo) puts a character beside the question. Our owl
   already exists; let it ask the questions on Path Choice and cheer
   on the trail.
2. **Chips are the language of preference** — Tripadvisor, Mindtrip,
   Bumble all use emoji+label chips, filled when selected. Our 12
   categories should be filled accent chips, not tiles.
3. **Positive constraints** — Bumble celebrates hitting the cap
   instead of erroring. Copy tone: "All 5 picked — sounds like a great
   day!"
4. **Recommendation = personal** — Mindtrip echoes your words back;
   corner annotates *why* each place was picked. Echo the wish text on
   Curated Adventures (already in skeleton) and annotate stops with the
   category that earned them.
5. **Reward objects on the path** — Duolingo chests / Ahead gifts →
   our passport stamp belongs ON the trail as a visible goal (we
   already do this; make it shinier).
6. **Palette stays ours** — references skew pastel/cream which matches
   our token system; no theme overhaul needed, just stronger accent
   usage on selected states.
