--!optimize 2
--!strict
--upstream: https://github.com/dtolnay/semver/blob/83154eaa576ebbb9637dabaf74922177982c6393/tests/test_version_req.rs

const test = require("@std/test")
const types = require("@std/test/types")

const Comparator = require("./Comparator")
const Version = require("./Version")
const VersionReq = require("./VersionReq")

const req = VersionReq.parse
const version = Version.parse
const comparator = Comparator.parse

const function assert_match_all(asserts: types.Asserts, r: VersionReq.VersionReq, versions: { string })
	for _, str in versions do
		local parsed = version(str)
		asserts.eq(r:matches(parsed), true)
	end
end
const function assert_match_none(asserts: types.Asserts, r: VersionReq.VersionReq, versions: { string })
	for _, str in versions do
		local parsed = version(str)
		asserts.eq(r:matches(parsed), false)
	end
end

test.suite("VersionReq", function(suite: types.TestSuite)
	suite:case("test_basic", function(asserts: types.Asserts)
		local r = req("1.0.0")
		asserts.eq(tostring(r), "^1.0.0")
		assert_match_all(asserts, r, { "1.0.0", "1.1.0", "1.0.1" })
		assert_match_none(asserts, r, { "0.9.9", "0.10.0", "0.1.0", "1.0.0-pre", "1.0.1-pre" })
	end)
	--[[VersionReq.default was omitted because it's not useful in Luau
	suite:case("test_default", function(asserts: types.Asserts)
		local r = VersionReq.default
		asserts.eq(r, VersionReq.STAR)
	end) --]]
	suite:case("test_exact", function(asserts: types.Asserts)
		local r = req("=1.0.0")
		asserts.eq(tostring(r), "=1.0.0")
		assert_match_all(asserts, r, { "1.0.0" })
		assert_match_none(asserts, r, { "1.0.1", "0.9.9", "0.10.0", "0.1.0", "1.0.0-pre" })

		r = req("=0.9.0")
		asserts.eq(tostring(r), "=0.9.0")
		assert_match_all(asserts, r, { "0.9.0" })
		assert_match_none(asserts, r, { "0.9.1", "1.9.0", "0.0.9", "0.9.0-pre" })

		r = req("=0.0.2")
		asserts.eq(tostring(r), "=0.0.2")
		assert_match_all(asserts, r, { "0.0.2" })
		assert_match_none(asserts, r, { "0.0.1", "0.0.3", "0.0.2-pre" })

		r = req("=0.1.0-beta2.a")
		asserts.eq(tostring(r), "=0.1.0-beta2.a")
		assert_match_all(asserts, r, { "0.1.0-beta2.a" })
		assert_match_none(asserts, r, { "0.9.1", "0.1.0", "0.1.1-beta2.a", "0.1.0-beta2" })

		r = req("=0.1.0+meta")
		asserts.eq(tostring(r), "=0.1.0")
		assert_match_all(asserts, r, { "0.1.0", "0.1.0+meta", "0.1.0+any" })
	end)
	suite:case("test_greater_than", function(asserts: types.Asserts)
		local r = req(">= 1.0.0")
		asserts.eq(tostring(r), ">=1.0.0")
		assert_match_all(asserts, r, { "1.0.0", "2.0.0" })
		assert_match_none(asserts, r, { "0.1.0", "0.0.1", "1.0.0-pre", "2.0.0-pre" })

		r = req(">= 2.1.0-alpha2")
		asserts.eq(tostring(r), ">=2.1.0-alpha2")
		assert_match_all(asserts, r, { "2.1.0-alpha2", "2.1.0-alpha3", "2.1.0", "3.0.0" })
		assert_match_none(asserts, r, { "2.0.0", "2.1.0-alpha1", "2.0.0-alpha2", "3.0.0-alpha2" })
	end)
	suite:case("test_less_than", function(asserts: types.Asserts)
		local r = req("< 1.0.0")
		asserts.eq(tostring(r), "<1.0.0")
		assert_match_all(asserts, r, { "0.1.0", "0.0.1" })
		assert_match_none(asserts, r, { "1.0.0", "1.0.0-beta", "1.0.1", "0.9.9-alpha" })

		r = req("<= 2.1.0-alpha2")
		assert_match_all(asserts, r, { "2.1.0-alpha2", "2.1.0-alpha1", "2.0.0", "1.0.0" })
		assert_match_none(asserts, r, { "2.1.0", "2.2.0-alpha1", "2.0.0-alpha2", "1.0.0-alpha2" })

		r = req(">1.0.0-alpha, <1.0.0")
		assert_match_all(asserts, r, { "1.0.0-beta" })

		r = req(">1.0.0-alpha, <1.0")
		assert_match_none(asserts, r, { "1.0.0-beta" })

		r = req(">1.0.0-alpha, <1")
		assert_match_none(asserts, r, { "1.0.0-beta" })
	end)
	suite:case("test_multiple", function(asserts: types.Asserts)
		local r = req("> 0.0.9, <= 2.5.3")
		asserts.eq(tostring(r), ">0.0.9, <=2.5.3")
		assert_match_all(asserts, r, { "0.0.10", "1.0.0", "2.5.3" })
		assert_match_none(asserts, r, { "0.0.8", "2.5.4" })

		r = req("0.3.0, 0.4.0")
		asserts.eq(tostring(r), "^0.3.0, ^0.4.0")
		assert_match_none(asserts, r, { "0.0.8", "0.3.0", "0.4.0" })

		r = req("<= 0.2.0, >= 0.5.0")
		asserts.eq(tostring(r), "<=0.2.0, >=0.5.0")
		assert_match_none(asserts, r, { "0.0.8", "0.3.0", "0.5.1" })

		r = req("0.1.0, 0.1.4, 0.1.6")
		asserts.eq(tostring(r), "^0.1.0, ^0.1.4, ^0.1.6")
		assert_match_all(asserts, r, { "0.1.6", "0.1.9" })
		assert_match_none(asserts, r, { "0.1.0", "0.1.4", "0.2.0" })

		asserts.throwsWith("unexpected end of input while parsing major version number", function()
			req("> 0.1.0,")
		end)

		asserts.throwsWith("unexpected character ',' while parsing major version number", function()
			req("> 0.3.0, ,")
		end)

		r = req(">=0.5.1-alpha3, <0.6")
		asserts.eq(tostring(r), ">=0.5.1-alpha3, <0.6")
		assert_match_all(asserts, r, {
			"0.5.1-alpha3",
			"0.5.1-alpha4",
			"0.5.1-beta",
			"0.5.1",
			"0.5.5",
		})
		assert_match_none(asserts, r, { "0.5.1-alpha1", "0.5.2-alpha3", "0.5.5-pre", "0.5.0-pre" })
		assert_match_none(asserts, r, { "0.6.0", "0.6.0-pre" })

		--https://github.com/steveklabnik/semver/issues/56
		asserts.throwsWith("expected comma after patch version number, found '-'", function()
			req("1.2.3 - 2.3.4")
		end)

		asserts.throwsWith("excessive number of version comparators", function()
			req(
				">1, >2, >3, >4, >5, >6, >7, >8, >9, >10, >11, >12, >13, >14, >15, >16, >17, >18, >19, >20, >21, >22, >23, >24, >25, >26, >27, >28, >29, >30, >31, >32, >33"
			)
		end)
	end)
	suite:case("test_whitespace_delimited_comparator_sets", function(asserts: types.Asserts)
		--https://github.com/steveklabnik/semver/issues/55
		asserts.throwsWith("expected comma after patch version number, found '<'", function()
			req("> 0.0.9 <= 2.5.3")
		end)
	end)
	suite:case("test_tilde", function(asserts: types.Asserts)
		local r = req("~1")
		assert_match_all(asserts, r, { "1.0.0", "1.0.1", "1.1.1" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "0.0.9" })

		r = req("~1.2")
		assert_match_all(asserts, r, { "1.2.0", "1.2.1" })
		assert_match_none(asserts, r, { "1.1.1", "1.3.0", "0.0.9" })

		r = req("~1.2.2")
		assert_match_all(asserts, r, { "1.2.2", "1.2.4" })
		assert_match_none(asserts, r, { "1.2.1", "1.9.0", "1.0.9", "2.0.1", "0.1.3" })

		r = req("~1.2.3-beta.2")
		assert_match_all(asserts, r, { "1.2.3", "1.2.4", "1.2.3-beta.2", "1.2.3-beta.4" })
		assert_match_none(asserts, r, { "1.3.3", "1.1.4", "1.2.3-beta.1", "1.2.4-beta.2" })
	end)
	suite:case("test_caret", function(asserts: types.Asserts)
		local r = req("^1")
		assert_match_all(asserts, r, { "1.1.2", "1.1.0", "1.2.1", "1.0.1" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "0.1.4" })
		assert_match_none(asserts, r, { "1.0.0-beta1", "0.1.0-alpha", "1.0.1-pre" })

		r = req("^1.1")
		assert_match_all(asserts, r, { "1.1.2", "1.1.0", "1.2.1" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "1.0.1", "0.1.4" })

		r = req("^1.1.2")
		assert_match_all(asserts, r, { "1.1.2", "1.1.4", "1.2.1" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "1.1.1", "0.0.1" })
		assert_match_none(asserts, r, { "1.1.2-alpha1", "1.1.3-alpha1", "2.9.0-alpha1" })

		r = req("^0.1.2")
		assert_match_all(asserts, r, { "0.1.2", "0.1.4" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "1.1.1", "0.0.1" })
		assert_match_none(asserts, r, { "0.1.2-beta", "0.1.3-alpha", "0.2.0-pre" })

		r = req("^0.5.1-alpha3")
		assert_match_all(asserts, r, {
			"0.5.1-alpha3",
			"0.5.1-alpha4",
			"0.5.1-beta",
			"0.5.1",
			"0.5.5",
		})
		assert_match_none(asserts, r, {
			"0.5.1-alpha1",
			"0.5.2-alpha3",
			"0.5.5-pre",
			"0.5.0-pre",
			"0.6.0",
		})

		r = req("^0.0.2")
		assert_match_all(asserts, r, { "0.0.2" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "1.1.1", "0.0.1", "0.1.4" })

		r = req("^0.0")
		assert_match_all(asserts, r, { "0.0.2", "0.0.0" })
		assert_match_none(asserts, r, { "0.9.1", "2.9.0", "1.1.1", "0.1.4" })

		r = req("^0")
		assert_match_all(asserts, r, { "0.9.1", "0.0.2", "0.0.0" })
		assert_match_none(asserts, r, { "2.9.0", "1.1.1" })

		r = req("^1.4.2-beta.5")
		assert_match_all(asserts, r, { "1.4.2", "1.4.3", "1.4.2-beta.5", "1.4.2-beta.6", "1.4.2-c" })
		assert_match_none(asserts, r, {
			"0.9.9",
			"2.0.0",
			"1.4.2-alpha",
			"1.4.2-beta.4",
			"1.4.3-beta.5",
		})
	end)
	suite:case("test_wildcard", function(asserts: types.Asserts)
		asserts.throwsWith("unexpected end of input while parsing major version number", function()
			req("")
		end)

		local r = req("*")
		assert_match_all(asserts, r, { "0.9.1", "2.9.0", "0.0.9", "1.0.1", "1.1.1" })
		assert_match_none(asserts, r, { "1.0.0-pre" })

		for _, s in { "x", "X" } do
			asserts.eq(r, req(s))
		end

		r = req("1.*")
		assert_match_all(asserts, r, { "1.2.0", "1.2.1", "1.1.1", "1.3.0" })
		assert_match_none(asserts, r, { "0.0.9", "1.2.0-pre" })

		for _, s in { "1.x", "1.X", "1.*.*" } do
			asserts.eq(r, req(s))
		end

		r = req("1.2.*")
		assert_match_all(asserts, r, { "1.2.0", "1.2.2", "1.2.4" })
		assert_match_none(asserts, r, { "1.9.0", "1.0.9", "2.0.1", "0.1.3", "1.2.2-pre" })

		for _, s in { "1.2.x", "1.2.X" } do
			asserts.eq(r, req(s))
		end
	end)
	suite:case("test_logical_or", function(asserts: types.Asserts)
		--https://github.com/steveklabnik/semver/issues/57
		asserts.throwsWith("expected comma after patch version number, found '|'", function()
			req("=1.2.3 || =2.3.4")
		end)

		asserts.throwsWith("expected comma after minor version number, found '|'", function()
			req("1.1 || =1.2.3")
		end)

		asserts.throwsWith("expected comma after minor version number, found '|'", function()
			req("6.* || 8.* || >= 10.*")
		end)
	end)
	suite:case("test_any", function(asserts: types.Asserts)
		local r = VersionReq.STAR
		assert_match_all(asserts, r, { "0.0.1", "0.1.0", "1.0.0" })
	end)
	suite:case("test_pre", function(asserts: types.Asserts)
		local r = req("=2.1.1-really.0")
		assert_match_all(asserts, r, { "2.1.1-really.0" })
	end)
	suite:case("test_parse", function(asserts: types.Asserts)
		asserts.throwsWith("unexpected character '\\0' while parsing major version number", function()
			req("\0")
		end)

		asserts.throwsWith("unexpected character '>' while parsing major version number", function()
			req(">= >= 0.0.2")
		end)

		asserts.throwsWith("unexpected character '=' while parsing major version number", function()
			req(">== 0.0.2")
		end)

		asserts.throwsWith("unexpected character 'a' while parsing major version number", function()
			req("a.0.0")
		end)

		asserts.throwsWith("empty identifier segment in pre-release identifier", function()
			req("1.0.0-")
		end)

		asserts.throwsWith("unexpected end of input while parsing major version number", function()
			req(">=")
		end)
	end)
	suite:case("test_comparator_parse", function(asserts: types.Asserts)
		local parsed = comparator("1.2.3-alpha")
		asserts.eq(tostring(parsed), "^1.2.3-alpha")

		parsed = comparator("2.X")
		asserts.eq(tostring(parsed), "2.*")

		parsed = comparator("2")
		asserts.eq(tostring(parsed), "^2")

		parsed = comparator("2.x.x")
		asserts.eq(tostring(parsed), "2.*")

		asserts.throwsWith("invalid leading zero in pre-release identifier", function()
			comparator("1.2.3-01")
		end)

		asserts.throwsWith("empty identifier segment in build metadata", function()
			comparator("1.2.3+4.")
		end)

		asserts.throwsWith("unexpected end of input while parsing major version number", function()
			comparator(">")
		end)

		asserts.throwsWith("unexpected end of input while parsing minor version number", function()
			comparator("1.")
		end)

		asserts.throwsWith("unexpected character after wildcard in version req", function()
			comparator("1.*.")
		end)

		asserts.throwsWith("unexpected character 'ÿ' after build metadata", function()
			comparator("1.2.3+4ÿ")
		end)
	end)
	suite:case("test_cargo3202", function(asserts: types.Asserts)
		local r = req("0.*.*")
		asserts.eq(tostring(r), "0.*")
		assert_match_all(asserts, r, { "0.5.0" })

		r = req("0.0.*")
		asserts.eq(tostring(r), "0.0.*")
	end)
	suite:case("test_digit_after_wildcard", function(asserts: types.Asserts)
		asserts.throwsWith("unexpected character after wildcard in version req", function()
			req("*.1")
		end)

		asserts.throwsWith("unexpected character after wildcard in version req", function()
			req("1.*.1")
		end)

		asserts.throwsWith("unexpected character after wildcard in version req", function()
			req(">=1.*.1")
		end)
	end)
	--[[Hash trait was omitted because it's not relevant to Luau.
	suite:case("test_eq_hash", function(asserts: types.Asserts)
		local calculate_hash(value: impl Hash): number
			let mut hasher = DefaultHasher::new();
			value.hash(&mut hasher);
			hasher.finish()
		}

		assert!(req("^1") == req("^1"));
		assert!(calculate_hash(req("^1")) == calculate_hash(req("^1")));
		assert!(req("^1") != req("^2"));
	end)--]]
	suite:case("test_leading_digit_in_pre_and_build", function()
		for _, op in { "=", ">", ">=", "<", "<=", "~", "^" } do
			--digit then alpha
			req(`{op} 1.2.3-1a`)
			req(`{op} 1.2.3+1a`)

			--digit then alpha (leading zero)
			req(`{op} 1.2.3-01a`)
			req(`{op} 1.2.3+01`)

			--multiple
			req(`{op} 1.2.3-1+1`)
			req(`{op} 1.2.3-1-1+1-1-1`)
			req(`{op} 1.2.3-1a+1a`)
			req(`{op} 1.2.3-1a-1a+1a-1a-1a`)
		end
	end)
	suite:case("test_wildcard_and_another", function(asserts: types.Asserts)
		asserts.throwsWith("wildcard req (*) must be the only comparator in the version req", function()
			req("*, 0.20.0-any")
		end)

		asserts.throwsWith("wildcard req (*) must be the only comparator in the version req", function()
			req("0.20.0-any, *")
		end)

		asserts.throwsWith("wildcard req (*) must be the only comparator in the version req", function()
			req("0.20.0-any, *, 1.0")
		end)
	end)
end)
