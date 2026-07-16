--!optimize 2
--!strict
--upstream: https://github.com/dtolnay/semver/blob/83154eaa576ebbb9637dabaf74922177982c6393/tests/test_identifier.rs

const test = require("@std/test")
const types = require("@std/test/types")

const BuildMetadata = require("./BuildMetadata")
const Prerelease = require("./Prerelease")
const prerelease = Prerelease.new
const build_metadata = BuildMetadata.new

const function never_throws(asserts: types.Asserts, func: () -> ...any)
	local ok, msg = pcall(func)
	asserts.that(ok, `Expected test never to throw, but got the following error: {msg}`)
end

test.suite("Identifier", function(suite: types.TestSuite)
	suite:case("test_new", function(asserts: types.Asserts)
		local function test_new(pre: Prerelease.Prerelease, expected: string)
			asserts.eq(pre:is_empty(), expected == "")
			asserts.eq(#pre, #expected)
			asserts.eq(tostring(pre), expected)
			asserts.eq(pre, pre)
			asserts.eq(pre, Prerelease.new(expected))
		end

		local str = ""
		for _ = 1, 40 do
			test_new(prerelease(str), str)
			str ..= "1"
		end
	end)
	suite:case("test_eq", function(asserts: types.Asserts)
		asserts.eq(prerelease("-"), prerelease("-"))
		asserts.neq(prerelease("a"), prerelease("aa"))
		asserts.neq(prerelease("aa"), prerelease("a"))
		asserts.neq(prerelease("aaaaaaaaa"), prerelease("a"))
		asserts.neq(prerelease("a"), prerelease("aaaaaaaaa"))
		asserts.neq(prerelease("aaaaaaaaa"), prerelease("bbbbbbbbb"))
		asserts.neq(build_metadata("1"), build_metadata("001"))
	end)
	suite:case("test_prerelease", function(asserts: types.Asserts)
		asserts.throwsWith("unexpected character in pre-release identifier", function()
			prerelease("1.b\0")
		end)
	end)

	--Additional tests (not upstream from github.com/dtolnay/semver)
	suite:case("test_leading_zero_ordering", function(asserts: types.Asserts)
		local vs = {
			"0",
			"00",
			"1",
			"01",
			"001",
			"2",
			"02",
			"002",
			"10",
		}
		local i = 2
		while i <= #vs do
			local a = build_metadata(vs[i - 1])
			local b = build_metadata(vs[i])
			asserts.eq(a < b, true)
			i += 1
		end
	end)
	suite:case("test_max_identifier_length", function(asserts: types.Asserts)
		asserts.throwsWith("pre-release identifier length exceeds MAX_IDENTIFIER_LENGTH (512)", function()
			prerelease(string.rep("a", 513))
		end)
		never_throws(asserts, function()
			prerelease(string.rep("a", 512))
		end)
		asserts.throwsWith("build metadata length exceeds MAX_IDENTIFIER_LENGTH (512)", function()
			build_metadata(string.rep("0", 513))
		end)
		never_throws(asserts, function()
			build_metadata(string.rep("0", 512))
		end)
	end)
end)
