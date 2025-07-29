--!optimize 2
--!strict
--upstream: https://github.com/dtolnay/semver/blob/83154eaa576ebbb9637dabaf74922177982c6393/tests/test_identifier.rs

local BuildMetadata = require("./BuildMetadata")
local Prerelease = require("./Prerelease")

local prerelease = Prerelease.new
local build_metadata = BuildMetadata.new

return function()
	local function assert_eq<T>(obj: T, expected: T)
		expect(obj).to.equal(expected)
	end
	local function assert_ne<T>(obj: T, expected: T)
		expect(obj).never.to.equal(expected)
	end

	it("test_new", function()
		local function test(pre: Prerelease.Prerelease, expected: string)
			assert_eq(pre:is_empty(), expected == "")
			assert_eq(#pre, #expected)
			assert_eq(tostring(pre), expected)
			assert_eq(pre, pre)
			assert_eq(pre, Prerelease.new(expected))
		end

		local str = ""
		for _ = 1, 40 do
			test(prerelease(str), str)
			str ..= "1"
		end
	end)
	it("test_eq", function()
		assert_eq(prerelease("-"), prerelease("-"))
		assert_ne(prerelease("a"), prerelease("aa"))
		assert_ne(prerelease("aa"), prerelease("a"))
		assert_ne(prerelease("aaaaaaaaa"), prerelease("a"))
		assert_ne(prerelease("a"), prerelease("aaaaaaaaa"))
		assert_ne(prerelease("aaaaaaaaa"), prerelease("bbbbbbbbb"))
		assert_ne(build_metadata("1"), build_metadata("001"))
	end)
	it("test_prerelease", function()
		expect(function()
			prerelease("1.b\0")
		end).to.throw("unexpected character in pre-release identifier")
	end)

	--Additional tests (not upstream from github.com/dtolnay/semver)
	it("test_leading_zero_ordering", function()
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
			expect(a < b).to.equal(true)
			i += 1
		end
	end)
	it("test_max_identifier_length", function()
		expect(function()
			prerelease(string.rep("a", 513))
		end).to.throw("pre-release identifier length exceeds MAX_IDENTIFIER_LENGTH (512)")
		expect(function()
			prerelease(string.rep("a", 512))
		end).never.to.throw()
		expect(function()
			build_metadata(string.rep("0", 513))
		end).to.throw("build metadata length exceeds MAX_IDENTIFIER_LENGTH (512)")
		expect(function()
			build_metadata(string.rep("0", 512))
		end).never.to.throw()
	end)
end
