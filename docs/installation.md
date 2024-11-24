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

### Method 2 - Wally package (Roblox)

Add Semver to your `wally.toml` dependency list:
```toml
[dependencies]
Semver = "tim7775/semver@1"
```

Then run `wally install` within your project.

Semver can now be required like any other module grabbed from Wally.

> **:information_source: Note:**  
> Not familiar with Wally? Wally is a package manager (like npm) for the Roblox ecosystem.
To get started, check out the [Wally repository](https://github.com/UpliftGames/wally).

### Method 3 - Manual (Roblox)
1. Visit the [latest release](https://github.com/Tim7775/luau-cargo-semver/releases/latest)
2. Under *Assets*, click `luau-cargo-semver.rbxm`
3. Open Roblox Studio and drag the file into the explorer

### Method 4 - npm (roblox-ts)
Run the following command to install the cargo-semver roblox-ts package:
```bash
npm install @rbxts/cargo-semver
```

Semver can now be imported and used as follows:
```typescript
import Semver from "@rbxts/cargo-semver"
const [ok, message] = Semver.validateVersion("1.0.0")
```
