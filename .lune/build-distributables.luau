local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

--Delete existing distributables
if fs.isDir("dist") then
	fs.removeDir("dist")
end

--Build Roblox-ts distributable
fs.copy("lib", "dist/roblox-ts-distributable", true)
--Delete wally.toml files to prevent accidental publishing of roblox-ts distributable to wally registry
fs.removeFile("dist/roblox-ts-distributable/CargoSemver/wally.toml")
fs.removeFile("dist/roblox-ts-distributable/Semver/wally.toml")

--Insert Roblox-ts README
fs.copy("docs/_roblox-ts-readme.md", "dist/roblox-ts-distributable/Semver/README.md", true)

--Restructure directory
local sourceDir = "dist/roblox-ts-distributable/Semver/"
local targetDir = "dist/roblox-ts-distributable/"
for _, entry in pairs(fs.readDir(sourceDir)) do
	fs.move(sourceDir .. entry, targetDir .. entry)
end
fs.removeDir(sourceDir)

--Fix require path
local file = fs.readFile(targetDir .. "init.luau")
local result, count = string.gsub(file, 'require%("%./CargoSemver"%)', 'require("@self/CargoSemver")', 1)
assert(count == 1, "Couldn't fix require path")
fs.writeFile(targetDir .. "init.luau", result)

--Set private to false so package can be published to npm
local package = serde.decode("json", fs.readFile(targetDir .. "package.json"))
package.private = nil
fs.writeFile(targetDir .. "package.json", serde.encode("json", package, true) .. "\n")
print("Built project to dist/roblox-ts-distributable")

--Build Roblox model
local modelDestination = "dist/luau-cargo-semver.rbxm"
local buildResult = process.exec("rojo", {
	"build",
	"default.project.json",
	"-o",
	modelDestination,
})
if not buildResult.ok then
	stdio.ewrite(stdio.color("red") .. "An error occured while building Roblox model file\n")
	stdio.ewrite(buildResult.stderr .. stdio.color("reset"))
	process.exit(1)
end
print(`Built project to {modelDestination}`)
