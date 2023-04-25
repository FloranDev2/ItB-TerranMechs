
--[[
	untestable by automatic tests:
	GetHighlighted
	IsHighlighted - failed
	MarkGridLoss
	IsGameBoard
	IsMissionBoard
	IsTipImage
]]

Testsuites.lapi = Testsuites.lapi or Tests.Testsuite()
Testsuites.lapi.name = "LApi-related tests"
Testsuites.lapi.board = Tests.Testsuite()
Testsuites.lapi.board.name = "LApi-Board-related tests"

local testsuite = Testsuites.lapi.board

function testsuite.test_BoardSetFire()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetFire(loc, true);				local fire = Board:IsFire(loc) == true
	Board:SetFire(loc, false);				local notFire = Board:IsFire(loc) == false
	
	Assert.True(fire)
	Assert.True(notFire)
	
	return true
end

function testsuite.test_BoardForestFire()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetForestFire(loc);				local forestFire = Board:IsForestFire(loc) == true
	Board:SetTerrain(loc, TERRAIN_ROAD);	local isNormalFire = Board:IsFire(loc) == true
											local notForestFire = Board:IsForestFire(loc) == false
	Board:SetForestFire(loc);
	Board:SetFire(loc, false);				local isForest = Board:IsForest(loc) == true
											local notFire = Board:IsFire(loc) == false
	
	Assert.True(forestFire)
	Assert.True(isNormalFire)
	Assert.True(notForestFire)
	Assert.True(isForest)
	Assert.True(notFire)
	
	return true
end

function testsuite.test_BoardIsShield()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	local createShield = SpaceDamage(loc)
	local removeShield = SpaceDamage(loc)
	createShield.iShield = 1
	removeShield.iShield = -1
	
											local notShield = Board:IsShield(loc) == false
	Board:DamageSpace(createShield);		local createShield = Board:IsShield(loc) == true
	Board:DamageSpace(removeShield);		local removeShield = Board:IsShield(loc) == false
	
	Assert.True(notShield)
	Assert.True(createShield)
	Assert.True(removeShield)
	
	return true
end

function testsuite.test_BoardSetShield()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	
											local notShield = Board:IsShield(loc) == false
	Board:SetShield(loc, true);				local createShield = Board:IsShield(loc) == true
	Board:SetShield(loc, false);			local removeShield = Board:IsShield(loc) == false
	
	Assert.True(notShield)
	Assert.True(createShield)
	Assert.True(removeShield)
	
	return true
end

function testsuite.test_BoardGetHealth()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	local damage = SpaceDamage(loc, 1)
	
												local hp2 = Board:GetHealth(loc)
	Board:DamageSpace(damage);					local hp1 = Board:GetHealth(loc)
	Board:DamageSpace(damage);					local hp0 = Board:GetHealth(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN);	local refresh = Board:GetHealth(loc)
	
	Assert.Equals(2, hp2)
	Assert.Equals(1, hp1)
	Assert.Equals(0, hp0)
	Assert.Equals(2, refresh)
	
	return true
end

function testsuite.test_BoardGetMaxHealth()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	
	local maxHp2 = Board:GetMaxHealth(loc)
	
	Assert.Equals(2, maxHp2)
	
	return true
end

function testsuite.test_BoardSetMaxHealth()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	Board:SetTerrain(loc, TERRAIN_BUILDING)
	
												local maxHp2 = Board:GetMaxHealth(loc)
	Board:SetMaxHealth(loc, 5);					local maxHp4 = Board:GetMaxHealth(loc)
	Board:SetMaxHealth(loc, -1);				local maxHp1 = Board:GetMaxHealth(loc)
	Board:SetMaxHealth(loc, 3);					local maxHp3 = Board:GetMaxHealth(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN);	local maxHpReset = Board:GetMaxHealth(loc)
	
	Assert.Equals(2, maxHp2)
	Assert.Equals(4, maxHp4)
	Assert.Equals(1, maxHp1)
	Assert.Equals(3, maxHp3)
	Assert.Equals(2, maxHpReset)
	
	return true
end

function testsuite.test_BoardSetBuilding()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
											local road = Board:IsBuilding(loc) == false
	Board:SetBuilding(loc, 4, 4);			local building = Board:IsBuilding(loc) == true
											local hp4 = Board:GetHealth(loc)
											local maxHp4 = Board:GetMaxHealth(loc)
	Board:SetBuilding(loc, 1, 3);			local hp1 = Board:GetHealth(loc)
											local maxHp3 = Board:GetMaxHealth(loc)
	
	Assert.True(road)
	Assert.True(building)
	Assert.Equals(4, hp4)
	Assert.Equals(4, maxHp4)
	Assert.Equals(1, hp1)
	Assert.Equals(3, maxHp3)
	
	return true
end

function testsuite.test_BoardSetMountain()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetMountain(loc, 2);				local mountain = Board:IsTerrain(loc, TERRAIN_MOUNTAIN) == true
											local maxHp2 = Board:GetMaxHealth(loc)
											local hp2 = Board:GetHealth(loc)
	Board:SetMountain(loc, 1);				local hp1 = Board:GetHealth(loc)
	Board:SetMountain(loc, 0);				local rubble = Board:IsTerrain(loc, TERRAIN_RUBBLE) == true
											local hp0 = Board:GetHealth(loc)
	
	Assert.True(mountain)
	Assert.True(rubble)
	Assert.Equals(2, maxHp2)
	Assert.Equals(2, hp2)
	Assert.Equals(1, hp1)
	Assert.Equals(0, hp0)
	
	return true
end

function testsuite.test_BoardSetIce()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetIce(loc, 2);					local ice = Board:IsTerrain(loc, TERRAIN_ICE) == true
											local maxHp2 = Board:GetMaxHealth(loc)
											local hp2 = Board:GetHealth(loc)
	Board:SetIce(loc, 1);					local hp1 = Board:GetHealth(loc)
	Board:SetIce(loc, 0);					local water = Board:IsTerrain(loc, TERRAIN_WATER) == true
	
	Assert.True(ice)
	Assert.True(water)
	Assert.Equals(2, maxHp2)
	Assert.Equals(1, hp1)
	Assert.Equals(2, hp2)
	
	return true
end

function testsuite.test_BoardSetRubble()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	local damage = SpaceDamage(loc, DAMAGE_DEATH)
	
	Board:SetRubble(loc, true);					local rubble = Board:IsTerrain(loc, TERRAIN_RUBBLE) == true
	Board:SetRubble(loc, false);				local mountain = Board:IsTerrain(loc, TERRAIN_MOUNTAIN) == true
	Board:SetTerrain(loc, TERRAIN_BUILDING);
	Board:DamageSpace(damage);
	Board:SetRubble(loc, false);				local building = Board:IsBuilding(loc) == true
	
	Assert.True(rubble)
	Assert.True(mountain)
	Assert.True(building)
	
	return true
end

function testsuite.test_BoardSetFrozen()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	
	Board:SetFrozen(loc, false);				local notFrozen1 = Board:IsFrozen(loc) == false
												local notSnow1 = Board:IsSnow(loc) == false
	
	Board:SetFrozen(loc, true);					local isFrozen1 = Board:IsFrozen(loc) == true
												local isSnow1 = Board:IsSnow(loc) == true
	
	Board:SetFrozen(loc, false);				local notFrozen2 = Board:IsFrozen(loc) == false
												local isSnow2 = Board:IsSnow(loc) == true
	
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	
	Board:SetFrozen(loc, false, true);			local notFrozen3 = Board:IsFrozen(loc) == false
												local notSnow2 = Board:IsSnow(loc) == false
	
	Board:SetFrozen(loc, true, true);			local isFrozen2 = Board:IsFrozen(loc) == true
												local isSnow3 = Board:IsSnow(loc) == true
	
	Board:SetFrozen(loc, false, true);			local notFrozen4 = Board:IsFrozen(loc) == false
												local isSnow4 = Board:IsSnow(loc) == true
	
	Assert.True(notFrozen1)
	Assert.True(notSnow1)
	Assert.True(isFrozen1)
	Assert.True(isSnow1)
	Assert.True(notFrozen2)
	Assert.True(isSnow2)
	Assert.True(notFrozen3)
	Assert.True(notSnow2)
	Assert.True(isFrozen2)
	Assert.True(isSnow3)
	Assert.True(notFrozen4)
	Assert.True(isSnow4)
	
	return true
end

function testsuite.test_BoardGetItemName()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetItem(loc, "Item_Mine");	local mine = Board:GetItemName(loc)
	
	Assert.Equals("Item_Mine", mine)
	
	return true
end
