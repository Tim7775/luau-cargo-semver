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

export type Pos =
	"major version number"
	| "minor version number"
	| "patch version number"
	| "pre-release identifier"
	| "build metadata"
local Position = table.freeze({
	Major = "major version number" :: Pos,
	Minor = "minor version number" :: Pos,
	Patch = "patch version number" :: Pos,
	Pre = "pre-release identifier" :: Pos,
	Build = "build metadata" :: Pos,
})

--[[
	Note that Luau only has a single number type,
	a 64-bit IEEE754 double precision number (which can represent integers up to 2^53 exactly),
	and larger integer literals are stored with precision loss. (https://luau-lang.org/syntax#number-literals)

	Note: 2^53 + 1 evaluates to 2^53, so a value of 2^53 could already have been the result of precision loss
]]
local LUAU_MAX_PRECISE_INT = 2 ^ 53 - 1
local MAX_IDENTIFIER_LENGTH = 512

local Bounds = table.freeze({
	LUAU_MAX_PRECISE_INT = LUAU_MAX_PRECISE_INT,
	MAX_IDENTIFIER_LENGTH = MAX_IDENTIFIER_LENGTH,
})

--stylua: ignore
local SPECIAL_CHARACTERS = table.freeze{
	["\a"] = "\\a", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r",
	["\t"] = "\\t", ["\v"] = "\\v", ["\0"] = "\\0", ["'"] = "\\'", ["\\"] = "\\\\",
}

local function quotedChar(stringView: { str: string, cursor: number, pos: Pos }): string
	local char = utf8.char(utf8.codepoint(stringView.str, stringView.cursor))
	return SPECIAL_CHARACTERS[char] or char
end

local Kind = table.freeze({
	Empty = "empty string, expected a semver version",
	UnexpectedEnd = function(pos: Pos)
		return `unexpected end of input while parsing {pos}`
	end,
	UnexpectedChar = function(stringView)
		return `unexpected character '{quotedChar(stringView)}' while parsing {stringView.pos}`
	end,
	UnexpectedCharAfter = function(stringView)
		return `unexpected character '{quotedChar(stringView)}' after {stringView.pos}`
	end,
	ExpectedCommaFound = function(stringView)
		return `expected comma after {stringView.pos}, found '{quotedChar(stringView)}'`
	end,
	LeadingZero = function(pos: Pos)
		return `invalid leading zero in {pos}`
	end,
	Overflow = function(pos: Pos)
		return `value of {pos} exceeds LUAU_MAX_PRECISE_INT (2^53 - 1)`
	end,
	EmptySegment = function(pos: Pos)
		return `empty identifier segment in {pos}`
	end,
	IllegalCharacter = function(pos: Pos)
		return `unexpected character in {pos}`
	end,
	WildcardNotTheOnlyComparator = function(ch: string)
		return `wildcard req ({ch}) must be the only comparator in the version req`
	end,
	UnexpectedAfterWildcard = "unexpected character after wildcard in version req",
	ExcessiveComparators = "excessive number of version comparators",
	MaxIdentifierLength = function(pos: Pos)
		return `{pos} length exceeds MAX_IDENTIFIER_LENGTH ({MAX_IDENTIFIER_LENGTH})`
	end,
})

return table.freeze({
	Position = Position,
	Kind = Kind,
	Bounds = Bounds,
})
