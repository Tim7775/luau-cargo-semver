local fs = require("@lune/fs")
local serde = require("@lune/serde")

--Build Roblox source
local robloxify = require("./lune-utils/robloxify")
robloxify("lib", "test/roblox-ts-source")

--Delete wally.toml files to prevent accidental publishing of roblox-ts source to wally registry
fs.removeFile("test/roblox-ts-source/CargoSemver/wally.toml")
fs.removeFile("test/roblox-ts-source/Semver/wally.toml")

--Restructure directory
local sourceDir = "test/roblox-ts-source/Semver/"
local targetDir = "test/roblox-ts-source/"
for _, entry in pairs(fs.readDir(sourceDir)) do
	fs.move(sourceDir .. entry, targetDir .. entry)
end
fs.removeDir(sourceDir)

--Fix require path
local file = fs.readFile(targetDir .. "init.luau")
local result, count = string.gsub(file, "require%(script.Parent.CargoSemver%)", "require(script.CargoSemver)", 1)
assert(count == 1, "Couldn't fix require path")
fs.writeFile(targetDir .. "init.luau", result)

--Set private to false so package can be published to npm
local package = serde.decode("json", fs.readFile(targetDir .. "package.json"))
package.private = nil
fs.writeFile(targetDir .. "package.json", serde.encode("json", package, true) .. "\n")
