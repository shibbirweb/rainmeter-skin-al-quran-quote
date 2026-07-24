-- Settings.lua : backs the Al-Quran Quote settings panel.
-- Runs in the settings skin (the AlQuranQuote\Settings child config). On open it seeds the panel's own
-- working variables from the parent config's current values. On every change it:
--   1. writes the value to the parent @Resources\Variables.inc (so it persists), and
--   2. applies it to the running MAIN skin (via !SetVariable, without a refresh, so the verse does not
--      refetch), then repaints the panel's previews in place.
-- The settings panel itself is never refreshed, so editing the skin never disturbs the panel.
-- Exceptions that DO refresh the main skin: rotation changes (RotateEvery/AutoChange feed the WebParser
-- UpdateRate, which is only read at load) and Reset.

local mainConfigName = 'AlQuranQuote'

-- Authoritative live state kept in Lua, so we never read back a variable we just set with a queued bang.
local fontColor = { red = 240, green = 240, blue = 240, alpha = 255 }
local backgroundColor = { red = 18, green = 22, blue = 28 }
local fontSize = 13
local backgroundOpacity = 205
local borderOpacity = 25
local autoChange = 1
local rotateEvery = 1800

-- Canonical defaults for Reset. Mirrors the initial values in the skin's Variables.inc.
local defaults = {
	QuoteFont = 'Georgia',
	QuoteSize = 13,
	QuoteStyle = 'Normal',
	QuoteColor = '240,240,240,255',
	PanelColorRGB = '18,22,28',
	PanelOpacity = 205,
	PanelBorderRGB = '255,255,255',
	PanelBorderOpacity = 25,
	ReferenceLabel = 'Al Quran',
	SettingsIconHidden = 0,
	RotateEvery = 1800,
	AutoChange = 1,
	WidthAuto = 1,
	FixedWidth = 340,
	HeightAuto = 1,
	FixedHeight = 160,
	PanelWidth = 340,
}

function Initialize()
	loadSettings()
end

function Update()
	return 1
end

-- Full path to the parent config's Variables.inc (ROOTCONFIGPATH points at the main skin folder).
local function variablesFilePath()
	return SKIN:GetVariable('ROOTCONFIGPATH') .. '@Resources\\Variables.inc'
end

-- Split "12,34,56[,78]" into a list of numbers.
local function splitNumbers(text)
	local numbers = {}
	if text == nil then
		return numbers
	end
	for token in string.gmatch(text, '([^,]+)') do
		numbers[#numbers + 1] = tonumber(token)
	end
	return numbers
end

-- Round to the nearest integer and clamp to [minimum, maximum].
local function clampRound(value, minimum, maximum)
	local number = tonumber(value)
	if number == nil then
		return minimum
	end
	number = math.floor(number + 0.5)
	if number < minimum then
		number = minimum
	end
	if number > maximum then
		number = maximum
	end
	return number
end

local function readNumber(variableName)
	return tonumber(SKIN:GetVariable(variableName))
end

-- Re-evaluate the panel's meters so previews and labels reflect the working variables. No config refresh.
local function updatePanel()
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end

-- Write one key to the parent Variables.inc (persist only).
local function persist(key, value)
	SKIN:Bang('!WriteKeyValue', 'Variables', key, value, variablesFilePath())
end

-- Persist a value and apply it live to the main skin without refetching a verse.
local function applyAppearance(key, value)
	persist(key, value)
	SKIN:Bang('!SetVariable', key, value, mainConfigName)
	SKIN:Bang('!UpdateMeter', '*', mainConfigName)
	SKIN:Bang('!Redraw', mainConfigName)
end

-- ---- Color helpers ----

local function applyFontColor()
	SKIN:Bang('!SetVariable', 'FontColorR', fontColor.red)
	SKIN:Bang('!SetVariable', 'FontColorG', fontColor.green)
	SKIN:Bang('!SetVariable', 'FontColorB', fontColor.blue)
	SKIN:Bang('!SetVariable', 'FontColorA', fontColor.alpha)
	local composed = fontColor.red .. ',' .. fontColor.green .. ',' .. fontColor.blue .. ',' .. fontColor.alpha
	applyAppearance('QuoteColor', composed)
	updatePanel()
end

local function applyBackgroundColor()
	SKIN:Bang('!SetVariable', 'BgColorR', backgroundColor.red)
	SKIN:Bang('!SetVariable', 'BgColorG', backgroundColor.green)
	SKIN:Bang('!SetVariable', 'BgColorB', backgroundColor.blue)
	local composed = backgroundColor.red .. ',' .. backgroundColor.green .. ',' .. backgroundColor.blue
	applyAppearance('PanelColorRGB', composed)
	updatePanel()
end

-- Color sliders report position as a percentage (0-100); map it to a 0-255 channel value.
local function channelFromPercent(percent)
	return clampRound(tonumber(percent) / 100 * 255, 0, 255)
end

-- Set which font-style button is highlighted as active.
local function highlightStyle(styleKeyword)
	local inactive = SKIN:GetVariable('SettingsInactiveColor')
	local active = SKIN:GetVariable('SettingsActiveColor')
	local boldColor = inactive
	local regularColor = inactive
	local italicColor = inactive
	if styleKeyword == 'Bold' then
		boldColor = active
	elseif styleKeyword == 'Normal' then
		regularColor = active
	elseif styleKeyword == 'Italic' then
		italicColor = active
	end
	SKIN:Bang('!SetVariable', 'BoldColor', boldColor)
	SKIN:Bang('!SetVariable', 'RegularColor', regularColor)
	SKIN:Bang('!SetVariable', 'ItalicColor', italicColor)
end

-- ---- Size / rotation apply helpers ----

-- Resolve the effective panel width (auto -> default; fixed -> clamped) and apply it to the main skin.
local function resolveAndApplyWidth(widthAuto, fixedWidth)
	local resolved
	if widthAuto == 1 then
		resolved = readNumber('DefaultPanelWidth')
	else
		resolved = clampRound(fixedWidth, readNumber('MinFixedWidth'), readNumber('MaxFixedWidth'))
	end
	applyAppearance('PanelWidth', resolved)
end

-- Apply height mode + fixed height to the main skin (the shape formula selects the branch).
local function applyHeight(heightAuto, fixedHeight)
	persist('HeightAuto', heightAuto)
	persist('FixedHeight', fixedHeight)
	SKIN:Bang('!SetVariable', 'HeightAuto', heightAuto, mainConfigName)
	SKIN:Bang('!SetVariable', 'FixedHeight', fixedHeight, mainConfigName)
	SKIN:Bang('!UpdateMeter', '*', mainConfigName)
	SKIN:Bang('!Redraw', mainConfigName)
end

-- Recompute EffectiveRate (AutoChange * RotateEvery; 0 pauses rotation), persist it, and refresh the main
-- skin so the WebParser picks up the new UpdateRate. A refresh re-downloads a verse; this is the reliable
-- Rainmeter way to change the WebParser's download timer.
local function applyRotation()
	local effective = autoChange * rotateEvery
	persist('AutoChange', autoChange)
	persist('RotateEvery', rotateEvery)
	persist('EffectiveRate', effective)
	SKIN:Bang('!Refresh', mainConfigName)
end

-- ---- Seeding (shared by load and reset) ----

-- Push a complete settings state into the panel's working variables and reveal/hide dependent controls.
local function seedWorkingState(state)
	fontColor.red = state.fontColor.red
	fontColor.green = state.fontColor.green
	fontColor.blue = state.fontColor.blue
	fontColor.alpha = state.fontColor.alpha
	backgroundColor.red = state.bgColor.red
	backgroundColor.green = state.bgColor.green
	backgroundColor.blue = state.bgColor.blue
	fontSize = state.fontSizeValue
	backgroundOpacity = state.opacity
	borderOpacity = state.borderOpacity
	autoChange = state.autoChangeValue
	rotateEvery = state.duration

	SKIN:Bang('!SetVariable', 'WorkFontFamily', state.fontFamily)
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)
	SKIN:Bang('!SetVariable', 'WorkStyle', state.style)
	SKIN:Bang('!SetVariable', 'WorkDuration', rotateEvery)
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	SKIN:Bang('!SetVariable', 'WorkReferenceLabel', state.referenceLabel)
	SKIN:Bang('!SetVariable', 'SettingsIconHidden', state.iconHidden)
	SKIN:Bang('!SetVariable', 'FontColorR', fontColor.red)
	SKIN:Bang('!SetVariable', 'FontColorG', fontColor.green)
	SKIN:Bang('!SetVariable', 'FontColorB', fontColor.blue)
	SKIN:Bang('!SetVariable', 'FontColorA', fontColor.alpha)
	SKIN:Bang('!SetVariable', 'BgColorR', backgroundColor.red)
	SKIN:Bang('!SetVariable', 'BgColorG', backgroundColor.green)
	SKIN:Bang('!SetVariable', 'BgColorB', backgroundColor.blue)
	SKIN:Bang('!SetVariable', 'WidthAuto', state.widthAuto)
	SKIN:Bang('!SetVariable', 'FixedWidth', state.fixedWidth)
	SKIN:Bang('!SetVariable', 'HeightAuto', state.heightAuto)
	SKIN:Bang('!SetVariable', 'FixedHeight', state.fixedHeight)
	SKIN:Bang('!SetVariable', 'AutoChange', state.autoChangeValue)

	highlightStyle(state.style)

	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	if state.widthAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'WidthInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'WidthInput')
	end
	if state.heightAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'HeightInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'HeightInput')
	end

	updatePanel()
end

-- Seed the panel from the parent config's current values (called on open).
function loadSettings()
	local fontColorParts = splitNumbers(SKIN:GetVariable('QuoteColor'))
	local backgroundColorParts = splitNumbers(SKIN:GetVariable('PanelColorRGB'))
	seedWorkingState({
		fontFamily = SKIN:GetVariable('QuoteFont'),
		fontSizeValue = clampRound(readNumber('QuoteSize'), readNumber('MinQuoteSize'), readNumber('MaxQuoteSize')),
		style = SKIN:GetVariable('QuoteStyle'),
		duration = readNumber('RotateEvery'),
		opacity = clampRound(readNumber('PanelOpacity'), readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity')),
		borderOpacity = clampRound(readNumber('PanelBorderOpacity'), readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity')),
		referenceLabel = SKIN:GetVariable('ReferenceLabel'),
		iconHidden = tonumber(SKIN:GetVariable('SettingsIconHidden')) or 0,
		fontColor = {
			red = fontColorParts[1] or 240,
			green = fontColorParts[2] or 240,
			blue = fontColorParts[3] or 240,
			alpha = fontColorParts[4] or 255,
		},
		bgColor = {
			red = backgroundColorParts[1] or 18,
			green = backgroundColorParts[2] or 22,
			blue = backgroundColorParts[3] or 28,
		},
		widthAuto = tonumber(SKIN:GetVariable('WidthAuto')) or 1,
		fixedWidth = readNumber('FixedWidth') or 340,
		heightAuto = tonumber(SKIN:GetVariable('HeightAuto')) or 1,
		fixedHeight = readNumber('FixedHeight') or 160,
		autoChangeValue = tonumber(SKIN:GetVariable('AutoChange')) or 1,
	})
end

-- ---- Font family (list + manual) ----

function toggleFontList()
	local visible = tonumber(SKIN:GetVariable('FontListVisible'))
	if visible == 1 then
		SKIN:Bang('!HideMeterGroup', 'FontList')
		SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	else
		SKIN:Bang('!ShowMeterGroup', 'FontList')
		SKIN:Bang('!SetVariable', 'FontListVisible', 1)
	end
	SKIN:Bang('!Redraw')
end

function setFont(fontName)
	SKIN:Bang('!SetVariable', 'WorkFontFamily', fontName)
	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	applyAppearance('QuoteFont', fontName)
	updatePanel()
end

-- ---- Font size (slider) ----

function setFontSizePercent(percent)
	local minimum = readNumber('MinQuoteSize')
	local maximum = readNumber('MaxQuoteSize')
	fontSize = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)
	applyAppearance('QuoteSize', fontSize)
	updatePanel()
end

function nudgeFontSize(step)
	local minimum = readNumber('MinQuoteSize')
	local maximum = readNumber('MaxQuoteSize')
	fontSize = clampRound(fontSize + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)
	applyAppearance('QuoteSize', fontSize)
	updatePanel()
end

-- ---- Font style ----

function setStyle(styleKeyword)
	SKIN:Bang('!SetVariable', 'WorkStyle', styleKeyword)
	highlightStyle(styleKeyword)
	applyAppearance('QuoteStyle', styleKeyword)
	updatePanel()
end

-- ---- Font color channels (percent is 0-100 from a slider; step is signed from the scroll wheel) ----

function setFontColorChannel(component, percent)
	local value = channelFromPercent(percent)
	if component == 'r' then
		fontColor.red = value
	elseif component == 'g' then
		fontColor.green = value
	elseif component == 'b' then
		fontColor.blue = value
	elseif component == 'a' then
		fontColor.alpha = value
	end
	applyFontColor()
end

function nudgeFontColorChannel(component, step)
	if component == 'r' then
		fontColor.red = clampRound(fontColor.red + step, 0, 255)
	elseif component == 'g' then
		fontColor.green = clampRound(fontColor.green + step, 0, 255)
	elseif component == 'b' then
		fontColor.blue = clampRound(fontColor.blue + step, 0, 255)
	elseif component == 'a' then
		fontColor.alpha = clampRound(fontColor.alpha + step, 0, 255)
	end
	applyFontColor()
end

-- Manual font color entry: "R,G,B" or "R,G,B,A". Alpha is kept unchanged if not supplied.
function setFontColorManual(text)
	local parts = splitNumbers(text)
	if #parts < 3 then
		return
	end
	fontColor.red = clampRound(parts[1], 0, 255)
	fontColor.green = clampRound(parts[2], 0, 255)
	fontColor.blue = clampRound(parts[3], 0, 255)
	if parts[4] ~= nil then
		fontColor.alpha = clampRound(parts[4], 0, 255)
	end
	applyFontColor()
end

-- ---- Background color channels (sliders) + manual R,G,B entry ----

function setBackgroundColorChannel(component, percent)
	local value = channelFromPercent(percent)
	if component == 'r' then
		backgroundColor.red = value
	elseif component == 'g' then
		backgroundColor.green = value
	elseif component == 'b' then
		backgroundColor.blue = value
	end
	applyBackgroundColor()
end

function nudgeBackgroundColorChannel(component, step)
	if component == 'r' then
		backgroundColor.red = clampRound(backgroundColor.red + step, 0, 255)
	elseif component == 'g' then
		backgroundColor.green = clampRound(backgroundColor.green + step, 0, 255)
	elseif component == 'b' then
		backgroundColor.blue = clampRound(backgroundColor.blue + step, 0, 255)
	end
	applyBackgroundColor()
end

function setBackgroundColorManual(text)
	local parts = splitNumbers(text)
	if #parts < 3 then
		return
	end
	backgroundColor.red = clampRound(parts[1], 0, 255)
	backgroundColor.green = clampRound(parts[2], 0, 255)
	backgroundColor.blue = clampRound(parts[3], 0, 255)
	applyBackgroundColor()
end

-- ---- Background opacity (range) + manual entry ----

function setOpacityPercent(percent)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	backgroundOpacity = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	applyAppearance('PanelOpacity', backgroundOpacity)
	updatePanel()
end

function nudgeOpacity(step)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	backgroundOpacity = clampRound(backgroundOpacity + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	applyAppearance('PanelOpacity', backgroundOpacity)
	updatePanel()
end

function setOpacityValue(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	backgroundOpacity = clampRound(number, readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity'))
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	applyAppearance('PanelOpacity', backgroundOpacity)
	updatePanel()
end

-- ---- Panel width (auto / fixed) ----

function toggleWidthAuto()
	local widthAuto = tonumber(SKIN:GetVariable('WidthAuto'))
	if widthAuto == 1 then
		widthAuto = 0
	else
		widthAuto = 1
	end
	SKIN:Bang('!SetVariable', 'WidthAuto', widthAuto)
	persist('WidthAuto', widthAuto)
	if widthAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'WidthInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'WidthInput')
	end
	resolveAndApplyWidth(widthAuto, readNumber('FixedWidth'))
	updatePanel()
end

function setFixedWidth(value)
	local number = clampRound(value, readNumber('MinFixedWidth'), readNumber('MaxFixedWidth'))
	SKIN:Bang('!SetVariable', 'FixedWidth', number)
	persist('FixedWidth', number)
	resolveAndApplyWidth(tonumber(SKIN:GetVariable('WidthAuto')), number)
	updatePanel()
end

-- ---- Panel height (auto / fixed) ----

function toggleHeightAuto()
	local heightAuto = tonumber(SKIN:GetVariable('HeightAuto'))
	if heightAuto == 1 then
		heightAuto = 0
	else
		heightAuto = 1
	end
	SKIN:Bang('!SetVariable', 'HeightAuto', heightAuto)
	if heightAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'HeightInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'HeightInput')
	end
	applyHeight(heightAuto, readNumber('FixedHeight'))
	updatePanel()
end

function setFixedHeight(value)
	local number = clampRound(value, readNumber('MinFixedHeight'), readNumber('MaxFixedHeight'))
	SKIN:Bang('!SetVariable', 'FixedHeight', number)
	applyHeight(tonumber(SKIN:GetVariable('HeightAuto')), number)
	updatePanel()
end

-- ---- Automatic rotation + duration ----

function toggleAutoChange()
	if autoChange == 1 then
		autoChange = 0
	else
		autoChange = 1
	end
	-- Update the panel's own checkbox variable, then apply the new rotation rate to the main skin.
	SKIN:Bang('!SetVariable', 'AutoChange', autoChange)
	applyRotation()
	updatePanel()
end

function setDuration(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	rotateEvery = clampRound(number, readNumber('MinRotateEvery'), readNumber('MaxRotateEvery'))
	SKIN:Bang('!SetVariable', 'WorkDuration', rotateEvery)
	applyRotation()
	updatePanel()
end

-- ---- Reference label ----

function setReferenceLabel(text)
	SKIN:Bang('!SetVariable', 'WorkReferenceLabel', text)
	applyAppearance('ReferenceLabel', text)
	updatePanel()
end

-- ---- Border opacity (range + manual) ----

function setBorderOpacityPercent(percent)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	borderOpacity = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	applyAppearance('PanelBorderOpacity', borderOpacity)
	updatePanel()
end

function nudgeBorderOpacity(step)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	borderOpacity = clampRound(borderOpacity + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	applyAppearance('PanelBorderOpacity', borderOpacity)
	updatePanel()
end

function setBorderOpacityValue(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	borderOpacity = clampRound(number, readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity'))
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	applyAppearance('PanelBorderOpacity', borderOpacity)
	updatePanel()
end

-- ---- Settings icon visibility ----

function toggleShowIcon()
	local hidden = tonumber(SKIN:GetVariable('SettingsIconHidden'))
	if hidden == 1 then
		hidden = 0
	else
		hidden = 1
	end
	SKIN:Bang('!SetVariable', 'SettingsIconHidden', hidden)
	applyAppearance('SettingsIconHidden', hidden)
	updatePanel()
end

-- ---- Reset ----

function resetSettings()
	for key, value in pairs(defaults) do
		persist(key, value)
	end
	persist('EffectiveRate', defaults.AutoChange * defaults.RotateEvery)
	SKIN:Bang('!Refresh', mainConfigName)

	local fontColorParts = splitNumbers(defaults.QuoteColor)
	local backgroundColorParts = splitNumbers(defaults.PanelColorRGB)
	seedWorkingState({
		fontFamily = defaults.QuoteFont,
		fontSizeValue = defaults.QuoteSize,
		style = defaults.QuoteStyle,
		duration = defaults.RotateEvery,
		opacity = defaults.PanelOpacity,
		borderOpacity = defaults.PanelBorderOpacity,
		referenceLabel = defaults.ReferenceLabel,
		iconHidden = defaults.SettingsIconHidden,
		fontColor = {
			red = fontColorParts[1],
			green = fontColorParts[2],
			blue = fontColorParts[3],
			alpha = fontColorParts[4],
		},
		bgColor = {
			red = backgroundColorParts[1],
			green = backgroundColorParts[2],
			blue = backgroundColorParts[3],
		},
		widthAuto = defaults.WidthAuto,
		fixedWidth = defaults.FixedWidth,
		heightAuto = defaults.HeightAuto,
		fixedHeight = defaults.FixedHeight,
		autoChangeValue = defaults.AutoChange,
	})
end
