-- Verse.lua : push a verse into the skin's display variables.

-- Set the quote + reference variables, then repaint the skin.
function applyVerse(quoteText, reference)
	if quoteText == nil then
		quoteText = ''
	end
	if reference == nil then
		reference = ''
	end
	SKIN:Bang('!SetVariable', 'QuoteText', quoteText)
	SKIN:Bang('!SetVariable', 'RefText', reference)
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end
