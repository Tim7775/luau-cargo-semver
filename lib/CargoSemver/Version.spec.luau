--!optimize 2
--!strict
--upstream: https://github.com/dtolnay/semver/blob/83154eaa576ebbb9637dabaf74922177982c6393/tests/test_version.rs

const test = require("@std/test")
const types = require("@std/test/types")

const BuildMetadata = require("./BuildMetadata")
const Prerelease = require("./Prerelease")
const Version = require("./Version")

const version = Version.parse
const build_metadata = BuildMetadata.new
const prerelease = Prerelease.new

const function never_throws(asserts: types.Asserts, func: () -> ...any)
	local ok, msg = pcall(func)
	asserts.that(ok, `Expected test never to throw, but got the following error: {msg}`)
end

test.suite("Version", function(suite: types.TestSuite)
	suite:case("test_parse", function(asserts: types.Asserts)
		asserts.throwsWith("empty string, expected a semver version", function()
			version("")
		end)

		asserts.throwsWith("unexpected character ' ' while parsing major version number", function()
			version("  ")
		end)

		asserts.throwsWith("unexpected end of input while parsing major version number", function()
			version("1")
		end)

		asserts.throwsWith("unexpected end of input while parsing minor version number", function()
			version("1.2")
		end)

		asserts.throwsWith("empty identifier segment in pre-release identifier", function()
			version("1.2.3-")
		end)

		asserts.throwsWith("unexpected character 'a' while parsing major version number", function()
			version("a.b.c")
		end)

		asserts.throwsWith("unexpected character ' ' after patch version number", function()
			version("1.2.3 abc")
		end)

		asserts.throwsWith("invalid leading zero in pre-release identifier", function()
			version("1.2.3-01")
		end)

		asserts.throwsWith("empty identifier segment in build metadata", function()
			version("1.2.3++")
		end)

		asserts.throwsWith("invalid leading zero in major version number", function()
			version("07")
		end)

		asserts.throwsWith("value of major version number exceeds LUAU_MAX_PRECISE_INT (2^53 - 1)", function()
			version("111111111111111111111.0.0")
		end)

		asserts.throwsWith("unexpected character '\\0' after major version number", function()
			version("8\0")
		end)

		local parsed = version("1.2.3")
		local expected = Version.new(1, 2, 3, Prerelease.EMPTY, BuildMetadata.EMPTY)
		asserts.eq(parsed, expected)

		parsed = version("1.2.3-alpha1")
		expected = Version.new(1, 2, 3, prerelease("alpha1"), BuildMetadata.EMPTY)
		asserts.eq(parsed, expected)

		parsed = version("1.2.3+build5")
		expected = Version.new(1, 2, 3, Prerelease.EMPTY, build_metadata("build5"))
		asserts.eq(parsed, expected)

		parsed = version("1.2.3+5build")
		expected = Version.new(1, 2, 3, Prerelease.EMPTY, build_metadata("5build"))
		asserts.eq(parsed, expected)

		parsed = version("1.2.3-alpha1+build5")
		expected = Version.new(1, 2, 3, prerelease("alpha1"), build_metadata("build5"))
		asserts.eq(parsed, expected)

		parsed = version("1.2.3-1.alpha1.9+build5.7.3aedf")
		expected = Version.new(1, 2, 3, prerelease("1.alpha1.9"), build_metadata("build5.7.3aedf"))
		asserts.eq(parsed, expected)

		parsed = version("1.2.3-0a.alpha1.9+05build.7.3aedf")
		expected = Version.new(1, 2, 3, prerelease("0a.alpha1.9"), build_metadata("05build.7.3aedf"))
		asserts.eq(parsed, expected)

		parsed = version("0.4.0-beta.1+0851523")
		expected = Version.new(0, 4, 0, prerelease("beta.1"), build_metadata("0851523"))
		asserts.eq(parsed, expected)

		--for https://nodejs.org/dist/index.json, where some older npm versions are "1.1.0-beta-10"
		parsed = version("1.1.0-beta-10")
		expected = Version.new(1, 1, 0, prerelease("beta-10"), BuildMetadata.EMPTY)
		asserts.eq(parsed, expected)
	end)

	suite:case("test_eq", function(asserts: types.Asserts)
		asserts.eq(version("1.2.3"), version("1.2.3"))
		asserts.eq(version("1.2.3-alpha1"), version("1.2.3-alpha1"))
		asserts.eq(version("1.2.3+build.42"), version("1.2.3+build.42"))
		asserts.eq(version("1.2.3-alpha1+42"), version("1.2.3-alpha1+42"))
	end)
	suite:case("test_ne", function(asserts: types.Asserts)
		asserts.neq(version("0.0.0"), version("0.0.1"))
		asserts.neq(version("0.0.0"), version("0.1.0"))
		asserts.neq(version("0.0.0"), version("1.0.0"))
		asserts.neq(version("1.2.3-alpha"), version("1.2.3-beta"))
		asserts.neq(version("1.2.3+23"), version("1.2.3+42"))
	end)

	suite:case("test_display", function(asserts: types.Asserts)
		asserts.eq(tostring(version("1.2.3")), "1.2.3")
		asserts.eq(tostring(version("1.2.3-alpha1")), "1.2.3-alpha1")
		asserts.eq(tostring(version("1.2.3+build.42")), "1.2.3+build.42")
		asserts.eq(tostring(version("1.2.3-alpha1+42")), "1.2.3-alpha1+42")
	end)

	suite:case("test_lt", function(asserts: types.Asserts)
		asserts.eq(version("0.0.0") < version("1.2.3-alpha2"), true)
		asserts.eq(version("1.0.0") < version("1.2.3-alpha2"), true)
		asserts.eq(version("1.2.0") < version("1.2.3-alpha2"), true)
		asserts.eq(version("1.2.3-alpha1") < version("1.2.3"), true)
		asserts.eq(version("1.2.3-alpha1") < version("1.2.3-alpha2"), true)
		asserts.eq(not (version("1.2.3-alpha2") < version("1.2.3-alpha2")), true)
		asserts.eq(version("1.2.3+23") < version("1.2.3+42"), true)
	end)
	suite:case("test_le", function(asserts: types.Asserts)
		asserts.eq(version("0.0.0") <= version("1.2.3-alpha2"), true)
		asserts.eq(version("1.0.0") <= version("1.2.3-alpha2"), true)
		asserts.eq(version("1.2.0") <= version("1.2.3-alpha2"), true)
		asserts.eq(version("1.2.3-alpha1") <= version("1.2.3-alpha2"), true)
		asserts.eq(version("1.2.3-alpha2") <= version("1.2.3-alpha2"), true)
		asserts.eq(version("1.2.3+23") <= version("1.2.3+42"), true)
	end)
	suite:case("test_gt", function(asserts: types.Asserts)
		asserts.eq(version("1.2.3-alpha2") > version("0.0.0"), true)
		asserts.eq(version("1.2.3-alpha2") > version("1.0.0"), true)
		asserts.eq(version("1.2.3-alpha2") > version("1.2.0"), true)
		asserts.eq(version("1.2.3-alpha2") > version("1.2.3-alpha1"), true)
		asserts.eq(version("1.2.3") > version("1.2.3-alpha2"), true)
		asserts.eq(not (version("1.2.3-alpha2") > version("1.2.3-alpha2")), true)
		asserts.eq(not (version("1.2.3+23") > version("1.2.3+42")), true)
	end)
	suite:case("test_ge", function(asserts: types.Asserts)
		asserts.eq(version("1.2.3-alpha2") >= version("0.0.0"), true)
		asserts.eq(version("1.2.3-alpha2") >= version("1.0.0"), true)
		asserts.eq(version("1.2.3-alpha2") >= version("1.2.0"), true)
		asserts.eq(version("1.2.3-alpha2") >= version("1.2.3-alpha1"), true)
		asserts.eq(version("1.2.3-alpha2") >= version("1.2.3-alpha2"), true)
		asserts.eq(not (version("1.2.3+23") >= version("1.2.3+42")), true)
	end)
	suite:case("test_spec_order", function(asserts: types.Asserts)
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
			asserts.eq(a < b, true)
			i += 1
		end
	end)
	suite:case("test_align", function(asserts: types.Asserts)
		local vers = version("1.2.3-rc1")
		asserts.eq(string.format("%-20s", tostring(vers)), "1.2.3-rc1           ")
		asserts.eq(string.format("%20s", tostring(vers)), "           1.2.3-rc1")
	end)

	--Additional tests (not upstream from github.com/dtolnay/semver)
	suite:case("test_leading_zero", function(asserts: types.Asserts)
		asserts.throwsWith("invalid leading zero in major version number", function()
			version("01.0.0")
		end)
		asserts.throwsWith("invalid leading zero in minor version number", function()
			version("1.00.0")
		end)
		asserts.throwsWith("invalid leading zero in pre-release identifier", function()
			version("1.0.0-00.0.0")
		end)
		asserts.throwsWith("invalid leading zero in pre-release identifier", function()
			version("1.0.0-1.00.0")
		end)
		asserts.throwsWith("invalid leading zero in pre-release identifier", function()
			version("1.0.0-1.0.00")
		end)
		never_throws(asserts, function()
			version("1.0.0-00-01")
		end)
		never_throws(asserts, function()
			version("1.0.0+00")
		end)
	end)
	suite:case("test_overflow", function(asserts: types.Asserts)
		asserts.throwsWith("value of major version number exceeds LUAU_MAX_PRECISE_INT (2^53 - 1)", function()
			version(`{2 ^ 53}.2.3`)
		end)
		never_throws(asserts, function()
			version(`{2 ^ 53 - 1}.2.3`)
		end)
	end)
	suite:case("test_utf8", function(asserts: types.Asserts)
		asserts.throwsWith("unexpected character '罗' after build metadata", function()
			version("1.2.3+rc.test罗布乐思")
		end)
		asserts.throwsWith("unexpected character in pre-release identifier", function()
			prerelease("罗布乐思")
		end)
	end)
end)
