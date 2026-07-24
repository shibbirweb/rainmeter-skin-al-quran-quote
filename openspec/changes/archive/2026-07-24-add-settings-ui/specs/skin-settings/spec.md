## ADDED Requirements

### Requirement: Open and close the settings panel

The skin SHALL provide a visible affordance on the main panel to open a settings panel, and the
settings panel SHALL provide a way to close itself. The settings panel SHALL NOT interfere with the
main skin's verse display while open.

#### Scenario: Open settings from the main panel

- **WHEN** the user activates the settings affordance on the main panel (for example clicks the gear
  control or selects "Settings" from the skin's context menu)
- **THEN** the settings panel is loaded and displayed

#### Scenario: Close the settings panel

- **WHEN** the user activates the close control on the settings panel
- **THEN** the settings panel is hidden or unloaded and the main skin continues running unaffected

### Requirement: Edit font family

The settings panel SHALL let the user change the verse font family and SHALL persist the chosen family
to `Variables.inc` and apply it to the running skin.

#### Scenario: Change the font family

- **WHEN** the user enters or selects a font family in the settings panel
- **THEN** the corresponding font variable in `Variables.inc` is updated with `!WriteKeyValue`, the main
  skin is refreshed, and the verse renders in the chosen font family

### Requirement: Edit font size

The settings panel SHALL let the user change the verse font size within a bounded range and SHALL
persist and apply the chosen size.

#### Scenario: Change the font size

- **WHEN** the user sets a new font size in the settings panel
- **THEN** the font size variable in `Variables.inc` is updated, the main skin is refreshed, and the
  verse renders at the new size

#### Scenario: Font size stays within bounds

- **WHEN** the user attempts to set a font size below the minimum or above the maximum
- **THEN** the size is clamped to the allowed range and the clamped value is what gets persisted

### Requirement: Edit font style

The settings panel SHALL let the user choose the verse font style from Bold, Regular, and Italic, and
SHALL persist and apply the chosen style.

#### Scenario: Select a font style

- **WHEN** the user selects one of Bold, Regular, or Italic in the settings panel
- **THEN** the font style variable in `Variables.inc` is set to that style, the main skin is refreshed,
  and the verse renders in the selected style

### Requirement: Edit font color

The settings panel SHALL let the user change the verse font color and SHALL persist and apply the chosen
color as an RGBA value.

#### Scenario: Change the font color

- **WHEN** the user chooses or enters a new font color in the settings panel
- **THEN** the font color variable in `Variables.inc` is updated with the RGBA value, the main skin is
  refreshed, and the verse text renders in the chosen color

### Requirement: Edit background color

The settings panel SHALL let the user change the background (panel) color and SHALL persist and apply
the chosen color, preserving the separately configured background opacity.

#### Scenario: Change the background color

- **WHEN** the user chooses or enters a new background color in the settings panel
- **THEN** the background color variable in `Variables.inc` is updated, the main skin is refreshed, and
  the panel renders in the chosen color at the current opacity

### Requirement: Edit background opacity

The settings panel SHALL let the user change the background opacity independently of the background color
and SHALL persist and apply the chosen opacity within a valid range.

#### Scenario: Change the background opacity

- **WHEN** the user sets a new background opacity in the settings panel
- **THEN** the background opacity variable in `Variables.inc` is updated, the main skin is refreshed, and
  the panel renders at the new opacity while keeping its color

#### Scenario: Opacity stays within bounds

- **WHEN** the user attempts to set an opacity outside the valid range (0 to 255, or 0 to 100 percent)
- **THEN** the opacity is clamped to the valid range before being persisted

### Requirement: Edit quote change duration

The settings panel SHALL let the user change how often the verse rotates and SHALL persist and apply the
new rotation duration.

#### Scenario: Change the rotation duration

- **WHEN** the user sets a new quote change duration in the settings panel
- **THEN** the rotation variable in `Variables.inc` is updated, the main skin is refreshed, and the verse
  subsequently rotates on the new interval

#### Scenario: Duration is a positive value

- **WHEN** the user attempts to set a duration that is zero, negative, or non-numeric
- **THEN** the change is rejected or clamped to the minimum allowed duration and a valid value is
  persisted

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
