local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/liberator/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

--1
local files = {
	"liberator_fighter.png",
	"liberator_fighter_a.png",
	"liberator_fighter_w.png",
	"liberator_fighter_w_broken.png",
	"liberator_fighter_broken.png",
	"liberator_fighter_ns.png",
	"liberator_fighter_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.liberator_fighter =         a.MechUnit:new{ Image = "units/player/liberator_fighter.png",          PosX = -26, PosY = -15 }
a.liberator_fightera =        a.MechUnit:new{ Image = "units/player/liberator_fighter_a.png",        PosX = -26, PosY = -15, NumFrames = 4 }
a.liberator_fighterw =        a.MechUnit:new{ Image = "units/player/liberator_fighter_w.png",        PosX = -26, PosY =  -4 }
a.liberator_fighter_broken =  a.MechUnit:new{ Image = "units/player/liberator_fighter_broken.png",   PosX = -26, PosY = -15 }
a.liberator_fighterw_broken = a.MechUnit:new{ Image = "units/player/liberator_fighter_w_broken.png", PosX = -26, PosY =  -4 }
a.liberator_fighter_ns =      a.MechIcon:new{ Image = "units/player/liberator_fighter_ns.png" }


--2
local files2 = {
	"liberator_defender.png",
	"liberator_defender_a.png",
	"liberator_defender_w.png",
	"liberator_defender_w_broken.png",
	"liberator_defender_broken.png",
	"liberator_defender_ns.png",
	"liberator_defender_h.png"
}

for _, file2 in ipairs(files2) do
	modApi:appendAsset("img/units/player/" .. file2, mechPath .. file2)
end

local a2 = ANIMS
a2.liberator_defender =         a2.MechUnit:new{ Image = "units/player/liberator_defender.png",          PosX = -26, PosY = -15 }
a2.liberator_defendera =        a2.MechUnit:new{ Image = "units/player/liberator_defender_a.png",        PosX = -26, PosY = -15, NumFrames = 4 }
a2.liberator_defenderw =        a2.MechUnit:new{ Image = "units/player/liberator_defender_w.png",        PosX = -26, PosY =  -4 }
a2.liberator_defender_broken =  a2.MechUnit:new{ Image = "units/player/liberator_defender_broken.png",   PosX = -26, PosY = -15 }
a2.liberator_defenderw_broken = a2.MechUnit:new{ Image = "units/player/liberator_defender_w_broken.png", PosX = -26, PosY =  -4 }
a2.liberator_defender_ns =      a2.MechIcon:new{ Image = "units/player/liberator_defender_ns.png" }


LiberatorMech = Pawn:new{
	Name = "Liberator Mech",
	Class = "Brute",

	Health = 3,
	MoveSpeed = 2,
	Massive = true,
	Flying = true,

	Image = "liberator_fighter",
	ImageOffset = imageOffset,
	
	SkillList = { "truelch_LiberatorWeapon" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,

	Tank = true, --Tonks achievement of the WotP squad!!
}