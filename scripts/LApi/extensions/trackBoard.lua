
local function initTrackedTiles()
	local trackedTiles = {}

	for index, point in ipairs(Board) do
		local trackedTile = {}
		trackedTiles[index] = trackedTile

		trackedTile.terrain = Board:GetTerrain(point)
		trackedTile.health = Board:GetHealth(point)
		trackedTile.healthMax = Board:GetMaxHealth(point)

		trackedTile.highlighted = false
		trackedTile.building = false
		trackedTile.uniqueBuilding = false
		trackedTile.uniqueBuildingName = nil
		trackedTile.item = false
		trackedTile.itemName = nil
		trackedTile.shield = false
		trackedTile.frozen = false
		trackedTile.smoke = false
		trackedTile.fire = false
		trackedTile.acid = false
	end

	return trackedTiles
end

local baseUpdate = Mission.BaseUpdate
function Mission:BaseUpdate(...)
	baseUpdate(self, ...)

	local trackedTiles = self.trackedTiles

	if trackedTiles == nil then
		trackedTiles = initTrackedTiles()
		self.trackedTiles = trackedTiles
	end

	for index, point in ipairs(Board) do
		local trackedTile = trackedTiles[index]

		local highlighted = Board:IsHighlighted(point)
		local terrain = Board:GetTerrain(point)
		local health = Board:GetHealth(point)
		local healthMax = Board:GetMaxHealth(point)

		local building = Board:IsBuilding(point)
		local uniqueBuilding = Board:IsUniqueBuilding(point)
		local uniqueBuildingName = Board:GetUniqueBuildingName(point)
		local item = Board:IsItem(point)
		local itemName = Board:GetItemName(point)
		local shield = Board:IsShield(point)
		local frozen = Board:IsFrozen(point)
		local smoke = Board:IsSmoke(point)
		local fire = Board:IsFire(point)
		local acid = Board:IsAcid(point)

		if highlighted ~= trackedTile.highlighted then
			local mission = GetCurrentMission()

			if highlighted then
				modApi.events.onTileHighlighted:dispatch(mission, point)
			else
				modApi.events.onTileUnhighlighted:dispatch(mission, point)
			end

			trackedTile.highlighted = highlighted
		end

		if health ~= trackedTile.health then
			modApi.events.onTileHealthChanged:dispatch(point, trackedTile.health, health)

			local damage = trackedTile.health - health
			if damage > 0 then
				modApi.events.onTileDamaged:dispatch(point, damage)

				if trackedTile.terrain == TERRAIN_BUILDING then
					modApi.events.onTileBuildingDamaged:dispatch(point, damage)

					if health == 0 then
						modApi.events.onTileBuildingDestroyed:dispatch(point)

						if trackedTile.uniqueBuilding then
							modApi.events.onTileUniqueBuildingDestroyed:dispatch(point, trackedTile.uniqueBuildingName)
						end
					end
				end
			end

			trackedTile.health = health
		end

		if healthMax ~= trackedTile.healthMax then
			modApi.events.onTileMaxHealthChanged:dispatch(point, trackedTile.healthMax, healthMax)

			trackedTile.healthMax = healthMax
		end

		if building ~= trackedTile.building then
			if building then
				modApi.events.onTileIsBuilding:dispatch(point)
			else
				modApi.events.onTileIsNotBuilding:dispatch(point)
			end

			trackedTile.building = building
		end

		if uniqueBuilding ~= trackedTile.uniqueBuilding then
			if uniqueBuilding then
				modApi.events.onTileIsUniqueBuilding:dispatch(point, uniqueBuildingName)
			else
				modApi.events.onTileIsNotUniqueBuilding:dispatch(point, trackedTile.uniqueBuildingName)
			end

			trackedTile.uniqueBuilding = uniqueBuilding
		end

		if item ~= trackedTile.item then
			if item then
				modApi.events.onTileIsItem:dispatch(point, itemName)
			else
				modApi.events.onTileIsNotItem:dispatch(point, trackedTile.itemName)
			end

			trackedTile.item = item
		end

		if uniqueBuildingName ~= trackedTile.uniqueBuildingName then
			modApi.events.onTileUniqueBuildingNameChanged:dispatch(point, uniqueBuildingName, trackedTile.uniqueBuildingName)

			trackedTile.uniqueBuildingName = uniqueBuildingName
		end

		if itemName ~= trackedTile.itemName then
			modApi.events.onTileItemNameChanged:dispatch(point, itemName, trackedTile.itemName)

			trackedTile.itemName = itemName
		end

		if terrain ~= trackedTile.terrain then
			modApi.events.onTileTerrainChanged:dispatch(point, trackedTile.terrain, terrain)
			trackedTile.terrain = terrain
		end

		if shield ~= trackedTile.shield then
			if shield then
				modApi.events.onTileIsShield:dispatch(point)
			else
				modApi.events.onTileIsNotShield:dispatch(point)
			end

			trackedTile.shield = shield
		end

		if frozen ~= trackedTile.frozen then
			if frozen then
				modApi.events.onTileIsFrozen:dispatch(point)
			else
				modApi.events.onTileIsNotFrozen:dispatch(point)
			end

			trackedTile.frozen = frozen
		end

		if smoke ~= trackedTile.smoke then
			if smoke then
				modApi.events.onTileIsSmoke:dispatch(point)
			else
				modApi.events.onTileIsNotSmoke:dispatch(point)
			end

			trackedTile.smoke = smoke
		end

		if fire ~= trackedTile.fire then
			if fire then
				modApi.events.onTileIsFire:dispatch(point)
			else
				modApi.events.onTileIsNotFire:dispatch(point)
			end

			trackedTile.fire = fire
		end

		if acid ~= trackedTile.acid then
			if acid then
				modApi.events.onTileIsAcid:dispatch(point)
			else
				modApi.events.onTileIsNotAcid:dispatch(point)
			end

			trackedTile.acid = acid
		end
	end
end
