# Watch Face v2 — Agent Handoff

## Goal

Replace the current OFFSET implementation with the approved **STACK Hero Time** face without rebuilding generic Connect IQ infrastructure that can be safely reused.

## Do first

1. Read `WATCH_FACE.md`.
2. Read `WATCH_FACE_LAYOUT_SPEC.md`.
3. Read `REFERENCE_REPOS.md`.
4. Read `FONT_SKOMELR_QUANTUM.md`.
5. Read `TRAINER_BOI_INTEGRATION.md`.
6. Run `scripts/fetch-reference-repos.ps1` locally.
7. Confirm a properly licensed `Skomelr Quantum.otf` is present before generating or distributing font assets.

## Implementation order

### Phase 1 — foundation

- keep Forerunner 265 (`fr265`, 416×416) as the validation target
- replace polygon-display numerals with generated bitmap font resources
- adapt the MIT font pipeline already added under `watch-face/tools/`
- keep layout anchors normalized enough to allow additional round AMOLED sizes later

### Phase 2 — active face

- render hour, colon, minute as separately colored Skomelr strings
- render actual Trainer Boi in the center negative space
- implement segmented daily step-goal ring
- implement top date/battery row
- implement three lower metric slots

### Phase 3 — settings

Add curated settings for:

- hour color
- minute color
- colon color
- ring mode: multicolor / single
- ring single color
- metric color mode
- Trainer Boi: full color / mono / off
- three metric selections

### Phase 4 — AOD

Implement the separate minimal AOD reference:

- monochrome/dim time
- optional date/battery
- no ring
- no lower metrics
- no full-color Trainer Boi

### Phase 5 — validation

Test at minimum:

- times: 1:11, 7:38, 8:11, 10:08, 10:48, 11:59, 12:47, 23:59
- 12-hour and 24-hour modes
- 0%, 50%, 100%+ step progress
- low and high battery values
- all color combinations in the curated palette
- Trainer Boi full color / mono / off
- normal and AOD transitions

## Reuse rules

- Prefer Garmin official Apache-2.0 examples for API/lifecycle code.
- Reuse/adapt WinterTime's MIT font-generation approach and retain notice.
- Do not paste source from Tactical Grid, Burndown, or Gregor because no explicit license was detected.
- Do not paste Crystal Face GPL code unless the project explicitly decides to adopt GPL obligations.

## Completion definition

Do not call the watch face complete until a simulator screenshot visually matches the reference direction and uses the actual font + actual Trainer Boi asset.
