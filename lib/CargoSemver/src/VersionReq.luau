--!optimize 2
--!strict
--[[
	* Copyright (c) 2023 Tim7775
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

local Comparator = require("./Comparator") -->require(script.Parent.Comparator)
local Error = require("./Error") -->require(script.Parent.Error)
local Version = require("./Version") -->require(script.Parent.Version)
local Position = Error.Position

local Parse = require("./Parse") -->require(script.Parent.Parse)
local wildcard = Parse.wildcard
local skipWhitespace = Parse.skipWhitespace

local MAX_COMPARATORS = 32

--[=[
	@class VersionReq
	@__index prototype
	SemVer version requirement describing the intersection of some version comparators, such as `>=1.2.3, <1.8`.

	Spec: https://docs.rs/semver/1.0.20/semver/struct.VersionReq.html
]=]
--[=[
	@within VersionReq
	@prop comparators {Comparator}
	@readonly
]=]
local VersionReq = {}
VersionReq.interface = {}
VersionReq.prototype = {}
VersionReq.metatable = { __index = VersionReq.prototype }

local bComma = string.byte(",")
--[=[
	@within VersionReq
	Possible reasons for the parse to fail include:
	@error UnexpectedChar (">a.b") -- unexpected characters in the partial version.
	@error UnexpectedChar ("@1.0.0) -- unrecognized comparison operator.
	@error UnexpectedEnd ("^1.0.0,") -- unexpected end of input.
	@error ExpectedCommaFound (">=1.0 <2.0") -- missing comma between comparators.
	@error UnexpectedAfterWildcard ("*.*") -- unsupported wildcard syntax.
]=]
function VersionReq.interface.parse(input: string): VersionReq
	local stringView: Parse.StringView = { str = input, cursor = 1, pos = Position.Major }
	local self = setmetatable({ comparators = {} :: { Comparator.Comparator } }, VersionReq.metatable)
	skipWhitespace(stringView)

	local wildcardByte = wildcard(stringView)
	if wildcardByte then
		skipWhitespace(stringView)
		local nextByte = string.byte(stringView.str, stringView.cursor)
		if nextByte == nil then
			table.freeze(self.comparators)
			return table.freeze(self)
		elseif nextByte == bComma then
			error(Error.Kind.WildcardNotTheOnlyComparator(string.char(wildcardByte)))
		else
			error(Error.Kind.UnexpectedAfterWildcard)
		end
	end

	local depth = 1
	while true do
		assert(depth <= MAX_COMPARATORS, Error.Kind.ExcessiveComparators)

		wildcardByte = wildcard(stringView)
		if wildcardByte then
			local nextByte = string.byte(stringView.str, stringView.cursor)
			if nextByte == nil or nextByte == bComma then
				error(Error.Kind.WildcardNotTheOnlyComparator(string.char(wildcardByte)))
			end
			stringView.cursor -= 1
		end

		table.insert(self.comparators, Comparator._parse_string_view(stringView))

		local byte = string.byte(stringView.str, stringView.cursor)
		if byte == nil then
			break
		elseif byte == bComma then
			stringView.cursor += 1
			skipWhitespace(stringView)
		else
			error(Error.Kind.ExpectedCommaFound(stringView))
		end

		depth += 1
	end
	table.freeze(self.comparators)
	return table.freeze(self)
end

--[=[
	@within VersionReq
	Returns `true` if `obj` is a [VersionReq].
]=]
function VersionReq.interface.is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == VersionReq.metatable
end

local function preIsCompatible(cmp: Comparator.Comparator, ver: Version.Version): boolean
	return cmp.major == ver.major and cmp.minor == ver.minor and cmp.patch == ver.patch and not cmp.pre:is_empty()
end

--[=[
	@within VersionReq
	@method matches
	@param ver Version
	@return boolean
	Evaluate whether the given [Version] satisfies the version requirement described by `self`.
]=]
function VersionReq.prototype.matches(self: VersionReq, ver: Version.Version): boolean
	for _, cmp in self.comparators do
		if not cmp:matches(ver) then
			return false
		end
	end

	if ver.pre:is_empty() then
		return true
	end

	-- If a version has a prerelease tag (for example, 1.2.3-alpha.3) then it
	-- will only be allowed to satisfy req if at least one comparator with the
	-- same major.minor.patch also has a prerelease tag.
	for _, cmp in self.comparators do
		if preIsCompatible(cmp, ver) then
			return true
		end
	end

	return false
end

--[=[
	@within VersionReq
	@method __tostring
	@return string
	This metamethod transforms `self` into a string.
]=]
function VersionReq.metatable.__tostring(self: VersionReq)
	if next(self.comparators) == nil then
		return "*"
	end
	local buffer = {}
	for _, comparator in ipairs(self.comparators) do
		table.insert(buffer, tostring(comparator))
	end
	return table.concat(buffer, ", ")
end

--[=[
	@within VersionReq
	@method __eq
	@param other VersionReq
	@return boolean
	This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.
]=]
function VersionReq.metatable.__eq(self: VersionReq, other: VersionReq)
	for _, comparator in ipairs(self.comparators) do
		if not table.find(other.comparators, comparator) then
			return false
		end
	end
	for _, comparator in ipairs(other.comparators) do
		if not table.find(self.comparators, comparator) then
			return false
		end
	end
	return true
end

--[=[
	@within VersionReq
	@prop STAR VersionReq
	@readonly
	@tag Static
	A `VersionReq` with no constraint on the version numbers it matches. Equivalent to `VersionReq.parse("*")`.

	In terms of comparators this is equivalent to `>=0.0.0`.

	Counterintuitively a `*` VersionReq does not match every possible version number. In particular, in order for *any* `VersionReq` to match a pre-release version, the `VersionReq` must contain at least one [Comparator] that has an explicit major, minor, and patch version identical to the pre-release being matched, and that has a nonempty pre-release component. Since `*` is not written with an explicit major, minor, and patch version, and does not contain a nonempty pre-release component, it does not match any pre-release versions.
]=]
VersionReq.interface.STAR = VersionReq.interface.parse("*")
table.freeze(VersionReq.interface)
table.freeze(VersionReq.prototype)
table.freeze(VersionReq.metatable)
table.freeze(VersionReq)

export type VersionReq = typeof(VersionReq.interface.parse(table.unpack(...)))
return VersionReq.interface
