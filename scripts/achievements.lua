----------------------------------------------------- Requires

--	achievementExt
--		difficultyEvents
--	personalSavedata
--	squadEvents
--	eventifyModApiExtHooks
--	attackEvents

----------------------------------------------------- Defs

local mod = modApi:getCurrentMod()
--local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils") --Oh it worked apparently
local scriptPath = mod.scriptPath
local utils = require(scriptPath .. "libs/utils")
local difficultyEvents = require(scriptPath .. "libs/difficultyEvents")
local achvExt = require(scriptPath.."libs/achievementExt")

--FMW
local truelch_terran_fmwApi = require(scriptPath .. "fmw/api")

----------------------------------------------------- Defs (test)

--old
local HEAVENS_DEVILS_GOAL = 3
local TRENCH_WARS_ENEMY_GOAL = 3
local EVENT_BUILDING_DAMAGED = 7
local squad = "truelch_TerranMechs"

--new
local CREATOR = "Truelch"
local SQUAD = "truelch_TerranMechs"

--Doesn't work... not sure if I need this anyway
--[[
local game_savedata = GAME_savedata(CREATOR, SQUAD, "Achievements")
LOG("game_savedata: " .. tostring(game_savedata))
]]


----------------------------------------------------- My Helper functions

local function countNonFrozenEnemies()
	local enemyCount = 0
	for i = 0, 7 do
		for j = 0, 7  do
			local point = Point(i, j)
			local pawn = Board:GetPawn(point)
			if Board:IsPawnSpace(point) and Board:GetPawn(point):IsEnemy() and not pawn:IsFrozen() then
				enemyCount = enemyCount + 1
			end
		end
	end
	return enemyCount
end

----------------------------------------------------- Helper functions

local function isRealMission()
	local mission = GetCurrentMission()

	return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsGameBoard()
end

local function isNotRealMission()
	return not isRealMission()
end

local function isGame()
	return Game ~= nil
end


local function isSquad()
	return true
		and isGame()
		and GAME.additionalSquadData.squad == squad
end

local function isMission()
	local mission = GetCurrentMission()

	return true
		and isGame()
		and mission ~= nil
		and mission ~= Mission_Test
end

local function isMissionBoard()
	return true
		and isMission()
		and Board ~= nil
		and Board:IsTipImage() == false
end

local function isGameData()
	return true
		and GAME ~= nil
		and GAME.truelch_TerranMechs ~= nil
		and GAME.truelch_TerranMechs.achievementData ~= nil
end

local function gameData()
	if GAME.truelch_TerranMechs == nil then
		GAME.truelch_TerranMechs = {}
	end

	if GAME.truelch_TerranMechs.achievementData == nil then
		GAME.truelch_TerranMechs.achievementData = {}
	end

	return GAME.truelch_TerranMechs.achievementData
end

local function missionData()
	local mission = GetCurrentMission()

	if mission.truelch_TerranMechs == nil then
		mission.truelch_TerranMechs = {}
	end

	if mission.truelch_TerranMechs.achievementData == nil then
		mission.truelch_TerranMechs.achievementData = {}
	end

	return mission.truelch_TerranMechs.achievementData
end

----------------------------------------------------- Achievements declaration

----------------------------------------------------- Heaven's Devils (solved inside hellFMW)
local heavensDevils = modApi.achievements:addExt{
	id = "heavensDevils",
	name = "Heaven's Devils",
	tooltip = "Ignite an ally on fire to ignite " .. tostring(HEAVENS_DEVILS_GOAL) .. " enemies",
	--textDiffComplete = "$highscore ignited enemies",
	image = mod.resourcePath.."img/achievements/heavensDevils.png",
	squad = SQUAD,
}

function completeHeavensDevils()
	if Board:IsTipImage() then
		return
	end

	--Board:AddAlert(Point(3, 3), "Heaven's Devils complete!") --Debug

	heavensDevils:completeWithHighscore(0) --works
	--achievements.heavensDevils:addProgress{ complete = true } --doesn't work
end


----------------------------------------------------- Trench War

--Maybe don't count frozen enemies?

local terranMechsIds =
{
	"HellMech",
	"VikingMech",
	"CrucioMech"
}

local function isTerranMech(pawnId)
	for _,v in pairs(terranMechsIds) do
		if v == pawnId then
			--LOG(tostring(pawnId) .. " is a Terran Mech!")
			return true
		end
	end
	return false
end

local trenchWar = modApi.achievements:addExt{
	id = "trenchWar",
	name = "Trench War",
	tooltip = "Finish a turn without taking Grid Damage nor moving Mechs while there are at least " .. tostring(TRENCH_WARS_ENEMY_GOAL) .. " non-frozen enemies on the board",
	image = mod.resourcePath.."img/achievements/trenchWar.png",
	squad = SQUAD,
}

function completeTrenchWar()
	if Board:IsTipImage() then
		return
	end

	--Board:AddAlert(Point(3, 3), "Trench War complete!") --Debug

	trenchWar:completeWithHighscore(0) --works
	--achievements.trenchWar:addProgress{ complete = true } --doesn't work
end

local function computeStartTurnTrenchWar()
	missionData().trenchWarMoveCount = 0
	local enemyCount = countNonFrozenEnemies()
	local enemyCountOk = enemyCount >= TRENCH_WARS_ENEMY_GOAL
	missionData().trenchWarEnemyCountOk = enemyCountOk
	missionData().trenchWarBuildingOk = true
end

--There's no end turn, so I'll use enemy start turn (except for turn 0) and mission end
local function computeEndTurnTrenchWar()
	if missionData().trenchWarEnemyCountOk and missionData().trenchWarMoveCount == 0 and missionData().trenchWarBuildingOk then
		completeTrenchWar()
	end
end

----------------------------------------------------- Transformers
local transformers = modApi.achievements:addExt{
	id = "transformers",
	name = "Transformers",
	tooltip = "Complete a mission where every Mech changed form every turn",
	image = mod.resourcePath.."img/achievements/transformers.png",
	squad = SQUAD,
}

function completeTransformers()
	if Board:IsTipImage() then
		return
	end

	--Board:AddAlert(Point(3, 3), "Transformers complete!") --Debug

	transformers:completeWithHighscore(0) --works
	--achievements.transformers:addProgress{ complete = true } --doesn't work
end


local transformWeapons =
{
    "truelch_HellWeapon",
    "truelch_HellWeapon_A",
    "truelch_HellWeapon_B",
    "truelch_HellWeapon_AB",
    "truelch_VikingWeapon",
    "truelch_VikingWeapon_A",
    "truelch_VikingWeapon_B",
    "truelch_VikingWeapon_AB",
    "truelch_CrucioWeapon",
    "truelch_CrucioWeapon_A",
    "truelch_CrucioWeapon_B",
    "truelch_CrucioWeapon_AB",
}

local function isTerranMechWeapon(fmwId)
    for _,v in pairs(transformWeapons) do
        if v == fmwId then
            return true
        end
    end
    return false
end


local function checkModeB(pawn, index)
	p = pawn:GetId()
	--LOG("checkModeB(p: " .. tostring(p) .. ", index: " .. tostring(index) .. ")")

    local fmwId = truelch_terran_fmwApi:GetSkillId(p, index)
    local fmw = truelch_terran_fmwApi:GetSkill(p, index, false)

    --Is FMWeapon?
    if fmw == nil or fmwId == nil then
		--LOG("Not a FMWeapon -> return!")
    	return
    end

    --Is Terran Mech Weapon?
    if not isTerranMechWeapon(fmwId) then
    	--LOG("Not a Terran Morph Weapon -> return!")
    	return
    end

    local currentMode = fmw:FM_GetMode(pawn:GetSpace())
    --LOG("currentMode: " .. currentMode)

    if currentMode == missionData().prevModes[pawn:GetId()] then
    	missionData().transformersOk = false
    	--LOG("------------------------------------------------------------------> Transformers achievement KO!")
    end

    --End
    if Game:GetTurnCount() == 0 then
    	missionData().prevModes[pawn:GetId()] = "None"
    else
    	missionData().prevModes[pawn:GetId()] = currentMode
    end    
end

local function checkMode(pawn)
	for index = 1, 2 do
		checkModeB(pawn, index) 
	end
end

local function checkModes()
	for i = 0, 2 do
		local pawn = Board:GetPawn(i)
		checkMode(pawn)
	end
end

----------------------------------------------- HOOKS SUBSCRIPTION -----------------------------------------------
local function HOOK_onMissionStart(mission)
	if not isSquad() then
		return
	end

	--LOG("On Mission Start!")
	--Init mission data
	missionData().transformersOk = true

    --Transformers
    if missionData().prevModes == nil then
    	--LOG("Initializing previous modes table!")
    	missionData().prevModes = {}
    	for i = 0, 2 do
    		missionData().prevModes[i] = "None"
    	end
    end
end

local function HOOK_onNextTurnHook()
	if not isSquad() then
		return
	end

    if Game:GetTeamTurn() == TEAM_PLAYER then
        LOG(" -> TEAM_PLAYER")

        --Trench War -> Reset data
        computeStartTurnTrenchWar()
    elseif Game:GetTeamTurn() == TEAM_ENEMY then
    	LOG(" -> TEAM_ENEMY (turn count: " .. tostring(Game:GetTurnCount()) .. ")")

    	--Trench War
    	computeEndTurnTrenchWar()

    	--Transformer
    	checkModes()    	
    end
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
	if not isSquad() then
		return
	end

    if weaponId == "Move" and isTerranMech(pawn:GetType()) then
        missionData().trenchWarMoveCount = missionData().trenchWarMoveCount + 1
        --LOG("A Terran Mech moved -> move count: " .. tostring(missionData().trenchWarMoveCount))
    end
end

local HOOK_onPawnUndoMove = function(mission, pawn, undonePosition)
	if not isSquad() then
		return
	end

    if isTerranMech(pawn:GetType()) then
    	missionData().trenchWarMoveCount = missionData().trenchWarMoveCount - 1
    	LOG("A Terran Mech cancelled move -> move count: " .. tostring(missionData().trenchWarMoveCount))
    end
end

local HOOK_onMissionEnd = function(mission)
	if not isSquad() then
		return
	end

	--Trench war
	computeEndTurnTrenchWar()

	--Transformers
	checkModes()

	if missionData().transformersOk then
		completeTransformers()
	end
end


local function EVENT_onModsLoaded()
	modApi:addMissionStartHook(HOOK_onMissionStart)
	modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addSkillEndHook(HOOK_onSkillEnd) --modApiExt:addSkillEndHook(HOOK_onSkillEnd)
    modapiext:addPawnUndoMoveHook(HOOK_onPawnUndoMove) --modApiExt:addPawnUndoMoveHook(HOOK_onPawnUndoMove)
    --modApiExt:addBuildingDestroyedHook(HOOK_onBuildingDestroyed) --Is only called when a complete building block is destroyed
    modApi:addMissionEndHook(HOOK_onMissionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

----------------------------------------------- EVENTS SUBSCRIPTION -----------------------------------------------
modApi.events.onMissionUpdate:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMission() == false

	if exit then
		return
	end

	if Game:GetEventCount(EVENT_BUILDING_DAMAGED) > 0 then
		LOG("A building has been damaged! -> trenchWarBuildingOk = false!")
		missionData().trenchWarBuildingOk = false
	end
end)