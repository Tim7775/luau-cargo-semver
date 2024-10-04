--[[
	* This file is subject to the terms of the Mozilla Public
	* License, v. 2.0. If a copy of the MPL was not distributed with this
	* file, You can obtain one at https://mozilla.org/MPL/2.0/.

	The createSpinner function was taken from:
		release.luau - A Lune script for publishing Roblox games
		Source: https://gist.github.com/boatbomber/85f1412d56086a1638055db6e1de550b
	It was released under the following license:
		MPL 2.0 License
		(c) 2024, Zack Ovits
--]]

local fs = require("@lune/fs")
local process = require("@lune/process")
local robloxify = require("./lune-utils/robloxify")
local stdio = require("@lune/stdio")
local task = require("@lune/task")

--Output utilities
local SPINNER_FRAMES = table.freeze({ "◜", "◝", "◞", "◟" })
--selene: allow(bad_string_escape)
local CLEAR_LINE = "\x1b[2K\r"
function createSpinner()
	local spinner: any = {
		animating = false,
		animateThread = nil,
		text = "",
		frame = 1,
	}

	function spinner.setText(newText: string)
		spinner.text = tostring(newText)
	end

	function spinner.start()
		if spinner.animateThread then
			return
		end

		spinner.animating = true
		spinner.frame = 1
		spinner.animateThread = task.spawn(function()
			while spinner.animating do
				stdio.write(
					CLEAR_LINE
						.. stdio.style("bold")
						.. stdio.color("green")
						.. SPINNER_FRAMES[spinner.frame]
						.. stdio.style("reset")
						.. stdio.color("reset")
						.. " "
						.. spinner.text
				)

				spinner.frame += 1
				if spinner.frame > #SPINNER_FRAMES then
					spinner.frame = 1
				end

				task.wait(1 / 20)
			end
		end)
	end

	function spinner.stop()
		spinner.animating = false
		task.cancel(spinner.animateThread)
		spinner.animateThread = nil

		spinner.text = ""
		spinner.frame = 1

		stdio.write(CLEAR_LINE)
	end

	return spinner
end

--Build Roblox source
robloxify("lib", "test/roblox-source")

--Install Wally packages
if not fs.isDir("test/Packages") then
	local result = process.spawn("wally", { "install" }, { cwd = process.cwd .. "/" .. "test" })
	if not result.ok then
		stdio.ewrite(stdio.color("red") .. "An error occured while installing Wally packages\n")
		stdio.ewrite(result.stderr .. stdio.color("reset"))
		process.exit(1)
	end
	stdio.write(stdio.color("blue") .. result.stderr .. stdio.color("reset"))
end

--Build Roblox place
local result = process.spawn("rojo", {
	"build",
	"roblox-place.project.json",
	"-o",
	"test/test.rbxl",
})
if not result.ok then
	stdio.ewrite(stdio.color("red") .. "An error occured while building Roblox place file\n")
	stdio.ewrite(result.stderr .. stdio.color("reset"))
	process.exit(1)
end
stdio.write(stdio.color("blue") .. result.stdout .. stdio.color("reset"))

--Run tests
local spinner = createSpinner()
spinner.setText("Running tests in Roblox Studio...")
spinner.start()
result = process.spawn("run-in-roblox", {
	"--place",
	"test/test.rbxl",
	"--script",
	"test/run.server.luau",
})
spinner.stop()

--Print test results
local robloxOutput = string.gsub(result.stdout, "[\r\n]*$", "")
if not result.ok then
	stdio.ewrite(stdio.color("red") .. result.stderr .. stdio.color("reset"))
	stdio.ewrite(stdio.color("red") .. robloxOutput .. stdio.color("reset"))
	process.exit(1)
end
print(stdio.color("green") .. robloxOutput .. stdio.color("reset"))
