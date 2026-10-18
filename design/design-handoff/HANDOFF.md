# Mystery City Adventures — design handoff

This folder is the contract between the design and the build agent
(Claude Code in a terminal, building Flutter — or SwiftUI). Everything
needed to recreate a screen without guessing lives here or in the three
asset zips. If something is missing for a screen, say so rather than
inventing it.

## Folder layout (after unzipping everything at the repo root)

    design-handoff/
      HANDOFF.md            this file
      tokens.json           the single source of color/type/spacing/motion truth
      SCREENS.md            index of all screens: reference → assets → behavior
      source/*.dc.html      pixel-exact HTML sources of 6 built screens (see below)
      assets/prefs_icons/   6 preference-tile icons
    design/reference/       full-screen reference PNGs (from asset zips v2+v3,
                            plus canvas Share → Export for the 6 built screens)
    assets/images/, assets/icons/   from mystery_city_assets v1+v2+v3 zips

## How to build a screen (in this order)

1. Read `tokens.json` once. Generate the theme from it. After that,
   NO screen may contain a color, font size, spacing, radius or duration
   literal — only token references. This is the consistency guarantee.
2. Read the screen's row in `SCREENS.md`: it names the reference image,
   the asset folder, and the behavior.
3. If the screen has a file in `source/`, treat that file as the
   authoritative spec: its inline styles carry the exact paddings, sizes
   and hexes, and its script block is the state machine (selection,
   favorite toggle, filtering). Translate structure → widget tree,
   inline styles → token references, script state → screen state.
   HTML flex/grid maps to Column/Row/GridView (Flutter) or
   VStack/HStack/Grid (SwiftUI) almost 1:1.
4. Otherwise build from the reference PNG + behavior line, composing the
   named assets. References are 390pt-wide phone designs; compare your
   result against the PNG at 390pt width.
5. Definition of done, per screen:
   - side-by-side with the reference at 390pt: same structure, spacing
     rhythm, type hierarchy; art may differ where assets are placeholders
   - zero style literals outside the theme
   - all listed behaviors work with dummy data (fixtures), none hardcoded
     in the widget
   - loops/parallax/entrances disabled under reduced motion
   - text is real text, never baked image text, except where SCREENS.md
     marks an asset "baked"

## Rules that keep recreation faithful

- Images never carry text or controls. Anything readable or tappable in a
  reference is a widget; the art behind it is the asset.
- One accent per quest theme (tokens.json → color.accent). A quest screen
  takes its accent as a parameter; never fork a second detail screen.
- Soft tints derive from the accent via the accentSoftRule, not new hexes.
- The ink decision in tokens.json meta must be made before screen one.
- Mascot: static PNGs now; the production plan is one Rive rig with five
  states (idle, curious, walking, celebrating, resting). Build mascot
  slots as a swappable widget so the rig drops in later.
