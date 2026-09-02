# External Garmin Reference Repositories

Goal: reuse proven Connect IQ patterns where licensing allows it and avoid rebuilding generic Garmin infrastructure.

## Reuse priority

| Repository | License | STACK use |
|---|---|---|
| `garmin/connectiq-apps` | Apache-2.0 | **Copy/adapt allowed with license compliance.** Use for canonical Garmin API patterns, watch-face lifecycle, settings, resources, and SDK examples. |
| `chrisdfennell/WinterTime-Watchface` | MIT | **Copy/adapt allowed with MIT notice retained.** Best source for the bitmap-font generator, per-resolution resource overrides, relative layout, and AMOLED/AOD patterns. |
| `warmsound/crystal-face` | GPL-3.0 | Reference architecture only unless STACK intentionally accepts GPL obligations for derivative code. |
| `ilkerender/ilker-garmin-watchface` (Tactical Grid) | No license detected | **Reference only. Do not copy code.** Useful for round-screen scaling and multi-device thinking. |
| `digitalhen/burndown-garmin-watchface` | No license detected | **Reference only. Do not copy code.** Useful for multi-device layout organization. |
| `gregor-srdic/garmin-watchface` | No license detected | **Reference only. Do not copy code.** Useful for AMOLED visual architecture and bitmap-digit concepts. |

## What we should actually borrow now

### 1. WinterTime font pipeline

Adapted locally as:

`watch-face/tools/gen_fonts.py`

Why:

- already supports 416×416 resource overrides
- outputs Garmin-compatible `.fnt` + PNG bitmap atlases
- alpha-mask glyphs can be tinted with `dc.setColor()`
- avoids inventing a custom font converter

Retain the Christopher Fennell MIT notice in `THIRD_PARTY_NOTICES.md`.

### 2. Garmin official examples

Use Garmin's Apache-2.0 examples as the canonical source when implementing:

- WatchFace lifecycle and low-power callbacks
- settings/preferences
- resource declarations
- device-specific resource paths
- local Garmin data access

When a Garmin example and an unlicensed third-party repo show different patterns, default to Garmin unless the third-party pattern is independently reimplemented from first principles.

### 3. Round-screen layout ideas

Tactical Grid, Burndown, and Gregor are useful for **design/architecture study only**. Their lack of an explicit license means public availability is not permission to copy their source.

## Local reference checkout

Run:

`powershell -ExecutionPolicy Bypass -File scripts/fetch-reference-repos.ps1`

The script clones repositories into `.reference-repos/`, which is gitignored.
