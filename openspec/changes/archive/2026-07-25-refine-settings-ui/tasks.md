## 1. Variables and defaults

- [x] 1.1 In `@Resources/Variables.inc`, add `ReferenceLabel=Al Quran` and `VerseKey=` (runtime).
- [x] 1.2 Replace `PanelBorder` with `PanelBorderRGB=255,255,255` and `PanelBorderOpacity=25`.
- [x] 1.3 Add `SettingsIconHidden=0`.
- [x] 1.4 Change the default `QuoteStyle` to `Normal` (Regular).

## 2. Main skin (AlQuranQuote.ini)

- [x] 2.1 Render the reference as `#ReferenceLabel# #VerseKey#` (DynamicVariables) instead of `#RefText#`.
- [x] 2.2 Change the panel border stroke to `Stroke Color #PanelBorderRGB#,#PanelBorderOpacity#`.
- [x] 2.3 Bind the settings icon meter to `Hidden=#SettingsIconHidden#` (DynamicVariables).
- [x] 2.4 Remove the `LeftMouseUpAction` from `[MeterPanel]` (full-window click no longer changes verse).
- [x] 2.5 Add a small next-verse control (vector Shape "next" triangle) on the reference line at the right;
  `LeftMouseUpAction=[!CommandMeasure MeasureQuran "Update"]`, tooltip "Next verse".

## 3. Verse scripts

- [x] 3.1 In `Verse.lua`, change `applyVerse` to set `QuoteText` and `VerseKey` (second arg is the key).
- [x] 3.2 In `RandomAyah.lua` `Online()`, pass the WebParser verse key.
- [x] 3.3 In `RandomAyah.lua` `Offline()`, extract the key from the bundled reference via
  `string.match(reference, '%d+:%d+')`, falling back to the raw reference if no match.

## 4. Settings.lua

- [x] 4.1 Add `setReferenceLabel(text)` (persist + apply live to main).
- [x] 4.2 Add border-opacity handlers: `setBorderOpacityPercent`, `nudgeBorderOpacity`, and
  `setBorderOpacityValue`, clamped to `MinPanelOpacity`-`MaxPanelOpacity`, applied live.
- [x] 4.3 Add `toggleShowIcon()` that flips `SettingsIconHidden`, persists, and applies live to main.
- [x] 4.4 Update the `defaults` table (`QuoteStyle=Normal`, `ReferenceLabel=Al Quran`,
  `PanelBorderRGB`/`PanelBorderOpacity`, `SettingsIconHidden=0`) and extend `seedWorkingState`/
  `loadSettings` to seed the new working variables.

## 5. Settings.ini + SettingsTheme.inc

- [x] 5.1 Add a reference-label text input (click-to-type) with a label.
- [x] 5.2 Add a border-opacity slider + value + manual entry (reuse the slider component).
- [x] 5.3 Add a "show settings icon" checkbox bound to `SettingsIconHidden`.
- [x] 5.4 Vertically center every checkbox label at `Y = checkboxY + (#CheckboxSize# - #SettingsFontSize#) / 2`.
- [x] 5.5 Recompute block base-Y metrics and `SettingsHeight` for the added rows.

## 6. Docs

- [x] 6.1 Update `CLAUDE.md` (reference composition, border split, icon show/hide, next-verse control,
  default style Regular).
- [x] 6.2 Record the changes under `[Unreleased]` in `CHANGELOG.md`.

## 7. Verify on Windows

- [x] 7.1 Reference shows "Al Quran X:Y"; editing the label updates it live for online and offline verses.
- [x] 7.2 Border opacity changes the border alpha without changing its color.
- [x] 7.3 Show/hide icon works and persists; when hidden, the panel reopens by loading the settings skin
  from Rainmeter.
- [x] 7.4 Checkbox and label are vertically aligned.
- [x] 7.5 The next-verse control fetches a new verse; clicking elsewhere in the window does not.
- [x] 7.6 A fresh install / Reset shows Regular font style. Restart Rainmeter; values persist. Check the
  log for errors.
