
local MODES = {
	init = { "initialize", "Initializing", "Initialized" },
	load = { "load", "Loading", "Loaded" }
}

local function isDirectory(path)
	return path:find("[\\/]$")
end

local function hasLuaFileExtension(path)
	return path:find("%.lua$")
end

local function hasFileExtension(path)
	return path:find("%.[^\\/]+$")
end

local function pruneExtension(file)
	return file:gsub("%.%a+$", "")
end

local function runScripts(parentPath, scripts, fn, ...)
	if type(parentPath) ~= 'string' then
		return
	end

	if type(scripts) ~= 'table' then
		scripts = {scripts}
	end

	for _, subPath in ipairs(scripts) do
		local path = parentPath .. subPath

		if isDirectory(path) then
			if modApi:directoryExists(path) then
				runScripts(path, mod_loader:enumerateFilesIn(path), fn, ...)
			else
				LOGD("Failed to %s %q: Directory does not exist", fn, path)
			end
		else
			if not hasFileExtension(path) then
				path = path ..".lua"
			end

			local name = pruneExtension(path)

			if hasLuaFileExtension(path) then
				if modApi:fileExists(path) then
					local component = require(name)

					if fn and type(component) == 'table' and type(component[fn]) == 'function' then
						LOGD(MODES[fn][2].." "..name.." ...")
						component[fn](component, ...)
						LOGD(MODES[fn][3].." "..name.." successfully!")
					end
				else
					LOGD("Failed to %s %q: File does not exist", MODES[fn][1], path)
				end
			end
		end
	end
end

local scripts = {}

function scripts:init(parentPath, scripts, ...)
	if parentPath == nil then return end
	runScripts(parentPath, scripts, 'init', ...)
end

function scripts:load(parentPath, scripts, ...)
	if parentPath == nil then return end
	runScripts(parentPath, scripts, 'load', ...)
end

return scripts
