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

local Error = require("./Error") -->require(script.Parent.Error)
local Parse = require("./Parse") -->require(script.Parent.Parse)

--[=[
	@class BuildMetadata
	@__index prototype
	Optional build metadata identifier. This comes after `+` in a SemVer version, as in `0.8.1+zstd.1.5.0`.

	Spec: https://docs.rs/semver/1.0.20/semver/struct.BuildMetadata.html
]=]
local BuildMetadata = {}
BuildMetadata.interface = {}
BuildMetadata.prototype = {}
BuildMetadata.metatable = { __index = BuildMetadata.prototype }

--- @within BuildMetadata
function BuildMetadata.interface.new(input: string): BuildMetadata
	local stringView = { str = input, cursor = 1, pos = Error.Position.Build }
	local identifier = Parse.buildIdentifier(stringView)
	if string.byte(input, stringView.cursor) ~= nil then
		error(Error.Kind.IllegalCharacter(Error.Position.Build))
	end
	local self = setmetatable({ identifier = identifier }, BuildMetadata.metatable)
	return table.freeze(self)
end

--- @within BuildMetadata
--- @private
function BuildMetadata.interface._new_unchecked(identifier: string): BuildMetadata
	local self = setmetatable({ identifier = identifier }, BuildMetadata.metatable)
	return table.freeze(self)
end

--[=[
	@within BuildMetadata
	Returns `true` if `obj` is [BuildMetadata].
]=]
function BuildMetadata.interface.is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == BuildMetadata.metatable
end

--[=[
	@within BuildMetadata
	@method is_empty
	@return boolean
]=]
function BuildMetadata.prototype.is_empty(self: BuildMetadata): boolean
	return self.identifier == ""
end

--[=[
	@within BuildMetadata
	@method __tostring
	@return string
	This metamethod transforms `self` into a string.
]=]
function BuildMetadata.metatable.__tostring(self: BuildMetadata)
	return self.identifier
end

--[=[
	@within BuildMetadata
	@method __len
	@return number
	This metamethod returns the length of `self` and is used by the `#` length operator.
]=]
function BuildMetadata.metatable.__len(self: BuildMetadata)
	return #self.identifier
end

--[=[
	@within BuildMetadata
	@method __eq
	@param other BuildMetadata
	@return boolean
	This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.
]=]
function BuildMetadata.metatable.__eq(self: BuildMetadata, other: BuildMetadata)
	return self.identifier == other.identifier
end

local b0, b9 = string.byte("0"), string.byte("9")
local function getIdentifierInfo(identifier: string): (boolean, number, number)
	local cursor = 1
	local digit = string.byte(identifier, 1)
	while digit == b0 do
		cursor += 1
		digit = string.byte(identifier, cursor)
		if digit == nil then
			return true, cursor - 1, cursor
		end
	end
	local numStart = cursor
	repeat
		if digit < b0 or digit > b9 then
			return false, numStart, cursor
		end
		cursor += 1
		digit = string.byte(identifier, cursor)
	until digit == nil
	return true, numStart, cursor
end

--[=[
	@within BuildMetadata
	@method __lt
	@param other BuildMetadata
	@return boolean
	This metamethod tests less than (for `self` and `other`) and is used by the operators `<` and `>`.
]=]
function BuildMetadata.metatable.__lt(self: BuildMetadata, other: BuildMetadata)
	--A version with BuildMetadata compares greater than a version without BuildMetadata.
	if self.identifier == other.identifier or other.identifier == "" then
		return false
	elseif self.identifier == "" then
		return true
	end

	local lhsIds = string.split(self.identifier, ".")
	local rhsIds = string.split(other.identifier, ".")

	local i = 1
	while true do
		local lhs, rhs = lhsIds[i], rhsIds[i]
		if lhs == rhs then
			i += 1
			continue
		elseif not lhs then
			return true
		elseif not rhs then
			return false
		end

		--In BuildMetadata leading zeros are allowed, unlike any other place in the SemVer grammar.
		local lhsIsNumeric, lhsNumStart, lhsCursor = getIdentifierInfo(lhs)
		local rhsIsNumeric, rhsNumStart, rhsCursor = getIdentifierInfo(rhs)
		if lhsIsNumeric and rhsIsNumeric then
			--0 < 00 < 1 < 01 < 001 < 2 < 02 < 002 < 10
			local lhsNumLength, rhsNumLength = lhsCursor - lhsNumStart, rhsCursor - rhsNumStart
			if lhsNumLength ~= rhsNumLength then
				return lhsNumLength < rhsNumLength
			end
			local trimmedLhs = if lhsNumStart > 1 then string.sub(lhs, lhsNumStart, lhsCursor - 1) else lhs
			local trimmedRhs = if rhsNumStart > 1 then string.sub(rhs, rhsNumStart, rhsCursor - 1) else rhs
			return if trimmedLhs ~= trimmedRhs then trimmedLhs < trimmedRhs else lhsNumStart < rhsNumStart
		elseif lhsIsNumeric then
			return true
		elseif rhsIsNumeric then
			return false
		else
			return lhs < rhs
		end
	end
end

--[=[
	@within BuildMetadata
	@method __le
	@param other BuildMetadata
	@return boolean
	This metamethod tests less than or equal to (for `self` and `other`) and is used by the operators `<=` and `>=`.
]=]
function BuildMetadata.metatable.__le(self: BuildMetadata, other: BuildMetadata)
	return self.identifier == other.identifier or self < other
end

--[=[
	@within BuildMetadata
	@prop EMPTY BuildMetadata
	@readonly
	@tag Static
	**Usage:**
	```lua
	local ver = Version.new(1, 0, 0, Prerelease.EMPTY, BuildMetadata.EMPTY)
	```
]=]
BuildMetadata.interface.EMPTY = BuildMetadata.interface.new("")
table.freeze(BuildMetadata.interface)
table.freeze(BuildMetadata.prototype)
table.freeze(BuildMetadata.metatable)
table.freeze(BuildMetadata)

export type BuildMetadata = typeof(BuildMetadata.interface.new(table.unpack(...)))
return BuildMetadata.interface
