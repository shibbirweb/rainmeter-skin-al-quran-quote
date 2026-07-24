[Variables]
; Settings panel theme, layout and working state. This file is the settings UI's OWN configuration and is
; deliberately separate from the skin's @Resources\Variables.inc, so editing the skin (font, colors, etc.)
; never changes how this panel looks. Block base-Y values stack the rows top to bottom; if you change a
; height, recompute the ones below it.

; ---- Panel look ----
SettingsWidth=300
SettingsHeight=824
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
ResetButtonW=268
ResetButtonH=26
ResetButtonBg=60,66,76,255
ResetButtonColor=235,235,235,255

; ---- Block base-Y positions (top of each setting block; stacked top to bottom) ----
FamilyBaseY=44
SizeBaseY=116
StyleBaseY=166
FontColorBaseY=216
BgColorBaseY=348
OpacityBaseY=458
WidthBaseY=530
HeightBaseY=602
RotateToggleBaseY=674
DurationBaseY=724
ResetBaseY=774

; ---- Curated font list ----
FontListTop=82
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
