## ADDED Requirements

### Requirement: Open and close controls render as vector icons

The open (main panel) and close (settings panel) controls SHALL render as vector Shape-drawn icons rather
than font glyphs, so they display correctly regardless of file encoding and without any bundled font or
image binary. Any skin file that still contains non-ASCII characters SHALL be saved as UTF-8 with a byte
order mark.

#### Scenario: Icons display correctly

- **WHEN** the main panel and the settings panel are shown
- **THEN** the open control and the close control appear as clean, recognizable icons with no garbled or
  placeholder characters

#### Scenario: Close control still closes the panel

- **WHEN** the user activates the close icon on the settings panel
- **THEN** the settings panel is deactivated and the main skin continues running unaffected

### Requirement: Setting rows never overlap their controls

Each setting row SHALL lay out its label and its control so the label text never overlaps the value or
control, at the panel's chosen width.

#### Scenario: Long labels stay clear of their controls

- **WHEN** the settings panel is open and shows labels such as "Background opacity" and "Change every"
- **THEN** each label is fully readable and does not visually collide with its control

### Requirement: Choose the font family from a list

The settings panel SHALL let the user pick the verse font family from a curated list of common,
widely-installed fonts instead of typing a font name, and SHALL persist and apply the chosen family.

#### Scenario: Select a font from the list

- **WHEN** the user opens the font list and clicks a font name
- **THEN** the `QuoteFont` variable in `Variables.inc` is updated to that font, the main skin is
  refreshed, and the verse renders in the selected font

#### Scenario: Current font is indicated

- **WHEN** the user opens the font list
- **THEN** the font family currently in effect is shown as the current selection

### Requirement: Pick the font color with sliders and a live preview

The settings panel SHALL let the user set the verse font color using red, green, blue, and alpha sliders
with a live color preview, and SHALL persist and apply the composed RGBA value to `QuoteColor`.

#### Scenario: Adjust a color channel

- **WHEN** the user moves the red, green, blue, or alpha slider for the font color
- **THEN** the preview swatch updates immediately to the composed color, the `QuoteColor` variable is
  updated, and the verse text renders in the new color

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
- **THEN** the preview updates, `PanelColorRGB` is updated, the main panel renders in the new color, and
  the current opacity is preserved

#### Scenario: Background sliders initialize from the current color

- **WHEN** the user opens the settings panel
- **THEN** the background color sliders and preview reflect the color currently stored in `PanelColorRGB`

### Requirement: Set background opacity with a range control

The settings panel SHALL let the user set the background opacity using a range (slider) control rather
than a typed number, and SHALL persist and apply the value to `PanelOpacity` within its bounds.

#### Scenario: Drag or click the opacity range

- **WHEN** the user drags the opacity handle or clicks a position on the opacity range
- **THEN** `PanelOpacity` is updated to the corresponding value within `MinPanelOpacity`-`MaxPanelOpacity`,
  and the main panel renders at the new opacity while keeping its color

#### Scenario: Opacity range initializes from the current value

- **WHEN** the user opens the settings panel
- **THEN** the opacity range handle reflects the value currently stored in `PanelOpacity`

### Requirement: The settings panel is isolated from the values it edits

The settings panel's own appearance (its fonts, colors, sizes, and opacity) SHALL be driven by a
dedicated settings-UI theme that is separate from the skin's editable variables, so that changing any
skin setting never alters how the settings panel itself looks. Applying a change SHALL update the main
skin only and SHALL NOT refresh or rebuild the settings panel.

#### Scenario: Editing the skin does not restyle the settings panel

- **WHEN** the user changes the verse font, size, style, colors, or opacity
- **THEN** the settings panel's own text, layout, colors, and opacity remain exactly as before

#### Scenario: Applying a change does not disrupt the open panel

- **WHEN** the user commits a change from the settings panel
- **THEN** the main skin updates to reflect the change and the settings panel is not refreshed or
  redrawn out from under the user; its controls continue to reflect the current values in place
