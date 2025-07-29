--!optimize 2
--!strict
--[[
	* Copyright (c) Tim7775. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]

local CargoSemver = require("./CargoSemver")
local Ordering = CargoSemver.Ordering
local parseVer = CargoSemver.Version.parse
local parseReq = CargoSemver.VersionReq.parse

--[=[
	@class Semver
	An idiomatic Luau API wrapper for the Rust-style API found in `cargo-semver`.
]=]
local Semver = {}

--[=[
	Compare the major, minor, patch, [Prerelease] and [BuildMetadata] value of two [Versions](Version).

	**Usage:**
	```lua
	-- Sort versions array
	local versions = { "3.1.2", "1.0.0", "1.0.0-rc.1", "1.0.0-rc.2", "0.3.0-alpha", "0.3.0-beta" }
	table.sort(versions, function(a, b)
		return Semver.cmp(a, "<", b)
	end)
	```
]=]
function Semver.cmp(lhs: string, op: "<" | "<=" | "==" | ">" | ">=" | "~=", rhs: string): boolean
	local lhsVer = parseVer(lhs)
	local rhsVer = parseVer(rhs)
	if op == "==" then
		return lhsVer == rhsVer
	elseif op == "<" then
		return lhsVer < rhsVer
	elseif op == ">" then
		return lhsVer > rhsVer
	elseif op == "<=" then
		return lhsVer <= rhsVer
	elseif op == ">=" then
		return lhsVer >= rhsVer
	elseif op == "~=" or op == "!=" then
		return lhsVer ~= rhsVer
	else
		error(string.format("Invalid operator: %*", op))
	end
end

--[=[
	Compare the major, minor, patch and [Prerelease] value of two [Versions](Version),
	disregarding [BuildMetadata]. [Versions](Version) that differ only in [BuildMetadata]
	are considered equal. This comparison is what the SemVer spec refers to
	as "precedence".

	**Usage:**
	```lua
	assert(Semver.cmpPrecedence(newVersion, ">=", oldVersion), "newVersion must be >= oldVersion")
	```
]=]
function Semver.cmpPrecedence(lhs: string, op: "<" | "<=" | "==" | ">" | ">=" | "~=", rhs: string): boolean
	local lhsVer = parseVer(lhs)
	local rhsVer = parseVer(rhs)
	local ordering = lhsVer:cmp_precedence(rhsVer)
	if op == "==" then
		return ordering == Ordering.Equal
	elseif op == "<" then
		return ordering == Ordering.Less
	elseif op == ">" then
		return ordering == Ordering.Greater
	elseif op == "<=" then
		return ordering ~= Ordering.Greater
	elseif op == ">=" then
		return ordering ~= Ordering.Less
	elseif op == "~=" or op == "!=" then
		return ordering ~= Ordering.Equal
	else
		error(string.format("Invalid operator: %*", op))
	end
end

--[=[
	**Usage:**
	```lua
	local versions = { "3.1.2", "0.3.0", "1.0.0", "1.6.0" }
	print(Semver.getMaxMatching(versions, "^1.0.0")) --> 1.6.0
	```
]=]
function Semver.getMaxMatching(versions: { string }, versionReq: string): string?
	local max = nil
	local maxSV = nil
	local req = parseReq(versionReq)
	for _, versionStr in versions do
		local ver = parseVer(versionStr)
		if req:matches(ver) and (maxSV == nil or ver > maxSV) then
			max = versionStr
			maxSV = ver
		end
	end
	return max
end

--[=[
	**Usage:**
	```lua
	local versions = { "3.1.2", "0.3.0", "1.0.0", "1.6.0" }
	print(Semver.getMinMatching(versions, "^1.0.0")) --> 1.0.0
	```
]=]
function Semver.getMinMatching(versions: { string }, versionReq: string): string?
	local min = nil
	local minSV = nil
	local req = parseReq(versionReq)
	for _, versionStr in versions do
		local ver = parseVer(versionStr)
		if req:matches(ver) and (minSV == nil or ver < minSV) then
			min = versionStr
			minSV = ver
		end
	end
	return min
end

--[=[
	**Usage:**
	```lua
	assert(Semver.matches(versionStr, "^1.0.0"), "version does not match requirement")
	```
]=]
function Semver.matches(version: string, versionReq: string): boolean
	local ver = parseVer(version)
	local req = parseReq(versionReq)
	return req:matches(ver)
end

type parseFunc = (string) -> any
--[=[
	@param memoizationFunc <T>((string) -> T)->(string) -> T
	Registers a memoization function for [Version.parse] or [VersionReq.parse],
	this can prevent repeated parsing of semver strings and greatly improve the performance of the [Semver] library.

	**💡 Tip:**
	Memoization functions can be found in the [luau-caching-and-memoization](https://github.com/tim7775/luau-caching-and-memoization) repository.

	**Usage:**
	```lua
	Semver.setMemoizationFunc("Version", memoizeFrame)
	Semver.setMemoizationFunc("VersionReq", function(parseFunc)
		return memoizeRecentlyUsed(50, parseFunc)
	end)
	```
]=]
function Semver.setMemoizationFunc(objToMemoize: "Version" | "VersionReq", memoizationFunc: (parseFunc) -> parseFunc)
	if objToMemoize == "Version" then
		parseVer = memoizationFunc(CargoSemver.Version.parse)
	elseif objToMemoize == "VersionReq" then
		parseReq = memoizationFunc(CargoSemver.VersionReq.parse)
	end
end

--[=[
	**Usage:**
	```lua
	assert(Semver.validateVersion("1.0"))
	--> Error: unexpected end of input while parsing minor version number
	```
]=]
function Semver.validateVersion(version: string): (boolean, string?)
	local ok: boolean, err: any = pcall(parseVer, version)
	return ok, if not ok then err else nil
end

--[=[
	**Usage:**
	```lua
	assert(Semver.validateVersionReq("1.0.a"))
	--> Error: unexpected character 'a' while parsing patch version number
	```
]=]
function Semver.validateVersionReq(versionReq: string): (boolean, string?)
	local ok: boolean, err: any = pcall(parseReq, versionReq)
	return ok, if not ok then err else nil
end

return table.freeze(Semver)
