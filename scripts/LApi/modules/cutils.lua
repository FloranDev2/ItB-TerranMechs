
local mod_id = modApi.currentMod
local filePath = ...
local folderPath = GetParentPath(filePath)
local parentPath = GetParentPath(folderPath)
local cutilsPath = parentPath.."cutils/cutils.dll"
local successMsg = "cutils.dll successfully loaded"
local failMsg = "Something went wrong when loading"
local NAME = "cutils-dll"

local cutils = {}

function cutils:init(options)
	options = options or {}
	options.name = options.name or NAME

	local ok, err = pcall(package.loadlib(cutilsPath, "luaopen_inspect"), options)

	if not ok then
		error(string.format("%s %s - %s", failMsg, cutilsPath, err))
	else
		LOGDF("%s into global table _G[\"%s\"]", successMsg, options.name)
	end
end

function cutils:get()
	return _G[NAME]
end

return cutils
