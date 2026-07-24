# skin-settings Specification

## Purpose

Let a user personalize the Al-Quran Quote skin from inside the skin itself: change the verse font family,
size, style, and color, the background color and opacity, the panel width and height, and how often the
verse rotates (or whether it rotates at all), plus reset everything to defaults, without hand-editing any
file. Changes are made in a companion settings panel, persisted to the skin's `Variables.inc`, and applied
to the running skin immediately.

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
control, at the panel's chosen width. Checkboxes SHALL be vertically aligned with their adjacent labels.

#### Scenario: Long labels stay clear of their controls

- **WHEN** the settings panel is open and shows labels such as "Background opacity" and "Change every"
- **THEN** each label is fully readable and does not visually collide with its control

#### Scenario: Checkboxes align with their labels

- **WHEN** the settings panel shows a checkbox and its label (for example the width/height "auto" or the
  automatic-rotation checkbox)
- **THEN** the checkbox and its label text are vertically aligned

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
SHALL persist and apply the chosen style to `QuoteStyle`. The default font style SHALL be Regular.

#### Scenario: Select a font style

- **WHEN** the user selects one of Bold, Regular, or Italic
- **THEN** `QuoteStyle` is set to that style keyword, the verse renders in the selected style, and the
  active choice is indicated in the panel

#### Scenario: Default font style

- **WHEN** the skin is installed with defaults (or the user resets)
- **THEN** the verse font style is Regular

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

### Requirement: Set the rounded border opacity

The settings panel SHALL let the user set the opacity of the panel's rounded border independently of the
border color, and SHALL persist and apply it within bounds.

#### Scenario: Change the border opacity

- **WHEN** the user sets a new border opacity in the settings panel
- **THEN** the border-opacity value is persisted and the panel border renders at the new opacity while
  keeping its color

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
NOT change on the timer; the next-verse control SHALL still fetch the next verse. Toggling this setting
SHALL NOT itself change the currently displayed verse.

#### Scenario: Disable automatic rotation

- **WHEN** the user turns automatic rotation off
- **THEN** the verse no longer changes on the timer and stays on the current verse until the next-verse
  control is used

#### Scenario: Enable automatic rotation

- **WHEN** the user turns automatic rotation on
- **THEN** the verse resumes changing on the configured rotation duration

#### Scenario: Toggling does not refetch

- **WHEN** the user turns automatic rotation on or off
- **THEN** the currently displayed verse does not change as a result of the toggle

### Requirement: Show or hide the settings icon

The settings panel SHALL let the user show or hide the settings icon on the quote window via a checkbox,
and SHALL persist and apply the choice. When the icon is hidden, the settings panel can be reopened by
loading the settings skin from Rainmeter.

#### Scenario: Hide the settings icon

- **WHEN** the user unchecks "show settings icon"
- **THEN** the settings icon is hidden on the quote window and the choice persists across a refresh

#### Scenario: Show the settings icon

- **WHEN** the user checks "show settings icon"
- **THEN** the settings icon is shown on the quote window

### Requirement: Settings icon does not overlap the verse

The settings icon on the main panel SHALL be positioned so it does not overlap the verse text, with a
visible gap between the icon and the text.

#### Scenario: Icon is clear of the verse

- **WHEN** the main panel shows a verse
- **THEN** the settings icon is fully visible and does not overlap the verse text

### Requirement: Change the verse from a dedicated control

The skin SHALL provide a small control next to the verse reference that fetches the next verse when
clicked. Clicking elsewhere in the quote window SHALL NOT change the verse.

#### Scenario: Change the verse with the control

- **WHEN** the user clicks the next-verse control next to the reference
- **THEN** the skin fetches and displays the next verse

#### Scenario: Clicking the window does not change the verse

- **WHEN** the user clicks the quote window outside the next-verse control
- **THEN** the displayed verse does not change

### Requirement: Edit quote change duration

The settings panel SHALL let the user change how often the verse rotates and SHALL persist and apply the
new duration to `RotateEvery`. Changing the duration SHALL NOT itself change the currently displayed verse.

#### Scenario: Change the rotation duration

- **WHEN** the user sets a new quote change duration
- **THEN** `RotateEvery` is updated, the verse subsequently rotates on the new interval, and the change is
  persisted

#### Scenario: Duration is a valid positive value

- **WHEN** the user attempts to set a duration that is zero, negative, non-numeric, or out of range
- **THEN** the change is rejected or clamped to the allowed range and a valid value is persisted

### Requirement: Customize the reference label

The settings panel SHALL let the user change the label shown before the verse reference, and SHALL persist
and apply it. The default label SHALL be "Al Quran" (so the reference reads, for example, "Al Quran
6:124"). The label SHALL apply to both online and offline verses.

#### Scenario: Change the reference label

- **WHEN** the user enters a new reference label in the settings panel
- **THEN** the label is persisted and the verse reference immediately renders with the new label followed
  by the verse key

#### Scenario: Default label

- **WHEN** the skin is installed with defaults (or the user resets)
- **THEN** the reference label is "Al Quran"

### Requirement: Reset all settings to defaults

The settings panel SHALL provide a control that resets every editable setting to its default value,
persists the defaults to `Variables.inc`, and applies them to the running skin.

#### Scenario: Reset restores defaults

- **WHEN** the user activates the reset control
- **THEN** every editable setting (font family, size, style, colors, background color and opacity, width,
  height, rotation duration, automatic rotation) is set to its default value, persisted, and applied, and
  the settings panel reflects the defaults

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
