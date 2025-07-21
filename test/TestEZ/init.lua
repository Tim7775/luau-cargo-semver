local Expectation = require("@self/Expectation")
local TeamCityReporter = require("@self/Reporters/TeamCityReporter")
local TestBootstrap = require("@self/TestBootstrap")
local TestEnum = require("@self/TestEnum")
local TestPlan = require("@self/TestPlan")
local TestPlanner = require("@self/TestPlanner")
local TestResults = require("@self/TestResults")
local TestRunner = require("@self/TestRunner")
local TestSession = require("@self/TestSession")
local TextReporter = require("@self/Reporters/TextReporter")
local TextReporterQuiet = require("@self/Reporters/TextReporterQuiet")

local function run(testRoot, callback)
	local modules = TestBootstrap:getModules(testRoot)
	local plan = TestPlanner.createPlan(modules)
	local results = TestRunner.runPlan(plan)

	callback(results)
end

local TestEZ = {
	run = run,

	Expectation = Expectation,
	TestBootstrap = TestBootstrap,
	TestEnum = TestEnum,
	TestPlan = TestPlan,
	TestPlanner = TestPlanner,
	TestResults = TestResults,
	TestRunner = TestRunner,
	TestSession = TestSession,

	Reporters = {
		TextReporter = TextReporter,
		TextReporterQuiet = TextReporterQuiet,
		TeamCityReporter = TeamCityReporter,
	},
}

return TestEZ
