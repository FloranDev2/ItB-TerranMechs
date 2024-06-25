local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/crucio/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

--1
local files = {
	"crucio_tank.png",
	"crucio_tank_a.png",
	"crucio_tank_w.png",
	"crucio_tank_w_broken.png",
	"crucio_tank_broken.png",
	"crucio_tank_ns.png",
	"crucio_tank_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.crucio_tank =         a.MechUnit:new{Image = "units/player/crucio_tank.png",          PosX = -24, PosY = -5 }
a.crucio_tanka =        a.MechUnit:new{Image = "units/player/crucio_tank_a.png",        PosX = -24, PosY = -5, NumFrames = 4 }
a.crucio_tankw =        a.MechUnit:new{Image = "units/player/crucio_tank_w.png",        PosX = -24, PosY = 4 }
a.crucio_tank_broken =  a.MechUnit:new{Image = "units/player/crucio_tank_broken.png",   PosX = -24, PosY = -5 }
a.crucio_tankw_broken = a.MechUnit:new{Image = "units/player/crucio_tank_w_broken.png", PosX = -24, PosY = 4 }
a.crucio_tank_ns =      a.MechIcon:new{Image = "units/player/crucio_tank_ns.png" }


--2
local files2 = {
	"crucio_siege.png",
	"crucio_siege_a.png",
	"crucio_siege_w.png",
	"crucio_siege_w_broken.png",
	"crucio_siege_broken.png",
	"crucio_siege_ns.png",
	"crucio_siege_h.png"
}

for _, file2 in ipairs(files2) do
	modApi:appendAsset("img/units/player/" .. file2, mechPath .. file2)
end

local a2 = ANIMS
a2.crucio_siege =         a2.MechUnit:new{Image = "units/player/crucio_siege.png",          PosX = -24, PosY = -5 }
a2.crucio_siegea =        a2.MechUnit:new{Image = "units/player/crucio_siege_a.png",        PosX = -24, PosY = -5, NumFrames = 4 }
a2.crucio_siegew =        a2.MechUnit:new{Image = "units/player/crucio_siege_w.png",        PosX = -24, PosY = 4 }
a2.crucio_siege_broken =  a2.MechUnit:new{Image = "units/player/crucio_siege_broken.png",   PosX = -24, PosY = -5 }
a2.crucio_siegew_broken = a2.MechUnit:new{Image = "units/player/crucio_siege_w_broken.png", PosX = -24, PosY = 4 }
a2.crucio_siege_ns =      a2.MechIcon:new{Image = "units/player/crucio_siege_ns.png" }


CrucioMech = Pawn:new{
	Name = "Crucio Mech",
	Class = "Ranged",

	Health = 2,
	MoveSpeed = 3,
	Massive = true,

	Image = "crucio_tank",
	ImageOffset = imageOffset,
	
	SkillList = { "truelch_CrucioWeapon" }, --{ "truelch_CrucioWeapon", "atlas_Mortar" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,

	Tank = true, --Tonks achievement of the WotP squad!!
}