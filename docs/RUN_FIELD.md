# Run Field

## Goal

Create a full-screen STACK training HUD inside Garmin's native Run activity.

## MVP layout

- top: elapsed time + workout label
- center: large live heart rate
- middle: five STACK zone blocks
- bottom: pace + distance

The active HR zone is calculated from Garmin's configured running zone thresholds.

## MVP behavior

- Z1–Z5 always visible.
- Active zone gets the strong accent.
- Target zone gets an outline / secondary treatment.
- Target defaults to Z2 until STACK sync exists.
- Smaller Garmin field layouts fall back to a compact HR + zone presentation.

## Later layouts

- Easy: HR zone first
- Long: distance + HR first
- Tempo: pace target first
- Intervals: rep + target pace first
- Race: pace + projected finish first
