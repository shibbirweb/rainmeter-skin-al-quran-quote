-- Verse.lua : push a verse into the skin's display variables.

-- Build the reference line from the label, the verse key and the two show toggles. Kept as one composed
-- string (not "#ReferenceLabel# #VerseKey#" in the meter) so either part can be hidden and a lone label
-- has no trailing space, which keeps it centered when there is no number. Global so RandomAyah.lua can use
-- it too. The verseKey is passed in (never read back right after it is set with a queued bang).
function composeReferenceText(verseKey)
	local showLabel = tonumber(SKIN:GetVariable('ShowReferenceLabel')) == 1
	local showNumber = tonumber(SKIN:GetVariable('ShowVerseNumber')) == 1

	local labelPart = ''
	if showLabel then
		labelPart = SKIN:GetVariable('ReferenceLabel')
	end

	local keyPart = ''
	if showNumber and verseKey ~= nil and verseKey ~= '' then
		keyPart = verseKey
	end

	if labelPart ~= '' and keyPart ~= '' then
		return labelPart .. ' ' .. keyPart
	end
	if labelPart ~= '' then
		return labelPart
	end
	return keyPart
end

-- Set the quote text and verse key, compose the reference, then repaint.
function applyVerse(quoteText, verseKey)
	if quoteText == nil then
		quoteText = ''
	end
	if verseKey == nil then
		verseKey = ''
	end
	SKIN:Bang('!SetVariable', 'QuoteText', quoteText)
	SKIN:Bang('!SetVariable', 'VerseKey', verseKey)
	SKIN:Bang('!SetVariable', 'RefText', composeReferenceText(verseKey))
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end

-- Recompose the reference from the CURRENT verse key without touching the quote, used when only the label
-- or a show toggle changed so the displayed verse must not move. VerseKey is read here (it was set on a
-- previous call, not in this one, so the value is current).
function refreshReference()
	local verseKey = SKIN:GetVariable('VerseKey')
	SKIN:Bang('!SetVariable', 'RefText', composeReferenceText(verseKey))
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end
