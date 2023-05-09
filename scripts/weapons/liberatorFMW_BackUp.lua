local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

--local fmw = require(path.."fmw/api") 

modApi:appendAsset("img/mortar_temp_icon.png", resources.."img/mortar_temp_icon.png")
modApi:appendAsset("img/shells/icon_standard_shell.png", resources.."img/shells/icon_standard_shell.png")
modApi:appendAsset("img/shells/icon_napalm_shell.png", resources.."img/shells/icon_napalm_shell.png")
modApi:appendAsset("img/shells/icon_acid_shell.png", resources.."img/shells/icon_acid_shell.png")
modApi:appendAsset("img/shells/icon_smoke_shell.png", resources.."img/shells/icon_smoke_shell.png")

modApi:appendAsset("img/effects/shotup_standardshell_missile.png", resources.."img/effects/shotup_standardshell_missile.png")
modApi:appendAsset("img/effects/shotup_napalmshell_missile.png", resources.."img//effects/shotup_napalmshell_missile.png")
modApi:appendAsset("img/effects/shotup_acidshell_missile.png", resources.."img/effects/shotup_acidshell_missile.png")
modApi:appendAsset("img/effects/shotup_smokeshell_missile.png", resources.."img/effects/shotup_smokeshell_missile.png")



--Icons
modApi:appendAsset("img/weapons/liberator_weapons.png", resources .."img/weapons/liberator_weapons.png")

modApi:appendAsset("img/modes/icon_liberator_fighter.png", resources .. "img/modes/icon_liberator_fighter.png")
modApi:appendAsset("img/modes/icon_liberator_defender.png", resources .. "img/modes/icon_liberator_defender.png")




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
	--aFM_twoClick = true,
}

--[[
function truelch_LiberatorMode1:second_targeting(p1, p2) 
    return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
end

function truelch_LiberatorMode1:second_fire(p1, p2, p3)
    return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
end
]]

CreateClass(truelch_LiberatorMode1)

-- these functions, "targeting" and "fire," are arbitrary
function truelch_LiberatorMode1:targeting(point)
	local points = {}

	--[[
	local dir = 0 --test
	for dir = 0, 3 do
		for j = -1, 1 do
			for i = 1, 2 do
				local left = DIR_VECTORS[(dir-1)%4]
				LOG("left: " .. tostring(left))
				local curr = point + DIR_VECTORS[dir]*i + DIR_VECTORS[left]*j
				if not tableContains(points, curr) then				
					points[#points+1] = curr
				end
			end
		end
	end
	]]

	--LOG("------ truelch_LiberatorMode1:targeting")

	for j = -2, 2 do
		for i = -2, 2 do
			local curr = point + Point(i, j)
			--LOG("-------------- point: " .. point:GetString() .. ", offset: " .. Point(i, j):GetString() .. " -> curr: " .. curr:GetString())
			--LOG("-------------- point: " .. point:GetString())
			--LOG("-------------- offset: " .. Point(i, j):GetString())
			--LOG("-------------- curr: " .. curr:GetString())
			if isAuthorizedPoint(curr) then
				points[#points+1] = curr
			end
		end
	end

	return points
end

function truelch_LiberatorMode1:fire(p1, p2, se)
	local direction = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2, self.innerDamage)
	
	if ANIMS[self.innerAnim .. direction] then
		damage.sAnimation = self.innerAnim .. direction
	else
		damage.sAnimation = self.innerAnim
	end	
	
	if self.innerPush then damage.iPush = DIR_VECTORS[direction] end
	if self.innerEffect then damage['i' .. self.innerEffect] = 1 end
		
	se:AddArtillery(damage, self.image) 
	se:AddBounce(p2, self.innerBounce)

	if self.AOE then
        for dir = 0, 3 do
			local aoeD = SpaceDamage(p2 + DIR_VECTORS[dir], self.outerDamage)
				
			if ANIMS[self.outerAnim .. dir] then 
				aoeD.sAnimation = self.outerAnim .. dir
			else
				aoeD.sAnimation = self.outerAnim
			end
			
			if self.outerPush then aoeD.iPush = dir end
			if self.outerEffect then aoeD['i' .. self.outerEffect] = 1 end
				
			se:AddDamage(aoeD) 
			se:AddBounce(p2 + DIR_VECTORS[dir], self.outerBounce) 
		end	
	end	
end


----------------------------------------------------- Mode 2: Siege

truelch_LiberatorMode2 = truelch_LiberatorMode1:new{
	aFM_name = "Defender Mode",
	aFM_desc = "Makes the Liberator Mode immobile (and stable?).",
	aFM_icon = "img/shells/icon_liberator_defender.png",
	--aFM_limited = 2, 
    --aFM_twoClick = false, --true
    
	innerDamage = 1, 
	innerEffect = "Fire",
	innerAnim = "ExploAir2",
	outerDamage = 0,
	outerEffect = "Fire",
	outerAnim = "explopush2_",
	image = "effects/shotup_napalmshell_missile.png",
}

function truelch_LiberatorMode2:fire(p1, p2, se)

end

--[[
function truelch_LiberatorMode2:second_targeting(p1, p2) 
    return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
end

function truelch_LiberatorMode2:second_fire(p1, p2, p3)
    return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
end
]]

truelch_LiberatorWeapon = aFM_WeaponTemplate:new{
	--Infos
	Name = "Liberator Weapons",
	Description = "Fighter mode:\nShoots mirrored projectile in front of the Liberator.\n\nDefender mode:\nCreate a zone near the Liberator, damaging every enemy entering it.",
	Class = "Brute",

	--Menu stats
	Rarity = 1,
	PowerCost = 0,

	--Upgrades

	--TC
    --TwoClick = true, --tmp!
z
    --Art
	Icon = "weapons/liberator_weapons.png", --"mortar_temp_icon.png"
	LaunchSound = "/weapons/back_shot", --tmp

	--FMW
	aFM_ModeList = { "truelch_LiberatorMode1", "truelch_LiberatorMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",


	--TipImage
	TipImage = {
		Unit = Point(2,2) 
	}
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

--[[
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
]]

function truelch_LiberatorWeapon:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentMode = _G[self:FM_GetMode(p1)]

	--[[
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then 
		se = currentMode:second_fire(p1, p2, p3)  
	end
	]]
    
    return se
end

return this 