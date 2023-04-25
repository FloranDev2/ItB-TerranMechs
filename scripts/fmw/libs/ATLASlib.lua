local this = {}
local modApiExt = modApiExt_internal.getMostRecent()

-- returns what weapons a pawn has powered
function this:getPoweredWeapons(p, includeUpgrades)
	local slots = {"primary", "secondary"}
	local weapons = {}

	if not p then 
		return 
	end

	local function isPowered(t)
		if not t then return false end
		
		for _,v in ipairs(t) do
			if v == 0 then return false end
		end
		
		return true
	end

	if Board then
		for i = 1, 2 do 
			local p = Board:GetPawn(p)
			local pId = p:GetId()
			local pType = p:GetType()
			
			--Lemonymous fix:
			--https://discord.com/channels/417639520507527189/418142041189646336/971475595173199872
			if p:IsMech() then
			    local ptable = modApiExt.pawn:getSavedataTable(pId)
			    local slot = slots[i]
			    if ptable then
			        local power = ptable[slot .. "_power"]
			        local mod1, mod2 = ptable[slot .. "_mod1"], ptable[slot .. "_mod2"]

			        if isPowered(power) then
			            if includeUpgrades then
			                if isPowered(mod1) then weapons[i] = ptable[slot] .. "_A" end
			                if isPowered(mod2) then weapons[i] = ptable[slot] .. "_B" end
			                if isPowered(mod1) and isPowered(mod2) then weapons[i] = ptable[slot] .. "_AB" end
			            end

			            if not weapons[i] then weapons[i] = ptable[slot] end
			        end
			    end
			else
			    weapons[i] = _G[pType].SkillList[i]
			end

			--Original version:
			--[[
			if p:IsMech() then
				local ptable = modApiExt.pawn:getSavedataTable(pId)
				local slot = slots[i]
				local power = ptable[slot .. "_power"]
				local mod1, mod2 = ptable[slot .. "_mod1"], ptable[slot .. "_mod2"]

				if ptable and isPowered(power) then
					if includeUpgrades then
						if isPowered(mod1) then weapons[i] = ptable[slot] .. "_A" end
						if isPowered(mod2) then weapons[i] = ptable[slot] .. "_B" end
						if isPowered(mod1) and isPowered(mod2) then weapons[i] = ptable[slot] .. "_AB" end
					end

					if not weapons[i] then weapons[i] = ptable[slot] end
				end
			else
				weapons[i] = _G[pType].SkillList[i]
			end
			]]
		end
	
		return weapons
	end

	return nil
end

-- returns true/false if a pawn has a specific weapon powered
function this:hasWeaponPowered(p, weapon, includeUpgrades)
	local powered = 0
	local poweredWeapon

	if not p then
		return false
	end
	
	local p = Board:GetPawn(p) 

	for i = 1, 2 do
		if this:getPoweredWeapons(p, includeUpgrades)[i] == weapon then
			poweredWeapon = this:getPoweredWeapons(p, true)[i]
			powered = powered + 1
		end
	end

	return powered > 0, poweredWeapon
end

-- the vanilla Pawn object is pretty weird since it sometimes won't update,
-- even if you have a pawn selected 
function this.Pawn()
	if Board then
		for i, p in pairs(extract_table(Board:GetPawns(TEAM_ANY))) do
			local p = Board:GetPawn(p) 
			
			if p:IsSelected() then
				return p 
			end
		end
	end
end

-- returns length of hash table
function this.hashLen(t) 
	local n = 0
	
	for _,_ in pairs(t) do
		n = n + 1
	end
	
	return n	
end

-- null safe version of Board:GetPawn()
this.GetPawn = {}
setmetatable(this.GetPawn, {
	__call = function(self, pawn)
		if not pawn then
			local t = {}
			
			setmetatable(t, {
				__index = function()
					return function() return end
				end
			})

			return t
		elseif Board then
			return Board:GetPawn(pawn)
		end
	end
})

return this