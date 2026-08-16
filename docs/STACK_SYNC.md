# STACK Sync

## Recommended path

Use the existing STACK backend as the source of truth and let the Connect IQ app request a very small watch-safe payload.

### Endpoint concept

`GET /api/garmin/today`

Return only what the watch needs for today's session.

## Authentication

Do not embed a permanent STACK credential in source code. Use a user-bound token / pairing flow and store only the resulting scoped token in Garmin application storage.

## Caching

The watch should cache the last successful plan payload so a run still works if the phone or network is unavailable.

## Phase 2 acceptance criteria

- planned run is visible before starting
- run field knows target zone / pace
- stale data is visibly identified
- run field remains fully functional with Garmin-only metrics when STACK is unreachable
