---
sidebar_position: 2
---

# Installation

### Method 1 - Git Submodule
Add the luau-cargo-semver repository as a git submodule ([Git Submodules explanation](https://gist.github.com/gitaarik/8735255)):
```bash
git submodule add https://github.com/Tim7775/luau-cargo-semver.git/ .lune/luau-cargo-semver
```
Scripts in the .lune folder can now require Semver as follows:
```lua
local Semver = require("./luau-cargo-semver/lib/Semver")
```

### Method 2 - As a Wally package

Add Semver to your `wally.toml` dependency list:
```toml
[dependencies]
Semver = "tim7775/semver@1"
```

Require Semver like any other module grabbed from Wally.

> **:information_source: Note:**  
> Not familiar with Wally? Wally is a package manager (like npm) for the Roblox ecosystem.
To get started, check out the [Wally repository](https://github.com/UpliftGames/wally).
