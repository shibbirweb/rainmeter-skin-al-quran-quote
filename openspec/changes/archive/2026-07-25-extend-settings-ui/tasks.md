## 1. Variables, defaults and bounds

- [x] 1.1 In `@Resources/Variables.inc`, add `WidthAuto=1`, `FixedWidth` (default = current width),
  `HeightAuto=1`, `FixedHeight`, `AutoChange=1`, `EffectiveRate=1800`, `DefaultPanelWidth=340`, and
  `IconGap`.
- [x] 1.2 Add bounds `MinFixedWidth`/`MaxFixedWidth` and `MinFixedHeight`/`MaxFixedHeight`.
- [x] 1.3 Confirm every tunable that reset touches has a clear default value in `Variables.inc`.

## 2. Main skin wiring

- [x] 2.1 In `AlQuranQuote.ini`, start the verse below the icon: `[MeterQuote]` Y uses
  `#Pad# + #GearIconHeight# + #IconGap#`, so the settings icon no longer overlaps the text.
- [x] 2.2 Change `[MeterPanel]` shape height to the arithmetic select:
  `#HeightAuto# * (autoHeightFormula) + (1 - #HeightAuto#) * #FixedHeight#`, where the auto formula
  includes the new top offset.
- [x] 2.3 Change the WebParser to `UpdateRate=#EffectiveRate#` (gated rotation).
- [x] 2.4 Confirm the panel keeps using `#PanelWidth#` (Lua resolves it from auto/fixed).

## 3. Settings.lua: size, rotation, reset, manual entry

- [x] 3.1 Add a `defaults` table with the canonical default for every tunable.
- [x] 3.2 Add `resetSettings()`: write all defaults to `Variables.inc`, refresh the main skin, and reseed
  the panel via `loadSettings()`.
- [x] 3.3 Add width handling: `toggleWidthAuto()` and `setFixedWidth(value)` that resolve and write
  `PanelWidth` (auto -> `DefaultPanelWidth`; fixed -> clamped `FixedWidth`) and refresh the main skin.
- [x] 3.4 Add height handling: `toggleHeightAuto()` and `setFixedHeight(value)` that write `HeightAuto` /
  clamped `FixedHeight` and refresh the main skin.
- [x] 3.5 Add `toggleAutoChange()` and recompute `EffectiveRate = AutoChange * RotateEvery` (also recompute
  it in `setDuration`), then refresh the main skin.
- [x] 3.6 Add `setBackgroundColorManual(text)` (split, clamp channels, reuse `applyBackgroundColor`) and
  `setOpacityValue(value)` (clamp, reuse the opacity apply path). Manual font reuses `setFont`.
- [x] 3.7 Extend `loadSettings()` to seed the new working variables (`WidthAuto`, `FixedWidth`,
  `HeightAuto`, `FixedHeight`, `AutoChange`) and set the reveal state of the width/height inputs.

## 4. Settings.ini + SettingsTheme.inc

- [x] 4.1 In `SettingsTheme.inc`, add layout metrics for the new blocks and recompute all block base-Y
  values and `SettingsHeight`.
- [x] 4.2 Add a manual font input (InputText) beside the font list; commit calls `setFont`.
- [x] 4.3 Add a manual background-color input (`R,G,B`) beside the sliders; commit calls
  `setBackgroundColorManual`.
- [x] 4.4 Add a manual opacity input beside the range; commit calls `setOpacityValue`.
- [x] 4.5 Add the width row: an "auto" checkbox (`toggleWidthAuto`) and a fixed-width input revealed only
  when auto is off (show/hide group).
- [x] 4.6 Add the height row: an "auto" checkbox (`toggleHeightAuto`) and a fixed-height input revealed
  only when auto is off.
- [x] 4.7 Add the automatic-rotation checkbox (`toggleAutoChange`).
- [x] 4.8 Add a "Reset to defaults" button (`resetSettings`).
- [x] 4.9 Draw checkboxes as vector Shapes (box + check when on); keep files ASCII.

## 5. Docs

- [x] 5.1 Update `CLAUDE.md`: new variables (`WidthAuto`/`FixedWidth`, `HeightAuto`/`FixedHeight`,
  `AutoChange`/`EffectiveRate`), the icon gap, the height arithmetic-select, and the manual-entry inputs.
- [x] 5.2 Record the changes under `[Unreleased]` in `CHANGELOG.md`.

## 6. Verify on Windows

- [ ] 6.1 Reset restores every setting to its default and applies it.
- [ ] 6.2 Width auto vs fixed: unchecking auto reveals the input; a fixed width renders; auto returns to
  default width.
- [ ] 6.3 Height auto vs fixed: unchecking auto reveals the input; a fixed height renders (verse clips);
  auto grows to fit.
- [ ] 6.4 Turning automatic rotation off stops timer changes; clicking still fetches; turning it on
  resumes on the duration.
- [ ] 6.5 The settings icon no longer overlaps the verse.
- [ ] 6.6 Manual font, background `R,G,B`, and opacity inputs each apply and stay in sync with the
  list/sliders.
- [ ] 6.7 Restart Rainmeter and confirm all values persist. Check About -> Log for errors.
