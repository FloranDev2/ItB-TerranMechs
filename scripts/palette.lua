local mod = modApi:getCurrentMod()

local palette = {
	id = mod.id,
	name = "Dominion Red", 
	image = "img/units/player/hellbat_ns.png",
	colorMap = {
		lights =         { 100, 200, 100 }, --PlateHighlight
		main_highlight = { 175,  75,  50 }, --PlateLight
		main_light =     { 125,  15,  15 }, --PlateMid
		main_mid =       {  75,   0,   0 }, --PlateDark
		main_dark =      {  15,  15,  15 }, --PlateOutline
		metal_light =    { 160, 150, 135 }, --BodyHighlight
		metal_mid =      { 100, 100,  90 }, --BodyColor
		metal_dark =     {  60,  60,  60 }, --PlateShadow
	}, 
}

modApi:addPalette(palette)