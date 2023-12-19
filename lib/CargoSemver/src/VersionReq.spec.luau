--!optimize 2
--!strict
--upstream: https://github.com/dtolnay/semver/blob/83154eaa576ebbb9637dabaf74922177982c6393/tests/test_version_req.rs

local Comparator = require("./Comparator") -->require(script.Parent.Comparator)
local Version = require("./Version") -->require(script.Parent.Version)
local VersionReq = require("./VersionReq") -->require(script.Parent.VersionReq)

local req = VersionReq.parse
local version = Version.parse
local comparator = Comparator.parse

return function()
	local function assert_eq<T>(obj: T, expected: T)
		expect(obj).to.equal(expected)
	end
	local function assert_to_string<T>(obj: T, str: string)
		expect(tostring(obj)).to.equal(str)
	end
	local function assert_match_all(r: VersionReq.VersionReq, versions: { string })
		for _, str in versions do
			local parsed = version(str)
			expect(r:matches(parsed)).to.equal(true)
		end
	end
	local function assert_match_none(r: VersionReq.VersionReq, versions: { string })
		for _, str in versions do
			local parsed = version(str)
			expect(r:matches(parsed)).to.equal(false)
		end
	end

	it("test_basic", function()
		local r = req("1.0.0")
		assert_to_string(r, "^1.0.0")
		assert_match_all(r, { "1.0.0", "1.1.0", "1.0.1" })
		assert_match_none(r, { "0.9.9", "0.10.0", "0.1.0", "1.0.0-pre", "1.0.1-pre" })
	end)
	it("test_default", function()
		local r = VersionReq.default
		expect(r).to.equal(VersionReq.STAR)
	end)
	it("test_exact", function()
		local r = req("=1.0.0")
		assert_to_string(r, "=1.0.0")
		assert_match_all(r, { "1.0.0" })
		assert_match_none(r, { "1.0.1", "0.9.9", "0.10.0", "0.1.0", "1.0.0-pre" })

		r = req("=0.9.0")
		assert_to_string(r, "=0.9.0")
		assert_match_all(r, { "0.9.0" })
		assert_match_none(r, { "0.9.1", "1.9.0", "0.0.9", "0.9.0-pre" })

		r = req("=0.0.2")
		assert_to_string(r, "=0.0.2")
		assert_match_all(r, { "0.0.2" })
		assert_match_none(r, { "0.0.1", "0.0.3", "0.0.2-pre" })

		r = req("=0.1.0-beta2.a")
		assert_to_string(r, "=0.1.0-beta2.a")
		assert_match_all(r, { "0.1.0-beta2.a" })
		assert_match_none(r, { "0.9.1", "0.1.0", "0.1.1-beta2.a", "0.1.0-beta2" })

		r = req("=0.1.0+meta")
		assert_to_string(r, "=0.1.0")
		assert_match_all(r, { "0.1.0", "0.1.0+meta", "0.1.0+any" })
	end)
	it("test_greater_than", function()
		local r = req(">= 1.0.0")
		assert_to_string(r, ">=1.0.0")
		assert_match_all(r, { "1.0.0", "2.0.0" })
		assert_match_none(r, { "0.1.0", "0.0.1", "1.0.0-pre", "2.0.0-pre" })

		r = req(">= 2.1.0-alpha2")
		assert_to_string(r, ">=2.1.0-alpha2")
		assert_match_all(r, { "2.1.0-alpha2", "2.1.0-alpha3", "2.1.0", "3.0.0" })
		assert_match_none(r, { "2.0.0", "2.1.0-alpha1", "2.0.0-alpha2", "3.0.0-alpha2" })
	end)
	it("test_less_than", function()
		local r = req("< 1.0.0")
		assert_to_string(r, "<1.0.0")
		assert_match_all(r, { "0.1.0", "0.0.1" })
		assert_match_none(r, { "1.0.0", "1.0.0-beta", "1.0.1", "0.9.9-alpha" })

		r = req("<= 2.1.0-alpha2")
		assert_match_all(r, { "2.1.0-alpha2", "2.1.0-alpha1", "2.0.0", "1.0.0" })
		assert_match_none(r, { "2.1.0", "2.2.0-alpha1", "2.0.0-alpha2", "1.0.0-alpha2" })

		r = req(">1.0.0-alpha, <1.0.0")
		assert_match_all(r, { "1.0.0-beta" })

		r = req(">1.0.0-alpha, <1.0")
		assert_match_none(r, { "1.0.0-beta" })

		r = req(">1.0.0-alpha, <1")
		assert_match_none(r, { "1.0.0-beta" })
	end)
	it("test_multiple", function()
		local r = req("> 0.0.9, <= 2.5.3")
		assert_to_string(r, ">0.0.9, <=2.5.3")
		assert_match_all(r, { "0.0.10", "1.0.0", "2.5.3" })
		assert_match_none(r, { "0.0.8", "2.5.4" })

		r = req("0.3.0, 0.4.0")
		assert_to_string(r, "^0.3.0, ^0.4.0")
		assert_match_none(r, { "0.0.8", "0.3.0", "0.4.0" })

		r = req("<= 0.2.0, >= 0.5.0")
		assert_to_string(r, "<=0.2.0, >=0.5.0")
		assert_match_none(r, { "0.0.8", "0.3.0", "0.5.1" })

		r = req("0.1.0, 0.1.4, 0.1.6")
		assert_to_string(r, "^0.1.0, ^0.1.4, ^0.1.6")
		assert_match_all(r, { "0.1.6", "0.1.9" })
		assert_match_none(r, { "0.1.0", "0.1.4", "0.2.0" })

		expect(function()
			req("> 0.1.0,")
		end).to.throw("unexpected end of input while parsing major version number")

		expect(function()
			req("> 0.3.0, ,")
		end).to.throw("unexpected character ',' while parsing major version number")

		r = req(">=0.5.1-alpha3, <0.6")
		assert_to_string(r, ">=0.5.1-alpha3, <0.6")
		assert_match_all(r, {
			"0.5.1-alpha3",
			"0.5.1-alpha4",
			"0.5.1-beta",
			"0.5.1",
			"0.5.5",
		})
		assert_match_none(r, { "0.5.1-alpha1", "0.5.2-alpha3", "0.5.5-pre", "0.5.0-pre" })
		assert_match_none(r, { "0.6.0", "0.6.0-pre" })

		--https://github.com/steveklabnik/semver/issues/56
		expect(function()
			req("1.2.3 - 2.3.4")
		end).to.throw("expected comma after patch version number, found '-'")

		expect(function()
			req(
				">1, >2, >3, >4, >5, >6, >7, >8, >9, >10, >11, >12, >13, >14, >15, >16, >17, >18, >19, >20, >21, >22, >23, >24, >25, >26, >27, >28, >29, >30, >31, >32, >33"
			)
		end).to.throw("excessive number of version comparators")
	end)
	it("test_whitespace_delimited_comparator_sets", function()
		--https://github.com/steveklabnik/semver/issues/55
		expect(function()
			req("> 0.0.9 <= 2.5.3")
		end).to.throw("expected comma after patch version number, found '<'")
	end)
	it("test_tilde", function()
		local r = req("~1")
		assert_match_all(r, { "1.0.0", "1.0.1", "1.1.1" })
		assert_match_none(r, { "0.9.1", "2.9.0", "0.0.9" })

		r = req("~1.2")
		assert_match_all(r, { "1.2.0", "1.2.1" })
		assert_match_none(r, { "1.1.1", "1.3.0", "0.0.9" })

		r = req("~1.2.2")
		assert_match_all(r, { "1.2.2", "1.2.4" })
		assert_match_none(r, { "1.2.1", "1.9.0", "1.0.9", "2.0.1", "0.1.3" })

		r = req("~1.2.3-beta.2")
		assert_match_all(r, { "1.2.3", "1.2.4", "1.2.3-beta.2", "1.2.3-beta.4" })
		assert_match_none(r, { "1.3.3", "1.1.4", "1.2.3-beta.1", "1.2.4-beta.2" })
	end)
	it("test_caret", function()
		local r = req("^1")
		assert_match_all(r, { "1.1.2", "1.1.0", "1.2.1", "1.0.1" })
		assert_match_none(r, { "0.9.1", "2.9.0", "0.1.4" })
		assert_match_none(r, { "1.0.0-beta1", "0.1.0-alpha", "1.0.1-pre" })

		r = req("^1.1")
		assert_match_all(r, { "1.1.2", "1.1.0", "1.2.1" })
		assert_match_none(r, { "0.9.1", "2.9.0", "1.0.1", "0.1.4" })

		r = req("^1.1.2")
		assert_match_all(r, { "1.1.2", "1.1.4", "1.2.1" })
		assert_match_none(r, { "0.9.1", "2.9.0", "1.1.1", "0.0.1" })
		assert_match_none(r, { "1.1.2-alpha1", "1.1.3-alpha1", "2.9.0-alpha1" })

		r = req("^0.1.2")
		assert_match_all(r, { "0.1.2", "0.1.4" })
		assert_match_none(r, { "0.9.1", "2.9.0", "1.1.1", "0.0.1" })
		assert_match_none(r, { "0.1.2-beta", "0.1.3-alpha", "0.2.0-pre" })

		r = req("^0.5.1-alpha3")
		assert_match_all(r, {
			"0.5.1-alpha3",
			"0.5.1-alpha4",
			"0.5.1-beta",
			"0.5.1",
			"0.5.5",
		})
		assert_match_none(r, {
			"0.5.1-alpha1",
			"0.5.2-alpha3",
			"0.5.5-pre",
			"0.5.0-pre",
			"0.6.0",
		})

		r = req("^0.0.2")
		assert_match_all(r, { "0.0.2" })
		assert_match_none(r, { "0.9.1", "2.9.0", "1.1.1", "0.0.1", "0.1.4" })

		r = req("^0.0")
		assert_match_all(r, { "0.0.2", "0.0.0" })
		assert_match_none(r, { "0.9.1", "2.9.0", "1.1.1", "0.1.4" })

		r = req("^0")
		assert_match_all(r, { "0.9.1", "0.0.2", "0.0.0" })
		assert_match_none(r, { "2.9.0", "1.1.1" })

		r = req("^1.4.2-beta.5")
		assert_match_all(r, { "1.4.2", "1.4.3", "1.4.2-beta.5", "1.4.2-beta.6", "1.4.2-c" })
		assert_match_none(r, {
			"0.9.9",
			"2.0.0",
			"1.4.2-alpha",
			"1.4.2-beta.4",
			"1.4.3-beta.5",
		})
	end)
	it("test_wildcard", function()
		expect(function()
			req("")
		end).to.throw("unexpected end of input while parsing major version number")

		local r = req("*")
		assert_match_all(r, { "0.9.1", "2.9.0", "0.0.9", "1.0.1", "1.1.1" })
		assert_match_none(r, { "1.0.0-pre" })

		for _, s in { "x", "X" } do
			assert_eq(r, req(s))
		end

		r = req("1.*")
		assert_match_all(r, { "1.2.0", "1.2.1", "1.1.1", "1.3.0" })
		assert_match_none(r, { "0.0.9", "1.2.0-pre" })

		for _, s in { "1.x", "1.X", "1.*.*" } do
			assert_eq(r, req(s))
		end

		r = req("1.2.*")
		assert_match_all(r, { "1.2.0", "1.2.2", "1.2.4" })
		assert_match_none(r, { "1.9.0", "1.0.9", "2.0.1", "0.1.3", "1.2.2-pre" })

		for _, s in { "1.2.x", "1.2.X" } do
			assert_eq(r, req(s))
		end
	end)
	it("test_logical_or", function()
		--https://github.com/steveklabnik/semver/issues/57
		expect(function()
			req("=1.2.3 || =2.3.4")
		end).to.throw("expected comma after patch version number, found '|'")

		expect(function()
			req("1.1 || =1.2.3")
		end).to.throw("expected comma after minor version number, found '|'")

		expect(function()
			req("6.* || 8.* || >= 10.*")
		end).to.throw("expected comma after minor version number, found '|'")
	end)
	it("test_any", function()
		local r = VersionReq.STAR
		assert_match_all(r, { "0.0.1", "0.1.0", "1.0.0" })
	end)
	it("test_pre", function()
		local r = req("=2.1.1-really.0")
		assert_match_all(r, { "2.1.1-really.0" })
	end)
	it("test_parse", function()
		expect(function()
			req("\0")
		end).to.throw("unexpected character '\\0' while parsing major version number")

		expect(function()
			req(">= >= 0.0.2")
		end).to.throw("unexpected character '>' while parsing major version number")

		expect(function()
			req(">== 0.0.2")
		end).to.throw("unexpected character '=' while parsing major version number")

		expect(function()
			req("a.0.0")
		end).to.throw("unexpected character 'a' while parsing major version number")

		expect(function()
			req("1.0.0-")
		end).to.throw("empty identifier segment in pre-release identifier")

		expect(function()
			req(">=")
		end).to.throw("unexpected end of input while parsing major version number")
	end)
	it("test_comparator_parse", function()
		local parsed = comparator("1.2.3-alpha")
		assert_to_string(parsed, "^1.2.3-alpha")

		parsed = comparator("2.X")
		assert_to_string(parsed, "2.*")

		parsed = comparator("2")
		assert_to_string(parsed, "^2")

		parsed = comparator("2.x.x")
		assert_to_string(parsed, "2.*")

		expect(function()
			comparator("1.2.3-01")
		end).to.throw("invalid leading zero in pre-release identifier")

		expect(function()
			comparator("1.2.3+4.")
		end).to.throw("empty identifier segment in build metadata")

		expect(function()
			comparator(">")
		end).to.throw("unexpected end of input while parsing major version number")

		expect(function()
			comparator("1.")
		end).to.throw("unexpected end of input while parsing minor version number")

		expect(function()
			comparator("1.*.")
		end).to.throw("unexpected character after wildcard in version req")

		expect(function()
			comparator("1.2.3+4ÿ")
		end).to.throw("unexpected character 'ÿ' after build metadata")
	end)
	it("test_cargo3202", function()
		local r = req("0.*.*")
		assert_to_string(r, "0.*")
		assert_match_all(r, { "0.5.0" })

		r = req("0.0.*")
		assert_to_string(r, "0.0.*")
	end)
	it("test_digit_after_wildcard", function()
		expect(function()
			req("*.1")
		end).to.throw("unexpected character after wildcard in version req")

		expect(function()
			req("1.*.1")
		end).to.throw("unexpected character after wildcard in version req")

		expect(function()
			req(">=1.*.1")
		end).to.throw("unexpected character after wildcard in version req")
	end)
	--[[Hash trait was omitted because it's not relevant to Luau.
	itSKIP("test_eq_hash", function()
		local calculate_hash(value: impl Hash): number
			let mut hasher = DefaultHasher::new();
			value.hash(&mut hasher);
			hasher.finish()
		}
	
		assert!(req("^1") == req("^1"));
		assert!(calculate_hash(req("^1")) == calculate_hash(req("^1")));
		assert!(req("^1") != req("^2"));
	end)--]]
	it("test_leading_digit_in_pre_and_build", function()
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
	it("test_wildcard_and_another", function()
		expect(function()
			req("*, 0.20.0-any")
		end).to.throw("wildcard req (*) must be the only comparator in the version req")

		expect(function()
			req("0.20.0-any, *")
		end).to.throw("wildcard req (*) must be the only comparator in the version req")

		expect(function()
			req("0.20.0-any, *, 1.0")
		end).to.throw("wildcard req (*) must be the only comparator in the version req")
	end)
end
