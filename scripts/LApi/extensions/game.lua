
local cutils = LApi.cutils:get()

local GameClass = {}

GameClass.GetRep = function(self)
	Assert.Signature{
		ret = "number",
		func = "GetRep",
		params = { self },
		{ "userdata|GameMap&" }
	}

	return cutils.Game.GetRep()
end

GameClass.SetRep = function(self, reputation)
	Assert.Signature{
		ret = "void",
		func = "SetRep",
		params = { self, reputation },
		{ "userdata|GameMap&", "number|int" }
	}

	reputation = math.max(0, reputation)

	return cutils.Game.SetRep(reputation)
end

GameClass.GetCores = function(self)
	Assert.Signature{
		ret = "number",
		func = "GetCores",
		params = { self },
		{ "userdata|GameMap&" }
	}

	return cutils.Game.GetCore()
end

GameClass.SetCores = function(self, cores)
	Assert.Signature{
		ret = "void",
		func = "SetCores",
		params = { self, cores },
		{ "userdata|GameMap&", "number|int" }
	}

	cores = math.max(0, cores)

	return cutils.Game.SetCore(cores)
end

GameClass.GetGridPower = function(self)
	Assert.Signature{
		ret = "number",
		func = "GetGridPower",
		params = { self },
		{ "userdata|GameMap&" }
	}

	return cutils.Game.GetPower()
end

GameClass.SetGridPower = function(self, power)
	Assert.Signature{
		ret = "void",
		func = "SetGridPower",
		params = { self, power },
		{ "userdata|GameMap&", "number|int" }
	}

	local maxPower = cutils.Game.GetMaxPower()
	power = math.max(0, math.min(power, maxPower))

	return cutils.Game.SetPower(power)
end

GameClass.GetGridMaxPower = function(self)
	Assert.Signature{
		ret = "number",
		func = "GetGridMaxPower",
		params = { self },
		{ "userdata|GameMap&" }
	}

	return cutils.Game.GetMaxPower()
end

GameClass.SetGridMaxPower = function(self, maxPower)
	Assert.Signature{
		ret = "void",
		func = "SetGridMaxPower",
		params = { self, maxPower },
		{ "userdata|GameMap&", "number|int" }
	}

	maxPower = math.max(0, maxPower)

	return cutils.Game.SetMaxPower(maxPower)
end

GameClass.GetGridResist = function(self)
	Assert.Signature{
		ret = "number",
		func = "GetGridResist",
		params = { self },
		{ "userdata|GameMap&" }
	}

	return cutils.Game.GetGrid()
end

GameClass.SetGridResist = function(self, resist)
	Assert.Signature{
		ret = "void",
		func = "SetGridResist",
		params = { self, resist },
		{ "userdata|GameMap&", "number|int" }
	}

	return cutils.Game.SetGrid(resist)
end

function InitializeGameClass(game)
	-- modify existing game functions here
end

local game_metatable
local doInit = true
local oldSetGame = SetGame
function SetGame(game)
	if game ~= nil then

		if doInit then
			doInit = nil

			InitializeGameClass(game)

			local old_metatable = getmetatable(game)
			game_metatable = copy_table(old_metatable)

			game_metatable.__index = function(self, key)
				local value = GameClass[key]
				if value then
					return value
				end

				return old_metatable.__index(self, key)
			end
		end

		cutils.Misc.SetUserdataMetatable(game, game_metatable)
	end

	oldSetGame(game)
end
