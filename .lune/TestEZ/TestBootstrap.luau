--[[
	Provides an interface to quickly run and report tests from a given object.
]]

local TestPlanner = require("./TestPlanner")
local TestRunner = require("./TestRunner")
local TextReporter = require("./Reporters/TextReporter")

local TestBootstrap = {}

local function normalize(strPath)
	return strPath:gsub("\\+", "/"):gsub("//+", "/"):gsub("/$", "")
end

local function getRequirePrefix(cwd)
	local cwdSegments = normalize(cwd):split("/")
	local scriptSegments = normalize(debug.info(2, "s")):split("/")
	local i = 1
	while cwdSegments[i] and scriptSegments[i] do
		assert(cwdSegments[i] == scriptSegments[i], "couldn't resolve relative require path")
		i += 1
	end
	local upSteps = #scriptSegments - i
	return upSteps == 0 and "./" or string.rep("../", upSteps)
end

local function stripSpecSuffix(name)
	return (name:gsub("%.spec$", ""))
end
local function isSpecScript(aScript)
	return aScript:IsA("ModuleScript") and aScript.Name:match("%.spec$")
end

local function reverse(tbl)
	for i = 1, #tbl // 2, 1 do
		tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end
	return tbl
end

local function getPathLune(filePath: string): { string }
	filePath = filePath:gsub("%.luau?$", "")
	-- Use the directory's node for init.spec files.
	filePath = filePath:gsub("/init%.spec$", "")
	local path = filePath:split("/")
	for i, component in path do
		path[i] = stripSpecSuffix(component)
	end
	if path[1] == "." and #path > 1 then
		table.remove(path, 1)
	end
	return reverse(path)
end

local function getPath(module, root)
	root = root or game

	local path = {}
	local last = module

	if last.Name == "init.spec" then
		-- Use the directory's node for init.spec files.
		last = last.Parent
	end

	while last ~= nil and last ~= root do
		table.insert(path, stripSpecSuffix(last.Name))
		last = last.Parent
	end
	table.insert(path, stripSpecSuffix(root.Name))

	return path
end

local function toStringPath(tablePath)
	local stringPath = ""
	local first = true
	for _, element in ipairs(tablePath) do
		if first then
			stringPath = element
			first = false
		else
			stringPath = element .. " " .. stringPath
		end
	end
	return stringPath
end

function TestBootstrap:getModulesImpl(root, modules, current)
	modules = modules or {}
	current = current or root

	if isSpecScript(current) then
		local method = require(current)
		local path = getPath(current, root)
		local pathString = toStringPath(path)

		table.insert(modules, {
			method = method,
			path = path,
			pathStringForSorting = pathString:lower(),
		})
	end
end

function TestBootstrap:getLuneModulesImpl(root: string, modules)
	local fs = require("@lune/fs")
	local function forEachFile(dirPath, callback)
		for _, entry in ipairs(fs.readDir(dirPath)) do
			local entryPath = dirPath .. "/" .. entry
			if fs.isFile(entryPath) then
				callback(entryPath, entry)
			else
				forEachFile(entryPath, callback)
			end
		end
	end

	local process = require("@lune/process")
	local requirePrefix = getRequirePrefix(process.cwd)
	local function requireFile(filePath)
		local requirePath = requirePrefix .. filePath:gsub("%.luau?$", "")
		return require(requirePath) :: any
	end

	local specFiles = {}
	local rootPath = normalize(root)
	if fs.isDir(rootPath) then
		forEachFile(rootPath, function(filePath, fileName)
			if fileName:match("%.spec%.luau?$") then
				table.insert(specFiles, filePath)
			end
		end)
	elseif rootPath:match("%.spec%.luau?$") then
		table.insert(specFiles, rootPath)
	end

	for _, filePath in ipairs(specFiles) do
		local method = requireFile(filePath)
		local path = getPathLune(filePath)
		local pathString = toStringPath(path)

		table.insert(modules, {
			method = method,
			path = path,
			pathStringForSorting = pathString:lower(),
		})
	end
end

--[[
	Find all the ModuleScripts in this tree that are tests.
]]
function TestBootstrap:getModules(root: string | Instance)
	local modules = {}

	if type(root) == "string" then
		self:getLuneModulesImpl(root, modules)
	else
		self:getModulesImpl(root, modules)
		for _, child in ipairs(root:GetDescendants()) do
			self:getModulesImpl(root, modules, child)
		end
	end

	return modules
end

--[[
	Runs all test and reports the results using the given test reporter.

	If no reporter is specified, a reasonable default is provided.

	This function demonstrates the expected workflow with this testing system:
	1. Locate test modules
	2. Generate test plan
	3. Run test plan
	4. Report test results

	This means we could hypothetically present a GUI to the developer that shows
	the test plan before we execute it, allowing them to toggle specific tests
	before they're run, but after they've been identified!
]]
function TestBootstrap:run(roots, reporter, otherOptions)
	reporter = reporter or TextReporter

	otherOptions = otherOptions or {}
	local showTimingInfo = otherOptions["showTimingInfo"] or false
	local testNamePattern = otherOptions["testNamePattern"]
	local extraEnvironment = otherOptions["extraEnvironment"] or {}

	if type(roots) ~= "table" then
		error(("Bad argument #1 to TestBootstrap:run. Expected table, got %s"):format(typeof(roots)), 2)
	end

	local startTime = os.clock()

	local modules = {}
	for _, subRoot in ipairs(roots) do
		local newModules = self:getModules(subRoot)

		for _, newModule in ipairs(newModules) do
			table.insert(modules, newModule)
		end
	end

	local afterModules = os.clock()

	local plan = TestPlanner.createPlan(modules, testNamePattern, extraEnvironment)
	local afterPlan = os.clock()

	local results = TestRunner.runPlan(plan)
	local afterRun = os.clock()

	reporter.report(results)
	local afterReport = os.clock()

	if showTimingInfo then
		local timing = {
			("Took %f seconds to locate test modules"):format(afterModules - startTime),
			("Took %f seconds to create test plan"):format(afterPlan - afterModules),
			("Took %f seconds to run tests"):format(afterRun - afterPlan),
			("Took %f seconds to report tests"):format(afterReport - afterRun),
		}

		print(table.concat(timing, "\n"))
	end

	return results
end

return TestBootstrap
