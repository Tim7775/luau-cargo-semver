---
sidebar_position: 5
---

# Memoization
To improve the performance of the [Semver](../api/Semver) library,
you can register memoization functions using [Semver.setMemoizationFunc](../api/Semver#setMemoizationFunc).
Memoization functions registered with this function cache the results of [Version.parse](../api/Version#parse)
or [VersionReq.parse](../api/VersionReq#parse), which can prevent repeated parsing of semver strings.

> **:bulb: Tip:**  
> Memoization functions can be found in the [luau-caching-and-memoization](https://github.com/tim7775/luau-caching-and-memoization) repository.

### Example:
```lua
Semver.setMemoizationFunc("Version", memoizeFrame)
Semver.setMemoizationFunc("VersionReq", function(parseFunc)
	return memoizeRecentlyUsed(50, parseFunc)
end)
```
