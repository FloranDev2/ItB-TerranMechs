
local events = {
	"onTileHighlighted",
	"onTileUnhighlighted",
	"onTileTerrainChanged",
	"onTileHealthChanged",
	"onTileMaxHealthChanged",
	"onTileDamaged",
	"onTileBuildingDamaged",
	"onTileBuildingDestroyed",
	"onTileUniqueBuildingDestroyed",
	"onTileUniqueBuildingNameChanged",
	"onTileItemNameChanged",
	"onTileIsBuilding",
	"onTileIsUniqueBuilding",
	"onTileIsItem",
	"onTileIsShield",
	"onTileIsFrozen",
	"onTileIsSmoke",
	"onTileIsFire",
	"onTileIsAcid",
	"onTileIsNotBuilding",
	"onTileIsNotUniqueBuilding",
	"onTileIsNotItem",
	"onTileIsNotShield",
	"onTileIsNotFrozen",
	"onTileIsNotSmoke",
	"onTileIsNotFire",
	"onTileIsNotAcid",
}

for _, eventId in ipairs(events) do
	if modApi.events[eventId] == nil then
		modApi.events[eventId] = Event()
	end
end
