---
sidebar_position: 4
---

# Examples

### Semver API
```lua
local Semver = require("luau-cargo-semver/lib/Semver")

local req = ">=1.2.3, <1.8.0"

-- Check whether this requirement matches version 1.2.3-alpha.1 (no)
assert(not Semver.matches("1.2.3-alpha.1", req), "assertion failed!")

-- Check whether it matches 1.3.0 (yes it does)
assert(Semver.matches("1.3.0", req), "assertion failed!")

-- Compare versions
assert(Semver.cmp("1.3.0", "~=", "1.3.0+build"), "assertion failed!")
assert(Semver.cmpPrecedence("1.3.0", "==", "1.3.0+build"), "assertion failed!")

-- Sort versions array
local versions = { "3.1.2", "1.0.0", "1.0.0-rc.1", "1.0.0-rc.2", "0.3.0-alpha", "0.3.0-beta" }
table.sort(versions, function(a, b)
	return Semver.cmp(a, "<", b)
end)
print(versions)
```

### CargoSemver API

```lua
local CargoSemver = require("luau-cargo-semver/lib/CargoSemver")
local BuildMetadata, Prerelease, Version, VersionReq, Ordering =
	CargoSemver.BuildMetadata, CargoSemver.Prerelease, CargoSemver.Version, CargoSemver.VersionReq, CargoSemver.Ordering

local req = VersionReq.parse(">=1.2.3, <1.8.0")

-- Check whether this requirement matches version 1.2.3-alpha.1 (no)
local ver = Version.new(1, 2, 3, Prerelease.new("alpha.1"), BuildMetadata.EMPTY)
assert(not req:matches(ver), "assertion failed!")

-- Check whether it matches 1.3.0 (yes it does)
ver = Version.parse("1.3.0")
assert(req:matches(ver), "assertion failed!")

-- Compare versions
local verBuild = Version.parse("1.3.0+build")
assert(ver ~= verBuild, "assertion failed!")
assert(ver:cmp_precedence(verBuild) == Ordering.Equal, "assertion failed!")

-- Sort versions array
local versions = {
	Version.parse("3.1.2"),
	Version.parse("1.0.0"),
	Version.parse("1.0.0-rc.1"),
	Version.parse("1.0.0-rc.2"),
	Version.parse("0.3.0-alpha"),
	Version.parse("0.3.0-beta"),
}
table.sort(versions)
print(versions)
```
