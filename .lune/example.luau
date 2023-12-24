local Semver = require("../lib/Semver")

do
	local req = ">=1.2.3, <1.8.0"
	-- Check whether this requirement matches version 1.2.3-alpha.1 (no)
	assert(not Semver.matches("1.2.3-alpha.1", req), "assertion failed!")
	-- Check whether it matches 1.3.0 (yes it does)
	assert(Semver.matches("1.3.0", req), "assertion failed!")

	-- Compare versions
	assert(Semver.cmp("1.3.0", "~=", "1.3.0+build"), "assertion failed!")
	assert(Semver.cmpPrecedence("1.3.0", "==", "1.3.0+build"), "assertion failed!")

	-- Sort versions array
	local versions = { "3.1.2", "1.0.0", "1.0.0-rc.1", "1.0.0-rc.2", "0.3.0-alpha", "0.3.0-beta" }
	table.sort(versions, function(a, b)
		return Semver.cmp(a, "<", b)
	end)
	print(versions)
end
