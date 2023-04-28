
modApi:appendWeaponAssets("img/", "mini_")


mini_Multishot = Skill:new{
	Name = "Multishot",
	Description = "Fires multiple shots",
	Icon = "weapons/mini_multishot.png",
	GetTargetArea = TankDefault.GetTargetArea,
	PathSize = INT_MAX,
	Shots = 3,
}

function mini_Multishot:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	for i = 1, self.Shots do
		-- Prepare N shots to be fired after this weapon has finished its SkillEffect
		ret:AddScript(string.format("mini_Multishot:PrepareFire(%s,%s,%s)", Pawn:GetId(), p1:GetString(), p2:GetString()))
	end

	-- Since we are doing the damage via scripts, there will be no preview unless manually added.
	-- The following adds a simple projectile path preview, but a more detailed preview could be added.
	local target = GetProjectileEnd(p1, p2)
	local damageEvent = SpaceDamage(target)
	ret:AddProjectile(p1, damageEvent, "", NO_DELAY)

	return ret
end

function mini_Multishot:PrepareFire(pawnId, p1, p2)
	local pawn = Board:GetPawn(pawnId)
	if pawn == nil then
		return
	end

	-- Create a new SkillEffect and add it to the Board, so the code will execute after the previous SkillEffect has finished.
	-- Check if the unit was originally boosted, so we can boost each shot manually if needed.
	local fx = SkillEffect()

	fx:AddScript(string.format("mini_Multishot:Fire(%s,%s,%s)", pawnId, p2:GetString(), tostring(pawn:IsBoosted())))

	Board:AddEffect(fx)
end

function mini_Multishot:Fire(pawnId, p2, boosted)
	local pawn = Board:GetPawn(pawnId)
	if pawn == nil then
		return
	end

	-- Boost the following shot if the unit was originally boosted.
	if boosted then
		pawn:SetBoosted(true)
	end

	-- Add a weapon, fire it, and remove it. Each shot will consume a boost.
	pawn:AddWeapon("mini_Singleshot")
	local count = pawn:GetWeaponCount()
	pawn:FireWeapon(p2, count)
	pawn:RemoveWeapon(count)
end


mini_Singleshot = Skill:new{
	GetTargetArea = TankDefault.GetTargetArea,
	PathSize = INT_MAX,
	Damage = 1,
}

function mini_Singleshot:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local target = GetProjectileEnd(p1, p2)
	local damageEvent = SpaceDamage(target, self.Damage)

	ret:AddProjectile(p1, damageEvent, "effects/shot_mechtank", FULL_DELAY)

	return ret
end
