<div align="center">

# luau-cargo-semver
[![CI](https://github.com/Tim7775/luau-cargo-semver/actions/workflows/ci.yml/badge.svg)](https://github.com/Tim7775/luau-cargo-semver/actions/workflows/ci.yml) [![Docs](https://github.com/Tim7775/luau-cargo-semver/actions/workflows/docs.yml/badge.svg)](https://tim7775.github.io/luau-cargo-semver/)<br>
**A parser and evaluator for Cargo's flavor of Semantic Versioning**<br>
[**View docs →**](https://tim7775.github.io/luau-cargo-semver/)
</div>

## About
The goal of this library is to mirror the behavior of the Rust crate [`semver`](https://crates.io/crates/semver) used by [Cargo](https://github.com/rust-lang/cargo), [Wally](https://github.com/UpliftGames/wally), [Foreman](https://github.com/Roblox/foreman) and [Aftman](https://github.com/LPGhatguy/aftman).

### Deviations from Cargo's semver
1. Identifiers ([Prerelease](https://tim7775.github.io/luau-cargo-semver/api/Prerelease) and [BuildMetadata](https://tim7775.github.io/luau-cargo-semver/api/BuildMetadata)) have a maximum length of 512 characters (NOTE: This should be enough for all use cases, for context npm has a limit of 256 characters for the complete semver string).
2. Major, minor and patch version numbers overflow at LUAU_MAX_PRECISE_INT (2^53 - 1) instead of u64::MAX (2^63 - 1) (NOTE: Numbers in identifiers do not have this limitation, they get compared with arbitrary-precision).
3. All instances of [Version](https://tim7775.github.io/luau-cargo-semver/api/Version), [Prerelease](https://tim7775.github.io/luau-cargo-semver/api/Prerelease), [BuildMetadata](https://tim7775.github.io/luau-cargo-semver/api/BuildMetadata), [VersionReq](https://tim7775.github.io/luau-cargo-semver/api/VersionReq) and [Comparator](https://tim7775.github.io/luau-cargo-semver/api/Comparator) have been made immutable to keep the complexity of the library manageable.
