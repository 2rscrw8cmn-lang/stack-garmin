# Architecture

## Principle

Garmin remains responsible for activity recording. STACK augments the experience.

## Connect IQ applications

### 1. STACK Watch Face
A `watchface` app type. It is the everyday dashboard and must respect Garmin watch-face power constraints.

### 2. STACK Run Field
A `datafield` app type. It runs inside Garmin's native Run activity and receives `Activity.Info` approximately once per second.

The full-screen one-field layout on the Forerunner 265 provides a 416×416 drawing area.

## Data ownership

### Garmin provides during a run
- heart rate
- speed / pace
- distance
- elapsed time
- cadence and other activity metrics later
- user's configured running HR-zone thresholds

### STACK eventually provides
- today's planned run
- workout type
- target zone / pace range
- planned distance or duration
- race context

## Sync direction

Phase 1 has no STACK backend dependency. The run field uses Garmin data plus a local target-zone default.

Phase 2 should let the Connect IQ apps retrieve a small authenticated JSON payload from the STACK backend using `Toybox.Communications` and cache it with `Application.Storage`. This avoids requiring a native iOS companion solely for Garmin sync.

Suggested payload:

```json
{
  "date": "2026-08-16",
  "workoutType": "easy",
  "title": "Easy Run",
  "targetZone": 2,
  "distanceMi": 5.0,
  "raceName": "OUC Half"
}
```

## Constraints

- Watch faces are power constrained and should avoid unnecessary redraws/network work.
- Data fields do not replace Garmin activity recording.
- Data fields cannot directly take user input during the activity.
- The UI must adapt if the user places the field in a smaller layout; the MVP strongly recommends a one-field full-screen page.
