# STACK Sync

## Status

STACK sync is **not part of the v1 watch-face plan**.

The watch face should remain independent, Garmin-local, and useful without authentication, network access, or cached STACK state.

Any future STACK sync work should be justified by the **run field** first.

## Potential future run-field path

If synced plan data proves useful during runs, use the existing STACK backend as the source of truth and let the Connect IQ run field request a very small watch-safe payload.

### Endpoint concept

`GET /api/garmin/today`

Return only what the run field needs for today's session.

Possible fields:

- workout type
- workout title
- target HR zone
- target pace range
- planned distance or duration
- race context when relevant

Do not send Crew, Build, recap, social, or general app state to the watch unless a later product decision explicitly requires it.

## Authentication

Do not embed a permanent STACK credential in source code.

If this phase is approved, use a user-bound pairing/scoped-token flow and store only the resulting scoped token in Garmin application storage.

## Caching

The run field should cache the last successful plan payload so it remains useful if the phone or network is unavailable.

Garmin-native run metrics must continue to work regardless of STACK availability.

## Acceptance criteria for any future sync phase

- sync clearly improves the run-field experience
- planned run context is available before or during the run
- target zone / pace / distance can be shown without cluttering the core data field
- stale cached data is visibly identified
- Garmin-only operation remains fully functional when STACK is unreachable
- the watch face remains independent unless a separate watch-face product decision changes that rule
