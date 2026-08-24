# Roadmap

## M0 — Bootstrap
- [x] Separate watch-face and data-field projects
- [x] Target Forerunner 265
- [x] Basic visual skeletons
- [x] HR-zone utility
- [ ] Compile both projects with the current Connect IQ SDK

## M1 — Watch Face Visual Reset
- [x] Define watch face as a brand-first product, not a passive dashboard
- [x] Select **OFFSET** as the canonical v1 layout
- [ ] Remove the tower from the current watch-face implementation
- [ ] Replace legacy Garmin palette with current STACK colors
- [ ] Build the oversized asymmetric `HH : MM` composition
- [ ] Add day/date, battery, temperature/weather, and one optional activity metric
- [ ] Create the first reusable decorative STACK block/icon set
- [x] Add custom numeric display typography (polygon numerals, no font resource)

## M2 — AMOLED + Physical Watch Validation
- [ ] Implement a deliberately simplified low-power / always-on state
- [ ] Review AMOLED burn-in and illuminated-area behavior
- [ ] Add a short wake-state motion treatment if power behavior remains acceptable
- [ ] Verify the 416×416 round safe area in simulator
- [ ] Sideload to the physical Forerunner 265
- [ ] Tune scale, edge spacing, and glance readability on hardware

## M3 — Watch Face Polish
- [ ] Refine STACK Display and STACK Mono font roles
- [ ] Finalize icon/block geometry
- [ ] Decide whether accent color is configurable
- [ ] Decide whether the optional metric is configurable
- [ ] Add 12/24-hour handling
- [ ] Keep OFFSET as the only required production layout

## M4 — Optional Watch Face Variants
- [ ] Prototype **BLOCK** layout
- [ ] Prototype **POSTER** layout
- [ ] Reuse the same color, type, icon, and low-power system
- [ ] Do not add variants until OFFSET is stable on hardware

## M5 — Run Field MVP
- [ ] Verify full-screen 416×416 rendering
- [ ] Validate Garmin running HR zones
- [ ] Validate pace / distance formatting
- [ ] Test FIT simulation and FIT playback
- [ ] Sideload to physical Forerunner 265

## M6 — Run Field Visual System
- [ ] Match current STACK typography / spacing
- [ ] Finalize zone block language
- [ ] Add workout-specific screen variants where useful
- [ ] Review power and readability during activity

## M7 — Optional STACK Plan Sync

This milestone applies to the **run field**, not the v1 watch face.

- [ ] Confirm that synced plan data adds enough value to justify the backend work
- [ ] Define a minimal watch-safe plan contract
- [ ] Implement pairing / scoped auth only if approved
- [ ] Fetch and cache today's workout
- [ ] Show target zone / pace / distance in the run field
- [ ] Preserve Garmin-only offline fallback

## M8 — Activity Contribution
- [ ] Decide whether any STACK-specific metrics belong in FIT
- [ ] Add FIT contributor fields only if useful
- [ ] Validate Garmin Connect display

## M9 — Distribution
- [ ] Maintain a simple private sideload workflow
- [ ] Add CI builds if they reduce friction
- [ ] Prepare Connect IQ Store assets only if publication is actually desired

## Current execution order

1. OFFSET watch-face visual reset
2. AMOLED / physical-watch validation
3. watch-face polish
4. run-field validation
5. optional sync and distribution work

The project should not block the watch face on STACK backend integration.
