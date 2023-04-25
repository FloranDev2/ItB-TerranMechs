---- todo
-----> ui code looks meh
-----> learn how to write better ui code
-----> fix ui for when player has fm movement and fm passive

atlas_FiringModeWeaponFramework = atlas_FiringModeWeaponFramework or {vers, hkRegistry = {}, repair = {}, move = {}}
local aFMWF = atlas_FiringModeWeaponFramework

local this = {vers = "8.2", modeSelectionHK}
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local resources = mod.resourcePath

local api = require(path.."fmw/api")

local modApiExt = modApiExt_internal.getMostRecent()
local atlaslib = require(path.."fmw/libs/ATLASlib")

local Ui2 = require(path .."fmw/libs/ui/Ui2")
local cover = require(path.."fmw/libs/ui/cover2")
local clip = require(path .."fmw/libs/clip")
local hotkey = require(path.."fmw/libs/hotkey")
local tlen = atlaslib.hashLen

local img_modeswitch_icon = sdlext.surface(path.."fmw/icon_mode_switch.png")
local img_hotkey_holder = sdlext.surface(path.."fmw/icon_hotkey_holder.png")
local movespeed_icon = sdlext.surface("img/combat/icons/icon_move.png")

local font_hk = sdlext.font("fonts/JustinFont12.ttf", 11)
local font_limited = sdlext.font("fonts/JustinFont12Bold.ttf", 11)
local limited_textset = deco.textset(deco.colors.white, sdl.rgb(7, 10, 18), 1)

local modeBtns = {}
local modeSwitchButton = nil
local modeSwitchButton2 = nil
local modeSwitchPanel = nil

aFMWF.repair = aFM_WeaponTemplate:new{
	aFM_ModeList = nil,
	aFM_ModeSwitchDesc = nil
}

aFMWF.move = aFM_WeaponTemplate:new{
	aFM_ModeList = nil,
	aFM_ModeSwitchDesc = nil
}

function aFM_WeaponTemplate:FM_RegisterHK(p)
	local id = api:GetSkillId(p, self)

	aFMWF.hkRegistry[id] = this.modeSelectionHK
end

local hotkeys = {
	[1] = 49,
	[2] = 50,
	[3] = 51,
	[4] = 52,
	[5] = 53,
	[6] = 54,
	[7] = 55,
	[8] = 56,
	[9] = 57,
	[10] = 48
}

local function modeSelectionHKChar(p, weapon)
	local hk = aFMWF.hkRegistry[api:GetSkillId(p, weapon)]

	local char = {
		[101] = "E",
		[102] = "F",
		[99]  = "C",
		[116] = "T",
		[-1]  = nil
	}

	return char[hk]
end

local function createHotkeyUi(parent, x, y, hk)
	if not hk then return end

	parent.hk = Ui2()
		:widthpx(18):heightpx(18)
		:decorate({
			DecoFrame(),
			DecoAlign(1, 0), DecoCAlignedText(hk, font_hk)
		})
		:addTo(parent)

	parent.hk.draw = function(uiself, screen)
		uiself:pospx(x, y)

		Ui2.draw(uiself, screen)
	end
end

local function getPos(p)
	local xOffset = 140 * (tlen(atlaslib:getPoweredWeapons(p)) - 1)

	return Location['mech_box'].x + (330 + xOffset), Location['mech_box'].y - 90
end

local function modeSwitchButtonOpen()
	return modeSwitchButton or modeSwitchButton2
end

local function closeModePanel()
	if modeSwitchPanel then
		for _, btn in pairs(modeBtns) do
			btn.hk:detach(); btn:detach()
		end

		if modeSwitchPanel.hk then
			modeSwitchPanel.hk:detach()
		end

		modeSwitchPanel:detach()
		modeSwitchPanel = nil
		modeBtns = {}
	end
end

local function openModePanel()
	local root = sdlext.getUiRoot()
	local weapon, _, owner = api:GetActiveSkill()

	local ownerSpace = owner:GetSpace()

	local width = (50 * #weapon.aFM_ModeList) + 20

	Game:TriggerSound("/ui/general/button_confirm")

	modeSwitchPanel = Ui2()
		:widthpx(width):heightpx(80)
		:decorate({ DecoFrame() })
		:addTo(root)

		cover {
			align = {x = -5, y = -5},
			size = {w = width, h = 80}
		}:addTo(modeSwitchPanel)

		createHotkeyUi(modeSwitchPanel, width - 20, 59, modeSelectionHKChar(ownerSpace, weapon))

	modeSwitchPanel.draw = function(uiself, screen)
		local x, y = getPos(ownerSpace)
		uiself:pospx(x, y)

		if uiself.hk then
			uiself.hk:pospx(width - 20, 59)
		end

		clip(Ui2, uiself, screen)
	end

	for i, mode in ipairs(weapon.aFM_ModeList) do
		local tt = string.format("%s\n\n%s", _G[mode].aFM_name, _G[mode].aFM_desc)
		local icon = sdlext.surface(_G[mode].aFM_icon)

		local modeBtn = Ui2()
			:widthpx(36):heightpx(60)
			:decorate({
				DecoButton(),
				DecoAlign(-8, -2), DecoSurface(icon),
				DecoAlign(-23, -15), DecoCAlignedText('', font_limited),
			})
			:settooltip(tt)
			:addTo(modeSwitchPanel)

			createHotkeyUi(modeBtn, 11, 35, i)

		modeBtn.id = mode
		modeBtn.mdisabled = false
		modeBtn.hotkey = hotkeys[i] or nil

		modeBtn.draw = function(uiself, screen)
			uiself:pospx(10 + 50 * (i - 1), 8)

			Ui2.draw(uiself, screen)
		end

		modeBtn.clicked = function(uiself, button)
			if button == 1 and not uiself.mdisabled then
				if mode ~= weapon:FM_GetMode(ownerSpace) then
					weapon:FM_OnModeSwitch(ownerSpace)
				end

				weapon:FM_SetMode(ownerSpace, mode)
				closeModePanel()
			elseif button == 1 then
				Game:TriggerSound("/ui/general/button_invalid")
			end
		end

		local buttonColour = deco.colors.button
		local borderColour = deco.colors.buttonborder
		local limited = weapon:FM_GetUses(ownerSpace, mode)

		if _G[mode].aFM_limited then
			modeBtn.decorations[5] = DecoCAlignedText(limited, font_limited, limited_textset)
		end

		if limited == 0 then
			modeBtn.mdisabled = true
			buttonColour = deco.colors.buttondisabled
			borderColour = deco.colors.buttonborderdisabled
		end

		if mode == weapon:FM_GetMode(ownerSpace) then
			borderColour = deco.colors.buttonborderhl
		end

		modeBtn.decorations[1] = DecoButton(buttonColour, borderColour)

		modeBtns[#modeBtns+1] = modeBtn
	end
end

local function closeModeSwitchButton()
	if modeSwitchButton then
		modeSwitchButton:detach()

		if modeSwitchButton.hk then
			modeSwitchButton.hk:detach()
		end

		modeSwitchButton = nil
	end


	if modeSwitchButton2 then
		modeSwitchButton2:detach()

		if modeSwitchButton2.hk then
			modeSwitchButton2.hk:detach()
		end

		modeSwitchButton2 = nil
	end
end

local function openModeSwitchButton()
	local root = sdlext.getUiRoot()
	local weapon, _, owner = api:GetActiveSkill()

	local ownerSpace = owner:GetSpace()
	local currentMode = weapon:FM_GetMode(ownerSpace)

	local tt = string.format("%s\n\n%s", weapon.aFM_ModeSwitchDesc, _G[currentMode].aFM_desc)
	local icon = sdlext.surface(_G[currentMode].aFM_icon)

	local limited = weapon:FM_GetUses(ownerSpace, currentMode)
	local hk = modeSelectionHKChar(ownerSpace, weapon)

	modeSwitchButton = Ui2()
		:widthpx(44):heightpx(80)
		:decorate({
			DecoButton(sdl.rgb(34, 34, 42)),
			DecoAlign(-4, 0), DecoSurface(img_modeswitch_icon),
			DecoAlign(-36, -13), DecoSurface(icon),
			DecoAlign(-23, -13), DecoCAlignedText('', font_limited)
		})
		:addTo(root)

		cover {
			align = {x = -5, y = -5},
			size = {w = 44, h = 80}
		}:addTo(modeSwitchButton)

		createHotkeyUi(modeSwitchButton, 19, 55, hk)

		modeSwitchButton:settooltip(tt)

	if limited == 0 or weapon:FM_IsModeSwitchDisabled(ownerSpace) then
		modeSwitchButton.decorations[1] = DecoButton(deco.colors.buttondisabled, deco.colors.buttonborderdisabled)
	end

	if _G[currentMode].aFM_limited then
		modeSwitchButton.decorations[7] = DecoCAlignedText(limited, font_limited, limited_textset)
	else
		modeSwitchButton.decorations[7] = DecoCAlignedText('', font_limited)
	end

	modeSwitchButton.draw = function(uiself, screen)
		local weapon, _, owner = api:GetActiveSkill()

		if weapon then
			local ownerSpace = owner:GetSpace()

			local x, y = getPos(ownerSpace)
			uiself:pospx(x, y)
		end

		clip(Ui2, uiself, screen)
	end

	modeSwitchButton.clicked = function(uiself, button)
		local weapon, _, owner = api:GetActiveSkill()
		local ownerId = owner:GetId()

		if button == 1 and not Board:IsBusy() and not weapon:FM_IsModeSwitchDisabled(ownerId) then
			if #weapon.aFM_ModeList == 2 then
				local sCurrentMode = list_indexof(weapon.aFM_ModeList, weapon:FM_GetMode(ownerId))
				local sNewMode = weapon.aFM_ModeList[sCurrentMode % 2 + 1]
				local newMode = _G[sNewMode]

				local surface = sdlext.surface(newMode.aFM_icon)
				local tooltip = string.format(
					"%s\n\n%s",
					weapon.aFM_ModeSwitchDesc,
					newMode.aFM_desc
				)

				weapon:FM_OnModeSwitch(ownerId)
				weapon:FM_SetMode(ownerId, sNewMode)

				uiself.decorations[5].surface = surface
				uiself:settooltip(tooltip)
			else
				openModePanel()
			end
		elseif button == 1 and not Board:IsBusy() then
			Game:TriggerSound("/ui/general/button_invalid")
		end
	end
end

function this:init()
	if not aFMWF.vers or modApi:isVersion(aFMWF.vers, this.vers) then
		aFMWF.vers = this.vers
	end

	modApi:appendAsset("img/icon_mode_switch.png", path.."fmw/icon_mode_switch.png")
	modApi:appendAsset("img/icon_hotkey_holder.png", path.."fmw/icon_hotkey_holder.png")

	modApi:addGenerationOption(
		"fmw_mode_hotkey",
		mod.FMW_hotkeyConfigTitle,
		mod.FMW_hotkeyConfigDesc,
		{
			strings = {"E", "F", "C", "T", "Disabled"},
			values = {101, 102, 99, 116, -1},
			value = 101
		}
	)
end


function this:load()
	require(path .. "fmw/libs/menu"):load()

	local options = mod_loader.currentModContent[mod.id].options
	this.modeSelectionHK = options["fmw_mode_hotkey"].value

	modApi:addModsLoadedHook(function()
		atlas_FMW_Loaded = false
	end)

	if not atlas_FMW_Loaded and modApi:isVersion(aFMWF.vers, this.vers) then    
		-- close the mode selection panel if the player clicks outside of it
		sdlext.addPreKeyDownHook(function(keycode)
			local weapon, weaponIdx, owner = api:GetActiveSkill()

			if weapon then
				local ownerSpace = owner:GetSpace()
				local hk = aFMWF.hkRegistry[api:GetSkillId(ownerSpace, weapon)]

				if hk ~= -1 then
					if keycode == hk and not weapon:FM_IsModeSwitchDisabled(ownerSpace) then
						if not modeSwitchPanel and not Board:IsBusy() then
							openModePanel()
						else
							closeModePanel()
						end

						return true
					elseif keycode == hk then
						Game:TriggerSound("/ui/general/button_invalid")
					end
				end

				if modeSwitchPanel then
					-- prevent weapon selection while panel is open
					for i = 1, 2 do
						if keycode == hotkey.keys[hotkey['WEAPON'..i]] then
							hotkey:suppress(hotkey['WEAPON'..i])
						end
					end

					if keycode == hotkey.keys[hotkey['REPAIR']] and not aFMWF.repair.aFM_ModeList[1] then
						hotkey:suppress(hotkey['REPAIR'])
					end

					for i, modeBtn in ipairs(modeBtns) do
						if keycode == modeBtn.hotkey and not modeBtn.mdisabled then
							if modeBtn.id ~= weapon:FM_GetMode(ownerSpace) then
								weapon:FM_OnModeSwitch(ownerSpace)
							end

							weapon:FM_SetMode(ownerSpace, modeBtn.id)
							closeModePanel()
						elseif keycode == modeBtn.hotkey then
							Game:TriggerSound("/ui/general/button_invalid")
						end
					end
				end
			end

			return false
		end)

		modApi:addMissionNextPhaseCreatedHook(function(prevM, nextM)
			nextM.atlas_CurrentFiringModes = {}
			nextM.atlas_LimitedFiringModes = {}
			nextM.atlas_DisabledModeSwitch = {}

			closeModePanel()
			closeModeSwitchButton()
		end)

		modApi:addTestMechEnteredHook(function(m)
			m.atlas_CurrentFiringModes = {}
			m.atlas_LimitedFiringModes = {}
			m.atlas_DisabledModeSwitch = {}
		end)

		modApi:addTestMechExitedHook(function(m)
			closeModeSwitchButton()
			closeModePanel()
		end)
        
        sdlext.addMainMenuEnteredHook(function()
         	closeModeSwitchButton()
			closeModePanel()   
        end)

		modApi:addMissionStartHook(function(m)
			m.atlas_CurrentFiringModes = {}
			m.atlas_LimitedFiringModes = {}
			m.atlas_DisabledModeSwitch = {}
		end)
      
     
		local assumedWeapon = {}

		modApi:addMissionUpdateHook(function(m)
			local Pawn = atlaslib:Pawn()

			for _, p in pairs(extract_table(Board:GetPawns(TEAM_MECH))) do
				local p = Board:GetPawn(p)
				local pId = p:GetId()
				local pSpace = p:GetSpace()

				--Lemonymous fix:
				--https://discord.com/channels/417639520507527189/418142041189646336/971507823768895488
				if api:HasSkill(pId) then
				    m.atlas_CurrentFiringModes[pId] = m.atlas_CurrentFiringModes[pId] or {}
				    m.atlas_LimitedFiringModes[pId] = m.atlas_LimitedFiringModes[pId] or {{}, {}, [50] = {}, [0] = {}}
				    m.atlas_DisabledModeSwitch[pId] = m.atlas_DisabledModeSwitch[pId] or {false, false, [50] = false, [0] = false}

				    for _, i in pairs({1, 2, 50, 0}) do
				        local weapon = api:GetSkill(pId, i)
				        assumedWeapon[pId] = assumedWeapon[pId] or weapon

				        if weapon then
				            weapon:FM_RegisterHK(pId)

				            m.atlas_CurrentFiringModes[pId][i] = m.atlas_CurrentFiringModes[pId][i] or weapon.aFM_ModeList[1]

				            if api:GetSkillId(pId, assumedWeapon[pId]) ~= api:GetSkillId(pId, weapon) then    
				                assumedWeapon[pId] = weapon
				                m.atlas_CurrentFiringModes[pId][i] = weapon.aFM_ModeList[1]
				            end

				            for j = 1, #weapon.aFM_ModeList do
				                local mode = weapon.aFM_ModeList[j]

				                m.atlas_LimitedFiringModes[pId][i][mode] = m.atlas_LimitedFiringModes[pId][i][mode] or _G[mode].aFM_limited or -1
				            end
				        end
				    end
				end

				--[[
				if api:HasSkill(pSpace) then
					m.atlas_CurrentFiringModes[pId] = m.atlas_CurrentFiringModes[pId] or {}
					m.atlas_LimitedFiringModes[pId] = m.atlas_LimitedFiringModes[pId] or {{}, {}, [50] = {}, [0] = {}}
					m.atlas_DisabledModeSwitch[pId] = m.atlas_DisabledModeSwitch[pId] or {false, false, [50] = false, [0] = false}

					for _, i in pairs({1, 2, 50, 0}) do
						local weapon = api:GetSkill(pSpace, i)
						assumedWeapon[pId] = assumedWeapon[pId] or weapon

						if weapon then
							weapon:FM_RegisterHK(pSpace)

							m.atlas_CurrentFiringModes[pId][i] = m.atlas_CurrentFiringModes[pId][i] or weapon.aFM_ModeList[1]

							if api:GetSkillId(pSpace, assumedWeapon[pId]) ~= api:GetSkillId(pSpace, weapon) then    
								assumedWeapon[pId] = weapon
								m.atlas_CurrentFiringModes[pId][i] = weapon.aFM_ModeList[1]
							end

							for j = 1, #weapon.aFM_ModeList do
								local mode = weapon.aFM_ModeList[j]

								m.atlas_LimitedFiringModes[pId][i][mode] = m.atlas_LimitedFiringModes[pId][i][mode] or _G[mode].aFM_limited or -1
							end
						end
					end
				end
				]]
			end

			if not Pawn or Pawn:GetArmedWeaponId() ~= 50 and aFMWF.repair.aFM_ModeList[1] then
				closeModePanel()
				aFMWF.repair.aFM_ModeList = nil
				aFMWF.repair.aFM_ModeSwitchDesc = nil
			end

			if not Pawn or Pawn:GetArmedWeaponId() ~= 0 and aFMWF.move.aFM_ModeList[1] then
				closeModePanel()
				aFMWF.move.aFM_ModeList = nil
				aFMWF.move.aFM_ModeSwitchDesc = nil
			end

			local weapon, _, owner = api:GetActiveSkill()
			local visible = weapon and owner:IsSelected() and owner:IsActive() and not modeSwitchPanel

			if not weapon then
				closeModePanel()
			end

			if visible and not modeSwitchButtonOpen() then
				openModeSwitchButton()
			end

			if not visible and modeSwitchButtonOpen() then
				closeModeSwitchButton()
			end

			if not modeSwitchPanel then
				hotkey:unsuppress(hotkey.WEAPON1)
				hotkey:unsuppress(hotkey.WEAPON2)
				hotkey:unsuppress(hotkey.REPAIR)
			end
		end)

		modApiExt:addSkillStartHook(function(m, pawn, weapon, p1, p2)
			if weapon == "Skill_Repair" then
				weapon = aFMWF.repair
			elseif weapon == "Move" then
				weapon = aFMWF.move
			else
				weapon = _G[weapon]
			end

			if weapon.aFM_ModeList and weapon.aFM_ModeList[1] then
				local mode = weapon:FM_GetMode(p1)

				if _G[mode].aFM_handleLimited == nil or _G[mode].aFM_handleLimited and weapon:FM_GetUses(p1, mode) > 0 then
					weapon:FM_SubUses(p1, mode, 1)
				end
			end
		end)

		atlas_FMW_Loaded = true
	end
end

return this
