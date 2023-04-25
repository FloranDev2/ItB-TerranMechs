local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath

-- GATLING

modApi:appendAsset("img/effects/gatling_muzzle_U.png", resourcePath.."img/effects/gatling_muzzle_U.png")
modApi:appendAsset("img/effects/gatling_muzzle_R.png", resourcePath.."img/effects/gatling_muzzle_R.png")
modApi:appendAsset("img/effects/gatling_muzzle_D.png", resourcePath.."img/effects/gatling_muzzle_D.png")
modApi:appendAsset("img/effects/gatling_muzzle_L.png", resourcePath.."img/effects/gatling_muzzle_L.png")

ANIMS.truelch_gatling_muzzle_flash_0 = Animation:new{
	Image = "effects/gatling_muzzle_U.png",
	NumFrames = 6,
	Time = 0.1, --0.08,
	PosX = -22, --
	PosY = 3,
}

ANIMS.truelch_gatling_muzzle_flash_1 = ANIMS.truelch_gatling_muzzle_flash_0:new{
	Image = "effects/gatling_muzzle_R.png",
	PosX = -26,
	PosY = 0,
}

ANIMS.truelch_gatling_muzzle_flash_2 = ANIMS.truelch_gatling_muzzle_flash_0:new{
	Image = "effects/gatling_muzzle_D.png",
	PosX = -25, -- -53 / 28
	PosY = 0, -- 12 / 12
}

ANIMS.truelch_gatling_muzzle_flash_3 = ANIMS.truelch_gatling_muzzle_flash_0:new{
	Image = "effects/gatling_muzzle_L.png",
	PosX = -30, --
	PosY = 2,
}