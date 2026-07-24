-- Settings.lua : backs the Al-Quran Quote settings panel.
-- Runs in the settings skin (the AlQuranQuote\Settings child config). On open it seeds the panel's own
-- working variables from the parent config's current values. On every change it:
--   1. writes the value to the parent @Resources\Variables.inc (so it persists), and
--   2. applies it to the running MAIN skin (via !SetVariable, without a refresh, so the verse does not
--      refetch), then repaints the panel's previews in place.
-- The settings panel itself is never refreshed, so editing the skin never disturbs the panel.

local mainConfigName = 'AlQuranQuote'

-- Authoritative live state kept in Lua, so we never read back a variable we just set with a queued bang.
local fontColor = { red = 240, green = 240, blue = 240, alpha = 255 }
local backgroundColor = { red = 18, green = 22, blue = 28 }
local fontSize = 13
local backgroundOpacity = 205

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

-- Re-evaluate the panel's meters so previews and labels reflect the working variables. No config refresh.
local function updatePanel()
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end

-- Persist a value to the parent Variables.inc and apply it live to the main skin without refetching.
local function applyAppearance(key, value)
	SKIN:Bang('!WriteKeyValue', 'Variables', key, value, variablesFilePath())
	SKIN:Bang('!SetVariable', key, value, mainConfigName)
	SKIN:Bang('!UpdateMeter', '*', mainConfigName)
	SKIN:Bang('!Redraw', mainConfigName)
end

-- Persist a value and fully refresh the main skin (needed when the WebParser UpdateRate changes).
local function applyWithRefresh(key, value)
	SKIN:Bang('!WriteKeyValue', 'Variables', key, value, variablesFilePath())
	SKIN:Bang('!Refresh', mainConfigName)
end

local function readNumber(variableName)
	return tonumber(SKIN:GetVariable(variableName))
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

-- Seed the panel's working variables from the parent config's current values.
function loadSettings()
	SKIN:Bang('!SetVariable', 'WorkFontFamily', SKIN:GetVariable('QuoteFont'))

	fontSize = clampRound(readNumber('QuoteSize'), readNumber('MinQuoteSize'), readNumber('MaxQuoteSize'))
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)

	backgroundOpacity = clampRound(readNumber('PanelOpacity'), readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity'))
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)

	SKIN:Bang('!SetVariable', 'WorkDuration', SKIN:GetVariable('RotateEvery'))

	local currentFontColor = splitNumbers(SKIN:GetVariable('QuoteColor'))
	fontColor.red = currentFontColor[1] or 240
	fontColor.green = currentFontColor[2] or 240
	fontColor.blue = currentFontColor[3] or 240
	fontColor.alpha = currentFontColor[4] or 255
	SKIN:Bang('!SetVariable', 'FontColorR', fontColor.red)
	SKIN:Bang('!SetVariable', 'FontColorG', fontColor.green)
	SKIN:Bang('!SetVariable', 'FontColorB', fontColor.blue)
	SKIN:Bang('!SetVariable', 'FontColorA', fontColor.alpha)

	local currentBackgroundColor = splitNumbers(SKIN:GetVariable('PanelColorRGB'))
	backgroundColor.red = currentBackgroundColor[1] or 18
	backgroundColor.green = currentBackgroundColor[2] or 22
	backgroundColor.blue = currentBackgroundColor[3] or 28
	SKIN:Bang('!SetVariable', 'BgColorR', backgroundColor.red)
	SKIN:Bang('!SetVariable', 'BgColorG', backgroundColor.green)
	SKIN:Bang('!SetVariable', 'BgColorB', backgroundColor.blue)

	highlightStyle(SKIN:GetVariable('QuoteStyle'))

	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)

	updatePanel()
end

-- ---- Font family ----

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

-- ---- Background color channels ----

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

-- ---- Background opacity (range) ----

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

-- ---- Quote change duration (typed) ----

function setDuration(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	local minimum = readNumber('MinRotateEvery')
	local maximum = readNumber('MaxRotateEvery')
	number = clampRound(number, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkDuration', number)
	applyWithRefresh('RotateEvery', number)
	updatePanel()
end
