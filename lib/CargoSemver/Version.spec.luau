--!optimize 2
--!strict
--upstream: https://github.com/dtolnay/semver/blob/83154eaa576ebbb9637dabaf74922177982c6393/tests/test_version.rs

local BuildMetadata = require("./BuildMetadata")
local Prerelease = require("./Prerelease")
local Version = require("./Version")

local version = Version.parse
local build_metadata = BuildMetadata.new
local prerelease = Prerelease.new

return function()
	local function assert_eq<T>(obj: T, expected: T)
		expect(obj).to.equal(expected)
	end
	local function assert_ne<T>(obj: T, expected: T)
		expect(obj).never.to.equal(expected)
	end
	local function assert_to_string<T>(obj: T, str: string)
		expect(tostring(obj)).to.equal(str)
	end

	it("test_parse", function()
		expect(function()
			version("")
		end).to.throw("empty string, expected a semver version")

		expect(function()
			version("  ")
		end).to.throw("unexpected character ' ' while parsing major version number")

		expect(function()
			version("1")
		end).to.throw("unexpected end of input while parsing major version number")

		expect(function()
			version("1.2")
		end).to.throw("unexpected end of input while parsing minor version number")

		expect(function()
			version("1.2.3-")
		end).to.throw("empty identifier segment in pre-release identifier")

		expect(function()
			version("a.b.c")
		end).to.throw("unexpected character 'a' while parsing major version number")

		expect(function()
			version("1.2.3 abc")
		end).to.throw("unexpected character ' ' after patch version number")

		expect(function()
			version("1.2.3-01")
		end).to.throw("invalid leading zero in pre-release identifier")

		expect(function()
			version("1.2.3++")
		end).to.throw("empty identifier segment in build metadata")

		expect(function()
			version("07")
		end).to.throw("invalid leading zero in major version number")

		expect(function()
			version("111111111111111111111.0.0")
		end).to.throw("value of major version number exceeds LUAU_MAX_PRECISE_INT (2^53 - 1)")

		expect(function()
			version("8\0")
		end).to.throw("unexpected character '\\0' after major version number")

		local parsed = version("1.2.3")
		local expected = Version.new(1, 2, 3, Prerelease.EMPTY, BuildMetadata.EMPTY)
		expect(parsed).to.equal(expected)

		parsed = version("1.2.3-alpha1")
		expected = Version.new(1, 2, 3, prerelease("alpha1"), BuildMetadata.EMPTY)
		expect(parsed).to.equal(expected)

		parsed = version("1.2.3+build5")
		expected = Version.new(1, 2, 3, Prerelease.EMPTY, build_metadata("build5"))
		expect(parsed).to.equal(expected)

		parsed = version("1.2.3+5build")
		expected = Version.new(1, 2, 3, Prerelease.EMPTY, build_metadata("5build"))
		expect(parsed).to.equal(expected)

		parsed = version("1.2.3-alpha1+build5")
		expected = Version.new(1, 2, 3, prerelease("alpha1"), build_metadata("build5"))
		expect(parsed).to.equal(expected)

		parsed = version("1.2.3-1.alpha1.9+build5.7.3aedf")
		expected = Version.new(1, 2, 3, prerelease("1.alpha1.9"), build_metadata("build5.7.3aedf"))
		expect(parsed).to.equal(expected)

		parsed = version("1.2.3-0a.alpha1.9+05build.7.3aedf")
		expected = Version.new(1, 2, 3, prerelease("0a.alpha1.9"), build_metadata("05build.7.3aedf"))
		expect(parsed).to.equal(expected)

		parsed = version("0.4.0-beta.1+0851523")
		expected = Version.new(0, 4, 0, prerelease("beta.1"), build_metadata("0851523"))
		expect(parsed).to.equal(expected)

		--for https://nodejs.org/dist/index.json, where some older npm versions are "1.1.0-beta-10"
		parsed = version("1.1.0-beta-10")
		expected = Version.new(1, 1, 0, prerelease("beta-10"), BuildMetadata.EMPTY)
		expect(parsed).to.equal(expected)
	end)

	it("test_eq", function()
		assert_eq(version("1.2.3"), version("1.2.3"))
		assert_eq(version("1.2.3-alpha1"), version("1.2.3-alpha1"))
		assert_eq(version("1.2.3+build.42"), version("1.2.3+build.42"))
		assert_eq(version("1.2.3-alpha1+42"), version("1.2.3-alpha1+42"))
	end)
	it("test_ne", function()
		assert_ne(version("0.0.0"), version("0.0.1"))
		assert_ne(version("0.0.0"), version("0.1.0"))
		assert_ne(version("0.0.0"), version("1.0.0"))
		assert_ne(version("1.2.3-alpha"), version("1.2.3-beta"))
		assert_ne(version("1.2.3+23"), version("1.2.3+42"))
	end)

	it("test_display", function()
		assert_to_string(version("1.2.3"), "1.2.3")
		assert_to_string(version("1.2.3-alpha1"), "1.2.3-alpha1")
		assert_to_string(version("1.2.3+build.42"), "1.2.3+build.42")
		assert_to_string(version("1.2.3-alpha1+42"), "1.2.3-alpha1+42")
	end)

	it("test_lt", function()
		expect(version("0.0.0") < version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.0.0") < version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.2.0") < version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.2.3-alpha1") < version("1.2.3")).to.equal(true)
		expect(version("1.2.3-alpha1") < version("1.2.3-alpha2")).to.equal(true)
		expect(not (version("1.2.3-alpha2") < version("1.2.3-alpha2"))).to.equal(true)
		expect(version("1.2.3+23") < version("1.2.3+42")).to.equal(true)
	end)
	it("test_le", function()
		expect(version("0.0.0") <= version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.0.0") <= version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.2.0") <= version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.2.3-alpha1") <= version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.2.3-alpha2") <= version("1.2.3-alpha2")).to.equal(true)
		expect(version("1.2.3+23") <= version("1.2.3+42")).to.equal(true)
	end)
	it("test_gt", function()
		expect(version("1.2.3-alpha2") > version("0.0.0")).to.equal(true)
		expect(version("1.2.3-alpha2") > version("1.0.0")).to.equal(true)
		expect(version("1.2.3-alpha2") > version("1.2.0")).to.equal(true)
		expect(version("1.2.3-alpha2") > version("1.2.3-alpha1")).to.equal(true)
		expect(version("1.2.3") > version("1.2.3-alpha2")).to.equal(true)
		expect(not (version("1.2.3-alpha2") > version("1.2.3-alpha2"))).to.equal(true)
		expect(not (version("1.2.3+23") > version("1.2.3+42"))).to.equal(true)
	end)
	it("test_ge", function()
		expect(version("1.2.3-alpha2") >= version("0.0.0")).to.equal(true)
		expect(version("1.2.3-alpha2") >= version("1.0.0")).to.equal(true)
		expect(version("1.2.3-alpha2") >= version("1.2.0")).to.equal(true)
		expect(version("1.2.3-alpha2") >= version("1.2.3-alpha1")).to.equal(true)
		expect(version("1.2.3-alpha2") >= version("1.2.3-alpha2")).to.equal(true)
		expect(not (version("1.2.3+23") >= version("1.2.3+42"))).to.equal(true)
	end)
	it("test_spec_order", function()
		local vs = {
			"1.0.0-alpha",
			"1.0.0-alpha.1",
			"1.0.0-alpha.beta",
			"1.0.0-beta",
			"1.0.0-beta.2",
			"1.0.0-beta.11",
			"1.0.0-rc.1",
			"1.0.0",
		}
		local i = 2
		while i <= #vs do
			local a = version(vs[i - 1])
			local b = version(vs[i])
			expect(a < b).to.equal(true)
			i += 1
		end
	end)
	it("test_align", function()
		local vers = version("1.2.3-rc1")
		expect(string.format("%-20s", tostring(vers))).to.equal("1.2.3-rc1           ")
		expect(string.format("%20s", tostring(vers))).to.equal("           1.2.3-rc1")
	end)

	--Additional tests (not upstream from github.com/dtolnay/semver)
	it("test_leading_zero", function()
		expect(function()
			version("01.0.0")
		end).to.throw("invalid leading zero in major version number")
		expect(function()
			version("1.00.0")
		end).to.throw("invalid leading zero in minor version number")
		expect(function()
			version("1.0.0-00.0.0")
		end).to.throw("invalid leading zero in pre-release identifier")
		expect(function()
			version("1.0.0-1.00.0")
		end).to.throw("invalid leading zero in pre-release identifier")
		expect(function()
			version("1.0.0-1.0.00")
		end).to.throw("invalid leading zero in pre-release identifier")
		expect(function()
			version("1.0.0-00-01")
		end).never.to.throw()
		expect(function()
			version("1.0.0+00")
		end).never.to.throw()
	end)
	it("test_overflow", function()
		expect(function()
			version(`{2 ^ 53}.2.3`)
		end).to.throw("value of major version number exceeds LUAU_MAX_PRECISE_INT (2^53 - 1)")
		expect(function()
			version(`{2 ^ 53 - 1}.2.3`)
		end).never.to.throw()
	end)
	it("test_utf8", function()
		expect(function()
			version("1.2.3+rc.test罗布乐思")
		end).to.throw("unexpected character '罗' after build metadata")
		expect(function()
			prerelease("罗布乐思")
		end).to.throw("unexpected character in pre-release identifier")
	end)
end
