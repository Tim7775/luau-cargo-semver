<div align="center">

# luau-cargo-semver
[![CI](https://github.com/Tim7775/luau-cargo-semver/actions/workflows/ci.yml/badge.svg)](https://github.com/Tim7775/luau-cargo-semver/actions/workflows/ci.yml) [![Wally](https://img.shields.io/badge/Wally-v1.0.0-AD4646)](https://wally.run/package/tim7775/semver?version=1.0.0) [![Docs](https://github.com/Tim7775/luau-cargo-semver/actions/workflows/docs.yml/badge.svg)](https://tim7775.github.io/luau-cargo-semver/)<br>
**A parser and evaluator for Cargo's flavor of Semantic Versioning**

[**View docs →**](https://tim7775.github.io/luau-cargo-semver/)
</div>

## About
The goal of this library is to replicate the exact behavior of the Rust crate [`semver`](https://crates.io/crates/semver) (currently `v1.0.20`) used by [Cargo](https://github.com/rust-lang/cargo) (and [Wally](https://github.com/UpliftGames/wally), [Foreman](https://github.com/Roblox/foreman) and [Aftman](https://github.com/LPGhatguy/aftman)). It succeeds in this with only minor deviations that should only ever present themselves when dealing with hostile user input.

#### Deviations from Cargo's semver:
1. Identifiers ([Prerelease](https://tim7775.github.io/luau-cargo-semver/api/Prerelease) and [BuildMetadata](https://tim7775.github.io/luau-cargo-semver/api/BuildMetadata)) have a maximum length of 512 characters (Note: This should be more than enough for all use cases. For context, npm has a limit of 256 characters for the complete semver string).
2. Major, minor and patch version numbers overflow at LUAU_MAX_PRECISE_INT (2^53 - 1) instead of u64::MAX (2^63 - 1) (Note: Numbers in identifiers do not have this limitation, they get compared with arbitrary-precision).
