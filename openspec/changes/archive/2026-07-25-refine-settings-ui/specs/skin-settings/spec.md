## ADDED Requirements

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

### Requirement: Set the rounded border opacity

The settings panel SHALL let the user set the opacity of the panel's rounded border independently of the
border color, and SHALL persist and apply it within bounds.

#### Scenario: Change the border opacity

- **WHEN** the user sets a new border opacity in the settings panel
- **THEN** the border-opacity value is persisted and the panel border renders at the new opacity while
  keeping its color

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

### Requirement: Change the verse from a dedicated control

The skin SHALL provide a small control next to the verse reference that fetches the next verse when
clicked. Clicking elsewhere in the quote window SHALL NOT change the verse.

#### Scenario: Change the verse with the control

- **WHEN** the user clicks the next-verse control next to the reference
- **THEN** the skin fetches and displays the next verse

#### Scenario: Clicking the window does not change the verse

- **WHEN** the user clicks the quote window outside the next-verse control
- **THEN** the displayed verse does not change

## MODIFIED Requirements

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
