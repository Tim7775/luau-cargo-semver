local fs = require("@lune/fs")

local function forEachFile(dirPath, callback)
	for _, entry in ipairs(fs.readDir(dirPath)) do
		local entryPath = dirPath .. "/" .. entry
		if fs.isFile(entryPath) then
			callback(entryPath)
		else
			forEachFile(entryPath, callback)
		end
	end
end

local function robloxifyRequires(file)
	--Bespoke path conversion algorithm (patent-pending)
	local result = string.gsub(file, "require%b() %-%->require%b()", function(capture)
		local nextRequire = string.gmatch(capture, "require%b()")
		local _pathRequire, robloxRequire = nextRequire(), nextRequire() :: string
		return robloxRequire
	end)
	return result
end

local function robloxifyWallyPackageManifest(file)
	return (string.gsub(file, "private = true #robloxify\n", "", 1))
end

local function robloxify(sourceFolder, targetFolder)
	if fs.isDir(targetFolder) then
		fs.removeDir(targetFolder)
	end
	fs.copy(sourceFolder, targetFolder)
	forEachFile(targetFolder, function(filePath)
		if string.match(filePath, "%.luau?$") then
			local file = fs.readFile(filePath)
			fs.writeFile(filePath, robloxifyRequires(file))
		elseif string.match(filePath, "wally%.toml$") then
			local file = fs.readFile(filePath)
			fs.writeFile(filePath, robloxifyWallyPackageManifest(file))
		end
	end)
end

return robloxify
