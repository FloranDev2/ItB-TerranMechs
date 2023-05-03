----------------------------------------------------- Imports
local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath


----------------------------------------------------- Icons
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

----------------------------------------------------- Hooks
-- Note:
-- - have MULTIPLE Liberators
-- - overlapping areas (add but also remove!!)
-- - when a liberator ends its overwatch, we don't want to remove points 
--   in a zone overlapped by another defending Liberator
local defendedArea

--Init list
local function initDefendedArea()
	defendedArea[0] = {}
	defendedArea[1] = {}
	defendedArea[2] = {}
end

--index should be between 0 and 2 included
local function addPointToDefArea(index, point)
	if not tableContains(defendedArea[index]) then
		table.insert(defendedArea[index], point)
	end
end

--Must be called at the start of every mission
--Same as init. Maybe cut this one
local function clearDefendedArea()
	defendedArea[0] = {}
	defendedArea[1] = {}
	defendedArea[2] = {}
end

local function debugAreas()
	
end

--Hm i need to check every mech weapon then (upgrade and stuff)
local function isInDefendedArea(point)
	for i = 0, 2 do
		--Check the weapon
		for j = 1, 2 do --I think this was the weapon indexes?

		end
	end
end

local onVekMoveEnded = function(mission, pawn, startLoc, endLoc)
	LOG(pawn:GetMechName() .. " has finished moving from " .. startLoc:GetString() .. " to " .. endLoc:GetString())
	if isInDefendedArea(endLoc) then
		LOG(" -> is in defended area!")
	end
end

--modApiExt:addVekMoveEndHook(onVekMoveEnded)
modapiext:addVekMoveEndHook(onVekMoveEnded)





----------------------------------------------------- Mode 1: Fighter
truelch_LiberatorMode1 = {
	aFM_name = "Fighter Mode",
	aFM_desc = "Can move normally.",
	aFM_icon = "img/modes/icon_liberator_fighter.png",
	aFM_twoClick = true,

	--Custom
	Damage = 1,

	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/weapons/rocket_launcher",
	Explo = "explopush1_",
	UpShot = "effects/shotup_tribomb_missile.png",
}

function truelch_LiberatorMode1:second_targeting(p1, p2)
	local ret = PointList()

	local diff = p1 - p2

	if math.abs(diff.x) > math.abs(diff.y) then
		ret:push_back(Point(p2.x, p1.y + diff.y))
	elseif math.abs(diff.x) < math.abs(diff.y) then
		ret:push_back(Point(p1.x + diff.x, p2.y))
	else
		ret:push_back(Point(p2.x, p1.y + diff.y))
		ret:push_back(Point(p1.x + diff.x, p2.y))
	end

	return ret
end

function truelch_LiberatorMode1:second_fire(p1, p2, p3)
	local se = SkillEffect()

	local x = (p2.x + p3.x) / 2
	local y = (p2.y + p3.y) / 2
	local mid = Point(x, y)
	local dir = GetDirection(mid - p1)

	--Wait what: https://discord.com/channels/417639520507527189/418142041189646336/1103243354772361297
	if p2 ~= p3 then
		--Split attack
		--TODO: take inspiration of tosx' Ecl_Ranged_Orion weapon
		local sd2 = SpaceDamage(p2, self.Damage, dir) --Has a delay
		--local sd2 = SpaceDamage(p2, self.Damage, dir, NO_DELAY) --doesn't work
		--local sd2 = SpaceDamage(p2, self.Damage, NO_DELAY, dir) --doesn't work
		sd2.sSound = self.LaunchSound
		--se:AddArtillery(sd2, self.UpShot)
		se:AddArtillery(sd2, self.UpShot, NO_DELAY) --test

		local sd3 = SpaceDamage(p3, self.Damage, dir)
		sd3.sSound = self.LaunchSound
		--se:AddArtillery(sd3, self.UpShot)
		se:AddArtillery(sd3, self.UpShot, NO_DELAY) --test
	else
		--Concentred attack
		local sd = SpaceDamage(p2, 2 * self.Damage, dir)
		sd.sSound = self.LaunchSound
		se:AddArtillery(sd, self.UpShot)
	end

	return se
end

CreateClass(truelch_LiberatorMode1)

function truelch_LiberatorMode1:targeting(point)
	local points = {}
	for j = -2, 2 do
		for i = -2, 2 do
			local curr = point + Point(i, j)
			if isAuthorizedPoint(Point(i, j)) then
				points[#points+1] = curr
			end
		end
	end
	return points
end

function truelch_LiberatorMode1:fire(p1, p2, ret)
	local dir = GetDirection(p2 - p1)
	local targetPawn = Board:GetPawn(p2)
	local spaceDamage = SpaceDamage(p2, 0)
	--local spaceDamage = SpaceDamage(p2, self.Damage, dir)
	--spaceDamage.sSound = self.LaunchSound
	ret:AddArtillery(spaceDamage, self.UpShot)
end


----------------------------------------------------- Mode 2: Defender
truelch_LiberatorMode2 = truelch_LiberatorMode1:new{
	aFM_name = "Defender Mode",
	aFM_desc = "TMP.",
	aFM_icon = "img/modes/icon_liberator_defender.png",
	aFM_twoClick = false,
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

	TwoClick = true,

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
		--se:AddSound(_G[currentShell].impactsound)
	end

	return se
end

function truelch_LiberatorWeapon:IsTwoClickException(p1,p2)
	return not _G[self:FM_GetMode(p1)].aFM_twoClick 
end

function truelch_LiberatorWeapon:GetSecondTargetArea(p1, p2)
	--LOG("----------------- truelch_LiberatorWeapon:GetSecondTargetArea")
	local currentMode = _G[self:FM_GetMode(p1)]
    local pl = PointList()
    
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then
		--LOG("----------------- OK :)")
		pl = currentMode:second_targeting(p1, p2)
	else
		--LOG("----------------- NOT ok :(")
	end
    
    return pl 
end

function truelch_LiberatorWeapon:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentMode = _G[self:FM_GetMode(p1)]

	--LOG("truelch_LiberatorWeapon:GetFinalEffect")

	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then
		--LOG(" -----------> ok") 
		se = currentMode:second_fire(p1, p2, p3)  
	end
    
    return se 
end

--Mode1: Fighter, Mode2: Defender
function truelch_LiberatorWeapon:FM_OnModeSwitch(p)
	if self:FM_GetMode(p) == "truelch_LiberatorMode1" then
		Pawn:SetMoveSpeed(0)
		Pawn:SetPushable(false) --test
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

return this