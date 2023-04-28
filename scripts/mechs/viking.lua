local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/viking/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

--1
local files = {
	"viking_fighter.png",
	"viking_fighter_a.png",
	"viking_fighter_w.png",
	"viking_fighter_w_broken.png",
	"viking_fighter_broken.png",
	"viking_fighter_ns.png",
	"viking_fighter_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.viking_fighter =         a.MechUnit:new{Image = "units/player/viking_fighter.png",          PosX = -22, PosY = -6 }
a.viking_fightera =        a.MechUnit:new{Image = "units/player/viking_fighter_a.png",        PosX = -22, PosY = -6, NumFrames = 4 }
a.viking_fighterw =        a.MechUnit:new{Image = "units/player/viking_fighter_w.png",        PosX = -22, PosY = -6 }
a.viking_fighter_broken =  a.MechUnit:new{Image = "units/player/viking_fighter_broken.png",   PosX = -22, PosY = -9 }
a.viking_fighterw_broken = a.MechUnit:new{Image = "units/player/viking_fighter_w_broken.png", PosX = -22, PosY = -6 }
a.viking_fighter_ns =      a.MechIcon:new{Image = "units/player/viking_fighter_ns.png" }

--2
local files2 = {
	"viking_assault.png",
	"viking_assault_a.png",
	"viking_assault_w.png",
	"viking_assault_w_broken.png",
	"viking_assault_broken.png",
	"viking_assault_ns.png",
	"viking_assault_h.png"
}

for _, file2 in ipairs(files2) do
	modApi:appendAsset("img/units/player/" .. file2, mechPath .. file2)
end

local a2 = ANIMS
a2.viking_assault =         a2.MechUnit:new{Image = "units/player/viking_assault.png",          PosX = -24, PosY = -6 }
a2.viking_assaulta =        a2.MechUnit:new{Image = "units/player/viking_assault_a.png",        PosX = -24, PosY = -6, NumFrames = 4 }
a2.viking_assaultw =        a2.MechUnit:new{Image = "units/player/viking_assault_w.png",        PosX = -24, PosY = 3 }
a2.viking_assault_broken =  a2.MechUnit:new{Image = "units/player/viking_assault_broken.png",   PosX = -24, PosY = -10 }
a2.viking_assaultw_broken = a2.MechUnit:new{Image = "units/player/viking_assault_w_broken.png", PosX = -24, PosY = 3 }
a2.viking_assault_ns =      a2.MechIcon:new{Image = "units/player/viking_assault_ns.png" }


VikingMech = Pawn:new{
	Name = "Viking Mech",
	Class = "Brute",

	Health = 2,
	MoveSpeed = 4,
	Massive = true,

	Flying = true,
	
	Image = "viking_fighter",
	ImageOffset = imageOffset,
	
	SkillList = { "truelch_VikingWeapon" }, --"CyborgWeapons_BloodyStream" --"mini_Multishot"

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}