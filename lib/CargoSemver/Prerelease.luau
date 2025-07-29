--!optimize 2
--!strict
--[[
	* Copyright (c) 2025 Tim7775
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

local Error = require("./Error")
local Parse = require("./Parse")

--[=[
	@class Prerelease
	@__index prototype
	Optional pre-release identifier on a version string. This comes after `-` in a SemVer version, like `1.0.0-alpha.1`

	Spec: https://docs.rs/semver/1.0.20/semver/struct.Prerelease.html
]=]
local Prerelease = {}
Prerelease.interface = {}
Prerelease.prototype = {}
Prerelease.metatable = { __index = Prerelease.prototype }

--- @within Prerelease
function Prerelease.interface.new(input: string): Prerelease
	local stringView = { str = input, cursor = 1, pos = Error.Position.Pre }
	local identifier = Parse.prereleaseIdentifier(stringView)
	if string.byte(input, stringView.cursor) ~= nil then
		error(Error.Kind.IllegalCharacter(Error.Position.Pre))
	end
	local self = setmetatable({ identifier = identifier }, Prerelease.metatable)
	return table.freeze(self)
end

--- @within Prerelease
--- @private
function Prerelease.interface._new_unchecked(identifier: string): Prerelease
	local self = setmetatable({ identifier = identifier }, Prerelease.metatable)
	return table.freeze(self)
end

--[=[
	@within Prerelease
	Returns `true` if `obj` is a [Prerelease].
]=]
function Prerelease.interface.is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == Prerelease.metatable
end

--[=[
	@within Prerelease
	@method is_empty
	@return boolean
]=]
function Prerelease.prototype.is_empty(self: Prerelease): boolean
	return self.identifier == ""
end

--[=[
	@within Prerelease
	@method __tostring
	@return string
	This metamethod transforms `self` into a string.
]=]
function Prerelease.metatable.__tostring(self: Prerelease)
	return self.identifier
end

--[=[
	@within Prerelease
	@method __len
	@return number
	This metamethod returns the length of `self` and is used by the `#` length operator.
]=]
function Prerelease.metatable.__len(self: Prerelease)
	return #self.identifier
end

--[=[
	@within Prerelease
	@method __eq
	@param other Prerelease
	@return boolean
	This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.
]=]
function Prerelease.metatable.__eq(self: Prerelease, other: Prerelease)
	return self.identifier == other.identifier
end

local b0, b9 = string.byte("0"), string.byte("9")
local function getIdentifierInfo(identifier: string): (boolean, number)
	local cursor = 1
	local digit = string.byte(identifier, 1)
	repeat
		if digit < b0 or digit > b9 then
			return false, cursor
		end
		cursor += 1
		digit = string.byte(identifier, cursor)
	until digit == nil
	return true, cursor
end

--[=[
	@within Prerelease
	@method __lt
	@param other Prerelease
	@return boolean
	This metamethod tests less than (for `self` and `other`) and is used by the operators `<` and `>`.
]=]
function Prerelease.metatable.__lt(self: Prerelease, other: Prerelease)
	--A real release compares greater than prerelease.
	if self.identifier == other.identifier or self.identifier == "" then
		return false
	elseif other.identifier == "" then
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
			-- Spec: "A larger set of pre-release fields has a higher
			-- precedence than a smaller set, if all of the preceding
			-- identifiers are equal."
			return true
		elseif not rhs then
			return false
		end

		-- tonumber can't be used to check if an identifier is numeric, because it does
		-- some evaluations that are not according to spec (e.g. tonumber("10e2") -> 1000).
		-- Converting to a number is also avoided because it can result in precision loss.
		local lhsIsNumeric, lhsCursor = getIdentifierInfo(lhs)
		local rhsIsNumeric, rhsCursor = getIdentifierInfo(rhs)
		if lhsIsNumeric and rhsIsNumeric then
			-- Numeric identifiers are compared numerically with arbitrary lenth precision.
			return if lhsCursor ~= rhsCursor then lhsCursor < rhsCursor else lhs < rhs
		elseif lhsIsNumeric then
			-- Numeric identifiers always have lower precedence than non-numeric identifiers.
			return true
		elseif rhsIsNumeric then
			return false
		else
			-- Num-numeric identifiers are compared lexically in ASCII sort order.
			return lhs < rhs
		end
	end
end

--[=[
	@within Prerelease
	@method __le
	@param other Prerelease
	@return boolean
	This metamethod tests less than or equal to (for `self` and `other`) and is used by the operators `<=` and `>=`.
]=]
function Prerelease.metatable.__le(self: Prerelease, other: Prerelease)
	return self.identifier == other.identifier or self < other
end

--[=[
	@within Prerelease
	@prop EMPTY Prerelease
	@readonly
	@tag Static
	**Usage:**
	```lua
	local ver = Version.new(1, 0, 0, Prerelease.EMPTY, BuildMetadata.EMPTY)
	```
]=]
Prerelease.interface.EMPTY = Prerelease.interface.new("")
table.freeze(Prerelease.interface)
table.freeze(Prerelease.prototype)
table.freeze(Prerelease.metatable)
table.freeze(Prerelease)

export type Prerelease = typeof(Prerelease.interface.new(table.unpack(...)))
return Prerelease.interface
