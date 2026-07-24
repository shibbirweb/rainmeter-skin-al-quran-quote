# skin-settings Specification

## Purpose

Let a user personalize the Al-Quran Quote skin from inside the skin itself: change the verse font family,
size, style, and color, the background color and opacity, and how often the verse rotates, without
hand-editing any file. Changes are made in a companion settings panel, persisted to the skin's
`Variables.inc`, and applied to the running skin immediately.

## Requirements

### Requirement: Open and close the settings panel

The skin SHALL provide a visible affordance on the main panel to open a settings panel, and the settings
panel SHALL provide a way to close itself. The open and close controls SHALL render as vector shapes (no
bundled font or image binary) so they display correctly regardless of file encoding. The settings panel
SHALL NOT interfere with the main skin's verse display while open.

#### Scenario: Open settings from the main panel

- **WHEN** the user activates the settings affordance on the main panel
- **THEN** the settings panel is loaded and displayed

#### Scenario: Close the settings panel

- **WHEN** the user activates the close control on the settings panel
- **THEN** the settings panel is deactivated and the main skin continues running unaffected

#### Scenario: Controls display correctly

- **WHEN** the main panel and the settings panel are shown
- **THEN** the open and close controls appear as clean, recognizable icons with no garbled or placeholder
  characters

### Requirement: Setting rows never overlap their controls

Each setting row SHALL lay out its label and its control so the label text never overlaps the value or
control, at the panel's chosen width.

#### Scenario: Long labels stay clear of their controls

- **WHEN** the settings panel is open and shows labels such as "Background opacity" and "Change every"
- **THEN** each label is fully readable and does not visually collide with its control

### Requirement: Choose the font family from a list

The settings panel SHALL let the user pick the verse font family from a curated list of common,
widely-installed fonts instead of typing a font name, and SHALL persist and apply the chosen family to
`QuoteFont`.

#### Scenario: Select a font from the list

- **WHEN** the user opens the font list and clicks a font name
- **THEN** `QuoteFont` is updated to that font, the main skin renders the verse in it, and the change is
  persisted

#### Scenario: Current font is indicated

- **WHEN** the user opens the settings panel
- **THEN** the font family currently in effect is shown as the current selection

### Requirement: Edit font size

The settings panel SHALL let the user change the verse font size within a bounded range
(`MinQuoteSize`-`MaxQuoteSize`) and SHALL persist and apply the chosen size to `QuoteSize`.

#### Scenario: Change the font size

- **WHEN** the user sets a new font size in the settings panel
- **THEN** `QuoteSize` is updated, the verse renders at the new size, and the change is persisted

#### Scenario: Font size stays within bounds

- **WHEN** the user attempts to set a font size below the minimum or above the maximum
- **THEN** the size is clamped to the allowed range and the clamped value is what gets persisted

### Requirement: Edit font style

The settings panel SHALL let the user choose the verse font style from Bold, Regular, and Italic, and
SHALL persist and apply the chosen style to `QuoteStyle`.

#### Scenario: Select a font style

- **WHEN** the user selects one of Bold, Regular, or Italic
- **THEN** `QuoteStyle` is set to that style keyword, the verse renders in the selected style, and the
  active choice is indicated in the panel

### Requirement: Pick the font color with sliders and a live preview

The settings panel SHALL let the user set the verse font color using red, green, blue, and alpha sliders
with a live color preview, and SHALL persist and apply the composed RGBA value to `QuoteColor`.

#### Scenario: Adjust a color channel

- **WHEN** the user moves the red, green, blue, or alpha slider for the font color
- **THEN** the preview swatch updates immediately, `QuoteColor` is updated, and the verse text renders in
  the new color

#### Scenario: Sliders initialize from the current color

- **WHEN** the user opens the settings panel
- **THEN** the font color sliders and preview reflect the color currently stored in `QuoteColor`

#### Scenario: Channels stay within range

- **WHEN** a color channel would go below 0 or above 255
- **THEN** the value is clamped to the 0-255 range before being composed and persisted

### Requirement: Pick the background color with sliders and a live preview

The settings panel SHALL let the user set the panel background color using red, green, and blue sliders
with a live color preview, and SHALL persist and apply the composed RGB value to `PanelColorRGB` while
leaving `PanelOpacity` unchanged.

#### Scenario: Adjust the background color

- **WHEN** the user moves the red, green, or blue slider for the background color
- **THEN** the preview updates, `PanelColorRGB` is updated, the panel renders in the new color, and the
  current opacity is preserved

#### Scenario: Background sliders initialize from the current color

- **WHEN** the user opens the settings panel
- **THEN** the background color sliders and preview reflect the color currently stored in `PanelColorRGB`

### Requirement: Set background opacity with a range control

The settings panel SHALL let the user set the background opacity using a range (slider) control,
independently of the background color, and SHALL persist and apply the value to `PanelOpacity` within its
bounds (`MinPanelOpacity`-`MaxPanelOpacity`).

#### Scenario: Set the opacity with the range

- **WHEN** the user clicks a position on the opacity range or nudges it with the scroll wheel
- **THEN** `PanelOpacity` is updated to the corresponding value within bounds, and the panel renders at the
  new opacity while keeping its color

#### Scenario: Opacity range initializes from the current value

- **WHEN** the user opens the settings panel
- **THEN** the opacity range reflects the value currently stored in `PanelOpacity`

### Requirement: Edit quote change duration

The settings panel SHALL let the user change how often the verse rotates and SHALL persist and apply the
new duration to `RotateEvery`.

#### Scenario: Change the rotation duration

- **WHEN** the user sets a new quote change duration
- **THEN** `RotateEvery` is updated, the verse subsequently rotates on the new interval, and the change is
  persisted

#### Scenario: Duration is a valid positive value

- **WHEN** the user attempts to set a duration that is zero, negative, non-numeric, or out of range
- **THEN** the change is rejected or clamped to the allowed range and a valid value is persisted

### Requirement: Settings persist across restarts

Every setting changed through the panel SHALL be written to `Variables.inc` so that the values survive a
skin refresh and a Rainmeter restart.

#### Scenario: Values survive a restart

- **WHEN** the user changes any setting and later restarts Rainmeter or refreshes the skin
- **THEN** the main skin loads with the last values chosen in the settings panel

### Requirement: Settings panel reflects current values

When opened, the settings panel SHALL display the values currently in effect for each editable setting so
the user sees the current state rather than blank or default controls.

#### Scenario: Panel shows current values on open

- **WHEN** the user opens the settings panel
- **THEN** each control shows the value currently stored in `Variables.inc` for that setting

### Requirement: The settings panel is isolated from the values it edits

The settings panel's own appearance (its fonts, colors, sizes, and opacity) SHALL be driven by a
dedicated settings-UI theme that is separate from the skin's editable variables, so that changing any skin
setting never alters how the settings panel itself looks. Applying a change SHALL update the main skin and
SHALL NOT refresh or rebuild the settings panel.

#### Scenario: Editing the skin does not restyle the settings panel

- **WHEN** the user changes the verse font, size, style, colors, or opacity
- **THEN** the settings panel's own text, layout, colors, and opacity remain exactly as before

#### Scenario: Applying a change does not disrupt the open panel

- **WHEN** the user commits a change from the settings panel
- **THEN** the main skin updates to reflect the change and the settings panel is not refreshed or redrawn
  out from under the user; its controls continue to reflect the current values in place
