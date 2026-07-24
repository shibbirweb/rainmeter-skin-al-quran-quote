## 1. Variables and main-skin wiring

- [x] 1.1 In `@Resources/Variables.inc`, add `QuoteStyle=Italic` and named numeric bounds
  (`MinQuoteSize`, `MaxQuoteSize`, `MinPanelOpacity`, `MaxPanelOpacity`, `MinRotateEvery`).
- [x] 1.2 In `@Resources/Variables.inc`, replace `PanelColor` with `PanelColorRGB=18,22,28` and
  `PanelOpacity=205`; keep defaults visually identical to the current look.
- [x] 1.3 In `AlQuranQuote.ini`, change `[MeterQuote]` to `StringStyle=#QuoteStyle#`.
- [x] 1.4 In `AlQuranQuote.ini`, change `[MeterPanel]` fill to `Fill Color #PanelColorRGB#,#PanelOpacity#`.
- [x] 1.5 In `AlQuranQuote.ini`, add a gear affordance meter (system-font glyph U+2699, tooltip
  "Settings") that toggles the settings skin via a bang.

## 2. Settings persistence helper

- [x] 2.1 Add `@Resources/Scripts/Settings.lua` with a `writeClamped(key, value, minimum, maximum)`
  function that clamps numeric input to the named bounds, then writes it to `Variables.inc` and refreshes
  the main skin.
- [x] 2.2 Add a `writeValue(key, value)` function for non-numeric fields (font family, style, colors).
- [x] 2.3 Keep functions small and single-purpose with descriptive names and no magic numbers, per
  CLAUDE.md.

## 3. Settings panel skin

- [x] 3.1 Create `Settings.ini` with `@IncludeVariables=#@#Variables.inc` and `DynamicVariables=1`, a
  titled panel, and a close control that toggles the skin off.
- [x] 3.2 Add the font family control (InputText) that writes `QuoteFont`.
- [x] 3.3 Add the font size control (InputText, `InputNumber=1`) routed through `writeClamped` for
  `QuoteSize` using `MinQuoteSize`/`MaxQuoteSize`.
- [x] 3.4 Add the font style controls: three buttons (Bold / Regular / Italic) that write `Bold`,
  `Normal`, `Italic` into `QuoteStyle`.
- [x] 3.5 Add the font color control (InputText for `R,G,B,A`) that writes `QuoteColor`.
- [x] 3.6 Add the background color control (InputText for `R,G,B`) that writes `PanelColorRGB`.
- [x] 3.7 Add the background opacity control (InputText, `InputNumber=1`) routed through `writeClamped`
  for `PanelOpacity` using `MinPanelOpacity`/`MaxPanelOpacity`.
- [x] 3.8 Add the quote change duration control (InputText, `InputNumber=1`) routed through
  `writeClamped` for `RotateEvery` using `MinRotateEvery`.
- [x] 3.9 Ensure each control shows the current value on open (via shared variables / DefaultValue).

## 4. Packaging and docs

- [x] 4.1 Confirm `Settings.ini` and `Settings.lua` ship in the `.rmskin` (they live under
  `Skins/AlQuranQuote/`); update `RMSKIN.ini` only if a path or LoadName needs it.
- [x] 4.2 Update `CLAUDE.md` architecture/file list to mention the settings skin and helper.
- [x] 4.3 Record the change under `[Unreleased]` in `CHANGELOG.md` (settings UI; `PanelColor` split into
  `PanelColorRGB` + `PanelOpacity`; new `QuoteStyle`).

## 5. Verify on Windows

- [ ] 5.1 Load the skin, open settings from the gear, and confirm each control shows current values.
- [ ] 5.2 Change font family, size, style, and font color; confirm the verse updates and the values
  persist after a refresh.
- [ ] 5.3 Change background color and opacity independently; confirm the panel updates and opacity does
  not reset color (and vice versa).
- [ ] 5.4 Change the quote change duration; confirm rotation follows the new interval and out-of-range
  numeric input is clamped.
- [ ] 5.5 Restart Rainmeter and confirm all chosen values reload. Check About -> Log for errors.
