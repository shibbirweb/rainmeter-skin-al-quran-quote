## ADDED Requirements

### Requirement: Reset all settings to defaults

The settings panel SHALL provide a control that resets every editable setting to its default value,
persists the defaults to `Variables.inc`, and applies them to the running skin.

#### Scenario: Reset restores defaults

- **WHEN** the user activates the reset control
- **THEN** every editable setting (font family, size, style, colors, background color and opacity, width,
  height, rotation duration, automatic rotation) is set to its default value, persisted, and applied, and
  the settings panel reflects the defaults

### Requirement: Set the panel width

The settings panel SHALL let the user choose between automatic width and a fixed width. When automatic is
selected the panel SHALL size its width automatically; when automatic is deselected the panel SHALL use a
user-entered fixed width in pixels, within bounds.

#### Scenario: Use automatic width

- **WHEN** the user selects the width "auto" option
- **THEN** the panel width is determined automatically and no fixed-width input is required

#### Scenario: Set a fixed width

- **WHEN** the user deselects "auto" and enters a fixed width
- **THEN** an input for the width is shown, the entered value (clamped to its bounds) is persisted, and the
  panel renders at that width

### Requirement: Set the panel height

The settings panel SHALL let the user choose between automatic height and a fixed height. When automatic is
selected the panel SHALL grow to fit the verse; when automatic is deselected the panel SHALL use a
user-entered fixed height in pixels, within bounds.

#### Scenario: Use automatic height

- **WHEN** the user selects the height "auto" option
- **THEN** the panel height grows to fit the verse and no fixed-height input is required

#### Scenario: Set a fixed height

- **WHEN** the user deselects "auto" and enters a fixed height
- **THEN** an input for the height is shown, the entered value (clamped to its bounds) is persisted, and
  the panel renders at that height

### Requirement: Toggle automatic verse rotation

The settings panel SHALL let the user turn automatic verse rotation on or off. When off, the verse SHALL
NOT change on the timer; clicking the panel SHALL still fetch the next verse.

#### Scenario: Disable automatic rotation

- **WHEN** the user turns automatic rotation off
- **THEN** the verse no longer changes on the timer and stays on the current verse until the panel is
  clicked

#### Scenario: Enable automatic rotation

- **WHEN** the user turns automatic rotation on
- **THEN** the verse resumes changing on the configured rotation duration

### Requirement: Settings icon does not overlap the verse

The settings icon on the main panel SHALL be positioned so it does not overlap the verse text, with a
visible gap between the icon and the text.

#### Scenario: Icon is clear of the verse

- **WHEN** the main panel shows a verse
- **THEN** the settings icon is fully visible and does not overlap the verse text

## MODIFIED Requirements

### Requirement: Pick the font color with sliders and a live preview

The settings panel SHALL let the user set the verse font color using red, green, blue, and alpha sliders
with a live color preview, and SHALL also let the user type an `R,G,B` or `R,G,B,A` value directly. Either
method SHALL persist and apply the composed RGBA value to `QuoteColor`.

#### Scenario: Adjust a color channel

- **WHEN** the user moves the red, green, blue, or alpha slider for the font color
- **THEN** the preview swatch updates immediately, `QuoteColor` is updated, and the verse text renders in
  the new color

#### Scenario: Type an R,G,B(,A) value

- **WHEN** the user enters an `R,G,B` or `R,G,B,A` value in the manual font-color input
- **THEN** each supplied channel is clamped to 0-255 (alpha is left unchanged if omitted), `QuoteColor` is
  updated, and the preview and verse render in the new color

#### Scenario: Sliders initialize from the current color

- **WHEN** the user opens the settings panel
- **THEN** the font color sliders and preview reflect the color currently stored in `QuoteColor`

#### Scenario: Channels stay within range

- **WHEN** a color channel would go below 0 or above 255
- **THEN** the value is clamped to the 0-255 range before being composed and persisted

### Requirement: Choose the font family from a list

The settings panel SHALL let the user pick the verse font family from a curated list of common,
widely-installed fonts, and SHALL also let the user type a font name directly. Either method SHALL persist
and apply the chosen family to `QuoteFont`.

#### Scenario: Select a font from the list

- **WHEN** the user opens the font list and clicks a font name
- **THEN** `QuoteFont` is updated to that font, the main skin renders the verse in it, and the change is
  persisted

#### Scenario: Type a font name

- **WHEN** the user enters a font name in the manual font input
- **THEN** `QuoteFont` is updated to the entered name, the main skin renders the verse in it, and the
  change is persisted

#### Scenario: Current font is indicated

- **WHEN** the user opens the settings panel
- **THEN** the font family currently in effect is shown as the current selection

### Requirement: Pick the background color with sliders and a live preview

The settings panel SHALL let the user set the panel background color using red, green, and blue sliders
with a live color preview, and SHALL also let the user type an `R,G,B` value directly. Either method SHALL
persist and apply the composed RGB value to `PanelColorRGB` while leaving `PanelOpacity` unchanged.

#### Scenario: Adjust the background color

- **WHEN** the user moves the red, green, or blue slider for the background color
- **THEN** the preview updates, `PanelColorRGB` is updated, the panel renders in the new color, and the
  current opacity is preserved

#### Scenario: Type an R,G,B value

- **WHEN** the user enters an `R,G,B` value in the manual background-color input
- **THEN** each channel is clamped to 0-255, `PanelColorRGB` is updated, the preview and panel render in
  the new color, and the current opacity is preserved

#### Scenario: Background sliders initialize from the current color

- **WHEN** the user opens the settings panel
- **THEN** the background color sliders and preview reflect the color currently stored in `PanelColorRGB`

### Requirement: Set background opacity with a range control

The settings panel SHALL let the user set the background opacity using a range (slider) control,
independently of the background color, and SHALL also let the user type the opacity value directly. Either
method SHALL persist and apply the value to `PanelOpacity` within its bounds
(`MinPanelOpacity`-`MaxPanelOpacity`).

#### Scenario: Set the opacity with the range

- **WHEN** the user clicks a position on the opacity range or nudges it with the scroll wheel
- **THEN** `PanelOpacity` is updated to the corresponding value within bounds, and the panel renders at the
  new opacity while keeping its color

#### Scenario: Type an opacity value

- **WHEN** the user enters an opacity value in the manual opacity input
- **THEN** the value is clamped to its bounds, `PanelOpacity` is updated, and the panel renders at the new
  opacity while keeping its color

#### Scenario: Opacity range initializes from the current value

- **WHEN** the user opens the settings panel
- **THEN** the opacity range reflects the value currently stored in `PanelOpacity`
