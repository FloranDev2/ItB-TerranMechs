----------------------------------------------------- Imports

local this = {}
local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

local fmw = require(scriptPath.."fmw/api")

--
local achvExt = require(scriptPath.."libs/achievementExt") --25/04/2023: will certainly need to be updated. Anyway, let's just comment that for now
--LOG("[hellFMW] achvExt: "..tostring(achvExt))

local achievements = require(scriptPath.."achievements") --25/04/2023: let's just put aside the achievements for now
--LOG("[hellFMW] achievements: "..tostring(achievements))

----------------------------------------------------- Icons

modApi:appendAsset("img/weapons/hell_weapons.png", resources.."img/weapons/hell_weapons.png")

modApi:appendAsset("img/modes/icon_hellion.png", resources.."img/modes/icon_hellion.png")
modApi:appendAsset("img/modes/icon_hellbat.png", resources.."img/modes/icon_hellbat.png")

----------------------------------------------------- Achievements

local HEAVENS_DEVILS_GOAL = 3 --3

----------------------------------------------------- Mode 1: Hellion

truelch_HellMode1 = {
	aFM_name = "Hellion",
	aFM_desc = "Return to normal move.\nInfernal flamethrower: ignite an adjacent tile and push the next tile forward.\n\nNote: you cannot change mode after moving.",
	aFM_icon = "img/modes/icon_hellion.png",
}

CreateClass(truelch_HellMode1)

-- these functions, "targeting" and "fire," are arbitrary
function truelch_HellMode1:targeting(point)
	local points = {}
	
	for dir = 0, 3 do
		local curr = point + DIR_VECTORS[dir]
		points[#points+1] = curr
	end	

	return points
end

function truelch_HellMode1:fire(p1, p2, ret, fireDmg, immoFluid)
	--LOG("A -> is tip image: "..tostring(Board:IsTipImage()))

	local direction = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)

	--Achv
	local ignitedEnemies = 0

	--test
	local exploding2

	--Fire
	local curr = p1 + DIR_VECTORS[direction]
	local damage = SpaceDamage(p1 + DIR_VECTORS[direction])

	local exploding = Board:IsPawnSpace(curr) and Board:GetPawn(curr):IsFire()
	if exploding then
		damage.iDamage = damage.iDamage + fireDmg
		damage.sAnimation = "ExploAir1"

		-- Immolation Fluid --->
		
		if immoFluid then
			for dirImmoFluid = 0, 3 do
				local adjacentPos = curr + DIR_VECTORS[dirImmoFluid]
				exploding2 = Board:IsPawnSpace(adjacentPos) and Board:GetPawn(adjacentPos):IsFire()
				--Don't ignite yourself AND let the push space damage have both effect.
				--So here, we only do left and right
				if adjacentPos ~= p1 and adjacentPos ~= p1 + DIR_VECTORS[direction] * 2 then
					if exploding2 then
						local spaceDamage2 = SpaceDamage(adjacentPos)
						spaceDamage2.iDamage = fireDmg
						ret:AddDamage(spaceDamage2)
					else
						local immoFluidSpaceDamage = SpaceDamage(adjacentPos)
						immoFluidSpaceDamage.iFire = EFFECT_CREATE
						ret:AddDamage(immoFluidSpaceDamage)
					end
					-- Achv (Heaven's Devils) --->
					--if Board:GetPawn(adjacentPos) ~= nil and isEnemyPawn(Board:GetPawn(adjacentPos)) then
					--Let's just comment achv stuff for now
					if Board:GetPawn(adjacentPos) ~= nil and Board:GetPawn(adjacentPos):IsEnemy() then
						ignitedEnemies = ignitedEnemies + 1
					end
					-- <--- Achv (Heaven's Devils)

				end
			end
		end

		-- <--- Immolation Fluid
	end

	damage.iFire = EFFECT_CREATE
	damage.sAnimation = "flamethrower"..distance.."_"..direction
	ret:AddDamage(damage)

	--Push
	curr = p1 + DIR_VECTORS[direction] * 2
	local pushDamage = SpaceDamage(curr, 0, direction)
	--not elegant, but I had to do this to have both push and fire in the tip
	if immoFluid and exploding then
		exploding2 = Board:IsPawnSpace(curr) and Board:GetPawn(curr):IsFire()
		if exploding2 then
			pushDamage.iDamage = fireDmg
		else
			pushDamage.iFire = EFFECT_CREATE
		end
		-- Achv (Heaven's Devils) --->
		if Board:GetPawn(curr) ~= nil and Board:GetPawn(curr):IsEnemy() then
			ignitedEnemies = ignitedEnemies + 1
		end
		-- <--- Achv (Heaven's Devils)
	end
	ret:AddDamage(pushDamage)

	-- [END] Achv (Heaven's Devils) --->
	local isTargetEnemy = true
	if Board:GetPawn(p2) ~= nil then
		isTargetEnemy = Board:GetPawn(p2):IsEnemy()
	end

	--LOG("isTargetEnemy: "..tostring(isTargetEnemy)..", ignitedEnemies: "..tostring(ignitedEnemies))
	
	if not isTargetEnemy and ignitedEnemies >= HEAVENS_DEVILS_GOAL then
		ret:AddScript("completeHeavensDevils()")
	end
	-- <--- [END] Achv (Heaven's Devils)
end


----------------------------------------------------- Mode 2: Hellbat

truelch_HellMode2 = truelch_HellMode1:new{
	aFM_name = "Hellbat",
	aFM_desc = "Reduces move by 2.\nNapalm Spray: ignite and push 3 tiles in front.\n\nNote: you cannot change mode after moving.",
	aFM_icon = "img/modes/icon_hellbat.png",
}

-- these functions, "targeting" and "fire," are arbitrary
function truelch_HellMode2:targeting(point)
	local points = {}
	
	for dir = 0, 3 do
		local curr = point + DIR_VECTORS[dir]
		points[#points+1] = curr
	end	

	return points
end

function truelch_HellMode2:CustomShot(ret, p1, pos, direction, fireDmg, immoFluid, ignitedEnemies)
	--LOG("truelch_HellMode2:CustomShot(ignitedEnemies: "..tostring(ignitedEnemies)..")")
	local spaceDamage = SpaceDamage(pos, 0, direction)
	spaceDamage.iFire = EFFECT_CREATE
	spaceDamage.sAnimation = "flamethrower1_"..direction	

	local exploding = Board:IsPawnSpace(pos) and Board:GetPawn(pos):IsFire() --and fireDmg > 0
	if exploding then
		spaceDamage.iDamage = spaceDamage.iDamage + fireDmg
		spaceDamage.sAnimation = "ExploAir1"

		-- Immolation Fluid --->
		if immoFluid then
			for dirImmoFluid = 0, 3 do
				local adjacentPos = pos + DIR_VECTORS[dirImmoFluid]
				local exploding2 = Board:IsPawnSpace(adjacentPos) and Board:GetPawn(adjacentPos):IsFire()
				if adjacentPos ~= p1 then
					if exploding2 then
						local spaceDamage2 = SpaceDamage(adjacentPos)
						spaceDamage2.iDamage = fireDmg
						ret:AddDamage(spaceDamage2)
					else
						local immoFluidSpaceDamage = SpaceDamage(adjacentPos)
						immoFluidSpaceDamage.iFire = EFFECT_CREATE
						ret:AddDamage(immoFluidSpaceDamage)
					end
					-- Achv (Heaven's Devils) --->
					if Board:GetPawn(adjacentPos) ~= nil and Board:GetPawn(adjacentPos):IsEnemy() then
						ignitedEnemies = ignitedEnemies + 1
					end
					-- <--- Achv (Heaven's Devils)
				end
			end
		end
		-- <--- Immolation Fluid
	end
	ret:AddDamage(spaceDamage)

	return ignitedEnemies
end

function truelch_HellMode2:fire(p1, p2, ret, fireDmg, immoFluid)
	local direction = GetDirection(p2 - p1)
	local pos

	local ignitedEnemies = 0

	--LOG("A")

	--LEFT
	pos = p2 - DIR_VECTORS[(direction + 1)% 4]
	ignitedEnemies = self:CustomShot(ret, p1, pos, direction, fireDmg, immoFluid, ignitedEnemies)

	--FRONT
	pos = p2
	ignitedEnemies = self:CustomShot(ret, p1, pos, direction, fireDmg, immoFluid, ignitedEnemies)

	--RIGHT
	pos = p2 + DIR_VECTORS[(direction + 1)% 4]
	ignitedEnemies = self:CustomShot(ret, p1, pos, direction, fireDmg, immoFluid, ignitedEnemies)

	-- [END] Achv (Heaven's Devils) --->
	local isTargetEnemy = true
	if Board:GetPawn(p2) ~= nil then
		isTargetEnemy = Board:GetPawn(p2):IsEnemy()
	end

	if not isTargetEnemy and ignitedEnemies >= HEAVENS_DEVILS_GOAL then
		ret:AddScript("completeHeavensDevils()")
	end
	-- <--- [END] Achv (Heaven's Devils)
end


----------------------------------------------------- Skill

truelch_HellWeapon = aFM_WeaponTemplate:new{
	--Infos
	Name = "Hell Weapons",
	Description = "Hellion:\nIgnites an adjacent targets and pushes the next tile forward."
		.."\n\nHellbat: has a move reduced by 2."
		.."\nIgnites and pushes 3 tiles in front. Has a move reduced by 2."
		.."\n\nNote: you cannot change mode after moving.",
	Class = "Prime",

	--Menu stats
	Rarity = 1,
	PowerCost = 0, --AE (was 1 before)

	--Upgrades
	Upgrades = 2,
	UpgradeCost = { 1, 2 },

	--Art
	Icon = "weapons/hell_weapons.png",
	LaunchSound = "/weapons/flamethrower",

	--FMW
	aFM_ModeList = { "truelch_HellMode1", "truelch_HellMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Gameplay stats
	ImmolationFluid = false,
	FireDamage = 0,

	--TipImage
	TipImage = {
		Unit = Point(2,3),

		Enemy = Point(2,2),
		Enemy2 = Point(1,2),
		Enemy3 = Point(3,2),
		Enemy4 = Point(2,1),

		Target = Point(2,2),

		Mountain = Point(1,1),
		Building = Point(3,1),

        Second_Origin = Point(2,3),
        Second_Target = Point(2,2),
	}
}

Weapon_Texts.truelch_HellWeapon_Upgrade1 = "Immolation Fluid"
Weapon_Texts.truelch_HellWeapon_Upgrade2 = "Infernal Pre-Igniter"

truelch_HellWeapon_A = truelch_HellWeapon:new{
	UpgradeDescription = "When attacking units already on fire, adjacent tiles are ignited as well.",
	ImmolationFluid = true,
}

truelch_HellWeapon_B = truelch_HellWeapon:new{
	UpgradeDescription = "Deal 2 damage to enemy units that are already on fire.",
	FireDamage = 2,
}

truelch_HellWeapon_AB = truelch_HellWeapon:new{
	ImmolationFluid = true,
	FireDamage = 2,
}

function truelch_HellWeapon:GetTargetArea(point)
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

function truelch_HellWeapon:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)

	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se, self.FireDamage, self.ImmolationFluid)
	end

	return se
end

function truelch_HellWeapon:FM_OnModeSwitch(p)
	if self:FM_GetMode(p) == "truelch_HellMode1" then
		Pawn:SetMoveSpeed(2)

		--LOG("(before) pawn base max health: " .. tostring(Pawn:GetBaseMaxHealth()))

		local healthLost = Pawn:GetMaxHealth() - Pawn:GetHealth()
		local newMaxHealth = Pawn:GetMaxHealth() + 1

		--LOG("(before hellion -> hellbat) pawn health: " .. tostring(Pawn:GetHealth()))
		--LOG("(before hellion -> hellbat) pawn max health: " .. tostring(Pawn:GetMaxHealth()))
		--LOG("(before hellion -> hellbat) pawn base max health: " .. tostring(Pawn:GetBaseMaxHealth()))
		--LOG("(before hellion -> hellbat) healthLost: " .. tostring(healthLost))

		--Pawn:SetMaxHealth(newMaxHealth)
		--Pawn:SetHealth(math.max(newMaxHealth - healthLost, 1))

		--LOG("(after hellion -> hellbat) pawn health: " .. tostring(Pawn:GetHealth()))
		--LOG("(after hellion -> hellbat) pawn max health: " .. tostring(Pawn:GetMaxHealth()))
		--LOG("(after hellion -> hellbat) pawn base max health: " .. tostring(Pawn:GetBaseMaxHealth()))

        if Pawn:GetType() == "HellMech" then
            Pawn:SetCustomAnim("hellbat")
        else
        	LOG("WTF pawn: " .. pawn:GetType())
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	elseif self:FM_GetMode(p) == "truelch_HellMode2" then
		Pawn:SetMoveSpeed(4)

		local healthLost = Pawn:GetMaxHealth() - Pawn:GetHealth()
		local newMaxHealth = Pawn:GetMaxHealth() - 1

		--LOG("(before hellbat -> hellion) pawn health: " .. tostring(Pawn:GetHealth()))
		--LOG("(before hellbat -> hellion) pawn max health: " .. tostring(Pawn:GetMaxHealth()))
		--LOG("(before hellion -> hellbat) pawn base max health: " .. tostring(Pawn:GetBaseMaxHealth()))
		--LOG("(before hellbat -> hellion) healthLost: " .. tostring(healthLost))
	
		--Pawn:SetHealth(math.max(newMaxHealth - healthLost, 1))
		--Pawn:SetMaxHealth(newMaxHealth)

		--LOG("(after hellbat -> hellion) pawn health: " .. tostring(Pawn:GetHealth()))
		--LOG("(after hellbat -> hellion) pawn max health: " .. tostring(Pawn:GetMaxHealth()))
		--LOG("(after hellion -> hellbat) pawn base max health: " .. tostring(Pawn:GetBaseMaxHealth()))
		
        if Pawn:GetType() == "HellMech" then
            Pawn:SetCustomAnim("hellion")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	end
end

return this