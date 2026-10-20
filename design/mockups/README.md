# Mystery AI — design mockups

High-fidelity PNG mockups for the new flow, built from the app's real
tokens (Voyage palette, Nunito) and existing placeholder assets, and
informed by the Mobbin references in `../mobbin/`. Source HTML lives in
`html/` — edit it and re-render with headless Chrome (390pt wide, 2x).

| PNG | Screen | What it proposes |
|---|---|---|
| 01_path_choice.png | **Path Choice** | Mascot asks the question; two tall illustrated cards (map art = Planned, mystery-glow art = Mystery) with benefit bullets; selected card gets gold ring + check; "★ MOST FUN" badge on Mystery; "switch modes anytime" reassurance. |
| 02_plan_setup.png | **Plan Setup** | One scrollable form: city/date/time fields, 12 emoji chips (selected = filled green), 4/5 counter pill, positive cap note ("Nice mix!"), wish textbox, mascot promise bubble, sparkle CTA. |
| 03_curated_adventures.png | **Curated Adventures** | Playlist cards with hero art, % match badge, handwritten "↳ because you picked…" annotation, meta chips, stop-teaser line; best match gets gold border. |
| 04_playlist_editor.png | **Playlist Editor** (Mystery mode) | Numbered rows with drag handles + dotted connectors; row 2 shown mid-drag (lifted, gold ring); emoji mystery thumbs, teaser titles, ~mi distance pills, ✕ remove; mascot summary card (total stops/miles); Save CTA + opens-on date. |
| 05_adventure_trail.png | **Adventure Trail** (refresh) | Header with stop progress bar; winding trail with traveled portion tinted green; done-stop quiet card; 🎁 surprise-bonus node; big glowing current node + mascot + card with "because you picked" + "I'm here — reveal it!" CTA; upcoming stops as teaser cards; 🏅 stamp goal at the end. |

Mockup caveats: the hero/card images are current placeholder assets
(some carry baked titles that clash with playlist names — final art
replaces them); the trail curve is an impression, the app's painted
scene stays the real implementation.

Render command:

    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --headless --hide-scrollbars --force-device-scale-factor=2 \
      --window-size=390,<height> --screenshot=<name>.png html/<name>.html
