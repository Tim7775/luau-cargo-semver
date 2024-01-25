local fs = require("@lune/fs")
local process = require("@lune/process")
local robloxify = require("./lune-utils/robloxify")
local stdio = require("@lune/stdio")

local function write(msg, color)
	print(stdio.color(color) .. (string.gsub(msg, "\n$", "")) .. stdio.color("reset"))
end

--Build Roblox source
robloxify("lib", "test/roblox-source")

--Install Wally packages
if not fs.isDir("test/Packages") then
	local result = process.spawn("wally", { "install" }, { cwd = process.cwd .. "/" .. "test" })
	if not result.ok then
		write("An error occured while installing Wally packages", "red")
		write(result.stderr, "red")
		process.exit(1)
	end
	write(result.stderr, "blue")
end

--Build Roblox place
local result = process.spawn("rojo", {
	"build",
	"roblox-place.project.json",
	"-o",
	"test/test.rbxl",
})
if not result.ok then
	write("An error occured while building Roblox place file", "red")
	write(result.stderr, "red")
	process.exit(1)
end
write(result.stdout, "blue")

--Run tests
result = process.spawn("run-in-roblox", {
	"--place",
	"test/test.rbxl",
	"--script",
	"test/run.server.luau",
})
if not result.ok then
	write(result.stdout, "red")
	process.exit(1)
end
write(result.stdout, "green")
