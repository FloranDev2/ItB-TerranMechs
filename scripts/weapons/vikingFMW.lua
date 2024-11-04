----------------------------------------------------- Imports

local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

local fmw = require(path.."fmw/api") 


----------------------------------------------------- Icons

modApi:appendAsset("img/weapons/viking_weapons.png", resources .."img/weapons/viking_weapons.png")

modApi:appendAsset("img/modes/icon_viking_fighter.png", resources .. "img/modes/icon_viking_fighter.png")
modApi:appendAsset("img/modes/icon_viking_assault.png", resources .. "img/modes/icon_viking_assault.png")

--Effects
modApi:appendAsset("img/effects/shotup_torpedo1.png", resources .. "img/effects/shotup_torpedo1.png")
modApi:appendAsset("img/effects/shotup_torpedo2.png", resources .. "img/effects/shotup_torpedo2.png")
modApi:appendAsset("img/effects/shotup_torpedo3.png", resources .. "img/effects/shotup_torpedo3.png")

----------------------------------------------------- Custom functions

--Should it only target enemy pawns?
--Would be too powerful I guess
local function computeSideAoE(ret, sidePos, dir)
	local pawn = Board:GetPawn(sidePos)
	if pawn ~= nil and pawn:IsEnemy() then
		local aoeSpaceDamage = SpaceDamage(sidePos, 1)
		--aoeSpaceDamage.sAnimation = "explopush1_"..dir
		--aoeSpaceDamage.sAnimation = "explopush1_"..dir
		aoeSpaceDamage.sAnimation = "ExploArt1" --above looks like it'd push
		ret:AddDamage(aoeSpaceDamage)
	end
end

local function computeAoE(ret, p, dir, aoe)
	computeSideAoE(ret, p + DIR_VECTORS[(dir-1)%4], (dir-1)%4)
	computeSideAoE(ret, p + DIR_VECTORS[(dir+1)%4], (dir+1)%4)
end


----------------------------------------------------- Mode 1: Fighter

truelch_VikingMode1 = {
	aFM_name = "Fighter Mode",
	aFM_desc = "Flying and 4 move.\nLanzer Torpedoes: hit either the first ground or first air target.\nDeal 2 damage to flying or massive enemy units.",
	aFM_icon = "img/modes/icon_viking_fighter.png",
	--Custom
	BonusDmg = 2,
	--Targeting
	PhaseThroughBuilding = true,
	PhaseThroughMountain = true,
	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/weapons/rocket_launcher",
	Explo = "explopush1_",
	NormalUpShot = "effects/shotup_torpedo_normal.png",
	PhobosUpShot = "effects/shotup_torpedo_phobos.png",
}

CreateClass(truelch_VikingMode1)

function truelch_VikingMode1:targeting(point)
	local points = {}

	for dir = 0, 3 do
		local hasFoundGroundTgt = false
		local hasFoundAirTgt = false

		for i = 1, 8 do
			local curr = point + DIR_VECTORS[dir] * i

			if not Board:IsValid(curr) then --non valid points are point outside the map [0;7]
				break
			end

			local pawn = Board:GetPawn(curr)

			if pawn ~= nil then
				if pawn:IsFlying() then
					if hasFoundAirTgt == false then
						points[#points+1] = curr
					end
					hasFoundAirTgt = true
				else
					if hasFoundGroundTgt == false then
						points[#points+1] = curr
					end
					hasFoundGroundTgt = true
				end
			elseif Board:IsBlocked(curr, PATH_PROJECTILE) then
				local terrain = Board:GetTerrain(curr)
				if terrain == TERRAIN_MOUNTAIN and self.PhaseThroughMountain == false then
					break
				end
				if terrain == TERRAIN_BUILDING and self.PhaseThroughBuilding == false then
					break
				end
			end
		end
	end

	return points
end

function truelch_VikingMode1:GetProjectileEnd(p1, p2)
	profile = PATH_PHASE

	local direction = GetDirection(p2 - p1)

	local target = p1 + DIR_VECTORS[direction]

	while not Board:IsBlocked(target, profile) do
		target = target + DIR_VECTORS[direction]
	end

	if not Board:IsValid(target) then
		target = target - DIR_VECTORS[direction]
	end
	
	return target
end

function truelch_VikingMode1:fire(p1, p2, ret, phobos, aoe)
	local dir = GetDirection(p2 - p1)
	local targetPawn = Board:GetPawn(p2)
	local dmg = 0

	--Bonus damage against Flying and Massive units!
	if targetPawn ~= nil then
		local bonusDmgOk = targetPawn:IsFlying() or targetPawn:IsMassive()
		bonusDmgOk = bonusDmgOk and targetPawn:IsEnemy()
		if bonusDmgOk then
			dmg = self.BonusDmg
			if phobos then
				dmg = dmg + 1
			end
		end
	end

	local soundDamage = SpaceDamage(p2)
	soundDamage.sSound = self.LaunchSound
	ret:AddDamage(soundDamage)

	local spaceDamage = SpaceDamage(p2, dmg, dir)

	--Took inspiration from Djinn's Tamed Monsters Impaling Spikes to improve this artillery visuals	
	
	local fakedamage = SpaceDamage(p2)

	if phobos == false then
		--2 Projectiles		
		ret:AddArtillery(fakedamage,"effects/shotup_torpedo1.png", NO_DELAY)
		ret:AddDamage(fakedamage)

		--Edit: this also sometimes bug?!
		--ret:AddDelay(0.015) --0.15 seems to be the limit before it screws arc
		--ret:AddDelay(0.025) --was better looking, but for some reason, it causes the arc to bug

		ret:AddArtillery(fakedamage,"effects/shotup_torpedo2.png", FULL_DELAY)

		ret:AddDamage(fakedamage)

		if dmg > 0 then
			spaceDamage.sAnimation = "explopush1_"..dir
		else
			spaceDamage.sAnimation = "airpush_"..dir
		end

		ret:AddDamage(spaceDamage)

	else
		--3 Projectiles
		ret:AddArtillery(fakedamage,"effects/shotup_torpedo1.png", NO_DELAY)
		--ret:AddDelay(0.015)
		ret:AddArtillery(fakedamage,"effects/shotup_torpedo2.png", NO_DELAY)
		--ret:AddDelay(0.015)
		ret:AddArtillery(fakedamage,"effects/shotup_torpedo3.png", FULL_DELAY)

		ret:AddDamage(fakedamage)

		if dmg > 0 then
			spaceDamage.sAnimation = "explopush2_"..dir
		else
			spaceDamage.sAnimation = "airpush_"..dir
		end

		ret:AddDamage(spaceDamage)
	end

	if aoe then
		local max = 2
		if phobos then max = 3 end
		for i = 1, max do
			computeAoE(ret, p2, dir, aoe)
		end
	end
end


----------------------------------------------------- Mode 2: Assault

truelch_VikingMode2 = truelch_VikingMode1:new{
	aFM_name = "Assault Mode",
	aFM_desc = "Move: 3 (ground).\nTwin Gatling Cannons: fire 2 projectiles that deal 1 damage each.\nMax range: 3.",
	aFM_icon = "img/modes/icon_viking_assault.png",	
	--Art
	impactsound = "/impact/generic/explosion_large",
	LaunchSound = "/general/combat/explode_small",
	--Custom art
	UpShot = "", --Old
	MuzzleEffectArt = "effects/truelch_gatling_muzzle_flash_",
	--Common
	Range = 3,
	Damage = 1,
	Shots = 2,
}

function truelch_VikingMode2:targeting(point)
	--LOG("------------------------------------- truelch_VikingMode2:targeting(point)")
	local points = {}
	
	for dir = 0, 3 do
		for i = 1, self.Range do
			local curr = point + DIR_VECTORS[dir] * i
			points[#points+1] = curr

			if not Board:IsValid(curr) then --non valid points are point outside the map [0;7]
				break
			end

			if Board:IsBlocked(curr, PATH_PHASING) then
				break
			end
		end
	end	

	return points
end

--Animation doesn't work but for some reason, it fixed the incorrect custom arc
function truelch_VikingMode2:CustomShot(ret, p1, target, dir, aoe)
	--LOG("CustomShot(p1: " .. p1:GetString() .. ", target: " .. target:GetString() .. ")")
	local spaceDamage = SpaceDamage(target, self.Damage)
	--spaceDamage.sAnimation = "explopush2_"..dir
	spaceDamage.sAnimation = "ExploArt1"

	spaceDamage.sSound = "/impact/generic/explosion"

	ret:AddArtillery(spaceDamage, self.UpShot)

	-- Muzzle flash effect --->
	local muzzle = SpaceDamage(p1 + DIR_VECTORS[dir])
	local muzzleAnim = "truelch_gatling_muzzle_flash_" .. dir
	muzzle.sAnimation = muzzleAnim
	ret:AddDamage(muzzle)
	-- <--- Muzzle flash effect

	--Area of Effect (left and right)
	if aoe then
		computeAoE(ret, target, dir, aoe)
	end
end

--For now, it assumes that this ability always has damage = 1
--TODO: shoot at buildings and mountains: Ok?
--Problem: can't predict building resist
function truelch_VikingMode2:fire(p1, p2, ret, phobos, aoe)
	local direction = GetDirection(p2 - p1)
	local target
	local spaceDamage
	local currPawn

	local shots = self.Shots	
	if phobos then
		shots = shots + 1
	end
	local remainingShots = shots
	
	local dmgInflicted = 0
	local dist = 0
	local curr
	local health
	local maxAttacksOnThisTarget
	local forLoopMax

	local terrainHp = 0
	local isObstacle

	--Loop!
	local loopContinue = true
	while loopContinue do
		--LOG("Loop iteration")
		dist = dist + 1
		curr = Point(p1 + DIR_VECTORS[direction] * dist)

		--Check valid --->
		if not Board:IsValid(curr) then
			--Outside of map!
			curr = Point(p1 + DIR_VECTORS[direction] * (dist - 1)) --set to previous point (assuming we can't shoot at ourself!)

			--shoots remaining projectile
			for i = 1, remainingShots do
				self:CustomShot(ret, p1, curr, direction, aoe)				
			end

			--end
			loopContinue = false
			break
		end

		if dist > self.Range then
			--Out of range!
			curr = Point(p1 + DIR_VECTORS[direction] * (dist - 1)) --set to previous point (assuming we can't shoot at ourself!)

			--shoots remaining projectile
			for i = 1, remainingShots do
				self:CustomShot(ret, p1, curr, direction, aoe)
			end

			--end
			loopContinue = false
			break
		end
		-- <--- Check valid

		currPawn = Board:GetPawn(curr)

		if currPawn ~= nil then
			--Pawns exists. Shoot as many projectiles as needed to its position

			--health --->
			health = currPawn:GetHealth()
			if currPawn:IsAcid() then
				health = math.ceil(health / 2)
			elseif currPawn:IsArmor() then
				--will finish all the shots here
				health = 100000 --"infinite" assuming damage = 1. Will change that when I've time
			end

			if currPawn:IsMech() then --Even dead mech must block projectiles!
				health = 100000 --"infinite" assuming damage = 1. Will change that when I've time
			end

			--other modificators
			-- -> is shield
			if currPawn:IsShield() then
				health = health + 1
			end
			-- -> is frozen (can be both frozen and shielded so, no elseif)
			if currPawn:IsFrozen() then
				health = health + 1
			end
			-- <--- health

			--Attacks
			--maxAttacksOnThisTarget = health --assuming damage == 1
			maxAttacksOnThisTarget = math.ceil(health / self.Damage)
			forLoopMax = math.min(maxAttacksOnThisTarget, shots)

			for i = 1, forLoopMax do
				self:CustomShot(ret, p1, curr, direction, aoe)
				remainingShots = remainingShots - 1
				if remainingShots <= 0 then
					--Did all the shots!
					--end
					loopContinue = false
					break
				end
			end
		elseif Board:IsBlocked(curr, PATH_PROJECTILE) then
			terrainHp = Board:GetHealth(curr)
			--Note: this verification is insufficient by itself: ground is considered to have 4 HP for some reason...
			--That's why I used IsBlocked

			-- Frozen -> +1 shot
			if Board:IsFrozen(curr) then
				terrainHp = terrainHp + 1
			end

			-- Shield -> +1 shot
			if Board:IsShield(curr) then
				terrainHp = terrainHp + 1
			end

			maxAttacksOnThisTarget = terrainHp
			forLoopMax = math.min(maxAttacksOnThisTarget, shots)
			for i = 1, forLoopMax do
				self:CustomShot(ret, p1, curr, direction, aoe)
				remainingShots = remainingShots - 1
				if remainingShots <= 0 then
					--Did all the shots!
					--end
					loopContinue = false
					break
				end
			end
		end
	end
end


----------------------------------------------------- Skill

truelch_VikingWeapon = aFM_WeaponTemplate:new{
	--Infos
	Name = "Viking Weapons",
	Description = "Fighter mode:\nFires a pushing projectile that phases through mountains and buildings and hits either the first ground or air target.\n+2 damage against flying or massive enemy units.\n\nAssault mode: loses 1 move and Flying.\nFires 2 projectiles that deal 1 damage each.\nMax range: 3.",
	Class = "Brute",

	--Menu stats
	Rarity = 1,	
	PowerCost = 0, --AE

	--Upgrades
	Upgrades = 2,
	UpgradeCost = { 2, 3 },

	--Art
	Icon = "weapons/viking_weapons.png",
	--LaunchSound = "/weapons/back_shot",
	LaunchSound = "",

	--FMW
	aFM_ModeList = { "truelch_VikingMode1", "truelch_VikingMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Artillery Arc
	ArtilleryHeight = 0,

	--Custom Stats
	Phobos = false,
	AoE = false,

	--TipImage
	TipImage = {
		Unit     = Point(3,3),

		CustomEnemy = "Hornet2",
		Mountain = Point(3,2),
		Enemy    = Point(3,1),
		Enemy2   = Point(2,1),
		Enemy3   = Point(4,1),
		Target   = Point(3,1),

		Building = Point(2,3),
		Friendly   = Point(1,3),
		Second_Origin = Point(3,3),
		Second_Target = Point(1,3),
	},
}

Weapon_Texts.truelch_VikingWeapon_Upgrade1 = "Phobos-Class W. Sys."
Weapon_Texts.truelch_VikingWeapon_Upgrade2 = "Ripwave Warheads"

truelch_VikingWeapon_A = truelch_VikingWeapon:new{
	UpgradeDescription = "Adds another projectile.",
	Phobos = true,
}

truelch_VikingWeapon_B = truelch_VikingWeapon:new{
	UpgradeDescription = "Each projectile deals 1 damage to enemies on the sides of the target (left and right).",
	AoE = true,

	--TipImage
	TipImage = {
		Unit = Point(2,3),
		Building = Point(2,2),
		Enemy = Point(1,1),
		Enemy2 = Point(2,1),
		Enemy3 = Point(3,1),
		Target = Point(2,1),
	},
}

truelch_VikingWeapon_AB = truelch_VikingWeapon:new{
	Phobos = true,
	AoE = true,

	--TipImage
	TipImage = {
		Unit = Point(2,3),
		Building = Point(2,2),
		Enemy = Point(1,1),
		Enemy2 = Point(2,1),
		Enemy3 = Point(3,1),
		Target = Point(2,1),
	},
}

function truelch_VikingWeapon:GetTargetArea(point)
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

function truelch_VikingWeapon:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentMode]:fire(p1, p2, se, self.Phobos, self.AoE)
	end

	return se
end

--Mode1: Fighter, Mode2: Assault
function truelch_VikingWeapon:FM_OnModeSwitch(p)
	if self:FM_GetMode(p) == "truelch_VikingMode1" then
		Pawn:SetMoveSpeed(3)
		Pawn:SetFlying(false)
        if Pawn:GetType() == "VikingMech" then
            Pawn:SetCustomAnim("viking_assault")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	elseif self:FM_GetMode(p) == "truelch_VikingMode2" then
		Pawn:SetMoveSpeed(4)
		Pawn:SetFlying(true)
        if Pawn:GetType() == "VikingMech" then
            Pawn:SetCustomAnim("viking_fighter")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	end
end

return this