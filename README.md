# STACK Garmin

Garmin Connect IQ projects designed to extend the STACK visual system onto Garmin hardware.

This repository contains **two separate Connect IQ applications**:

- `watch-face/` — an expressive STACK-designed everyday watch face.
- `run-field/` — a full-screen STACK data field used inside Garmin's native Run activity.

Initial hardware target: **Garmin Forerunner 265 (`fr265`, 416×416 AMOLED)**.

## Product split

The two apps intentionally solve different problems.

### Watch face

The watch face is a **brand object first, utility second**.

v1 direction: **OFFSET**

- oversized asymmetric split time
- current STACK color system
- custom chunky numeric typography
- day/date
- battery
- weather/temperature when available
- one optional activity metric such as steps
- small reusable STACK graphic pieces
- intentionally simplified always-on state
- no Build tower
- no STACK backend dependency
- no training-plan dashboard

See `docs/WATCH_FACE.md` for the canonical watch-face design contract.

### Run field

The run field remains the technical running surface.

- live heart rate
- Garmin running HR zones
- active-zone STACK visualization
- pace
- distance
- elapsed time
- target-zone placeholder until future plan sync exists

If STACK plan connectivity is added later, it belongs primarily to the run-field experience rather than the everyday watch face.

## Setup

1. Install Garmin Connect IQ SDK Manager and the current SDK.
2. Install the Garmin **Monkey C** extension in VS Code.
3. Install Java 11 or newer.
4. Download the `fr265` device in SDK Manager.
5. Open `stack-garmin.code-workspace` in VS Code.
6. Run either project against the Forerunner 265 simulator.

Both projects use minimum API level 5.2.0 because the first target is the Forerunner 265.

## Simulator

For the run field, use Garmin's simulated FIT data:

`Simulation → FIT Data → Simulate`

For best run-field validation, use a real running FIT file containing:

- heart rate
- speed
- distance
- elapsed time

For the watch face, validate both normal/high-power rendering and low-power/always-on behavior.

## Repository map

```text
stack-garmin/
├── watch-face/
├── run-field/
├── docs/
└── .github/ISSUE_TEMPLATE/
```

## Current priorities

1. Rebuild the watch face around the OFFSET visual direction.
2. Replace the legacy Garmin watch palette with current STACK tokens.
3. Add custom display typography and reusable STACK graphic pieces.
4. Implement an intentional low-power AMOLED state.
5. Continue validating the run field independently.

See `docs/ROADMAP.md`.
