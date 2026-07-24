-- Verse.lua : push a verse into the skin's display variables.

-- Set the quote text and verse key, then repaint. The reference line is composed in the meter as
-- "#ReferenceLabel# #VerseKey#", so the label stays editable and updates live.
function applyVerse(quoteText, verseKey)
	if quoteText == nil then
		quoteText = ''
	end
	if verseKey == nil then
		verseKey = ''
	end
	SKIN:Bang('!SetVariable', 'QuoteText', quoteText)
	SKIN:Bang('!SetVariable', 'VerseKey', verseKey)
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end
