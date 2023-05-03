----------------------------------------------------- Imports
local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath


----------------------------------------------------- Icons
modApi:appendAsset("img/weapons/liberator_weapons.png", resources .."img/weapons/liberator_weapons.png")
modApi:appendAsset("img/modes/icon_liberator_fighter.png", resources .. "img/modes/icon_liberator_fighter.png")
modApi:appendAsset("img/modes/icon_liberator_defender.png", resources .. "img/modes/icon_liberator_defender.png")

modApi:appendAsset("img/combat/icons/truelch_defended.png", resources.."img/combat/icons/truelch_defended.png")
	Location["combat/icons/truelch_defended.png"] = Point(-15, 6)

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
local defendedArea --> should be a mission data variable

--Reset (init or clear)
local function resetDefendedArea()
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

--Hm i need to check every mech weapon then (upgrade and stuff)
local function isInDefendedArea(point)
	for i = 0, 2 do
		--Check the weapon
		for j = 1, 2 do --I think this was the weapon indexes?

		end
	end
end

---Hooks
local HOOK_onVekMoveEnd = function(mission, pawn, startLoc, endLoc)
	LOG(pawn:GetMechName() .. " has finished moving from " .. startLoc:GetString() .. " to " .. endLoc:GetString())
	if isInDefendedArea(endLoc) then
		LOG(" -> is in defended area!")
	end
end

local HOOK_onMissionStart = function(mission)
	LOG("Mission started!")

end

----------------------------------------------------- Events
local function EVENT_onModsLoaded()
	modapiext:addVekMoveEndHook(HOOK_onVekMoveEnd)
	modApi:addMissionStartHook(HOOK_onMissionStart)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

modApi.events.onMissionUpdate:subscribe(function(mission)
	local allpawns = extract_table(Board:GetPawns(TEAM_ENEMY))
	for i, id in pairs(allpawns) do
		local point = Board:GetPawnSpace(id)
		local pawn = Board:GetPawn(point)
		Board:AddAnimation(point, "truelch_defended", 0.08)
		LOG("point: " .. point:GetString())
	end
end)


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

	if p2 ~= p3 then
		--Split attack
		local sd2 = SpaceDamage(p2, self.Damage, dir)
		sd2.sSound = self.LaunchSound
		se:AddArtillery(sd2, self.UpShot, NO_DELAY)

		local sd3 = SpaceDamage(p3, self.Damage, dir)
		sd3.sSound = self.LaunchSound
		--se:AddArtillery(sd3, self.UpShot)
		se:AddArtillery(sd3, self.UpShot, NO_DELAY) --not needed?
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
	ret:AddArtillery(spaceDamage, self.UpShot)
end


----------------------------------------------------- Mode 2: Defender
truelch_LiberatorMode2 = truelch_LiberatorMode1:new{
	aFM_name = "Defender Mode",
	aFM_desc = "TMP.",
	aFM_icon = "img/modes/icon_liberator_defender.png",
	aFM_twoClick = true, --false
	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/general/combat/explode_small",
	UpShot = "effects/shotup_tribomb_missile.png",
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
	local spaceDamage = SpaceDamage(p2, 0)
	ret:AddDamage(spaceDamage)
end

function truelch_LiberatorMode2:second_targeting(p1, p2)
	local ret = PointList()
	for j = -1, 1 do
		for i = -1, 1 do
			ret:push_back(p2 + Point(i, j))
		end
	end
	return ret
end

function truelch_LiberatorMode2:second_fire(p1, p2, p3)
	local se = SkillEffect()
	local sd = SpaceDamage(p3, 2) --[[self.Damage]]
	sd.sSound = self.LaunchSound
	se:AddArtillery(sd, self.UpShot)
	return se
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
	local currentMode = _G[self:FM_GetMode(p1)]
    local pl = PointList()    
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then
		pl = currentMode:second_targeting(p1, p2)
	end
    return pl 
end

function truelch_LiberatorWeapon:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentMode = _G[self:FM_GetMode(p1)]
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then
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