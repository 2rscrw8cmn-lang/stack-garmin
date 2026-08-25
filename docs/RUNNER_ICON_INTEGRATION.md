# STACK Runner Mark — Garmin Integration

## Purpose

`watch-face/artwork/stack-runner-mark.svg` is the canonical source artwork for the one-color STACK runner mark approved for the Garmin watch face.

The SVG is **source artwork**, not the runtime implementation.

For the Forerunner 265 watch face, keep the current lightweight primitive-rendering architecture and trace the approved silhouette into normalized Monkey C geometry. Do not add the SVG directly to the runtime drawable bundle unless profiling proves that a raster/vector resource is clearly better.

## Source of truth

Canonical artwork:

```text
watch-face/artwork/stack-runner-mark.svg
```

Important source characteristics:

- viewBox: `0 0 213.7 234.56`
- one-color silhouette
- two filled paths: body/limbs and head
- no shadow
- no outline
- no internal color separation

The source fill color is not authoritative for the watch-face treatment. The runtime mark should use the metric slot's accent color, currently `StackTheme.BLUE` for steps.

## Where it integrates

Current runtime path:

```text
StackWatchFaceView.drawDataSlot()
  -> StackMetrics.drawIcon()
     -> StackMetrics.runnerIcon()
```

The agent should replace only the geometry inside:

```text
watch-face/source/StackMetrics.mc
function runnerIcon(dc, x, cy, h)
```

Do **not** bypass `StackMetrics` and do not hard-place the runner in `StackWatchFaceView`.

The slot model is intentional: the icon must continue to behave like any other secondary-data mark.

## Required function contract

Keep the existing signature:

```text
function runnerIcon(dc, x, cy, h)
```

The function must:

1. draw entirely from the supplied `x`, `cy`, and `h`
2. scale proportionally with `h`
3. use the color already set by `StackMetrics.drawIcon()`
4. return the horizontal advance needed before the step value is drawn
5. allocate no persistent bitmap/font resource
6. render safely in both high-power and tinted/AOD paths if the slot is ever used there

Recommended return value:

```text
h * 0.92 to h * 1.00
```

Tune from the actual silhouette width after tracing.

## Geometry strategy

### Preferred implementation

Trace the SVG silhouette into a small set of normalized convex polygons plus one head shape.

Use the SVG only as the geometric reference.

Recommended process:

1. Normalize the SVG viewBox to a unit box.
2. Preserve the overall runner pose and silhouette first.
3. Reduce the source to the fewest shapes that still match the mark at 24–32 px.
4. Express every point as a fraction of `h`.
5. Use existing helpers such as `uQuad()` where possible.
6. Add a small polygon helper only if the silhouette genuinely requires more than four points.
7. Avoid sub-pixel micro-details that disappear on the 416 px AMOLED screen.

### Target complexity

Aim for approximately:

- 1 head shape
- 1 torso/left-arm shape
- 1 right-arm shape
- 1 rear-leg/foot shape
- 1 front-leg/foot shape

The exact split may differ from the SVG. Matching the **small-size silhouette** matters more than preserving the original Illustrator path topology.

Do not recreate all original path nodes. The source SVG is intentionally more detailed than the watch-face rendering needs.

## Small-size behavior

Primary target height in OFFSET:

```text
30 px
```

Validate at:

- 24 px
- 28 px
- 30 px
- 32 px
- 36 px

At 30 px the mark must still clearly read as a runner without relying on the adjacent step value.

If detail merges at 24–30 px, simplify the geometry further rather than making strokes thinner.

## Color

Default steps slot:

```text
StackTheme.BLUE
```

Do not bake a color into `runnerIcon()`.

`StackMetrics.drawIcon()` already sets the accent color before calling the mark renderer. This allows the silhouette to be reused or tinted without duplicating artwork.

## Positioning inside the slot

Current OFFSET default:

```text
Slot B
x = 52
center y = 250
mark height = 30 px
```

The runner should visually sit on the same centerline as the step value.

The SVG source is taller than it is wide. When normalizing it, compensate optically so the head does not make the icon appear too high relative to the number.

Do not move Slot B just to make the icon fit. Fix the icon's local normalized bounds first.

## What not to do

Do not:

- load the Illustrator SVG in `onUpdate()`
- introduce a full-color version for the step metric
- add shadows or outlines
- hard-code `StackTheme.BLUE` inside `runnerIcon()`
- move step rendering out of `StackMetrics`
- add a bitmap just because it is faster to implement without checking memory and tint behavior
- reproduce every SVG path point at runtime
- make the mark anatomically detailed

## Optional fallback: resource drawable

If primitive tracing cannot reproduce the approved silhouette cleanly, a resource-based version is acceptable as a second choice.

If using a drawable:

1. create a reduced monochrome asset specifically for Garmin
2. size it only for the needed watch-face resolution range
3. profile steady-state memory before and after
4. confirm it can be tinted or provide only the exact required blue asset
5. keep `StackMetrics.runnerIcon()` as the abstraction boundary
6. do not load/decode the resource on every update

Given the current watch face is only around 15 kB steady-state, there is headroom, but primitives remain preferred because they are scalable and slot-color aware.

## Acceptance criteria

The integration is complete when:

- the step slot uses the approved runner silhouette from `stack-runner-mark.svg`
- it reads clearly at 30 px on the Forerunner 265 simulator
- the adjacent `0`, `6.2K`, etc. remains aligned and readable
- the icon is visibly closer to the approved STACK logo than the existing generic runner primitive
- no new runtime crash is introduced
- no clipping occurs at Slot B across the normal OFFSET composition
- the mark uses the slot-provided accent color
- memory remains comfortably below the 128 KiB watch-face ceiling

## Agent task

Implement the approved runner mark in `StackMetrics.runnerIcon()` using `watch-face/artwork/stack-runner-mark.svg` as the source of truth.

Prioritize silhouette fidelity at 30 px over SVG path fidelity. Keep the existing metric-slot API unchanged. Use normalized primitive geometry where possible. Validate in the Forerunner 265 simulator with both `0` steps and a formatted value such as `6.2K` before considering the task complete.
