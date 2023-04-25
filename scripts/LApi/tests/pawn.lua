
--[[
	untestable by automatic tests:
	ClearUndoMove
	SetUndoLoc
	GetUndoLoc
	IsHighlighted
	PawnIsPlayerControlled
	MarkHpLoss
	GetMoveSkill
	SetMoveSkill
	SetRepairSkill
]]

Testsuites.lapi = Testsuites.lapi or Tests.Testsuite()
Testsuites.lapi.name = "LApi-related tests"
Testsuites.lapi.pawn = Tests.Testsuite()
Testsuites.lapi.pawn.name = "LApi-Pawn-related tests"

local testsuite = Testsuites.lapi.pawn


LApi_TEST_WEAPON = Prime_Punchmech:new{}
LApi_TEST_MECH = PunchMech:new{}

function testsuite.test_PawnGetOwner()
	local loc = Point(0,0)
	local target = Point(1,0)
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	LApi_TEST_MECH = PunchMech:new{ SkillList = {"LApi_TEST_WEAPON"} }
	LApi_TEST_WEAPON = Skill:new{
		GetSkillEffect = function(self, p1, p2)
			local ret = SkillEffect()
			local damage = SpaceDamage(p2)
			damage.sPawn = "LApi_TEST_MECH"
			ret:AddDamage(damage)
			return ret
		end
	}
	
	local parent = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	Board:AddPawn(parent, loc)
	parent:FireWeapon(target, 1)
	
	local child = Board:GetPawn(target)
	local ownerIsParent = child:GetOwner() == parent:GetId()
	
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	Assert.True(ownerIsParent)
	
	return true
end

function testsuite.test_PawnSetOwner()
	local loc = Point(0,0)
	local target = Point(1,0)
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	LApi_TEST_MECH = PunchMech:new{}
	
	local parent = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local child = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
	Board:AddPawn(parent, loc)
	Board:AddPawn(child, target)
	
									local hasNoParent = child:GetOwner() == -1
	child:SetOwner(parent:GetId()); local hasParent = child:GetOwner() == parent:GetId()
	
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	Assert.True(hasNoParent)
	Assert.True(hasParent)
	
	return true
end

function testsuite.test_PawnSetFire()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	LApi_TEST_MECH = PunchMech:new{}
	
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	Board:AddPawn(pawn, loc)
	
						local notOnFire = pawn:IsFire() == false
	pawn:SetFire(true); local onFire = pawn:IsFire() == true
	
	Board:ClearSpace(loc)
	
	Assert.True(notOnFire)
	Assert.True(onFire)
	
	return true
end

function testsuite.test_PawnGetImpactMaterial()
	LApi_TEST_MECH = PunchMech:new{ ImpactMaterial = IMPACT_INSECT }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local insect = pawn:GetImpactMaterial() == IMPACT_INSECT
	
	LApi_TEST_MECH = PunchMech:new{ ImpactMaterial = IMPACT_BLOB }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local blob = pawn:GetImpactMaterial() == IMPACT_BLOB
	
	Assert.True(insect)
	Assert.True(blob)
	
	return true
end

function testsuite.test_PawnSetImpactMaterial()
	LApi_TEST_MECH = PunchMech:new{ ImpactMaterial = IMPACT_INSECT }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
											local insect = pawn:GetImpactMaterial() == IMPACT_INSECT
	pawn:SetImpactMaterial(IMPACT_BLOB);	local blob = pawn:GetImpactMaterial() == IMPACT_BLOB
	
	Assert.True(insect)
	Assert.True(blob)
	
	return true
end

function testsuite.test_PawnIsMassive()
	LApi_TEST_MECH = PunchMech:new{ Massive = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local massive = pawn:IsMassive() == true
	
	LApi_TEST_MECH = PunchMech:new{ Massive = false }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local notMassive = pawn:IsMassive() == false
	
	Assert.True(massive)
	Assert.True(notMassive)
	
	return true
end

function testsuite.test_PawnSetMassive()
	LApi_TEST_MECH = PunchMech:new{ Massive = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local massive = pawn:IsMassive() == true
	pawn:SetMassive(false);	local notMassive = pawn:IsMassive() == false
	
	Assert.True(massive)
	Assert.True(notMassive)
	
	return true
end

function testsuite.test_PawnSetFlying()
	LApi_TEST_MECH = PunchMech:new{ Flying = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local flying = pawn:IsFlying() == true
	pawn:SetFlying(false);	local notFlying = pawn:IsFlying() == false
	
	Assert.True(flying)
	Assert.True(notFlying)
	
	return true
end

function testsuite.test_PawnSetTeleporter()
	LApi_TEST_MECH = PunchMech:new{ Teleporter = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
								local teleporter = pawn:IsTeleporter() == true
	pawn:SetTeleporter(false);	local notTeleporter = pawn:IsTeleporter() == false
	
	Assert.True(teleporter)
	Assert.True(notTeleporter)
	
	return true
end

function testsuite.test_PawnSetJumper()
	LApi_TEST_MECH = PunchMech:new{ Jumper = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local jumper = pawn:IsJumper() == true
	pawn:SetJumper(false);	local notJumper = pawn:IsJumper() == false
	
	Assert.True(jumper)
	Assert.True(notJumper)
	
	return true
end

-- fails if there are units on the field altering health.
function testsuite.test_PawnGetMaxHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local maxHealth5 = pawn:GetMaxHealth()
	
	LApi_TEST_MECH = PunchMech:new{ Health = 6 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local maxHealth6 = pawn:GetMaxHealth()
	
	Assert.Equals(5, maxHealth5)
	Assert.Equals(6, maxHealth6)
	
	return true
end

function testsuite.test_PawnGetBaseMaxHealth()
	local loc = Point(0,0)
	local locJelly = Point(1,0)
	Board:ClearSpace(loc)
	Board:ClearSpace(locJelly)
	
	local jelly = PAWN_FACTORY:CreatePawn("Jelly_Health1"); Board:AddPawn(jelly, locJelly)
	
	LApi_TEST_MECH = PunchMech:new{ Health = 5, SkillList = { "Passive_Psions" } }
	
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH"); Board:AddPawn(pawn, loc)
	local baseMaxHealth5 = pawn:GetBaseMaxHealth()
	
	Board:ClearSpace(loc)
	Board:ClearSpace(locJelly)
	
	Assert.Equals(5, baseMaxHealth5)
	
	return true
end

function testsuite.test_PawnSetHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
						local health5 = pawn:GetHealth()
	pawn:SetHealth(7);	local health5Max = pawn:GetHealth()
	pawn:SetHealth(2);	local health2 = pawn:GetHealth()
	
	Assert.Equals(5, health5)
	Assert.Equals(5, health5Max)
	Assert.Equals(2, health2)
	
	return true
end

function testsuite.test_PawnSetMaxHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local maxHealth5 = pawn:GetMaxHealth()
	pawn:SetMaxHealth(7);	local maxHealth7 = pawn:GetMaxHealth()
	
	Assert.Equals(5, maxHealth5)
	Assert.Equals(7, maxHealth7)
	
	return true
end

function testsuite.test_PawnSetBaseMaxHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
								local baseMaxHealth5 = pawn:GetBaseMaxHealth()
	pawn:SetBaseMaxHealth(7);	local baseMaxHealth7 = pawn:GetBaseMaxHealth()
	
	Assert.Equals(5, baseMaxHealth5)
	Assert.Equals(7, baseMaxHealth7)
	
	return true
end
