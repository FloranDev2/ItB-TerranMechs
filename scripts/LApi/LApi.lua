
local path = GetParentPath(...)
local VERSION = "0.4.3"
local extensions = {
	"assert",
	"board",
	"pawn",
	"game",
	"trackBoard",
}
local tests = {
	"board",
	"pawn",
}
local modules = {
	"scripts",
	"library",
	"cutils",
}

local function onModsInitialized()
	local isHighestVersion = true
		and LApi.initialized ~= true
		and LApi.version == VERSION

	if isHighestVersion then
		LApi:finalizeInit()
		LApi.initialized = true
	end
end

local function onModsLoaded()
	LApi.loaded = nil
	LApi:finalizeLoad()
	LApi.loaded = true
end

modApi:addModsInitializedHook(onModsInitialized)

local isNewerVersion = false
	or LApi == nil
	or VERSION > LApi.version

if isNewerVersion then
	LApi = LApi or {}
	LApi.version = VERSION

	require(path.."events")

	function LApi:finalizeInit()
		self.scripts:init(path.."modules/", modules)
		self.scripts:init(path.."extensions/", extensions)

		modApi.events.onModsLoaded:subscribe(onModsLoaded)
	end

	function LApi:finalizeLoad()
		self.scripts:load(path.."modules/", modules)
		self.scripts:load(path.."extensions/", extensions)
		self.scripts:load(path.."tests/", tests)
	end

	-- give all modules new metatables in order to redirect all function calls
	-- to the modules of the highest version of LApi
	for _, moduleId in ipairs(modules) do
		LApi[moduleId] = LApi[moduleId] or {}
		local module = require(path.."modules/"..moduleId)
		local metatable = getmetatable(module) or {}
		rawset(metatable, "__index", module)
		setmetatable(LApi[moduleId], metatable)
	end
end

return LApi
