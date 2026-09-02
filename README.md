# STACK Garmin

Garmin Connect IQ projects that extend the STACK visual system onto Garmin hardware.

This repository contains two separate Connect IQ applications:

- `watch-face/` — an expressive everyday STACK watch face.
- `run-field/` — a full-screen STACK data field used inside Garmin's native Run activity.

Primary hardware target: **Garmin Forerunner 265 (`fr265`, 416×416 AMOLED)**.

## Current watch-face direction

The previous **OFFSET** experiment is superseded by the current **STACK Hero Time** direction.

The face should communicate STACK without needing a STACK wordmark:

- large **Skomelr Quantum** hero time
- independently configurable hour / minute / colon colors
- the actual full-color **Trainer Boi** artwork from `stack-run`
- a segmented outer ring with a real purpose: **daily step-goal progress**
- three configurable lower metrics, with defaults of distance, heart rate, and Body Battery
- black AMOLED background
- bright STACK color accents taken from the canonical Trainer Boi artwork
- deliberately simplified always-on state
- no Build tower
- no STACK backend dependency in v1

See:

- `docs/WATCH_FACE.md` — canonical product/design contract
- `docs/WATCH_FACE_LAYOUT_SPEC.md` — implementation zones and sizing guidance
- `docs/TRAINER_BOI_INTEGRATION.md` — actual artwork source and Garmin treatment
- `docs/FONT_SKOMELR_QUANTUM.md` — font pipeline and licensing status
- `docs/REFERENCE_REPOS.md` — what to reuse from public Garmin projects and what must remain reference-only
- `docs/IMPLEMENTATION_HANDOFF.md` — implementation notes and execution history

Reference mockups:

- `docs/screenshots/watch-face-v2-reference.png`
- `docs/screenshots/watch-face-v2-aod-reference.png`

Forerunner 265 simulator captures of the implemented face:

- `docs/screenshots/hero-time-fr265-active.png` — active face at 50% of the daily step goal
- `docs/screenshots/hero-time-fr265-steps-100.png` — completed daily step ring
- `docs/screenshots/hero-time-fr265-aod.png` — reduced always-on composition

## Font licensing

The project owner reviewed the Skomelr Quantum license and cleared it for STACK/Garmin use.

The raw `.otf` / `.ttf` source files remain intentionally gitignored and local-only. The repository contains the generated Garmin bitmap font resources used by the watch face.

Place the licensed source file locally at:

`watch-face/fonts-src/Skomelr Quantum.otf`

Then regenerate resources with:

`python watch-face/tools/gen_fonts.py`

## Reuse strategy

Do not rebuild generic Connect IQ infrastructure when a permissively licensed implementation already solves it.

Primary reusable sources:

1. **Garmin `connectiq-apps`** — Apache-2.0; canonical Garmin patterns and APIs.
2. **WinterTime-Watchface** — MIT; bitmap font-generation pipeline, 416×416 resource overrides, relative layout, and AMOLED/AOD patterns.

Reference-only sources unless licensing changes:

- Tactical Grid (`ilkerender/ilker-garmin-watchface`) — no license detected.
- Burndown (`digitalhen/burndown-garmin-watchface`) — no license detected.
- Gregor Forerunner Watch Face (`gregor-srdic/garmin-watchface`) — no license detected.
- Crystal Face (`warmsound/crystal-face`) — GPL-3.0; do not copy code into STACK unless the project intentionally accepts GPL obligations.

Run `scripts/fetch-reference-repos.ps1` to clone the external references into a local ignored folder.

## Setup

1. Install Garmin Connect IQ SDK Manager and the current SDK.
2. Install Garmin's **Monkey C** extension in VS Code.
3. Install Java 11 or newer.
4. Download the `fr265` device in SDK Manager.
5. Open `stack-garmin.code-workspace` in VS Code.
6. Place the properly licensed Skomelr source font at `watch-face/fonts-src/Skomelr Quantum.otf`.
7. Run `python watch-face/tools/gen_fonts.py` if the generated font resources need to be refreshed.
8. Build and run the watch face against the Forerunner 265 simulator.

## Product split

### Watch face

Brand object first, utility second. Garmin-local data only for v1.

### Run field

Technical running surface for live heart rate, zones, pace, distance, elapsed time, and any future STACK-plan context.

Do not force run-field requirements into the everyday watch face.
