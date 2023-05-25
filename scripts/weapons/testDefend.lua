local movingEnemy = nil
local tries = 0
local maxTries = 200

local defendFlag = false

local HOOK_onVekMoveEnd = function(mission, pawn, startLoc, endLoc)
	LOG(pawn:GetMechName() .. " has finished moving from " .. startLoc:GetString() .. " to " .. endLoc:GetString())	
	--Board:AddAlert(startLoc, "START: " .. startLoc:GetString())
	--Board:AddAlert(endLoc, "END: " .. endLoc:GetString())

	defendFlag = true
	--local mech = Board:GetPawn(2)
	--mech:FireWeapon(endLoc, 1)
	defendFlag = false
	
	movingEnemy = pawn
	tries = 0
end

modApi.events.onMissionUpdate:subscribe(function(mission)
	if tries < maxTries and movingEnemy ~= nil then
		tries = tries + 1
		--LOG("[".. tostring(tries) .."] pos: " .. movingEnemy:GetSpace():GetString() .. " board busy: " .. tostring(Board:IsBusy()))
		if remainingTries == 0 then
			movingEnemy = nil
		end

		--Now, the board busy is at first true and then false, while it was the opposite before.
		--Yet, I've reverted the changes on alter.lua (line 192)
		--scripts\mod_loader\extensions\modLoaderExtensions\mods\modApiExt\scripts\alter.lua
		--if Board:IsBusy() then --old
		--[[
		if not Board:IsBusy() then --new
			--Clear vars
			Board:AddAlert(movingEnemy:GetSpace(), "Here?")
			Board:Ping(movingEnemy:GetSpace(), GL_Color(30,40,250))

			movingEnemy = nil
			tries = 0
		end
		]]
	end
end)

local function EVENT_onModsLoaded()
	modapiext:addVekMoveEndHook(HOOK_onVekMoveEnd)
end
modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)


--modapiext:addSkillStartHook(HOOK_onSkillStart)
--modapiext:addSkillEndHook(HOOK_onSkillEnd)

testDefend = LineArtillery:new{
	Name = "Test Defend",
	Description = "Test defend.",
	Class = "Brute",
	Icon = "weapons/liberator_weapons.png",
	Rarity = 3,
	Damage = 2,
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",	
	UpShot = "effects/shot_artimech.png",
	Explosion = "",
	--Custom
	--TipImage
	TipImage = {
		Unit = Point(2, 3),
	}
}

function testDefend:GetTargetArea(point)
	local ret = PointList()
	
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			ret:push_back(curr)
		end
	end
	
	return ret
end

function testDefend:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, self.Damage)
	ret:AddArtillery(damage, self.UpShot)
	return ret
end