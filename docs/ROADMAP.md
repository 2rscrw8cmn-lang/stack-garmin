# STACK Garmin Roadmap

## Watch face — current priority

### M1 — v2 design handoff

- [x] Lock Skomelr Quantum as the display numeral direction
- [x] Lock actual full-color Trainer Boi as the central brand element
- [x] Define outer segmented ring as daily step-goal progress
- [x] Define outlined-hour / filled-minute white Hero Time treatment
- [x] Define three lower metric slots
- [x] Define separate AOD composition
- [x] Add active + AOD reference mockups
- [x] Document font licensing gate
- [x] Add licensed external-reference strategy
- [x] Add reusable MIT bitmap-font generator

### M2 — implementation reset

- [ ] Replace current OFFSET polygon numerals with generated Skomelr bitmap fonts
- [ ] Add Trainer Boi optimized drawable/resource path
- [ ] Add segmented step-goal ring
- [ ] Rebuild active layout to match `WATCH_FACE_LAYOUT_SPEC.md`
- [ ] Add curated color settings
- [ ] Add configurable metric slots
- [ ] Implement AOD reference state

### M3 — validation

- [ ] Compile on current Connect IQ SDK
- [ ] Validate Forerunner 265 simulator at required test times
- [ ] Validate 12/24-hour settings
- [ ] Validate step ring at 0 / 50 / 100%+
- [ ] Validate all color settings
- [ ] Measure memory and draw performance
- [ ] Validate on physical Forerunner 265

### M4 — additional devices

Only after the 265 is stable:

- [ ] 454×454 round AMOLED
- [ ] 390×390 round AMOLED
- [ ] 360×360 round AMOLED

Use resource overrides and normalized anchors rather than redesigning from scratch.

## Run field

Continue independently from watch-face design work.

- [ ] Keep validating HR-zone rendering
- [ ] Validate pace / distance / elapsed-time behavior on real FIT data
- [ ] Revisit STACK plan sync only after the local Garmin experience is stable
