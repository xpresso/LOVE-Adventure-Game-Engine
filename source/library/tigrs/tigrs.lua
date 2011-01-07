--[[

Copyright (C) 2010 Andre Leiradella

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source
distribution.

-------------------------------------------------------------------------------

CHANGELOG

tigrs-1.1

* Now uses LÖVE's built-in font.
* The rating configuration is now embededd in the tigrs.lua file.
* Got rid of "require" to release memory when the rating is no longer used.

tigrs-1.0

* First public release.

-------------------------------------------------------------------------------

INSTRUCTIONS

Unpack tigrs/* onto your game's root folder.

Edit the comments below to suit your needs, leaving exactly one line
uncommented in each section. To generate the rating box, write:

	tigrs = love.filesystem.load( 'tigrs/tigrs.lua' )()

To draw the logo, write:

  tigrs:draw( x, y )

If x is nil, the logo is horizontally centered. If y is nil, the logo is
vertically centered.

The TIGRS (TM) name, logo, and ratings are trademarks of Daniel Kinney.

DO NOT CHANGE THE SHORT DESCRIPTIONS. DOING SO WILL VOID YOUR RIGHT TO USE THE
TIGRS (TM) RATING LOGO. SEE http://www.tigrs.org/?page=specs

]]

local tigrs = {}

-- EDIT AFTER THIS LINE -------------------------------------------------------

------------
-- Rating --
------------

-- tigrs.rating = 'Family friendly'
tigrs.rating = 'Teen content'
-- tigrs.rating = 'Adult content'

--------------
-- Violence --
--------------

-- Cartoon Violence

-- tigrs.cartoon_violence = nil -- None
tigrs.cartoon_violence = 'Mild Cartoon Violence' -- Depictions of cartoon-like characters in unsafe situations
-- tigrs.cartoon_violence = 'Cartoon Violence' -- Depictions of cartoon-like characters in aggressive conflict
-- tigrs.cartoon_violence = 'Intense Cartoon Violence' -- Graphic depictions of violence involving cartoon-like characters

-- Fantasy Violence

-- tigrs.fantasy_violence = nil -- None
-- tigrs.fantasy_violence = 'Mild Fantasy Violence' -- Depictions of characters in unsafe situations easily distinguishable from real life
tigrs.fantasy_violence = 'Fantasy Violence' -- Depictions of characters in aggressive conflict easily distinguishable from real life
-- tigrs.fantasy_violence = 'Intense Fantasy Violence' -- Graphic depictions of violence involving situations easily distinguishable from real life

-- Realistic Violence

tigrs.realistic_violence = nil -- None
-- tigrs.realistic_violence = 'Mild Realistic Violence' -- Mild depictions of realistic characters in unsafe situations
-- tigrs.realistic_violence = 'Realistic Violence' -- Depictions of realistic characters in aggressive conflict
-- tigrs.realistic_violence = 'Intense Realistic Violence' -- Graphic depictions of violence involving realistic characters

-- Bloodshed

tigrs.bloodshed = nil -- None
-- tigrs.bloodshed = 'Animated Bloodshed' -- Unrealistic depictions of bloodshed
-- tigrs.bloodshed = 'Realistic Bloodshed' -- Realistic depictions of bloodshed
-- tigrs.bloodshed = 'Blood and Gore' -- Depictions of bloodshed and the mutilation of body parts

-- Sexual Violence

tigrs.sexual_violence = nil -- None
-- tigrs.sexual_violence = 'Sexual Violence' -- Depictions of or graphic references to rape or other violent sexual behavior

-------------------
-- Alcohol/Drugs --
-------------------

-- Alcohol

-- tigrs.alcohol = nil -- None
-- tigrs.alcohol = 'Alcohol Reference' -- References to or images of alcoholic beverages
tigrs.alcohol = 'Alcohol Use' -- Use of alcoholic beverages

-- Drugs

tigrs.drugs = nil -- None
-- tigrs.drugs = 'Drug Reference' -- References to or images of illicit drugs
-- tigrs.drugs = 'Drug Use' -- Use of illicit drugs

-- Tobacco

tigrs.tobacco = nil -- None
-- tigrs.tobacco = 'Tobacco Reference' -- References to or images of tobacco products
-- tigrs.tobacco = 'Tobacco Use' -- Use of tobacco products

----------------
-- Sex/Nudity --
----------------

-- Nudity

-- tigrs.nudity = nil -- None
-- tigrs.nudity = 'Brief Nudity' -- Brief depictions of nudity or artistic nudity
tigrs.nudity = 'Nudity' -- Prolonged depictions of nudity

-- Sexual Themes

-- tigrs.sexual_themes = nil -- None
tigrs.sexual_themes = 'Suggestive Themes' -- Provocative references or depictions
-- tigrs.sexual_themes = 'Sexual Themes' -- Sexual references or depictions
-- tigrs.sexual_themes = 'Strong Sexual Content' -- Graphic depictions of sexual behavior

-- Sexual Violence

tigrs.sexual_violence = nil -- None
-- tigrs.sexual_violence = 'Sexual Violence' -- Depictions of or graphic references to rape or other violent sexual behavior

-------------------
-- Miscellaneous --
-------------------

-- Language

-- tigrs.language = nil -- None
-- tigrs.language = 'Mild Language' -- Mild or infrequent use of profanity
tigrs.language = 'Moderate Language' -- Moderate use of profanity
-- tigrs.language = 'Strong Language' -- Strong or frequent use of profanity

-- Humor

-- tigrs.humor = nil -- None
tigrs.humor = 'Comical Shenanigans' -- Depictions of or dialog including slapstick humor
-- tigrs.humor = 'Crass Humor' -- Depictions of or dialog including vulgar humor; bathroom humor
-- tigrs.humor = 'Mature Humor' -- Depictions of or dialog including mature humor; sexual humor

-- Gambling

-- tigrs.gambling = nil -- None
tigrs.gambling = 'Simulated Gambling' -- Player can gamble using "play" money
-- tigrs.gambling = 'Real Gambling' -- Player can gamble using real money

-- DO NOT EDIT BELOW THIS LINE ------------------------------------------------

-- Rating.
if tigrs.rating == 'Family friendly' then
	tigrs.rating = love.graphics.newImage( 'source/library/tigrs/tigrs-horizontal-family-crystal.png' )
elseif tigrs.rating == 'Teen content' then
	tigrs.rating = love.graphics.newImage( 'source/library/tigrs/tigrs-horizontal-teen-gradient.png' )
else -- if tigrs.rating == 'Adult content' then
	tigrs.rating = love.graphics.newImage( 'source/library/tigrs/tigrs-horizontal-adult-crystal.png' )
end

-- Cartoon violence.
if tigrs.cartoon_violence then
	tigrs[ #tigrs + 1 ] = tigrs.cartoon_violence
end

-- Fantasy Violence
if tigrs.fantasy_violence then
	tigrs[ #tigrs + 1 ] = tigrs.fantasy_violence
end

-- Realistic Violence
if tigrs.realistic_violence then
	tigrs[ #tigrs + 1 ] = tigrs.realistic_violence
end

-- Bloodshed
if tigrs.bloodshed then
	tigrs[ #tigrs + 1 ] = tigrs.bloodshed
end

-- Sexual Violence
if tigrs.sexual_violence then
	tigrs[ #tigrs + 1 ] = tigrs.sexual_violence
end

-- Alcohol
if tigrs.alcohol then
	tigrs[ #tigrs + 1 ] = tigrs.alcohol
end

-- Drugs
if tigrs.drugs then
	tigrs[ #tigrs + 1 ] = tigrs.drugs
end

-- Tobacco
if tigrs.tobacco then
	tigrs[ #tigrs + 1 ] = tigrs.tobacco
end

-- Nudity
if tigrs.nudity then
	tigrs[ #tigrs + 1 ] = tigrs.nudity
end

-- Sexual Themes
if tigrs.sexual_themes then
	tigrs[ #tigrs + 1 ] = tigrs.sexual_themes
end

-- Sexual Violence
if tigrs.sexual_violence then
	tigrs[ #tigrs + 1 ] = tigrs.sexual_violence
end

-- Language
if tigrs.language then
	tigrs[ #tigrs + 1 ] = tigrs.language
end

-- Humor
if tigrs.humor then
	tigrs[ #tigrs + 1 ] = tigrs.humor
end

-- Gambling
if tigrs.gambling then
	tigrs[ #tigrs + 1 ] = tigrs.gambling
end

local text_width = 0, 0
local font       = love.graphics.newFont( 10 )

for _, text in ipairs( tigrs ) do
	local width = font:getWidth( text )

	if width > text_width then
		text_width = width
	end
end

tigrs.font        = font
tigrs.text_width  = text_width
tigrs.line_height = font:getHeight()
tigrs.width       = ( #tigrs ~= 0 ) and ( text_width + tigrs.rating:getWidth() + 16 ) or ( tigrs.rating:getWidth() )
tigrs.height      = tigrs.rating:getHeight()

function tigrs:draw( x0, y0 )
	-- Center x.
	if not x0 then
		x0 = ( love.graphics.getWidth() - self.width ) / 2
	end
	-- Center y.
	if not y0 then
		y0 = ( love.graphics.getHeight() - self.height ) / 2
	end

	if #tigrs ~= 0 then
		-- Draw the box white background.
		local box_left  = x0 + self.width - self.text_width - 26
		local box_width = self.text_width + 25
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( 'fill', box_left, y0, box_width, self.height )

		-- Draw the box borders.
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.rectangle( 'fill', box_left, y0, box_width, 6 )
		love.graphics.rectangle( 'fill', box_left, y0 + self.height - 6, box_width, 6 )
		love.graphics.rectangle( 'fill', x0 + self.width - 6, y0, 6, self.height )
	end

	-- Draw the rating logo.
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw( self.rating, x0, y0 )

	-- Draw the text.
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.setFont( self.font )

	x0 = x0 + self.rating:getWidth() + 5
	local y = y0 + 5
	local line_height = self.line_height
	for _, text in ipairs( self ) do
		y = y + line_height
		love.graphics.print( text, x0, y )
	end
end

return tigrs
