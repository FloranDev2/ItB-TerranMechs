----------------------------------------------------- Imports
local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath

--FMW
local truelch_terran_fmwApi = require(scriptPath .. "fmw/api") --that's what I needed!

----------------------------------------------------- Test custom anim
--local a = ANIMS
local customAnim = require(scriptPath .."libs/customAnim")
modApi:appendAsset("img/effects/truelch_defended.png", resources.."img/effects/truelch_defended.png")

ANIMS.truelch_defended = Animation:new{
	Image = "effects/truelch_defended.png",
	NumFrames = 1,
	Loop = false,
	Time = 0.08,
	PosX = -27,
	PosY = 2,
}

----------------------------------------------------- Icons
modApi:appendAsset("img/weapons/liberator_weapons.png", resources .."img/weapons/liberator_weapons.png")
modApi:appendAsset("img/modes/icon_liberator_fighter.png", resources .. "img/modes/icon_liberator_fighter.png")
modApi:appendAsset("img/modes/icon_liberator_defender.png", resources .. "img/modes/icon_liberator_defender.png")

--Doesn't work:
--[[
modApi:appendAsset("img/combat/icons/truelch_defended.png", resources.."img/combat/icons/truelch_defended.png")
	Location["combat/icons/truelch_defended.png"] = Point(-15, 6)
]]

----------------------------------------------------- Utility / local functions
local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

local function missionData()
    local mission = GetCurrentMission()

    --Test
    if mission == nil then
    	return nil
    end

    if mission.truelch_TerranMechs == nil then
        mission.truelch_TerranMechs = {}
    end

    return mission.truelch_TerranMechs
end


----------------------------------------------------- Custom functions
function tableContains(myTable, value)
  for i = 1, #myTable do
    if (myTable[i] == value) then
      return true
    end
  end
  return false
end

local unauthorizedOffsets = {
	Point(-2, -2),
	Point(-2,  2),
	Point( 0,  0),
	Point( 2, -2),
	Point( 2,  2),
	--Range upgrade!

	Point(-2, -3),
	Point(-3, -2),
	Point(-3, -3),

	Point(-2,  3),
	Point(-3,  2),
	Point(-3,  3),

	Point( 2, -3),
	Point( 3, -2),
	Point( 3, -3),

	Point( 2,  3),
	Point( 3,  2),
	Point( 3,  3)
}

function isAuthorizedOffset(offset)
	for _, p in ipairs(unauthorizedOffsets) do
		if p == offset then
			return false
		end
	end
	return true
end

--Reset (init or clear)
local function resetDefendedArea()
	LOG("resetDefendedArea()")
	missionData().defendedArea = {}
	missionData().defendedArea[0] = {}
	missionData().defendedArea[1] = {}
	missionData().defendedArea[2] = {}
end

local function checkReset()
	LOG("checkReset()")
	if missionData().defendedArea == nil or missionData().defendedArea[0] == nil then
		LOG("-> need to reset!")
		resetDefendedArea()
	end
end

local function clearDefendedAtSlot(playerId)
	LOG("clearDefendedAtSlot(playerId: " .. tostring(playerId) .. ")")
	missionData().defendedArea[playerId] = {}
end

--index should be between 0 and 2 included
local function addPointToDefArea(index, point)
	if not tableContains(missionData().defendedArea[index]) and Board:IsValid(point) then
		table.insert(missionData().defendedArea[index], point)
	end
end

--Hm i need to check every mech weapon then (upgrade and stuff)
local function isInDefendedArea(point)
	for i = 0, 2 do
		if missionData().defendedArea[i] == point then
			return true
		end
	end
	return false
end

local function computeHaloAoE(ret, point)
	for dir = 0, 3 do
		local curr = point + DIR_VECTORS[dir]
		local currPawn = Board:GetPawn(curr)
		if currPawn ~= nil and currPawn:IsEnemy() then
			local haloDmg = SpaceDamage(curr, 1)
			haloDmg.sAnimation = "airpush_"..dir
			ret:AddDamage(haloDmg)
		end
	end
end

--123456789012345678901
--truelch_LiberatorWeapon
local function isLiberatorWeapon(weaponId)
	LOG("isLiberatorWeapon")
	if weaponId == nil then
		LOG("weaponId is nil!!")
		return false
	end
	LOG("type: " .. type(weaponId))
	LOG("weaponId: " .. weaponId)
	local subStr = string.sub(weaponId, 9, 17)
	local isLiberatorWeapon = (subStr == "Liberator")
	return isLiberatorWeapon
end

--01       10        20
---1234567890123456789012
---truelch_LiberatorMode2
local function isDefenderMode(mode)
	return string.sub(mode, 9, 22) == "LiberatorMode2"
end

----------------------------------------------------- Hooks
--Isn't called for test mission
local HOOK_onMissionStart = function(mission)
	LOG("Mission started!")
	resetDefendedArea()
end

local HOOK_onVekMoveEnd = function(mission, pawn, startLoc, endLoc)
	LOG(pawn:GetMechName() .. " has finished moving from " .. startLoc:GetString() .. " to " .. endLoc:GetString())
	if isInDefendedArea(endLoc) then
		LOG(" -> is in defended area!")
		Board:AddAlert(endLoc, "PIEW!")
	end
end

local HOOK_onSkillStart = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s is using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))
	if weaponId == "Move" then
		local weapons = pawn:GetPoweredWeapons()
		for weaponIdx = 1, 2 do
			local weapon = weapons[weaponIdx]
			if isLiberatorWeapon(weapon) then
				checkReset() --fix
				clearDefendedAtSlot(pawn:GetId())
			end
		end
	end
end

local HOOK_onFinalEffectEnd = function(mission, pawn, weaponId, p1, p2, p3)
	--LOG(string.format("%s has finished using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
	if isLiberatorWeapon(weaponId) then
		checkReset()
	    local pawnId = pawn:GetId()
	    for weaponIdx = 1, 2 do
		    local fmw = truelch_terran_fmwApi:GetSkill(pawnId, weaponIdx, false)
		    if fmw ~= nil then
			    local mode = fmw:FM_GetMode(pawnId)
				if isDefenderMode(mode) then
					for j = -1, 1 do
						for i = -1, 1 do
							local defPoint = p2 + Point(i, j)
							if Board:IsValid(defPoint) then
								addPointToDefArea(pawnId, defPoint)
							end
						end
					end
				end
		    end
		end
	end
end



----------------------------------------------------- Events
local function EVENT_onModsLoaded()
	modApi:addMissionStartHook(HOOK_onMissionStart)
	modapiext:addVekMoveEndHook(HOOK_onVekMoveEnd)
	modapiext:addFinalEffectEndHook(HOOK_onFinalEffectEnd)
	modapiext:addSkillStartHook(HOOK_onSkillStart)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)


modApi.events.onMissionUpdate:subscribe(function(mission)
	if mission.truelch_TerranMechs == nil then
		return
	end

	if mission.truelch_TerranMechs.defendedArea == nil then
		return
	end

	for i = 0, 2 do
		for _, p in ipairs(missionData().defendedArea[i]) do
			Board:AddAnimation(p, "truelch_defended", 0.08)
		end
	end
end)


local handler = function()
	LOG("Entered map editor test mission")
end

modApi.events.onMapEditorTestEntered:subscribe(handler)

----------------------------------------------------- Mode 1: Fighter
truelch_LiberatorMode1 = {
	aFM_name = "Fighter Mode",
	aFM_desc = "Can move normally.",
	aFM_icon = "img/modes/icon_liberator_fighter.png",
	aFM_twoClick = true,

	--Custom
	SplitDmg = 1,
	ConcentratedDmg = 2,

	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/weapons/rocket_launcher",
	Explo = "explopush1_",
	UpShot = "effects/shotup_tribomb_missile.png",
}

function truelch_LiberatorMode1:second_targeting(p1, p2--[[, advBallistics]])
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

function truelch_LiberatorMode1:second_fire(p1, p2, p3, haloAmmo)
	local se = SkillEffect()

	local x = (p2.x + p3.x) / 2
	local y = (p2.y + p3.y) / 2
	local mid = Point(x, y)
	local dir = GetDirection(mid - p1)

	if p2 ~= p3 then
		--Split attack
		local sd2 = SpaceDamage(p2, self.SplitDmg, dir)
		sd2.sSound = self.LaunchSound
		se:AddArtillery(sd2, self.UpShot, NO_DELAY)

		local sd3 = SpaceDamage(p3, self.SplitDmg, dir)
		sd3.sSound = self.LaunchSound
		se:AddArtillery(sd3, self.UpShot)
		--se:AddArtillery(sd3, self.UpShot, NO_DELAY) --not needed?

		if haloAmmo then
			--Fix the damage preview on the middle tile! (it displays 1 instead of 2 (1x2))
			--Eh, I need to take account of armor
			--So maybe do something like Lemonymous x2 attack
			computeHaloAoE(se, p2)
			computeHaloAoE(se, p3)
		end
	else
		--Concentred attack
		local sd = SpaceDamage(p2, self.ConcentratedDmg, dir)
		sd.sSound = self.LaunchSound
		se:AddArtillery(sd, self.UpShot)

		if haloAmmo then
			computeHaloAoE(se, p2) --once? Or x2 dmg?
		end
	end

	return se
end

CreateClass(truelch_LiberatorMode1)

function truelch_LiberatorMode1:targeting(point, advBallistics)
	local points = {}
	local range = 2
	if advBallistics then
		range = 3
	end
	for j = -range, range do
		for i = -range, range do
			local curr = point + Point(i, j)
			if isAuthorizedOffset(Point(i, j)) then
				points[#points+1] = curr
			end
		end
	end
	return points
end

function truelch_LiberatorMode1:fire(p1, p2, ret, haloAmmo)
	local dir = GetDirection(p2 - p1)
	local targetPawn = Board:GetPawn(p2)
	local spaceDamage = SpaceDamage(p2, self.SplitDmg)
	ret:AddArtillery(spaceDamage, self.UpShot)

	if haloAmmo then
		computeHaloAoE(ret, p2)
	end
end


----------------------------------------------------- Mode 2: Defender
truelch_LiberatorMode2 = truelch_LiberatorMode1:new{
	aFM_name = "Defender Mode",
	aFM_desc = "TMP.",
	aFM_icon = "img/modes/icon_liberator_defender.png",
	aFM_twoClick = true, --false

	--Initial shot

	--Defend shots

	--Custom


	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/weapons/rocket_launcher",
	UpShot = "effects/shot_artimech.png",
}

function truelch_LiberatorMode2:targeting(point, advBallistics)
	local points = {}

	local range = 1
	if advBallistics then
		range = 2
	end

	for j = -range, range do
		for i = -range, range do
			local curr = point + Point(i, j)
			points[#points+1] = curr
		end
	end

	return points
end


function truelch_LiberatorMode2:fire(p1, p2, ret, haloAmmo)
	local spaceDamage = SpaceDamage(p2, 0)
	ret:AddDamage(spaceDamage)
end

function truelch_LiberatorMode2:second_targeting(p1, p2--[[, advBallistics]])
	local ret = PointList()
	for j = -1, 1 do
		for i = -1, 1 do
			ret:push_back(p2 + Point(i, j))
		end
	end
	return ret
end

function truelch_LiberatorMode2:second_fire(p1, p2, p3, haloAmmo)
	local se = SkillEffect()
	local sd = SpaceDamage(p3, 2) --self.Damage
	sd.sSound = self.LaunchSound
	se:AddArtillery(sd, self.UpShot)

	if haloAmmo then
		computeHaloAoE(se, p3)
	end

	return se
end


----------------------------------------------------- Skill
truelch_LiberatorWeapon = aFM_WeaponTemplate:new{
	--Infos
	Name = "Liberator Weapons",
	Description = "Fighter mode:\nShoots mirrored projectile in front of the Liberator.\n\nDefender mode:\nCreate a zone near the Liberator, damaging every enemy entering it.",
	Class = "Brute",

	TwoClick = true,

	--Menu stats
	Rarity = 1,
	PowerCost = 0,

	--Upgrades
	Upgrades = 2,
	UpgradeCost = { 2, 2 },

	--Upgrade params
	HaloAmmo = false, --AoE dmg
	AdvBallistics = false, --+1 range

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
		Enemy = Point(2,2),
		Enemy2 = Point(3,2),
		Enemy3 = Point(4,2),
		Target = Point(2,2),
		Second_Click = Point(4,2)
	},
}

Weapon_Texts.truelch_LiberatorWeapon_Upgrade1 = "H.A.L.O. Ammo"
Weapon_Texts.truelch_LiberatorWeapon_Upgrade2 = "Advanced Ballistics"

truelch_LiberatorWeapon_A = truelch_LiberatorWeapon:new{
	UpgradeDescription = "Attacking enemy units will deal 1 damage to enemy units that are adjacent to the target.",
	HaloAmmo = true,
}

truelch_LiberatorWeapon_B = truelch_LiberatorWeapon:new{
	UpgradeDescription = "Increases the range by 1.\nFighter: tiles in the line in front or the next tiles in front.\nDefender: the Liberator must be within the 3x3 zone or adjacent to it.",
	AdvBallistics = true,
}

truelch_LiberatorWeapon_AB = truelch_LiberatorWeapon:new{
	HaloAmmo = true,
	AdvBallistics = true,
}

function truelch_LiberatorWeapon:GetTargetArea(point)
	local pl = PointList()
	local currentMode = _G[self:FM_GetMode(point)]
	if self:FM_CurrentModeReady(point) then 
		local points = currentMode:targeting(point, self.AdvBallistics)		
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
		_G[currentMode]:fire(p1, p2, se, self.HaloAmmo)
		--se:AddSound(_G[currentShell].impactsound)
	end

	return se
end

function truelch_LiberatorWeapon:IsTwoClickException(p1,p2)
	return not _G[self:FM_GetMode(p1)].aFM_twoClick 
end

function truelch_LiberatorWeapon:GetSecondTargetArea(p1, p2)
	local currentMode = _G[self:FM_GetMode(p1)]
    local pl = PointList()    
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then
		pl = currentMode:second_targeting(p1, p2--[[, self.AdvBallistics]])
	end
    return pl 
end

function truelch_LiberatorWeapon:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentMode = _G[self:FM_GetMode(p1)]
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then
		se = currentMode:second_fire(p1, p2, p3, self.HaloAmmo)  
	end
    return se 
end

--Mode1: Fighter, Mode2: Defender
function truelch_LiberatorWeapon:FM_OnModeSwitch(p)
	clearDefendedAtSlot(Pawn:GetId())
	if self:FM_GetMode(p) == "truelch_LiberatorMode1" then
		Pawn:SetMoveSpeed(0)
		Pawn:SetPushable(false)
        if Pawn:GetType() == "LiberatorMech" then
            Pawn:SetCustomAnim("liberator_defender")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	elseif self:FM_GetMode(p) == "truelch_LiberatorMode2" then
		Pawn:SetMoveSpeed(2)
		Pawn:SetPushable(true)
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