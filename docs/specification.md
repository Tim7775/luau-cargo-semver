---
sidebar_position: 3
---

# Specification
The goal of this library is to replicate the exact behavior of the Rust crate [`semver`](https://crates.io/crates/semver) (currently `v1.0.20`) used by [Cargo](https://github.com/rust-lang/cargo) (and [Wally](https://github.com/UpliftGames/wally), [Foreman](https://github.com/Roblox/foreman) and [Rokit](https://github.com/rojo-rbx/rokit)). It succeeds in this with only minor deviations that should only ever present themselves when dealing with hostile user input.

#### Deviations from Cargo's semver:
1. Identifiers ([Prerelease](../api/Prerelease) and [BuildMetadata](../api/BuildMetadata)) have a maximum length of 512 characters (Note: This should be more than enough for all use cases. For context, npm has a limit of 256 characters for the complete semver string).
2. Major, minor and patch version numbers overflow at LUAU_MAX_PRECISE_INT (2^53 - 1) instead of u64::MAX (2^63 - 1) (Note: Numbers in identifiers do not have this limitation, they get compared with arbitrary-precision).
