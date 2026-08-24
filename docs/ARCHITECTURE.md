# Architecture

## Principle

Garmin remains responsible for activity recording. STACK augments the experience where it adds real value.

The repository contains two Connect IQ apps with intentionally different responsibilities. They should not be forced into one shared product model.

## Connect IQ applications

### 1. STACK Watch Face

A `watchface` app type.

The watch face is an independent STACK-designed everyday face, not a training dashboard and not a projection of the STACK app onto Garmin.

v1 responsibilities:

- render the OFFSET time composition
- render day/date
- render battery
- render temperature/weather when locally available
- optionally render one activity metric such as steps
- render reusable STACK decorative/icon geometry
- manage high-power and low-power AMOLED states

v1 does **not** require:

- STACK authentication
- STACK backend requests
- training-plan data
- Build/tower state
- race or Crew data

The watch face should remain fully useful if the phone is unavailable.

### 2. STACK Run Field

A `datafield` app type. It runs inside Garmin's native Run activity and receives `Activity.Info` approximately once per second.

The full-screen one-field layout on the Forerunner 265 provides a 416×416 drawing area.

The run field is the appropriate home for technical running information and any future STACK plan context.

## Data ownership

### Garmin provides during a run

- heart rate
- speed / pace
- distance
- elapsed time
- cadence and other activity metrics later
- user's configured running HR-zone thresholds

### Garmin/local watch data may provide to the watch face

- clock/time
- date
- battery
- steps/activity-monitor data
- weather/temperature where supported and available

### STACK may eventually provide to the run field

- today's planned run
- workout type
- target zone / pace range
- planned distance or duration
- race context

## Sync direction

### Watch face

No STACK sync is planned for v1.

Do not introduce networking, pairing, authentication, or cached plan state solely to make the face feel more connected. The brand and visual system are sufficient.

### Run field

Phase 1 has no STACK backend dependency. The run field uses Garmin data plus local/default workout targets where required.

A later phase may allow the run field to retrieve a small authenticated JSON payload from the STACK backend using `Toybox.Communications` and cache it with `Application.Storage`.

Example future payload:

```json
{
  "date": "2026-08-24",
  "workoutType": "easy",
  "title": "Easy Run",
  "targetZone": 2,
  "distanceMi": 5.0,
  "raceName": "OUC Half"
}
```

That integration is optional and should be justified by run-field value before implementation.

## Constraints

### Watch face

- respect Garmin watch-face power constraints
- keep the low-power state intentionally sparse
- avoid unnecessary redraws
- avoid network work in v1
- optimize custom font resources to the glyphs actually needed
- design against the Forerunner 265 round 416×416 AMOLED target first

### Run field

- does not replace Garmin activity recording
- receives activity data through Garmin's data-field APIs
- cannot assume the same power/rendering model as the watch face
- should adapt if the user places it in a smaller layout, although the MVP strongly recommends a one-field full-screen page

## Separation rule

Do not let future run-field requirements turn the watch face into a dense training dashboard.

Shared visual primitives are encouraged. Shared product responsibilities are not.
