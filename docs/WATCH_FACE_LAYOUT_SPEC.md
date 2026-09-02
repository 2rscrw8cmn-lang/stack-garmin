# STACK Hero Time — Forerunner 265 Layout Spec

Target canvas: **416×416 round AMOLED**.

This is an implementation guide, not a requirement to hard-code every coordinate. Use normalized/relative anchors where practical.

## Safe zones

| Zone | Approx. bounds | Purpose |
|---|---|---|
| Outer ring | radius ~184–192 px | segmented daily-step progress |
| Top utility | y 42–72 | day/date + battery |
| Hero time | y 78–205 | Skomelr Quantum HH:MM |
| Trainer Boi | y 205–300 | centered brand anchor |
| Metric shelf | y 302–382 | three compact data slots |
| Bottom breathing room | y 382–410 | optional tiny accent blocks only |

Do not place important text in the extreme circular corners.

## Hero time

Reference time for layout testing: `10:08`.

Also test:

- `1:11`
- `7:38`
- `8:11`
- `10:48`
- `11:59`
- `12:47`
- `23:59` in 24-hour mode

The implementation must measure glyph widths and center the composite hour + colon + minute group optically.

Recommended 416 px hero font target: roughly **88–98 px**, tuned from the generated Skomelr atlas.

Draw hour, colon, and minute separately to allow independent colors.

## Trainer Boi

Default active target height: **~82 px**.

Start centered around x=208, with the full figure entirely below the hero time and above the metric shelf.

Do not trace him into a generic block person. Preserve the actual full-color character silhouette and color separation.

## Step ring

Recommended:

- 14–18 segments
- arc width ~6–8 px
- bottom opening of roughly 55–75 degrees
- filled count = rounded fraction of `steps / stepGoal`
- clamp at 100%; do not overflow unless a later deliberate over-goal treatment is designed

Default multicolor order should use the canonical STACK palette and repeat predictably. Empty segments use dark charcoal.

## Top utility row

Keep metadata roughly 12–15 px equivalent and quiet.

- day/date left of center
- battery right of center
- a tiny colored square/block may separate them

Do not add a top STACK wordmark.

## Metrics

Use three equal-ish visual zones, but avoid putting each metric inside a rounded card.

Recommended anchors:

- left x ≈ 90
- center x ≈ 208
- right x ≈ 326

Metric number size: roughly **28–34 px** Skomelr.

Unit/label: 10–12 px system/mono font or a compact graphic mark.

The metrics may use different accent colors, but the numeric values should remain highly legible.

## Active reference

`docs/screenshots/watch-face-v2-reference.png`

This reference was generated with the actual Skomelr demo font and the actual Trainer Boi SVG to lock the visual direction. It is a design reference, not a literal screenshot from the Garmin simulator.

## AOD reference

`docs/screenshots/watch-face-v2-aod-reference.png`

AOD intentionally removes the ring, Trainer Boi, and lower metrics.
