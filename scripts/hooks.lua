----------------------------------------------- IMPORTS -----------------------------------------------
local mod = modApi:getCurrentMod() --same, but better (thx Lemonymous!)
local scriptPath = mod.scriptPath

--FMW
local truelch_terran_fmw = require(scriptPath .. "fmw/FMW") --not needed?
local truelch_terran_fmwApi = require(scriptPath .. "fmw/api") --that's what I needed!



----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

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
end

local function gameData()
    if GAME.truelch_TerranMechs == nil then
        GAME.truelch_TerranMechs = {}
    end

    return GAME.truelch_TerranMechs
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_TerranMechs == nil then
        mission.truelch_TerranMechs = {}
    end

    return mission.truelch_TerranMechs
end


----------------------------------------------- CUSTOM FUNCTIONS -----------------------------------------------

local function applyModeOnPawn(pawn, weaponIdx)
    local p = pawn:GetId()
    local fmw = truelch_terran_fmwApi:GetSkill(p, weaponIdx, false)

    if fmw == nil then
        return
    end

    --LOG("(before mode)")

    local mode = fmw:FM_GetMode(p) --works!

    --LOG("applyModeOnPawn(pawn: " .. pawn:GetType() .. ")")

    if mode == "truelch_HellMode1" then
        --LOG("(apply) Hellion")
        pawn:SetMoveSpeed(4)
        local healthLost = pawn:GetMaxHealth() - pawn:GetHealth()
        local newMaxHealth = pawn:GetMaxHealth() + 1
        --LOG("(before apply hellion) pawn health: " .. tostring(pawn:GetHealth()))
        --LOG("(before apply hellion) pawn max health: " .. tostring(pawn:GetMaxHealth()))
        --LOG("(before apply hellion) pawn base max health: " .. tostring(pawn:GetBaseMaxHealth()))
        --LOG("(before apply hellion) healthLost: " .. tostring(healthLost))
        --pawn:SetMaxHealth(newMaxHealth)
        --pawn:SetHealth(newMaxHealth - healthLost)
        --LOG("(after apply hellion) pawn health: " .. tostring(pawn:GetHealth()))
        --LOG("(after apply hellion) pawn max health: " .. tostring(pawn:GetMaxHealth()))
        --LOG("(after apply hellion) pawn base max health: " .. tostring(pawn:GetBaseMaxHealth()))
        if pawn:GetType() == "HellMech" then
            pawn:SetCustomAnim("hellion")
        end
    elseif mode == "truelch_HellMode2" then
        --LOG("(apply) Hellbat")
        pawn:SetMoveSpeed(2)
        local healthLost = pawn:GetMaxHealth() - pawn:GetHealth()
        local newMaxHealth = pawn:GetMaxHealth() - 1
        --LOG("(before apply hellbat) pawn health: " .. tostring(pawn:GetHealth()))
        --LOG("(before apply hellbat) pawn max health: " .. tostring(pawn:GetMaxHealth()))
        --LOG("(before apply hellbat) pawn base max health: " .. tostring(pawn:GetBaseMaxHealth()))
        --LOG("(before apply hellbat) healthLost: " .. tostring(healthLost))
        --pawn:SetMaxHealth(newMaxHealth)
        --pawn:SetHealth(newMaxHealth - healthLost)
        --LOG("(after apply hellbat) pawn health: " .. tostring(pawn:GetHealth()))
        --LOG("(after apply hellbat) pawn max health: " .. tostring(pawn:GetMaxHealth()))
        --LOG("(after apply hellbat) pawn base max health: " .. tostring(pawn:GetBaseMaxHealth()))
        if pawn:GetType() == "HellMech" then
            pawn:SetCustomAnim("hellbat")
        end
    elseif mode == "truelch_VikingMode1" then
        --LOG("(apply) Viking Fighter")
        pawn:SetMoveSpeed(4)
        pawn:SetFlying(true)
        if pawn:GetType() == "VikingMech" then
            pawn:SetCustomAnim("viking_fighter")
        end
        --LOG(" --- OK!")
    elseif mode == "truelch_VikingMode2" then
        --LOG("(apply) Viking Assault")
        pawn:SetMoveSpeed(3)
        pawn:SetFlying(false)
        if pawn:GetType() == "VikingMech" then
            pawn:SetCustomAnim("viking_assault")
        end
        --LOG(" --- OK!")
    elseif mode == "truelch_CrucioMode1" then
        --LOG("(apply) Crucio Tank")
        pawn:SetMoveSpeed(3)
        --pawn:SetPushable(true)
        if pawn:GetType() == "CrucioMech" then
            pawn:SetCustomAnim("crucio_tank")
        end
        --LOG(" --- OK!")
    elseif mode == "truelch_CrucioMode2" then
        --LOG("(apply) Crucio Siege")
        pawn:SetMoveSpeed(0)
        --pawn:SetPushable(false)
        if pawn:GetType() == "CrucioMech" then
            pawn:SetCustomAnim("crucio_siege")
        end
        --LOG(" --- OK!")
    elseif mode == "truelch_LiberatorMode1" then --------NEW!!!
        --LOG("(apply) Liberator Fighter")
        pawn:SetMoveSpeed(2)
        --pawn:SetPushable(true)
        if pawn:GetType() == "LiberatorMech" then
            pawn:SetCustomAnim("liberator_fighter")
        end
        --LOG(" --- OK!")
    elseif mode == "truelch_LiberatorMode2" then --------NEW!!!
        --LOG("(apply) Liberator Defender")
        pawn:SetMoveSpeed(0)
        --pawn:SetPushable(false)
        if pawn:GetType() == "LiberatorMech" then
            pawn:SetCustomAnim("liberator_defender")
        end
        --LOG(" --- OK!")
    end
end

--function HOOK_onMissionStart() ?????????
--HOOK_onMissionNextPhaseCreated() ?
--HOOK_onPostLoadGame() --Needed when we continue the game
--HOOK_onNextTurnHook()
local function applyModes()
    --LOG("applyModes")
    if isMissionBoard() then
        --The following doesn't work with my Mech Divers / Hell Breachers mod (after a new Mech is spawned)
        --[[
        for i = 0, 2 do
            local pawn = Board:GetPawn(i)
            applyModeOnPawn(pawn, 1)
            applyModeOnPawn(pawn, 2)
        end
        ]]

        for j = 0, 7 do
            for i = 0, 7 do
               local pawn = Board:GetPawn(Point(i, j))
               if pawn ~= nil and pawn:IsMech() then
                    applyModeOnPawn(pawn, 1)
                    applyModeOnPawn(pawn, 2)
                end
            end
        end
    end
end

--I forgot to include upgraded versions of the weapons!
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

--TODO: check if it's a real mission or the test mission.
--If it's a test mission, don't disable transformation!
local function setMorphWeaponSwitchModeDisabledB(p, b, index)

    --So you can switch and move around in the test mission
    local mission = GetCurrentMission()
    if mission == Mission_Test then
        return
    end

    local fmwId = truelch_terran_fmwApi:GetSkillId(p, index)
    local fmw = truelch_terran_fmwApi:GetSkill(p, index, false)

    if fmw == nil then
        return
    end
    
    for _,v in pairs(transformWeapons) do
        if v == fmwId then
            fmw:FM_SetModeSwitchDisabled(p, b)
        end
    end
end

local function setMorphWeaponSwitchModeDisabled(p, b)
    setMorphWeaponSwitchModeDisabledB(p, b, 1)
    setMorphWeaponSwitchModeDisabledB(p, b, 2)
end

local function enableSwitchForAllMechs()
    --The following doesn't work with my Mech Divers / Hell Breachers mod (after a new Mech is spawned)
    --[[
    for i = 0, 2 do
        local pawnId = Board:GetPawn(i):GetId()
        setMorphWeaponSwitchModeDisabled(pawnId, false)
    end
    ]]

    --Hoping that we don't have mechs outside of Board... (orbital stuff? But they can't die anyway?)
    for j = 0, 7 do
        for i = 0, 7 do
            local pawn = Board:GetPawn(Point(i, j))
            if pawn ~= nil and pawn:IsMech() then
                local pawnId = pawn:GetId()
                setMorphWeaponSwitchModeDisabled(pawnId, false)
            end
        end
    end
end

-- TEST RETURN TO DEFAULT MODE FOR ALL MECHS --
--FM_SetMode(p, mode) --FMW, api.lua, line 205

local function returnToDefaultModeB(pawn, pawnId, index)
    --LOG("returnToDefaultModeB(p: " .. pawnId .. ", index: " .. tostring(index) .. ")")

    local fmwId = truelch_terran_fmwApi:GetSkillId(pawnId, index)

    --LOG("fmwId: " .. tostring(fmwId))

    local fmw = truelch_terran_fmwApi:GetSkill(pawnId, index, false)

    if fmw == nil then
        return
    end

    --LOG("FMW exists! pawn:GetType(): " .. pawn:GetType())
    
    --Big if
    --if fmwId == "truelch_HellMode2" then
    if fmwId == "truelch_HellWeapon" or
        fmwId == "truelch_HellWeapon_A" or
        fmwId == "truelch_HellWeapon_B" or
        fmwId == "truelch_HellWeapon_AB" then
        --LOG("Changing hellbat to hellion!")
        --fmw:FM_SetMode(pawnId, "truelch_HellMode1")
        pawn:SetMoveSpeed(4)
        if pawn:GetType() == "HellMech" then
            pawn:SetCustomAnim("hellion")
        end
    --elseif fmwId == "truelch_VikingMode2" then
    elseif fmwId == "truelch_VikingWeapon" or
        fmwId == "truelch_VikingWeapon_A" or
        fmwId == "truelch_VikingWeapon_B" or
        fmwId == "truelch_VikingWeapon_AB" then
        --LOG("Changing viking's assault mode to fighter mode!")
        --fmw:FM_SetMode(pawnId, "truelch_VikingMode1")
        pawn:SetMoveSpeed(4)
        pawn:SetFlying(true)
        if pawn:GetType() == "VikingMech" then
            pawn:SetCustomAnim("viking_fighter")
        end
    --elseif fmwId == "truelch_CrucioMode2" then
    elseif fmwId == "truelch_CrucioWeapon" or
        fmwId == "truelch_CrucioWeapon_A" or
        fmwId == "truelch_CrucioWeapon_B" or
        fmwId == "truelch_CrucioWeapon_AB" then
        --LOG("Changing crucio's siege mode to tank mode!")
        --fmw:FM_SetMode(pawnId, "truelch_CrucioMode1")
        pawn:SetMoveSpeed(3)
        --pawn:SetPushable(true)
        if pawn:GetType() == "CrucioMech" then
            pawn:SetCustomAnim("crucio_tank")
        end
    end
end

local function returnToDefaultMode(pawn, pawnId)
    --LOG("returnToDefaultMode(pawnId: " .. tostring(pawnId) .. ")")
    returnToDefaultModeB(pawn, pawnId, 1)
    returnToDefaultModeB(pawn, pawnId, 2)
end

local function returnToDefaultModeForAllMechs()
    --LOG("returnToDefaultModeForAllMechs()")
    --The following doesn't work with my Mech Divers / Hell Breachers mod (after a new Mech is spawned)
    --[[
    for i = 0, 2 do
        local pawn = Board:GetPawn(i)
        local pawnId = pawn:GetId()
        returnToDefaultMode(pawn, pawnId)
    end
    ]]

    for j = 0, 7 do
        for i = 0, 7 do
            local pawn = Board:GetPawn(Point(i, j))
            if pawn ~= nil and pawn:IsMech() then
                local pawnId = pawn:GetId()
                returnToDefaultMode(pawn, pawnId)
            end
        end
    end
end


----------------------------------------------- HOOKS -----------------------------------------------

local HOOK_onPawnUndoMove = function(mission, pawn, undonePosition)
    setMorphWeaponSwitchModeDisabled(pawn:GetId(), false) --Enable switch
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
    if pawn ~= nil and weaponId == "Move" then
        setMorphWeaponSwitchModeDisabled(pawn:GetId(), true) --Disable switch
    end
end

--maybe only useful for the first turn
local function HOOK_onNextTurnHook()
    --LOG("HOOK_onNextTurnHook()")
    if Game:GetTeamTurn() == TEAM_PLAYER then
        --LOG(" -> TEAM_PLAYER")
        enableSwitchForAllMechs()
        --not needed anymore as we change non-temporary stats
        --well, it seems that I DO need it for the turn reset
        applyModes()
    end
end

local function HOOK_onPostLoadGame()
    modApi:runLater(function()
        --LOG("\n1 frame later\n")
        --Board not nil here! LET'S GOOOO
        --applyModes()
        --Adding some frames to let FMW init itself too (not sure about this)
        modApi:runLater(function()
            --LOG("\n2 frames later\n")
            modApi:runLater(function()
                --LOG("\n3 frames later\n")
                modApi:runLater(function()
                    --LOG("\n4 frames later\n")
                    modApi:runLater(function()
                        --LOG("\n5 frames later\n")
                        modApi:runLater(function()
                            --LOG("\n6 frames later\n")
                            modApi:runLater(function()
                                applyModes() --test, really not sure about this
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)
end

local function HOOK_onMissionStart(mission)
    --LOG("HOOK_onMissionStart()")
    returnToDefaultModeForAllMechs()
end

local function HOOK_onMissionEnd(mission)
    --LOG("HOOK_onMissionEnd()")
    enableSwitchForAllMechs() --to be sure they can use the morph
    returnToDefaultModeForAllMechs()
end

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addSkillEndHook(HOOK_onSkillEnd) --truelch_terran_ModApiExt:addSkillEndHook(HOOK_onSkillEnd)
    modapiext:addPawnUndoMoveHook(HOOK_onPawnUndoMove) --truelch_terran_ModApiExt:addPawnUndoMoveHook(HOOK_onPawnUndoMove)
    modApi:addPostLoadGameHook(HOOK_onPostLoadGame)
    modApi:addMissionStartHook(HOOK_onMissionStart)
    --modApi:addMissionEndHook(HOOK_onMissionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)