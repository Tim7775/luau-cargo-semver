---
sidebar_position: 3
---

# Specification

The goal of this library is to mirror the exact behavior of the Rust crate [`semver`](https://crates.io/crates/semver) used by [Cargo](https://github.com/rust-lang/cargo), [Wally](https://github.com/UpliftGames/wally), [Foreman](https://github.com/Roblox/foreman) and [Aftman](https://github.com/LPGhatguy/aftman).

## Deviations from Cargo's semver
1. Identifiers ([Prerelease](../api/Prerelease) and [BuildMetadata](../api/BuildMetadata)) have a maximum length of 512 characters (NOTE: This should be enough for all use cases, for context npm has a limit of 256 characters for the complete semver string).
2. Major, minor and patch version numbers overflow at LUAU_MAX_PRECISE_INT (2^53 - 1) instead of u64::MAX (2^63 - 1) (NOTE: Numbers in identifiers do not have this limitation, they get compared with arbitrary-precision).
3. All instances of [Version](../api/Version), [Prerelease](../api/Prerelease), [BuildMetadata](../api/BuildMetadata), [VersionReq](../api/VersionReq) and [Comparator](../api/Comparator) have been made immutable to keep the complexity of the library manageable.
