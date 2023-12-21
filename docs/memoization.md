---
sidebar_position: 5
---

# Memoization

The performance of the [Semver](../api/Semver) library can be improved by registering memoization functions. Memoization functions can prevent repeated parsing of the same [Version](../api/Version) or [VersionReq](../api/VersionReq) string.

:::tip
Memoization functions can be found in the [luau-caching-and-memoization](https://github.com/tim7775/luau-caching-and-memoization) repository.
:::

### Example:
```lua
Semver.setMemoizationFunc("Version", memoizeFrame)
Semver.setMemoizationFunc("VersionReq", function(parseFunc)
	return memoizeRecentlyUsed(50, parseFunc)
end)
```
