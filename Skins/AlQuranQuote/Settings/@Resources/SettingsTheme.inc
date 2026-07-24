[Variables]
; Settings panel theme, layout and working state. This file is the settings UI's OWN configuration and is
; deliberately separate from the skin's @Resources\Variables.inc, so editing the skin (font, colors, etc.)
; never changes how this panel looks. Block base-Y values stack the rows top to bottom; if you change a
; height, recompute the ones below it.

; ---- Panel look ----
; Two-column layout: the left column starts at Pad, the right at Col2X. Slider-based controls live in the
; left column (their X positions are width-relative); flat controls (labels, inputs, checkboxes) go right.
SettingsWidth=616
SettingsHeight=424
Col1X=16
Col2X=316
Pad=16
Radius=12
SettingsBg=24,28,34,245
SettingsBorder=255,255,255,30
SettingsTitleColor=245,245,245,255
SettingsLabelColor=175,182,193,255
SettingsTextColor=235,235,235,255
SettingsInactiveColor=150,156,166,255
SettingsActiveColor=120,200,255,255
SettingsInputBg=20,24,30,255
SettingsFont=Segoe UI
SettingsFontSize=11
SettingsTitleSize=13
SettingsSmallSize=9

; ---- Slider component ----
SliderChannelLabelX=16
SliderX=34
SliderWidth=210
SliderValueX=284
SliderH=10
SliderYOffset=3
SliderTrackColor=60,66,76,255
SliderFillColor=120,200,255,255
CornerRadius=4
; Scroll-wheel steps (positive up, negative down) for the sliders.
ChannelStep=5
NegChannelStep=-5
SizeStep=1
NegSizeStep=-1
OpacityStep=5
NegOpacityStep=-5

; ---- Layout metrics ----
LabelH=18
RowH=20
ChannelH=20
InputH=18
ContentW=268
StyleButtonWidth=56
CloseBoxSize=10
PreviewX=210
PreviewW=74
PreviewH=16

; ---- Checkboxes and reset button ----
CheckboxSize=14
CheckboxTextX=38
CheckboxColor=175,182,193,255
CheckboxCheckRGB=120,200,255
ResetButtonW=584
ResetButtonH=26
ResetButtonBg=60,66,76,255
ResetButtonColor=235,235,235,255

; ---- Tabs ----
; The settings are split into three tabs so the panel stays short. Only one tab's meters are shown at a
; time (Settings.lua's setTab hides the other Tab groups); every tab's blocks stack from ContentTopY, so
; the base-Y values below repeat that start per tab. ActiveTab and the Tab*Color values are seeded by Lua.
ActiveTab=1
TabBarY=42
TabH=26
TabGap=6
TabW=190
Tab1X=16
Tab2X=212
Tab3X=408
Tab1Color=120,200,255,255
Tab2Color=150,156,166,255
Tab3Color=150,156,166,255
ContentTopY=78

; ---- Block base-Y positions (each tab is two columns, each column stacks from ContentTopY) ----
; Tab 1 (Text): left column = size + color (sliders); right column = family + style.
SizeBaseY=78
FontColorBaseY=126
FamilyBaseY=78
StyleBaseY=152
; Tab 2 (Panel): left column = background color + background/border opacity (sliders); right column =
; width + height + settings icon.
BgColorBaseY=78
OpacityBaseY=186
BorderOpacityBaseY=256
WidthBaseY=78
HeightBaseY=148
ShowIconBaseY=218
; Tab 3 (Verse): left column = rotation + duration + online fetch + reference label + show toggles; right
; column = custom verse + custom text + sura + verse + open fallback file.
RotateToggleBaseY=78
DurationBaseY=126
OnlineFetchBaseY=174
ReferenceLabelBaseY=222
ShowReferenceLabelBaseY=270
ShowVerseNumberBaseY=318
CustomVerseBaseY=78
CustomTextBaseY=126
SuraNumberBaseY=174
VerseNumberBaseY=222
OpenFallbackBaseY=270
; Reset button, shown on every tab at the bottom (below the tallest column across all tabs).
ResetBaseY=380

; ---- Curated font list (overlay on the Text tab, below the font family row) ----
FontListTop=116
FontItemH=22
FontCount=10
ItemInset=8
ListVPad=4
Font1=Georgia
Font2=Segoe UI
Font3=Arial
Font4=Calibri
Font5=Cambria
Font6=Times New Roman
Font7=Consolas
Font8=Verdana
Font9=Tahoma
Font10=Trebuchet MS

; ---- Working state (seeded from the skin's current values by Settings.lua on open) ----
FontListVisible=0
WorkFontFamily=Georgia
WorkFontSize=13
WorkStyle=Italic
WorkDuration=1800
WorkOpacity=205
WorkBorderOpacity=25
WorkReferenceLabel=Al Quran
WorkCustomText=
WorkSuraNumber=
WorkVerseNumber=
FontColorR=240
FontColorG=240
FontColorB=240
FontColorA=255
BgColorR=18
BgColorG=22
BgColorB=28
BoldColor=150,156,166,255
RegularColor=150,156,166,255
ItalicColor=150,156,166,255
