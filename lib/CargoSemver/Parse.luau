--!native
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

local Error = require("./Error")

export type StringView = {
	str: string,
	cursor: number,
	pos: Error.Pos,
}

local b0, b9 = string.byte("0"), string.byte("9")
local function numericIdentifier(input: StringView): number
	local start, value = input.cursor, 0

	local digit = string.byte(input.str, start)
	while digit and digit >= b0 and digit <= b9 do
		if value == 0 and input.cursor > start then
			error(Error.Kind.LeadingZero(input.pos))
		end
		value *= 10
		value += digit - b0

		input.cursor += 1
		digit = string.byte(input.str, input.cursor)
	end

	if input.cursor > start then
		if value > Error.Bounds.LUAU_MAX_PRECISE_INT then
			error(Error.Kind.Overflow(input.pos))
		end
		return value
	elseif digit == nil then
		error(Error.Kind.UnexpectedEnd(input.pos))
	else
		error(Error.Kind.UnexpectedChar(input))
	end
end

local bDot = string.byte(".")
local function dot(input: StringView)
	local byte = string.byte(input.str, input.cursor)
	if byte == nil then
		error(Error.Kind.UnexpectedEnd(input.pos))
	elseif byte ~= bDot then
		error(Error.Kind.UnexpectedCharAfter(input))
	end
	input.cursor += 1
end

local bSpace = string.byte(" ")
local function skipWhitespace(input: StringView)
	local byte = string.byte(input.str, input.cursor)
	while byte == bSpace do
		input.cursor += 1
		byte = string.byte(input.str, input.cursor)
	end
end

local function findByte(input: StringView, byte: number): boolean
	if string.byte(input.str, input.cursor) == byte then
		input.cursor += 1
		return true
	end
	return false
end

local bStar, bx, bX = string.byte("*xX", 1, 3)
local function wildcard(input: StringView): number?
	local byte = string.byte(input.str, input.cursor)
	if byte == bStar or byte == bx or byte == bX then
		input.cursor += 1
		return byte
	end
	return nil
end

local bDash, ba, bz, bA, bZ = string.byte("-azAZ", 1, 5)
local function buildIdentifier(input: StringView): string
	local start, isSegmentEmpty = input.cursor, true

	local b = string.byte(input.str, start)
	while b and ((b >= ba and b <= bz) or (b >= b0 and b <= b9) or b == bDot or b == bDash or (b >= bA and b <= bZ)) do
		if b == bDot then
			if isSegmentEmpty then
				error(Error.Kind.EmptySegment(input.pos))
			end
			isSegmentEmpty = true
		else
			isSegmentEmpty = false
		end
		input.cursor += 1
		b = string.byte(input.str, input.cursor)
	end

	if input.cursor ~= start and isSegmentEmpty then
		error(Error.Kind.EmptySegment(input.pos)) --Catch trailing dots
	elseif input.cursor - start > Error.Bounds.MAX_IDENTIFIER_LENGTH then
		error(Error.Kind.MaxIdentifierLength(input.pos))
	end
	return string.sub(input.str, start, input.cursor - 1)
end

local function prereleaseIdentifier(input: StringView): string
	local result = buildIdentifier(input)
	if string.find(result, "%f[^%.\0]0%d+%f[%.\0]") then
		error(Error.Kind.LeadingZero(input.pos))
	end
	return result
end

export type Operator = "=" | ">" | ">=" | "<" | "<=" | "~" | "^" | "*"
local Operators = table.freeze({
	Default = "^" :: Operator,
	Exact = "=" :: Operator,
	Greater = ">" :: Operator,
	GreaterEq = ">=" :: Operator,
	Less = "<" :: Operator,
	LessEq = "<=" :: Operator,
	Tilde = "~" :: Operator,
	Caret = "^" :: Operator,
	Wildcard = "*" :: Operator,
})

local bEquals, bGreater, bLess, bTilde, bCaret = string.byte("=><~^", 1, 5)
local function operator(input: StringView): Operator
	local byte = string.byte(input.str, input.cursor)
	if byte == bEquals then
		input.cursor += 1
		return Operators.Exact
	elseif byte == bGreater then
		if string.byte(input.str, input.cursor + 1) == bEquals then
			input.cursor += 2
			return Operators.GreaterEq
		else
			input.cursor += 1
			return Operators.Greater
		end
	elseif byte == bLess then
		if string.byte(input.str, input.cursor + 1) == bEquals then
			input.cursor += 2
			return Operators.LessEq
		else
			input.cursor += 1
			return Operators.Less
		end
	elseif byte == bTilde then
		input.cursor += 1
		return Operators.Tilde
	elseif byte == bCaret then
		input.cursor += 1
		return Operators.Caret
	end
	return Operators.Default
end

return table.freeze({
	numericIdentifier = numericIdentifier,
	dot = dot,
	skipWhitespace = skipWhitespace,
	findByte = findByte,
	wildcard = wildcard,
	prereleaseIdentifier = prereleaseIdentifier,
	buildIdentifier = buildIdentifier,
	operator = operator,
	Operators = Operators,
})
