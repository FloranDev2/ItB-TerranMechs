local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

local fmw = require(path.."fmw/api")
--local weaponPreview = require(path .. "libs/weaponPreview")

--Icons
modApi:appendAsset("img/weapons/crucio_weapons.png", resources .."img/weapons/crucio_weapons.png")

modApi:appendAsset("img/modes/icon_crucio_tank.png", resources .. "img/modes/icon_crucio_tank.png")
modApi:appendAsset("img/modes/icon_crucio_siege.png", resources .. "img/modes/icon_crucio_siege.png")

----------------------------------------------------- Utility functions


----------------------------------------------------- Dummy wall (stealing it from you Lemonymous ^^)
truelch_Wall = Pawn:new{
	Health = 10,
	Flying = true,
	Neutral = true,
	DefaultTeam = TEAM_NONE,
}


----------------------------------------------------- Mode 1: Tank
truelch_CrucioMode1 = {
	aFM_name = "Tank Mode",
	aFM_desc = "Can move normally.\n90mm Twin Cannon: projectile that pushes its target and deals 1 damage.",
	aFM_icon = "img/modes/icon_crucio_tank.png",
}

CreateClass(truelch_CrucioMode1)

function truelch_CrucioMode1:targeting(point)
	local points = {}
	
	for dir = 0, 3 do
		for i = 1, 8 do
			local curr = point + DIR_VECTORS[dir] * i

			if not Board:IsValid(curr) then --non valid points are point outside the map [0;7]
				break
			end

			points[#points+1] = curr

			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end	

	return points
end

function truelch_CrucioMode1:fire(p1, p2, ret, tankDmg, siegePrimaryDmg, SiegeSecondaryDmg, friendlyFire)
	local dir = GetDirection(p2 - p1)

	local target = GetProjectileEnd(p1, p2)

	--Friendly fire
	local targetPawn = Board:GetPawn(target)
	if targetPawn ~= nil and not targetPawn:IsEnemy() and not friendlyFire then
		tankDmg = 0
	elseif Board:IsBuilding(target) and not friendlyFire then
		tankDmg = 0
	end

	local damage = SpaceDamage(target, tankDmg, dir)
	ret:AddProjectile(damage, "effects/shot_mechtank")
end

function truelch_CrucioMode1:GetProjectileEnd(p1, p2)
	profile = PATH_PROJECTILE
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


----------------------------------------------------- Mode 2: Siege

truelch_CrucioMode2 = truelch_CrucioMode1:new{
	aFM_name = "Siege Mode",
	aFM_desc = "Makes the Crucio Mech immobile.\nShock Cannon: artillery shot that deals 4 damage to the main target and 1 damage to surrounding tiles.", --\nThey are also pulled if there's nothing in the center. <-- not anymore :( :(
	aFM_icon = "img/modes/icon_crucio_siege.png",
	--Art
	image = "effects/shotup_standardshell_missile.png",
	innerAnim = "ExploArt2",
	outerAnim = "explopush1_",
	--GamePlay
	pull = false, --test
}

function truelch_CrucioMode2:targeting(point)
	local points = {}
	for dir = 0, 3 do
		for i = 2, 8 do
			local curr = point + DIR_VECTORS[dir]*i
			points[#points+1] = curr
		end
	end
	return points
end


function truelch_CrucioMode2:fire(p1, p2, ret, tankDmg, siegePrimaryDmg, siegeSecondaryDmg, friendlyFire)
	---- INIT VARS ----

	--From vortex
	local pre_event_index
	local pre_event = SpaceDamage()
	local post_event = SpaceDamage()
	local push_event = SpaceDamage()
	local collide_event = SpaceDamage()

	local pushedTargets = {}

	collide_event.loc = p2

	ret:AddDamage(pre_event)
	pre_event_index = ret.effect:size()

	--my vars
	local direction = GetDirection(p2 - p1)

	---- MAIN TARGET ---
	--Friendly fire --->
	local targetPawn = Board:GetPawn(p2)
	--if targetPawn ~= nil and not isEnemyPawn(targetPawn) and not friendlyFire then
	if targetPawn ~= nil and not targetPawn:IsEnemy() and not friendlyFire then
		siegePrimaryDmg = 0
	elseif Board:IsBuilding(p2) and not friendlyFire then
		siegePrimaryDmg = 0
	end
	-- <--- Friendly fire

	local damage = SpaceDamage(p2, siegePrimaryDmg)

	if ANIMS[self.innerAnim .. direction] then
		damage.sAnimation = self.innerAnim .. direction
	else
		damage.sAnimation = self.innerAnim
	end

	ret:AddDamage(damage)
	ret:AddBounce(p2, 3)
	ret:AddBounce(p1, 2)
	---- MAIN TARGET ---

	---- AREA OF EFFECT ----
	--find number of colliding units
	for dir = DIR_START, DIR_END do
		local loc = p2 + DIR_VECTORS[dir]
		local pawn = Board:GetPawn(loc)

		local pawnIsPushable = pawn ~= nil and pawn:IsGuarding() == false

		if pawnIsPushable then
			pushedTargets[#pushedTargets+1] = loc
		end
	end

	--Original version: add something in the center only if needed
	local collisionInCenter = #pushedTargets > 1 and Board:IsBlocked(p2, PATH_FLYER) == false

	local aoeDmgReset = siegeSecondaryDmg --fix

	for dir = DIR_START, DIR_END do
		siegeSecondaryDmg = aoeDmgReset --fix

		local dir_opposite = (dir+2)%4
		local vec = DIR_VECTORS[dir]
		local loc = p2 + vec

		push_event.loc = loc
		--if self.pull and collisionInCenter then
		if self.pull and Board:IsBlocked(p2, PATH_FLYER) == false then
			push_event.iPush = dir_opposite
			push_event.sImageMark = ""
			push_event.sAnimation = "explopush1_" .. dir_opposite
		else
			push_event.sAnimation = "explopush1_" .. dir
		end		

		--importing my logic here --->
		local targetPawn2 = Board:GetPawn(loc)
		--if targetPawn2 ~= nil and isFriendlyPawn(targetPawn2) and not friendlyFire then
		if targetPawn2 ~= nil and not targetPawn2:IsEnemy() and not friendlyFire then
			siegeSecondaryDmg = 0
		elseif Board:IsBuilding(loc) and not friendlyFire then
			siegeSecondaryDmg = 0
		end
		push_event.iDamage = siegeSecondaryDmg
		ret:AddBounce(loc, 1)
		-- <---importing my logic here

		ret:AddDamage(push_event)
	end

	--Removed pull effect

	---- AREA OF EFFECT ----
end


----------------------------------------------------- Skill

truelch_CrucioWeapon = aFM_WeaponTemplate:new{
	--Infos
	Name = "Crucio Weapons",
	Description = "Tank mode:\nFires a pushing projectile that deals 1 damage.\n\nSiege mode: is immobile.\nShoots a powerful artillery shot that that deals 4 damage on the center and 1 damage to adjacent tiles.\nAdjacent tiles are also pulled if there's nothing in the center.",
	Class = "Ranged",

	--Ugrades
	Upgrades = 2,
	UpgradeCost = { 1, 2 },

	--Art
	Icon = "weapons/crucio_weapons.png",
	LaunchSound = "/weapons/back_shot",

	--FMW
	aFM_ModeList = { "truelch_CrucioMode1", "truelch_CrucioMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Menu stats
	PowerCost = 0, --AE
	Rarity = 0, --Cannot be found in the shop

	--Gameplay - Tank
	TankDamage = 1,
	--Gameplay - Siege
	SiegePrimaryDamage = 4,
	SiegeSecondaryDamage = 1,
	--Gameplay - Common
	FriendlyFire = true,

	--TipImage
	TipImage = {
		Unit     = Point(3,3),

		CustomEnemy = "Leaper2",		
		Enemy    = Point(3,1),
		Target   = Point(3,1),

		Friendly   = Point(2,3),
		Second_Origin = Point(3,3),
		Second_Target = Point(2,3),
	}

}

Weapon_Texts.truelch_CrucioWeapon_Upgrade1 = "Shaped Blast"
Weapon_Texts.truelch_CrucioWeapon_Upgrade2 = "Maelstrom Rounds"

truelch_CrucioWeapon_A = truelch_CrucioWeapon:new{
	UpgradeDescription = "No longer deal damage to friendly units or buildings.",
	FriendlyFire = false,
}

truelch_CrucioWeapon_B = truelch_CrucioWeapon:new{
	UpgradeDescription = "+1 damage to the main target.",
	TankDamage = 2,
	SiegePrimaryDamage = 5,
}

truelch_CrucioWeapon_AB = truelch_CrucioWeapon:new{
	FriendlyFire = false,
	TankDamage = 2,
	SiegePrimaryDamage = 5,
}

function truelch_CrucioWeapon:GetTargetArea(point)
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

function truelch_CrucioWeapon:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se, self.TankDamage, self.SiegePrimaryDamage, self.SiegeSecondaryDamage, self.FriendlyFire)
	end

	return se
end

function truelch_CrucioWeapon:FM_OnModeSwitch(p)
	if self:FM_GetMode(p) == "truelch_CrucioMode1" then
		Pawn:SetMoveSpeed(0)
		--Pawn:SetPushable(false)
        if Pawn:GetType() == "CrucioMech" then
            Pawn:SetCustomAnim("crucio_siege")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	elseif self:FM_GetMode(p) == "truelch_CrucioMode2" then
		Pawn:SetMoveSpeed(3)
		--Pawn:SetPushable(true)
        if Pawn:GetType() == "CrucioMech" then
            Pawn:SetCustomAnim("crucio_tank")
        end
        --Sound
        local effect = SkillEffect()
		effect:AddSound("/weapons/swap")
		Board:AddEffect(effect)
	end
end

return this