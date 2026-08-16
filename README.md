# STACK Garmin

Garmin Connect IQ companion projects for STACK.

This repository intentionally contains **two Connect IQ applications**:

- `watch-face/` — passive STACK dashboard for the Garmin home screen.
- `run-field/` — full-screen STACK data field used inside Garmin's native Run activity.

Initial hardware target: **Garmin Forerunner 265 (`fr265`, 416×416 AMOLED)**.

## MVP

### Watch face
- STACK-branded time display
- battery and steps
- compact training tower placeholder
- designed for AMOLED / low-power constraints

### Run field
- live heart rate
- Garmin running HR zones
- active-zone STACK visualization
- pace, distance, elapsed time
- target-zone placeholder (Z2 until STACK sync is implemented)

## Setup

1. Install Garmin Connect IQ SDK Manager and the latest SDK.
2. Install the Garmin **Monkey C** extension in VS Code.
3. Install Java 11 or newer.
4. Download the `fr265` device in SDK Manager.
5. Open `stack-garmin.code-workspace` in VS Code.
6. Run either project against the Forerunner 265 simulator.

Garmin's current SDK release is Connect IQ 9.2.0 (June 8, 2026). Both projects use minimum API level 5.2.0 because the first target is the Forerunner 265.

## Simulator

For the run field, use Garmin's simulated FIT data:

`Simulation → FIT Data → Simulate`

For best validation, use a real running FIT file with:
- heart rate
- speed
- distance
- elapsed time

## Repository map

```text
stack-garmin/
├── watch-face/
├── run-field/
├── docs/
└── .github/ISSUE_TEMPLATE/
```

## Next milestone

Get `run-field` running full screen in the Forerunner 265 simulator, verify live HR-zone switching, then sideload it to the physical watch.

See `docs/ROADMAP.md`.
