# Mystery City — design assets v3 (screens 11–25: live adventure, rewards, profile)

Unzips over v1/v2 at the Flutter project root.

assets/images/
- path/      the full Adventure Path concept (the centerpiece screen, as one painting)
- chapter/   chapter-loop art: chapter hero, clue scene + 3 clue-option thumbs,
             location-reveal mascot + venue thumb, chapter-complete star scene,
             quiz image + quiz mascot, pause-bench mascot
- rewards/   the De Bakkerij stamp postcard + 6 passport stamp cards
             (Amsterdam, Paris, London, Barcelona, Tokyo, coming-soon placeholder)
- complete/  adventure-complete mascot scene + 4 "moments" thumbs
- profile/   profile avatar/arch header, settings footer scene (sleeping mascot)
- icons/     13 new SVGs: trophy, bell, shield, info, share, star, log_out,
             pause, play, close, check_circle, camera, lock

design/reference/  all 15 full screens (11_adventure_path ... 25_settings),
numbered to match your concept boards.

RESOLUTION WARNING: these came from multi-phone boards (~250-315px per phone),
so crops are ~1x — fine for development, soft on retina. The passport stamps
and the Adventure Path painting are the ones worth regenerating as single
852px-wide images (like screens in the v2 batch) before release.
Stamp cards keep their baked city labels on purpose (they are the collectible
design); numbered badges on some thumbs are baked too.
