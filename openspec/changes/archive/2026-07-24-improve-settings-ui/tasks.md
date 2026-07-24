## 1. Settings-UI theme (decoupling)

- [x] 1.1 Create `Settings/@Resources/SettingsTheme.inc` holding only the panel's own look: fonts, sizes,
  text/label/panel colors, panel background and opacity, slider track/fill/handle colors, and named
  layout/block/slider metrics (no magic numbers).
- [x] 1.2 Add the curated font list to `SettingsTheme.inc` as a named list (e.g. Georgia, Segoe UI, Arial,
  Calibri, Cambria, Times New Roman, Consolas, Verdana, Tahoma, Trebuchet MS).
- [x] 1.3 In `Settings.ini`, include the theme via `@IncludeVariables=#@#SettingsTheme.inc` and the parent
  tunables via `@IncludeVariables2=#ROOTCONFIGPATH#@Resources\Variables.inc`; style the panel only from
  the theme.

## 2. Encoding-proof icons

- [x] 2.1 In `AlQuranQuote.ini`, replace the gear String glyph with a Shape "sliders" icon (three
  horizontal lines with small ellipse knobs); keep the toggle action and "Settings" tooltip.
- [x] 2.2 In `Settings.ini`, replace the close String glyph with a Shape "X" (two crossing lines); keep
  the `!DeactivateConfig` action and "Close" tooltip.
- [x] 2.3 Ensure any `.ini` that still contains non-ASCII text is saved as UTF-8 with a BOM.

## 3. Layout fix (no overlap)

- [x] 3.1 Rework `Settings.ini` into a vertical stack of blocks (label line above its control), full panel
  width, using the named block metrics so labels never overlap controls.
- [x] 3.2 Recompute the panel height/background from the block metrics.

## 4. Reusable slider component

- [x] 4.1 Build a slider as track + fill + handle Shapes bound to a value variable and a named range.
- [x] 4.2 Add click-to-set: clicking the track sets the value from the click position (Rainmeter
  mouse-position action variable), clamped to the range; confirm the exact mouse variable against the
  Rainmeter docs.
- [x] 4.3 Add scroll-to-nudge: `MouseScrollUpAction` / `MouseScrollDownAction` change the value by a named
  step, clamped to the range.

## 5. Color picker (font + background)

- [x] 5.1 In `Settings.lua`, add `loadColorComponents` to parse `QuoteColor` into `FontColorR/G/B/A` and
  `PanelColorRGB` into `BgColorR/G/B` on panel open (called from `Initialize`).
- [x] 5.2 Add font-color sliders (R, G, B, A) using the slider component bound to the `FontColor*` working
  variables, with a live preview swatch (Shape filled from the working variables).
- [x] 5.3 Add background-color sliders (R, G, B) bound to the `BgColor*` working variables, with a live
  preview swatch.
- [x] 5.4 In `Settings.lua`, add helpers that compose `FontColor*` back into `QuoteColor` and `BgColor*`
  into `PanelColorRGB`, write to `Variables.inc`, and refresh the main skin only.
- [x] 5.5 Wire each channel's change to update the preview/fills in place (`!UpdateMeter` + `!Redraw` on the
  settings skin) with no settings-config refresh.

## 6. Opacity range and font list

- [x] 6.1 Replace the opacity InputText with the slider component bound to `PanelOpacity`
  (`MinPanelOpacity`-`MaxPanelOpacity`).
- [x] 6.2 Replace the font-family InputText with a click-to-open overlay list of the curated fonts
  (`FontListVisible` toggles `Hidden`); clicking a name writes `QuoteFont`, applies to the main skin, and
  hides the list.
- [x] 6.3 Show the current font family (and highlight it in the list) via a settings-owned display
  variable, updated in place.

## 7. Decouple apply path and remaining controls

- [x] 7.1 Change `Settings.lua` so no writer refreshes the settings config; each writer refreshes the main
  skin and updates settings display/working variables in place.
- [x] 7.2 Make font size a slider (consistent with the color/opacity sliders), keep duration as InputText
  and font style as three buttons, and reflect each control's current value through settings-owned working
  variables updated on commit (no self-refresh).
- [x] 7.3 Confirm changing any skin value leaves the settings panel's own fonts, colors, layout, and
  opacity unchanged.

## 8. Docs

- [x] 8.1 Update `CLAUDE.md`: settings-UI theme file, Shape icons + UTF-8 BOM rule, color-slider/opacity
  range/font-list controls, and the no-self-refresh apply path.
- [x] 8.2 Record the changes under `[Unreleased]` in `CHANGELOG.md`.

## 9. Verify on Windows

- [ ] 9.1 Confirm the open and close icons render correctly (no garbled characters).
- [ ] 9.2 Confirm no label overlaps any control at the panel width.
- [ ] 9.3 Pick a font from the list; confirm the verse updates.
- [ ] 9.4 Adjust font-color and background-color sliders; confirm the preview and the main skin update and
  the color persists.
- [ ] 9.5 Set opacity with the range (click and scroll); confirm the panel opacity changes and the color is
  preserved.
- [ ] 9.6 Change several skin values and confirm the settings panel's own appearance never changes and is
  not refreshed out from under you.
- [ ] 9.7 Restart Rainmeter and confirm all values persist. Check About -> Log for errors.
