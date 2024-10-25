--!optimize 2
--!strict
--[[
	* Copyright (c) 2024 Tim7775
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

local Prerelease = require("./Prerelease") -->require(script.Parent.Prerelease)
local Version = require("./Version") -->require(script.Parent.Version)

local Parse = require("./Parse") -->require(script.Parent.Parse)
local Operators = Parse.Operators
local buildIdentifier = Parse.buildIdentifier
local prereleaseIdentifier = Parse.prereleaseIdentifier
local numericIdentifier = Parse.numericIdentifier
local wildcard = Parse.wildcard
local skipWhitespace = Parse.skipWhitespace
local operator = Parse.operator
local findByte = Parse.findByte

local Error = require("./Error") -->require(script.Parent.Error)
local Position = Error.Position
local bDot, bMinus, bPlus = string.byte(".-+", 1, 3)

--[=[
	@class Comparator
	@__index prototype
	A pair of comparison operator and partial version, such as `>=1.2`. Forms one piece of a [VersionReq].

	Spec: https://docs.rs/semver/1.0.20/semver/struct.Comparator.html
]=]
local Comparator = {}
Comparator.interface = {}
Comparator.prototype = {}
Comparator.metatable = { __index = Comparator.prototype }

--- @within Comparator
--- @prop op "=" | ">" | ">=" | "<" | "<=" | "~" | "^" | "*"
--- @readonly

--- @within Comparator
--- @prop major number
--- @readonly

--- @within Comparator
--- @prop minor number?
--- @readonly

--- @within Comparator
--- @prop patch number?
--- @readonly

--- @within Comparator
--- @prop pre Prerelease
--- @readonly

--- @within Comparator
--- @private
--- @type StringView {cursor: number, str: string, pos: string}

--- @within Comparator
--- @private
--- @param stringView StringView
function Comparator.interface._parse_string_view(stringView: Parse.StringView): Comparator
	local start = stringView.cursor
	local op: Parse.Operator = operator(stringView)
	local defaultOp = start == stringView.cursor
	skipWhitespace(stringView)

	stringView.pos = Position.Major
	local major = numericIdentifier(stringView)

	local minor: number?, patch: number? = nil, nil
	if findByte(stringView, bDot) then
		stringView.pos = Position.Minor
		local hasWildcard = wildcard(stringView) ~= nil
		if not hasWildcard then
			minor = numericIdentifier(stringView)
		elseif defaultOp then
			op = Operators.Wildcard
		end

		if findByte(stringView, bDot) then
			stringView.pos = Position.Patch
			if wildcard(stringView) then
				if defaultOp then
					op = Operators.Wildcard
				end
			elseif hasWildcard then
				error(Error.Kind.UnexpectedAfterWildcard)
			else
				patch = numericIdentifier(stringView)
			end
		end
	end

	local pre: Prerelease.Prerelease = Prerelease.EMPTY
	if patch ~= nil then
		if findByte(stringView, bMinus) then
			stringView.pos = Position.Pre
			pre = Prerelease._new_unchecked(prereleaseIdentifier(stringView))
			if pre:is_empty() then
				error(Error.Kind.EmptySegment(stringView.pos))
			end
		end
		if findByte(stringView, bPlus) then
			stringView.pos = Position.Build
			if buildIdentifier(stringView) == "" then
				error(Error.Kind.EmptySegment(stringView.pos))
			end
		end
	end
	skipWhitespace(stringView)

	local self = setmetatable({ op = op, major = major, minor = minor, patch = patch, pre = pre }, Comparator.metatable)
	table.freeze(self)
	return self
end

--- @within Comparator
function Comparator.interface.parse(input: string): Comparator
	local stringView: Parse.StringView = { str = input, cursor = 1, pos = Position.Major }
	local result = Comparator.interface._parse_string_view(stringView)
	if string.byte(stringView.str, stringView.cursor) ~= nil then
		error(Error.Kind.UnexpectedCharAfter(stringView))
	end
	return result
end

--[=[
	@within Comparator
	Returns `true` if `obj` is a [Comparator].
]=]
function Comparator.interface.is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == Comparator.metatable
end

--[=[
	@within Comparator
	@method __eq
	@param other Comparator
	@return boolean
	This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.
]=]
function Comparator.metatable.__eq(self: Comparator, other: Comparator)
	return self.op == other.op
		and self.major == other.major
		and self.minor == other.minor
		and self.patch == other.patch
		and self.pre == other.pre
end

--[=[
	@within Comparator
	@method __tostring
	@return string
	This metamethod transforms `self` into a string.
]=]
function Comparator.metatable.__tostring(self: Comparator)
	local result = if self.op == Operators.Wildcard then "" else self.op
	result ..= self.major
	if self.minor ~= nil then
		result ..= "." .. self.minor
		if self.patch ~= nil then
			result ..= "." .. self.patch
		elseif self.op == Operators.Wildcard then
			result ..= ".*"
		end
	elseif self.op == Operators.Wildcard then
		result ..= ".*"
	end
	if not self.pre:is_empty() then
		result ..= "-" .. self.pre.identifier
	end
	return result
end

local function matchesExact(cmp: Comparator, ver: Version.Version)
	if ver.major ~= cmp.major then
		return false
	end

	local minor = cmp.minor
	if minor ~= nil then
		if ver.minor ~= minor then
			return false
		end
	end

	local patch = cmp.patch
	if patch ~= nil then
		if ver.patch ~= patch then
			return false
		end
	end

	return ver.pre == cmp.pre
end

local function matchesGreater(cmp: Comparator, ver: Version.Version)
	if ver.major ~= cmp.major then
		return ver.major > cmp.major
	end

	local minor = cmp.minor
	if minor == nil then
		return false
	elseif ver.minor ~= minor then
		return ver.minor > minor
	end

	local patch = cmp.patch
	if patch == nil then
		return false
	elseif ver.patch ~= patch then
		return ver.patch > patch
	end

	return ver.pre > cmp.pre
end

local function matchesGreaterEq(cmp: Comparator, ver: Version.Version)
	return matchesGreater(cmp, ver) or matchesExact(cmp, ver)
end

local function matchesLess(cmp: Comparator, ver: Version.Version)
	if ver.major ~= cmp.major then
		return ver.major < cmp.major
	end

	local minor = cmp.minor
	if minor == nil then
		return false
	elseif ver.minor ~= minor then
		return ver.minor < minor
	end

	local patch = cmp.patch
	if patch == nil then
		return false
	elseif ver.patch ~= patch then
		return ver.patch < patch
	end

	return ver.pre < cmp.pre
end

local function matchesLessEq(cmp: Comparator, ver: Version.Version)
	return matchesLess(cmp, ver) or matchesExact(cmp, ver)
end

local function matchesTilde(cmp: Comparator, ver: Version.Version)
	if ver.major ~= cmp.major then
		return false
	end

	local minor = cmp.minor
	if minor ~= nil then
		if ver.minor ~= minor then
			return false
		end
	end

	local patch = cmp.patch
	if patch ~= nil then
		if ver.patch ~= patch then
			return ver.patch > patch
		end
	end

	return ver.pre >= cmp.pre
end

local function matchesCaret(cmp: Comparator, ver: Version.Version)
	if ver.major ~= cmp.major then
		return false
	end

	local minor = cmp.minor :: number
	if minor == nil then
		return true
	end

	local patch = cmp.patch :: number
	if patch == nil then
		if cmp.major > 0 then
			return ver.minor >= minor
		else
			return ver.minor == minor
		end
	end

	if cmp.major > 0 then
		if ver.minor ~= minor then
			return ver.minor > minor
		elseif ver.patch ~= patch then
			return ver.patch > patch
		end
	elseif minor > 0 then
		if ver.minor ~= minor then
			return false
		elseif ver.patch ~= patch then
			return ver.patch > patch
		end
	elseif ver.minor ~= minor or ver.patch ~= patch then
		return false
	end

	return ver.pre >= cmp.pre
end

local matchesImpl: { [Parse.Operator]: (Comparator, Version.Version) -> boolean } = {
	[Operators.Exact] = matchesExact,
	[Operators.Greater] = matchesGreater,
	[Operators.GreaterEq] = matchesGreaterEq,
	[Operators.Less] = matchesLess,
	[Operators.LessEq] = matchesLessEq,
	[Operators.Tilde] = matchesTilde,
	[Operators.Caret] = matchesCaret,
	[Operators.Wildcard] = matchesExact,
}

--[=[
	@within Comparator
	@method matches
	@param ver Version
	@return boolean
]=]
function Comparator.prototype.matches(self: Comparator, ver: Version.Version): boolean
	return matchesImpl[self.op](self, ver)
end

table.freeze(Comparator.interface)
table.freeze(Comparator.prototype)
table.freeze(Comparator.metatable)
table.freeze(Comparator)

export type Comparator = typeof((Comparator.interface.parse(table.unpack(...))))
return Comparator.interface
