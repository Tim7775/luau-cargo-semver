const fs = require("@std/fs")
const json = require("@std/json")
const path = require("@std/path")
const process = require("@std/process")
const stringext = require("@std/stringext")

const function copyDirectory(from: path.Pathlike, to: path.Pathlike, options: { excludeSuffix: string? })
	local filetype = fs.metadata(from).type
	if filetype == "dir" then
		fs.createDirectory(to, { makeParents = true })
		for _, entry in fs.listDirectory(from) do
			copyDirectory(path.join(from, entry.name), path.join(to, entry.name), options)
		end
	elseif filetype == "file" then
		if options.excludeSuffix == nil or not stringext.hasSuffix(tostring(from), options.excludeSuffix) then
			fs.copy(from, to)
		end
	else
		error(`Unsupported file type: {filetype}`)
	end
end

--Delete existing distributables
if fs.exists("dist") then
	fs.removeDirectory("dist", { recursive = true })
end
--Build Roblox-ts distributable
local targetDir = path.join("dist", "roblox-ts-distributable")
copyDirectory("lib", targetDir, { excludeSuffix = ".spec.luau" })

--Delete wally.toml files to prevent accidental publishing of roblox-ts distributable to wally registry
fs.remove(path.join(targetDir, "CargoSemver", "wally.toml"))
fs.remove(path.join(targetDir, "Semver", "wally.toml"))

--Insert Roblox-ts README
fs.copy(path.join("docs", "_roblox-ts-readme.md"), path.join(targetDir, "Semver", "README.md"))

--Restructure directory
local sourceDir = path.join(targetDir, "Semver")
for _, entry in pairs(fs.listDirectory(sourceDir)) do
	fs.copy(path.join(sourceDir, entry.name), path.join(targetDir, entry.name))
end
fs.removeDirectory(sourceDir, { recursive = true })

--Fix require path
local filePath = path.join(targetDir, "init.luau")
local file = fs.readFileToString(filePath)
local result, count = string.gsub(file, 'require%("%./CargoSemver"%)', 'require("@self/CargoSemver")', 1)
assert(count == 1, "Couldn't fix require path")
fs.writeStringToFile(filePath, result)

--Set private to false so package can be published to npm
local package: any = json.deserialize(fs.readFileToString(path.join(targetDir, "package.json")))
package.private = nil
fs.writeStringToFile(path.join(targetDir, "package.json"), json.serialize(package, true))
print(`Built project to {targetDir}`)

--Build Roblox model
local modelDestination = path.join("dist", "luau-cargo-semver.rbxm")
local buildResult = process.run({ "rojo", "build", "default.project.json", "-o", tostring(modelDestination) })
if not buildResult.ok then
	print("An error occured while building Roblox model file")
	print(buildResult.stderr)
	process.exit(buildResult.exitcode)
end
print(`Built project to {modelDestination}`)
