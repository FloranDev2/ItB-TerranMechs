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
	
atlas_ShellStd = {
	aFM_name = "Standard Shell",												 -- required
	aFM_desc = "High-explosive shell that explodes upon impact.",				 -- required
	aFM_icon = "img/shells/icon_standard_shell.png",	 						 -- required (if you don't have an image an empty string will work) 
	-- aFM_limited = 2, 														 -- optional (FMW will automatically handle uses for weapons)
	-- aFM_handleLimited = false 												 -- optional (FMW will no longer automatically handle uses for this mode if set) 
	minrange = 2,
	maxrange = 8,
	innerDamage = 2,
	innerEffect = nil, -- "Fire", "Smoke", "Acid", "Frozen" 
	innerPush = false,
	innerAnim = "ExploArt2",
	innerBounce = 2, 
	AOE = true, 
	outerDamage = 1,
	outerEffect = nil, -- "Fire", "Smoke", "Acid", "Frozen" 
	outerPush = true,
	outerAnim = "explopush1_",
	outerBounce = 1,
	impactsound = "/impact/generic/explosion_large",
	image = "effects/shotup_standardshell_missile.png",
}

CreateClass(atlas_ShellStd)

-- these functions, "targeting" and "fire," are arbitrary
function atlas_ShellStd:targeting(point)
	local points = {}

	for dir = 0, 3 do
		for i = self.minrange, self.maxrange do
			local curr = point + DIR_VECTORS[dir]*i
			points[#points+1] = curr
		end
	end
	return points
end

function atlas_ShellStd:fire(p1, p2, se)
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


atlas_ShellFire = atlas_ShellStd:new{
	aFM_name = "Napalm Shell",
	aFM_desc = "Explosive shell that sets an area on fire.",
	aFM_icon = "img/shells/icon_napalm_shell.png",
	aFM_limited = 2, 
    aFM_twoClick = true, 
    
	innerDamage = 1, 
	innerEffect = "Fire",
	innerAnim = "ExploAir2",
	outerDamage = 0,
	outerEffect = "Fire",
	outerAnim = "explopush2_",
	image = "effects/shotup_napalmshell_missile.png",
}

function atlas_ShellFire:second_targeting(p1, p2) 
    return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
end

function atlas_ShellFire:second_fire(p1, p2, p3)
    return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
end

atlas_Mortar = aFM_WeaponTemplate:new{
	Name = "Mortar",
	Description = "bloop",
	Class = "Ranged",
    TwoClick = true, 
	Icon = "mortar_temp_icon.png",
	LaunchSound = "/weapons/back_shot",
	aFM_ModeList = {"atlas_ShellStd", "atlas_ShellFire"},
	aFM_ModeSwitchDesc = "Click to change Mortar shells.",
	TipImage = {
		Unit = Point(2,2) 
	}
}


function atlas_Mortar:GetTargetArea(point)
	local pl = PointList()
	local currentShell = _G[self:FM_GetMode(point)]
    
	if self:FM_CurrentModeReady(point) then 
		local points = currentShell:targeting(point)
		
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end
	 
	return pl
end

function atlas_Mortar:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentShell = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentShell]:fire(p1, p2, se)
		se:AddSound(_G[currentShell].impactsound)
	end

	return se
end

function atlas_Mortar:IsTwoClickException(p1,p2)
	return not _G[self:FM_GetMode(p1)].aFM_twoClick 
end

function atlas_Mortar:GetSecondTargetArea(p1, p2)
	local currentShell = _G[self:FM_GetMode(p1)]
    local pl = PointList()
    
	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		pl = currentShell:second_targeting(p1, p2)
	end
    
    return pl 
end

function atlas_Mortar:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentShell = _G[self:FM_GetMode(p1)]

	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		se = currentShell:second_fire(p1, p2, p3)  
	end
    
    return se 
end

return this 