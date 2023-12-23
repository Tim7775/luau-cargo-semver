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

local BuildMetadata = require("./BuildMetadata") -->require(script.Parent.BuildMetadata)
local Ordering = require("./Ordering") -->require(script.Parent.Ordering)
local Prerelease = require("./Prerelease") -->require(script.Parent.Prerelease)

local Parse = require("./Parse") -->require(script.Parent.Parse)
local buildIdentifier = Parse.buildIdentifier
local prereleaseIdentifier = Parse.prereleaseIdentifier
local numericIdentifier = Parse.numericIdentifier
local findByte = Parse.findByte
local dot = Parse.dot

local Error = require("./Error") -->require(script.Parent.Error)
local Position = Error.Position

local function validateVersionNumber(num: number, pos: Error.Pos)
	if type(num) ~= "number" or num < 0 or math.floor(num) ~= num then
		error(`{pos} must be an unsigned integer`)
	elseif num > Error.Bounds.LUAU_MAX_PRECISE_INT then
		error(Error.Kind.Overflow(pos))
	end
end

local function prerelease(stringView: Parse.StringView): Prerelease.Prerelease
	stringView.pos = Position.Pre
	local pre = Prerelease._new_unchecked(prereleaseIdentifier(stringView))
	if pre:is_empty() then
		error(Error.Kind.EmptySegment(Position.Pre))
	end
	return pre
end

local function buildMetadata(stringView: Parse.StringView): BuildMetadata.BuildMetadata
	stringView.pos = Position.Build
	local build = BuildMetadata._new_unchecked(buildIdentifier(stringView))
	if build:is_empty() then
		error(Error.Kind.EmptySegment(Position.Build))
	end
	return build
end

--[=[
	@class Version
	@__index prototype
	SemVer version as defined by https://semver.org.

	Spec: https://docs.rs/semver/1.0.20/semver/struct.Version.html
]=]
local Version = {}
Version.interface = {}
Version.prototype = {}
Version.metatable = { __index = Version.prototype }

--- @within Version
--- @prop major number
--- @readonly

--- @within Version
--- @prop minor number
--- @readonly

--- @within Version
--- @prop patch number
--- @readonly

--- @within Version
--- @prop pre Prerelease
--- @readonly

--- @within Version
--- @prop build BuildMetadata
--- @readonly

--- @within Version
--- @param major number
--- @param minor number
--- @param patch number
--- @param pre Prerelease
--- @param build BuildMetadata
function Version.interface.new(
	major: number,
	minor: number,
	patch: number,
	pre: Prerelease.Prerelease,
	build: BuildMetadata.BuildMetadata
): Version
	validateVersionNumber(major, Position.Major)
	validateVersionNumber(minor, Position.Minor)
	validateVersionNumber(patch, Position.Patch)
	assert(Prerelease.is(pre), "param #4 pre is invalid")
	assert(BuildMetadata.is(build), "param #5 build is invalid")
	local self =
		setmetatable({ major = major, minor = minor, patch = patch, pre = pre, build = build }, Version.metatable)
	return table.freeze(self)
end

local bMinus, bPlus = string.byte("-"), string.byte("+")
--[=[
	@within Version
	Possible reasons for the parse to fail include:
	@error UnexpectedEnd ("1.0") -- too few numeric components. A SemVer version must have exactly three. If you are looking at something that has fewer than three numbers in it, it’s possible it is a VersionReq instead (with an implicit default ^ comparison operator).
	@error LeadingZero ("1.0.01") -- a numeric component has a leading zero.
	@error UnexpectedChar ("1.0.unknown") -- unexpected character in one of the components.
	@error EmptySegment ("1.0.0-" or "1.0.0+") -- the pre-release or build metadata are indicated present but empty.
	@error UnexpectedCharAfter ("1.0.0-alpha_123") -- pre-release or build metadata have something outside the allowed characters, which are 0-9, A-Z, a-z, -, and . (dot).
	@error Overflow ("9007199254740992.0.0") -- value of major, minor or patch exceeds LUAU_MAX_PRECISE_INT (2^53 - 1).
	@error MaxIdentifierLength ("1.0.0-" .. string.rep("a", 513)) -- identifier length exceeds MAX_IDENTIFIER_LENGTH (512).
]=]
function Version.interface.parse(input: string): Version
	assert(input ~= "", Error.Kind.Empty)
	local stringView: Parse.StringView = { str = input, cursor = 1, pos = Position.Major }

	local major = numericIdentifier(stringView)
	dot(stringView)

	stringView.pos = Position.Minor
	local minor = numericIdentifier(stringView)
	dot(stringView)

	stringView.pos = Position.Patch
	local patch = numericIdentifier(stringView)

	local pre: Prerelease.Prerelease, build: BuildMetadata.BuildMetadata
	pre = if findByte(stringView, bMinus) then prerelease(stringView) else Prerelease.EMPTY
	build = if findByte(stringView, bPlus) then buildMetadata(stringView) else BuildMetadata.EMPTY

	if string.byte(stringView.str, stringView.cursor) ~= nil then
		error(Error.Kind.UnexpectedCharAfter(stringView))
	end

	local self =
		setmetatable({ major = major, minor = minor, patch = patch, pre = pre, build = build }, Version.metatable)
	return table.freeze(self)
end

--[=[
	@within Version
	Returns `true` if `obj` is a [Version].
]=]
function Version.interface.is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == Version.metatable
end

--[=[
	@within Version
	@method __tostring
	@return string
	This metamethod transforms `self` into a string.
]=]
function Version.metatable.__tostring(self: Version)
	--Note: A string.format call using %d casts the number from a double into a long long, this may result in precision loss.
	--Precision loss can be avoided with string interpolation or by formatting numbers using %* or %s instead.
	local buffer = { `{self.major}.{self.minor}.{self.patch}` }
	if not self.pre:is_empty() then
		table.insert(buffer, "-" .. tostring(self.pre))
	end
	if not self.build:is_empty() then
		table.insert(buffer, "+" .. tostring(self.build))
	end
	return table.concat(buffer)
end

--[=[
	@within Version
	@method __eq
	@param other Version
	@return boolean
	This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.
]=]
function Version.metatable.__eq(self: Version, other: Version)
	return self.major == other.major
		and self.minor == other.minor
		and self.patch == other.patch
		and self.pre == other.pre
		and self.build == other.build
end

--[=[
	@within Version
	@method __lt
	@param other Version
	@return boolean
	This metamethod tests less than (for `self` and `other`) and is used by the operators `<` and `>`.
]=]
function Version.metatable.__lt(self: Version, other: Version)
	if self.major ~= other.major then
		return self.major < other.major
	elseif self.minor ~= other.minor then
		return self.minor < other.minor
	elseif self.patch ~= other.patch then
		return self.patch < other.patch
	elseif self.pre ~= other.pre then
		return self.pre < other.pre
	end
	return self.build < other.build
end

--[=[
	@within Version
	@method __le
	@param other Version
	@return boolean
	This metamethod tests less than or equal to (for `self` and `other`) and is used by the operators `<=` and `>=`.
]=]
function Version.metatable.__le(self: Version, other: Version)
	if self.major ~= other.major then
		return self.major < other.major
	elseif self.minor ~= other.minor then
		return self.minor < other.minor
	elseif self.patch ~= other.patch then
		return self.patch < other.patch
	elseif self.pre ~= other.pre then
		return self.pre < other.pre
	end
	return self.build <= other.build
end

--[=[
	@within Version
	@method cmp_precedence
	@param other Version
	@return -1 | 0 | 1
	Compare the major, minor, patch and [Prerelease] value of `self` and `other`. Unlike the relational operators,
	this method disregards [BuildMetadata] and considers [Versions](Version) that differ only in [BuildMetadata]
	equal. This comparison is what the SemVer spec refers to as "precedence".

	Returns:
	- -1 if `self` has lower precedence than `other`
	- 0 if `self` and `other` have the same precedence
	- 1 if `self` has higher precedence than `other`

	The `CargoSemver.Ordering` enum (with the fields: `Less` = -1, `Equal` = 0, `Greater` = 1) can be used to clarify code using this method.

	**Usage:**
	```lua
	if removedVersion:cmp_precedence(addedVersion) == Ordering.Greater then
		warn("Downgrading", msg)
	else
		print("Updating", msg)
	end
	```
]=]
function Version.prototype.cmp_precedence(self: Version, other: Version): number
	if self.major ~= other.major then
		return if self.major < other.major then Ordering.Less else Ordering.Greater
	elseif self.minor ~= other.minor then
		return if self.minor < other.minor then Ordering.Less else Ordering.Greater
	elseif self.patch ~= other.patch then
		return if self.patch < other.patch then Ordering.Less else Ordering.Greater
	elseif self.pre ~= other.pre then
		return if self.pre < other.pre then Ordering.Less else Ordering.Greater
	end
	return Ordering.Equal
end

table.freeze(Version.interface)
table.freeze(Version.prototype)
table.freeze(Version.metatable)
table.freeze(Version)

export type Version = typeof(Version.interface.parse(table.unpack(...)))
return Version.interface
