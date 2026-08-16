# Roadmap

## M0 — Bootstrap
- [x] Separate watch-face and data-field projects
- [x] Target Forerunner 265
- [x] Basic visual skeletons
- [x] HR-zone utility
- [ ] Compile both projects with Connect IQ SDK 9.2.0

## M1 — Run Field MVP
- [ ] Verify full-screen 416×416 rendering
- [ ] Validate Garmin running HR zones
- [ ] Validate pace / distance formatting
- [ ] Test FIT simulation and FIT playback
- [ ] Sideload to physical Forerunner 265

## M2 — Visual System
- [ ] Match STACK typography / spacing
- [ ] Finalize zone block language
- [ ] Add workout-specific screen variants
- [ ] Add AMOLED burn-in / power review

## M3 — STACK Sync
- [ ] Define `/api/garmin/today` contract
- [ ] Implement pairing / scoped auth
- [ ] Fetch and cache today's workout
- [ ] Show target zone / pace / distance
- [ ] Offline fallback

## M4 — Activity Contribution
- [ ] Decide which STACK-specific metrics belong in FIT
- [ ] Add FIT contributor fields if useful
- [ ] Validate Garmin Connect display

## M5 — Distribution
- [ ] Private sideload workflow
- [ ] CI builds
- [ ] Connect IQ Store assets only if we decide to publish
