--!nocheck
local TestEZ = require("../test/TestEZ")
local process = require("@lune/process")

local results = TestEZ.TestBootstrap:run({
	"lib",
})

if results.failureCount > 0 then
	process.exit(1)
end
