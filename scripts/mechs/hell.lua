local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/hell/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

--1
local files = {
	"hellion.png",
	"hellion_a.png",
	"hellion_w.png",
	"hellion_w_broken.png",
	"hellion_broken.png",
	"hellion_ns.png",
	"hellion_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.hellion =         a.MechUnit:new{Image = "units/player/hellion.png",          PosX = -24, PosY = -7 }
a.helliona =        a.MechUnit:new{Image = "units/player/hellion_a.png",        PosX = -24, PosY = -7, NumFrames = 4 }
a.hellionw =        a.MechUnit:new{Image = "units/player/hellion_w.png",        PosX = -24, PosY = 1 }
a.hellion_broken =  a.MechUnit:new{Image = "units/player/hellion_broken.png",   PosX = -24, PosY = -7 }
a.hellionw_broken = a.MechUnit:new{Image = "units/player/hellion_w_broken.png", PosX = -24, PosY = 1 }
a.hellion_ns =      a.MechIcon:new{Image = "units/player/hellion_ns.png" }

--2
local files2 = {
	"hellbat.png",
	"hellbat_a.png",
	"hellbat_w.png",
	"hellbat_w_broken.png",
	"hellbat_broken.png",
	"hellbat_ns.png",
	"hellbat_h.png"
}

for _, file2 in ipairs(files2) do
	modApi:appendAsset("img/units/player/" .. file2, mechPath .. file2)
end

local a2 = ANIMS
a2.hellbat =         a2.MechUnit:new{Image = "units/player/hellbat.png",          PosX = -24, PosY = -10 }
a2.hellbata =        a2.MechUnit:new{Image = "units/player/hellbat_a.png",        PosX = -24, PosY = -10, NumFrames = 4 }
a2.hellbatw =        a2.MechUnit:new{Image = "units/player/hellbat_w.png",        PosX = -24, PosY = 6 }
a2.hellbat_broken =  a2.MechUnit:new{Image = "units/player/hellbat_broken.png",   PosX = -24, PosY = -10 }
a2.hellbatw_broken = a2.MechUnit:new{Image = "units/player/hellbat_w_broken.png", PosX = -24, PosY = 6 }
a2.hellbat_ns =      a2.MechIcon:new{Image = "units/player/hellbat_ns.png" }


HellMech = Pawn:new{
	Name = "Hell Mech",
	Class = "Prime",

	Health = 2,
	MoveSpeed = 4,
	Massive = true,
	
	Image = "hellion",
	ImageOffset = imageOffset,
	
	SkillList = { "truelch_HellWeapon" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}