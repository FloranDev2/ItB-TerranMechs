----------------------------------------------------- Imports

local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

--local fmw = require(path.."fmw/api") 


----------------------------------------------------- Icons
--Old (viking)
modApi:appendAsset("img/weapons/viking_weapons.png", resources .."img/weapons/viking_weapons.png")
modApi:appendAsset("img/modes/icon_viking_fighter.png", resources .. "img/modes/icon_viking_fighter.png")
modApi:appendAsset("img/modes/icon_viking_assault.png", resources .. "img/modes/icon_viking_assault.png")
modApi:appendAsset("img/effects/shotup_torpedo_normal.png",  resources .. "img/effects/shotup_torpedo_normal.png")
modApi:appendAsset("img/effects/shotup_torpedo_phobos.png",  resources .. "img/effects/shotup_torpedo_phobos.png")


--New (liberator)
modApi:appendAsset("img/weapons/liberator_weapons.png", resources .."img/weapons/liberator_weapons.png")
modApi:appendAsset("img/modes/icon_liberator_fighter.png", resources .. "img/modes/icon_liberator_fighter.png")
modApi:appendAsset("img/modes/icon_liberator_defender.png", resources .. "img/modes/icon_liberator_defender.png")


----------------------------------------------------- Custom functions

function tableContains(table, value)
  for i = 1, #testTable do
    if (testTable[i] == value) then
      return true
    end
  end
  return false
end

local unauthorizedPoints = {
	Point(-2, -2),
	Point(-2,  2),
	Point( 0,  0),
	Point( 2, -2),
	Point( 2,  2)
}

function isAuthorizedPoint(point)
	for _, p in ipairs(unauthorizedPoints) do
		if p == point then
			return false
		end
	end
	return true
end


----------------------------------------------------- Mode 1: Fighter

truelch_LiberatorMode1 = {
	aFM_name = "Fighter Mode",
	aFM_desc = "Can move normally.",
	aFM_icon = "img/modes/icon_liberator_fighter.png",
	--Custom
	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/weapons/rocket_launcher",
	Explo = "explopush1_",
	UpShot = "effects/shotup_tribomb_missile.png",
}

CreateClass(truelch_LiberatorMode1)

function truelch_LiberatorMode1:targeting(point)
	local points = {}
	for j = -2, 2 do
		for i = -2, 2 do
			local curr = point + Point(i, j)
			if isAuthorizedPoint(curr) then
				points[#points+1] = curr
			end
		end
	end
	return points
end

function truelch_LiberatorMode1:fire(p1, p2, ret)
	local dir = GetDirection(p2 - p1)
	local targetPawn = Board:GetPawn(p2)
	local dmg = 0

	--Can also be triggered by other obstacles like Mountains or Buildings
	local spaceDamage = SpaceDamage(p2, dmg, dir)
	spaceDamage.sSound = self.LaunchSound

	ret:AddArtillery(spaceDamage, self.UpShot)
end


----------------------------------------------------- Mode 2: Defender

truelch_LiberatorMode2 = truelch_LiberatorMode1:new{
	aFM_name = "Defender Mode",
	aFM_desc = "TMP.",
	aFM_icon = "img/modes/icon_liberator_defender.png",	
	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/general/combat/explode_small",
	--Custom art
	UpShot = "",
}

function truelch_LiberatorMode2:targeting(point)
	local points = {}
	for j = -2, 2 do
		for i = -2, 2 do
			local curr = point + Point(i, j)
			points[#points+1] = curr
		end
	end
	return points
end


function truelch_LiberatorMode2:fire(p1, p2, ret)
	local direction = GetDirection(p2 - p1)
	local target
	local spaceDamage
	local currPawn

	--TODO
end


----------------------------------------------------- Skill

truelch_LiberatorWeapon = aFM_WeaponTemplate:new{
	--Infos
	Name = "Liberator Weapons",
	Description = "TMP.",
	Class = "Brute",

	--Menu stats
	Rarity = 1,
	PowerCost = 0,

	--Art
	Icon = "weapons/liberator_weapons.png",
	--LaunchSound = "/weapons/back_shot",
	LaunchSound = "",

	--FMW
	aFM_ModeList = { "truelch_LiberatorMode1", "truelch_LiberatorMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--TipImage
	TipImage = {
		Unit = Point(3,3),
	},
}

function truelch_LiberatorWeapon:GetTargetArea(point)
	local pl = PointList()
	local currentMode = _G[self:FM_GetMode(point)]
	if self:FM_CurrentModeReady(point) then 
		local points = currentMode:targeting(point)		
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end	 
	return pl
end

function truelch_LiberatorWeapon:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentMode]:fire(p1, p2, se)
	end
	return se
end

--Mode1: Fighter, Mode2: Defender
--[[
function truelch_LiberatorWeapon:FM_OnModeSwitch(p)
	if self:FM_GetMode(p) == "truelch_LiberatorMode1" then
		Pawn:SetMoveSpeed(0) --See Crucio
        if Pawn:GetType() == "LiberatorMech" then
            Pawn:SetCustomAnim("liberator_defender")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	elseif self:FM_GetMode(p) == "truelch_LiberatorMode2" then
		Pawn:SetMoveSpeed(2)
        if Pawn:GetType() == "LiberatorMech" then
            Pawn:SetCustomAnim("liberator_fighter")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	end
end
]]

return this