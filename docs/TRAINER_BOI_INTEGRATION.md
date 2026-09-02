# Trainer Boi — Garmin Integration

## Canonical asset

Use:

`watch-face/artwork/trainer-boi-full-color.svg`

This is the same canonical full-color runner artwork used by the main `stack-run` repository.

Do not replace it with:

- a generic running icon
- a single-color approximation unless the user selects Mono
- a traced stick figure
- an AI-generated character

## Color source

The SVG itself is the source of truth for the Trainer Boi palette.

Primary colors include:

- `#0CB9FC`
- `#02BCC0`
- `#0A66DA`
- `#FCBC12`
- `#FC9809`
- `#FD4E2E`
- `#65FC04`
- `#8537DF`
- `#4C229E`

## Garmin runtime strategy

Do not assume the source SVG can simply be dropped into the runtime unchanged.

Preferred order:

1. keep the canonical SVG as source artwork in `watch-face/artwork/`
2. generate a Garmin-appropriate raster drawable at the exact needed size(s)
3. load/cache the drawable once rather than decoding on every `onUpdate()`
4. profile memory on the Forerunner 265

Because the active face intentionally uses Trainer Boi as a full-color brand element, a small optimized raster resource is preferable to recreating all of the SVG path geometry in Monkey C.

Target active size: roughly 72–90 px high at 416×416.

## User setting

`trainerBoiMode`

- `fullColor` — default active state
- `mono` — simplified/tinted version
- `off`

AOD default: off.

## Acceptance criteria

- figure is recognizably the exact STACK Trainer Boi
- colors match the canonical asset
- no clipping at the chosen active size
- resource is loaded outside the hot draw path where possible
- memory remains within the Forerunner 265 watch-face budget
