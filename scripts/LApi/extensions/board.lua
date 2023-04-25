
local cutils = LApi.cutils:get()
local FIRE_TYPE_NO_FIRE = 0
local FIRE_TYPE_NORMAL_FIRE = 1
local FIRE_TYPE_FOREST_FIRE = 2

PATH_JUMPER = 6
PATH_TELEPORTER = 5

TERRAIN_ICE_CRACKED = -1
TERRAIN_MOUNTAIN_CRACKED = -2
TERRAIN_FOREST_FIRE = -3

RUBBLE_BUILDING = 0
RUBBLE_MOUNTAIN = 1

local BoardClassEx = {}

BoardClassEx.GetBoardTable = function(self)
	Assert.Signature{
		ret = "table",
		func = "GetBoardTable",
		params = { self },
		{ "userdata|GameBoard&" }
	}

	local region = GetCurrentRegion()

	if region then
		return region.player.map_data.map
	end

	return {}
end

BoardClassEx.GetTileTable = function(self, loc)
	Assert.Signature{
		ret = "table",
		func = "GetTileTable",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}

	local boardTable = self:GetBoardTable()

	for _, entry in ipairs(boardTable) do
		if entry.loc == loc then
			return entry
		end
	end

	return {}
end

BoardClassEx.IsShield = function(self, loc)
	Assert.Signature{
		ret = "bool",
		func = "IsShield",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	return cutils.Board.IsShield(loc)
end

BoardClassEx.IsForest = function(self, loc)
	Assert.Signature{
		ret = "bool",
		func = "IsForest",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}

	return self:IsTerrainVanilla(loc, TERRAIN_FOREST) or self:IsForestFire(loc)
end

BoardClassEx.IsForestFire = function(self, loc)
	Assert.Signature{
		ret = "bool",
		func = "IsForestFire",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}

	return cutils.Board.GetFireType(loc) == 2
end

BoardClassEx.SetForest = function(self, loc)
	Assert.Signature{
		ret = "void",
		func = "SetForest",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}

	if cutils.Board.GetFireType(loc) > 0 then
		self:SetForestFire(loc)
	else
		self:SetTerrainVanilla(loc, TERRAIN_FOREST)
	end
end

BoardClassEx.SetForestFire = function(self, loc)
	Assert.Signature{
		ret = "void",
		func = "SetForestFire",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}

	self:SetTerrainVanilla(loc, TERRAIN_ROAD)
	cutils.Board.SetFireType(loc, FIRE_TYPE_FOREST_FIRE)
end

BoardClassEx.SetShield = function(self, loc, shield, no_animation)
	Assert.Signature{
		ret = "void",
		func = "SetShield",
		params = { self, loc, shield, no_animation },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool", "boolean|bool" },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	-- Shielding empty tiles is possible, but they are not stored in the savegame,
	-- so that shouldn't be part of the mod loader.
	local iTerrain = self:GetTerrain(loc)
	local isShieldableTerrain = iTerrain == TERRAIN_BUILDING or iTerrain == TERRAIN_MOUNTAIN
	
	if shield == nil then
		shield = true
	end
	
	if no_animation == nil then
		no_animation = false
	end
	
	if isShieldableTerrain then
		if no_animation then
			cutils.Board.SetShield(loc, shield)
		else
			local d = SpaceDamage(loc)
			d.iShield = shield and 1 or -1
			self:DamageSpace(d)
		end
	elseif self:IsPawnSpace(loc) then
		self:GetPawn(loc):SetShield(shield, no_animation)
	end
end

BoardClassEx.SetWater = function(self, loc, water, sink)
	Assert.Signature{
		ret = "void",
		func = "SetWater",
		params = { self, loc, water, sink },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool", "boolean|bool" },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" }
	}
	
	if water then
		if sink then
			local d = SpaceDamage(loc)
			d.iTerrain = TERRAIN_LAVA
			self:DamageSpace(d)
		else
			self:SetTerrainVanilla(loc, TERRAIN_WATER)
		end
		
		self:SetLava(loc, false)
		self:SetAcid(loc, false)
	elseif self:GetTerrain(loc) == TERRAIN_WATER then
		self:SetTerrainVanilla(loc, TERRAIN_ROAD)
	end
end

BoardClassEx.SetAcidWater = function(self, loc, acid, sink)
	Assert.Signature{
		ret = "void",
		func = "SetAcidWater",
		params = { self, loc, acid, sink },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool", "boolean|bool" },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" }
	}
	
	if acid then
		if sink then
			local d = SpaceDamage(loc)
			d.iTerrain = TERRAIN_LAVA
			self:DamageSpace(d)
		else
			self:SetTerrainVanilla(loc, TERRAIN_WATER)
		end
		
		self:SetLava(loc, false)
		self:SetAcid(loc, true)
	elseif self:GetTerrain(loc) == TERRAIN_WATER and self:IsAcid(loc) then
		self:SetAcid(loc, false)
		self:SetTerrainVanilla(loc, TERRAIN_ROAD)
	end
end

BoardClassEx.GetHealth = function(self, loc)
	Assert.Signature{
		ret = "int",
		func = "GetHealth",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	return cutils.Board.GetHealth(loc)
end

BoardClassEx.GetMaxHealth = function(self, loc)
	Assert.Signature{
		ret = "int",
		func = "GetMaxHealth",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	return cutils.Board.GetMaxHealth(loc)
end

BoardClassEx.GetLostHealth = function(self, loc)
	Assert.Signature{
		ret = "int",
		func = "GetLostHealth",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	return cutils.Board.GetLostHealth(loc)
end

BoardClassEx.SetHealth = function(self, loc, hp)
	Assert.Signature{
		ret = "void",
		func = "SetHealth",
		params = { self, loc, hp },
		{ "userdata|GameBoard&", "userdata|Point", "number|int" }
	}
	
	local hp_max = cutils.Board.GetMaxHealth(loc)
	local iTerrain = self:GetTerrain(loc)
	hp = math.max(0, math.min(hp, hp_max))
	
	local rubbleState = cutils.Board.GetRubbleType(loc)
	local isRubble = iTerrain == TERRAIN_RUBBLE
	local isBuilding = iTerrain == TERRAIN_BUILDING
	local isMountain = iTerrain == TERRAIN_MOUNTAIN
	local isRuins = isRubble and rubbleState == RUBBLE_BUILDING
	local isDestroyedMountain = isRubble and rubbleState == RUBBLE_MOUNTAIN
	
	if isBuilding or isRuins then
		self:SetBuilding(loc, hp, hp_max)
		
	elseif isMountain or isDestroyedMountain then
		self:SetMountain(loc, hp, hp_max)
		
	elseif iTerrain == TERRAIN_ICE then
		self:SetIce(loc, hp, hp_max)
	end
end

BoardClassEx.SetMaxHealth = function(self, loc, hp_max)
	Assert.Signature{
		ret = "void",
		func = "SetMaxHealth",
		params = { self, loc, hp_max },
		{ "userdata|GameBoard&", "userdata|Point", "number|int" }
	}
	
	local rubbleState = cutils.Board.GetRubbleType(loc)
	local iTerrain = self:GetTerrain(loc)
	
	local isBuilding = iTerrain == TERRAIN_BUILDING
	local isRuins = iTerrain == TERRAIN_RUBBLE and rubbleState == RUBBLE_BUILDING
	
	if isBuilding or isRuins then
		
		if self:IsUniqueBuilding(loc) then
			hp_max = 1
		else
			hp_max = math.max(1, math.min(4, hp_max))
		end
		
		local hp = cutils.Board.GetHealth(loc)
		
		self:SetBuilding(loc, hp, hp_max)
	end
end

BoardClassEx.SetBuilding = function(self, loc, hp, hp_max)
	Assert.Signature{
		ret = "void",
		func = "SetBuilding",
		params = { self, loc, hp, hp_max },
		{ "userdata|GameBoard&", "userdata|Point", "number|int", "number|int" },
		{ "userdata|GameBoard&", "userdata|Point", "number|int" },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	hp_max = hp_max or cutils.Board.GetMaxHealth(loc)
	hp = hp or cutils.Board.GetHealth(loc)
	
	cutils.Board.SetMaxHealth(loc, hp_max)
	cutils.Board.SetHealth(loc, hp)
	
	self:SetTerrainVanilla(loc, TERRAIN_ROAD)
	self:SetTerrainVanilla(loc, TERRAIN_BUILDING)
	
	if hp > 0 then
		self:SetPopulated(true, loc)
	else
		self:SetRubble(loc)
	end
end

BoardClassEx.SetMountain = function(self, loc, hp)
	Assert.Signature{
		ret = "void",
		func = "SetMountain",
		params = { self, loc, hp },
		{ "userdata|GameBoard&", "userdata|Point", "number|int" }
	}
	
	self:SetTerrainVanilla(loc, TERRAIN_MOUNTAIN)
	
	if hp > 0 then
		cutils.Board.SetHealth(loc, hp)
	else
		self:SetRubble(loc)
	end
end

BoardClassEx.SetIce = function(self, loc, hp)
	Assert.Signature{
		ret = "void",
		func = "SetIce",
		params = { self, loc, hp },
		{ "userdata|GameBoard&", "userdata|Point", "number|int" }
	}
	
	self:SetTerrainVanilla(loc, TERRAIN_ICE)
	
	if hp > 0 then
		cutils.Board.SetMaxHealth(loc, 2)
		cutils.Board.SetHealth(loc, hp)
	else
		self:SetTerrainVanilla(loc, TERRAIN_ROAD)
		self:SetTerrainVanilla(loc, TERRAIN_WATER)
	end
end

BoardClassEx.SetRubble = function(self, loc, flag)
	Assert.Signature{
		ret = "void",
		func = "SetRubble",
		params = { self, loc, flag },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	if flag == nil then
		flag = true
	end
	
	local iTerrain = self:GetTerrain(loc)
	
	if flag then
		if iTerrain == TERRAIN_BUILDING then
			cutils.Board.SetHealth(loc, 0)
			cutils.Board.SetRubbleType(loc, RUBBLE_BUILDING)
			self:SetTerrainVanilla(loc, TERRAIN_BUILDING)
			cutils.Board.SetTerrain(loc, TERRAIN_RUBBLE)
			
		elseif iTerrain == TERRAIN_MOUNTAIN then
			cutils.Board.SetHealth(loc, 0)
			cutils.Board.SetRubbleType(loc, RUBBLE_MOUNTAIN)
			cutils.Board.SetTerrain(loc, TERRAIN_RUBBLE)
			
		else
			self:SetTerrainVanilla(loc, TERRAIN_RUBBLE)
		end
		
	elseif iTerrain == TERRAIN_RUBBLE then
		
		local rubbleState = cutils.Board.GetRubbleType(loc)
		
		if rubbleState == RUBBLE_BUILDING then
			local hp_max = self:GetMaxHealth(loc)
			self:SetBuilding(loc, hp_max, hp_max)
			
		else
			self:SetTerrainVanilla(loc, TERRAIN_MOUNTAIN)
		end
	end
end

BoardClassEx.SetSnow = function(self, loc, snow)
	Assert.Signature{
		ret = "void",
		func = "SetSnow",
		params = { self, loc, snow },
		{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	if snow == nil then
		snow = true
	end
	
	local custom_tile = self:GetCustomTile(loc)
	
	if snow then
		if custom_tile == "" then
			self:SetCustomTile(loc, "snow.png")
		end
	else
		if custom_tile == "snow.png" then
			self:SetCustomTile(loc, "")
		end
	end
end

BoardClassEx.IsSnow = function(self, loc)
	Assert.Signature{
		ret = "bool",
		func = "IsSnow",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	return self:GetCustomTile(loc) == "snow.png"
end

BoardClassEx.GetItemName = function(self, loc)
	Assert.Signature{
		ret = "string",
		func = "GetItemName",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	if not self:IsItem(loc) then
		return nil
	end
	
	return cutils.Board.GetItemName(loc)
end

BoardClassEx.GetUniqueBuildingName = function(self, loc)
	Assert.Signature{
		ret = "string",
		func = "GetUniqueBuildingName",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	if not self:IsUniqueBuilding(loc) then
		return nil
	end
	
	return cutils.Board.GetUniqueBuildingName(loc)
end

BoardClassEx.GetHighlighted = function(self)
	Assert.Signature{
		ret = "void",
		func = "GetHighlighted",
		params = { self },
		{ "userdata|GameBoard&" }
	}
	
	return Point(
		cutils.Board.GetHighlightedX(),
		cutils.Board.GetHighlightedY()
	)
end

BoardClassEx.IsHighlighted = function(self, loc)
	Assert.Signature{
		ret = "bool",
		func = "IsHighlighted",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}
	
	return cutils.Board.IsHighlighted(loc)
end

BoardClassEx.MarkGridLoss = function(self, loc, grid_loss)
	Assert.Signature{
		ret = "void",
		func = "MarkGridLoss",
		params = { self, loc, grid_loss },
		{ "userdata|GameBoard&", "userdata|Point", "number|int" }
	}
	
	cutils.Board.SetGridLoss(loc, grid_loss)
end

BoardClassEx.IsGameBoard = function(self)
	Assert.Signature{
		ret = "boolean",
		func = "IsGameBoard",
		params = { self },
		{ "userdata|GameBoard&" }
	}
	
	return cutils.Board.IsGameboard()
end

BoardClassEx.IsMissionBoard = BoardClassEx.IsGameBoard

BoardClassEx.IsTipImage = function(self)
	Assert.Signature{
		ret = "boolean",
		func = "IsTipImage",
		params = { self },
		{ "userdata|GameBoard&" }
	}
	
	return not cutils.Board.IsGameboard()
end

BoardClassEx.GetTerrainIcon = function(self, loc)
	Assert.Signature{
		ret = "string",
		func = "GetTerrainIcon",
		params = { self, loc },
		{ "userdata|GameBoard&", "userdata|Point" }
	}

	return cutils.Board.GetTerrainIcon(loc)
end



function InitializeBoardClass(board)
	-- modify existing board functions here
	
	BoardClassEx.GetReachableVanilla = board.GetReachable
	BoardClassEx.GetReachable = function(self, loc, movespeed, pathing)
		local reachable = self:GetReachableVanilla(loc, movespeed, pathing)
		
		if pathing % 16 == PATH_JUMPER or pathing % 16 == PATH_TELEPORTER then
			local size = reachable:size()
			local massive = Pawn:IsMassive()
			local flying = Pawn:IsFlying()
			
			for i = size, 1, -1 do
				local p = reachable:index(i)
				local terrain = self:GetTerrain(p)
				if terrain == TERRAIN_HOLE then
					if not flying then
						reachable:erase(i)
					end
				elseif terrain == TERRAIN_WATER then
					if not massive and not flying then
						reachable:erase(i)
					end
				end
			end
		end
		
		return reachable
	end
	
	BoardClassEx.SetLavaVanilla = board.SetLava
	BoardClassEx.SetLava = function(self, loc, lava, sink)
		Assert.Signature{
			ret = "void",
			func = "SetLava",
			params = { self, loc, lava, sink },
			{ "userdata|GameBoard&", "userdata|Point", "boolean|bool", "boolean|bool" },
			{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" }
		}
		
		if lava and sink then
			local d = SpaceDamage(loc)
			d.iTerrain = TERRAIN_LAVA
			self:DamageSpace(d)
		else
			self:SetLavaVanilla(loc, lava)
		end
	end
	
	BoardClassEx.SetTerrainVanilla = board.SetTerrain
	BoardClassEx.SetTerrain = function(self, loc, iTerrain)
		Assert.Signature{
			ret = "void",
			func = "SetTerrain",
			params = { self, loc, iTerrain },
			{ "userdata|GameBoard&", "userdata|Point", "number|int" }
		}
		
		if iTerrain == TERRAIN_MOUNTAIN_CRACKED then
			self:SetMountain(loc, 1)
			
		elseif iTerrain == TERRAIN_ICE_CRACKED then
			self:SetIce(loc, 1)
			
		elseif iTerrain == TERRAIN_FOREST then
			self:SetForest(loc)
			
		elseif iTerrain == TERRAIN_FOREST_FIRE then
			self:SetForestFire(loc)
			
		elseif iTerrain == TERRAIN_BUILDING then
			local health = self:GetHealth(loc)
			local maxHealth = self:GetMaxHealth(loc)
			self:SetBuilding(loc, health, maxHealth)
			
		elseif iTerrain == TERRAIN_RUBBLE then
			self:SetRubble(loc)
		else
			self:SetTerrainVanilla(loc, iTerrain)
		end
		
		if iTerrain ~= TERRAIN_FOREST and iTerrain ~= TERRAIN_FOREST_FIRE and self:IsForestFire(loc) then
			cutils.Board.SetFireType(loc, FIRE_TYPE_NORMAL_FIRE)
		end
	end
	
	BoardClassEx.IsTerrainVanilla = board.IsTerrain
	BoardClassEx.IsTerrain = function(self, loc, iTerrain)
		Assert.Signature{
			ret = "bool",
			func = "IsTerrain",
			params = { self, loc, iTerrain },
			{ "userdata|GameBoard&", "userdata|Point", "number|int" }
		}
		
		if iTerrain == TERRAIN_ICE_CRACKED then
			local iTerrain = self:GetTerrain(loc)
			local hp = self:GetHealth(loc)
			
			return iTerrain == TERRAIN_ICE and hp == 1
			
		elseif iTerrain == TERRAIN_MOUNTAIN_CRACKED then
			local iTerrain = self:GetTerrain(loc)
			local hp = self:GetHealth(loc)
			
			return iTerrain == TERRAIN_MOUNTAIN and hp == 1
			
		elseif iTerrain == TERRAIN_FOREST_FIRE then
			return self:IsForestFire(loc)
		end
		
		return self:IsTerrainVanilla(loc, iTerrain)
	end
	
	BoardClassEx.SetFireVanilla = board.SetFire
	BoardClassEx.SetFire = function(self, loc, fire)
		Assert.Signature{
			ret = "void",
			func = "SetFire",
			params = { self, loc, fire },
			{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" },
			{ "userdata|GameBoard&", "userdata|Point" }
		}
		
		local iTerrain = self:GetTerrain(loc)
		local isForestFire = self:IsForestFire(loc)
		
		if fire == nil then
			fire = true
		end
		
		self:SetFireVanilla(loc, fire)
		
		-- update forest fire graphics
		if fire then
			if iTerrain == TERRAIN_FOREST or isForestFire then
				self:SetForestFire(loc)
			end
		end
	end
	
	-- added no_animation parameter similar to what vanilla function SetSmoke has.
	BoardClassEx.SetFrozenVanilla = board.SetFrozen
	BoardClassEx.SetFrozen = function(self, loc, frozen, no_animation)
		Assert.Signature{
			ret = "void",
			func = "SetFrozen",
			params = { self, loc, frozen, no_animation },
			{ "userdata|GameBoard&", "userdata|Point", "boolean|bool", "boolean|bool" },
			{ "userdata|GameBoard&", "userdata|Point", "boolean|bool" },
			{ "userdata|GameBoard&", "userdata|Point" }
		}
		
		local iTerrain = self:GetTerrain(loc)
		local isFreezableTerrain = iTerrain == TERRAIN_BUILDING or iTerrain == TERRAIN_MOUNTAIN
		
		if frozen == nil then
			frozen = true
		end
		
		if no_animation == nil then
			no_animation = false
		end
		
		if no_animation then
			if frozen then
				if self:GetCustomTile(loc) == "" then
					self:SetCustomTile(loc, "snow.png")
				end
				
				if cutils.Board.GetFireType(loc) ~= FIRE_TYPE_NO_FIRE then
					cutils.Board.SetFireType(loc, FIRE_TYPE_NO_FIRE)
				end
			end
			
			if isFreezableTerrain then
				cutils.Board.SetFrozen(loc, frozen)
				
			elseif self:IsPawnSpace(loc) then
				self:GetPawn(loc):SetFrozen(frozen, no_animation)
			end
		else
			self:SetFrozenVanilla(loc, frozen)
		end
	end
	
	-- the PointList returned by vanilla GetBuildings is inconsistent.
	-- destroyed buildings will linger as valid points until SetTerrain is used.
	BoardClassEx.GetBuildingsVanilla = board.GetBuildings
	BoardClassEx.GetBuildings = function(self)
		local buildings = self:GetBuildingsVanilla()
		
		for i = buildings:size(), 1, -1 do
			local isBuilding = self:IsTerrain(buildings:index(i), TERRAIN_BUILDING) 
			
			if not isBuilding then
				buildings:erase(i)
			end
		end
		
		return buildings
	end
end

local board_metatable
local doInit = true
local oldSetBoard = SetBoard
function SetBoard(board)
	if board ~= nil then
		
		if doInit then
			doInit = nil
			
			InitializeBoardClass(board)
			
			local old_metatable = getmetatable(board)
			board_metatable = copy_table(old_metatable)
			
			board_metatable.__index = function(self, key)
				local value = BoardClassEx[key]
				if value then
					return value
				end
				
				return old_metatable.__index(self, key)
			end
		end
		
		cutils.Misc.SetUserdataMetatable(board, board_metatable)
	end
	
	oldSetBoard(board)
end
