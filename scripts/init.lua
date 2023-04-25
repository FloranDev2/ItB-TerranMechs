local mod = {
	id = "truelch_TerranMechs",
	name = "Terran Mechs",
	icon = "img/mod_icon.png",
	version = "2.0.0",
	modApiVersion = "2.9.1",
	gameVersion = "1.2.88",
    dependencies = {
        modApiExt = "1.17",
		memedit = "1.0.1",
    }
}

function mod:init()
	--Palette
	require(self.scriptPath .. "palette")
	
	--Mechs
	require(self.scriptPath .. "mechs/hell")
	require(self.scriptPath .. "mechs/viking")
	require(self.scriptPath .. "mechs/crucio")
	
	--Libs
	require(self.scriptPath .. "libs/artilleryArc")

	-- FMW ----->
	--modapi already defined
	self.FMW_hotkeyConfigTitle = "Mode Selection Hotkey" -- title of hotkey config in mod config
	self.FMW_hotkeyConfigDesc = "Hotkey used to open and close firing mode selection." -- description of hotkey config in mod config

	--init FMW
	require(self.scriptPath .. "fmw/FMW"):init()

	--FMW weapons
	require(self.scriptPath .. "/weapons/hellFMW")
	require(self.scriptPath .. "/weapons/vikingFMW")
	require(self.scriptPath .. "/weapons/crucioFMW")
	-- <----- FMW

	--Animations
	require(self.scriptPath .. "animations")

	--Hooks
	require(self.scriptPath .. "hooks")

	--Achievements
	require(self.scriptPath .. "achievements")
end

function mod:load(options, version)
	--modApiExt
	truelch_terran_ModApiExt:load(self, options, version)

	--FMW
	require(self.scriptPath .. "fmw/FMW"):load()

	modApi:addSquad(
		{
			id = "truelch_TerranMechs",
			"Terran Mechs",
			"HellMech",
			"VikingMech",
			"CrucioMech"
		},
		"Terran Mechs",
		"The numerous parallel timelines created a breach to the Koprulu System.\nA Squad of Terran Mechs has been trapped and fights its way back to the Terran Dominion!",
		self.resourcePath .."img/squad_icon.png"
	)
end

return mod