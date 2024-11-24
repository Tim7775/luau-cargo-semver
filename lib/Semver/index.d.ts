declare namespace Semver {
	/**
	 * Compare the major, minor, patch, [Prerelease](https://tim7775.github.io/luau-cargo-semver/api/Prerelease) and [BuildMetadata](https://tim7775.github.io/luau-cargo-semver/api/BuildMetadata) value of two [Versions](https://tim7775.github.io/luau-cargo-semver/api/Version).
	 *
	 * **Usage:**
	 * ```ts
	 * //Sort versions array
	 * const versions = [ "3.1.2", "1.0.0", "1.0.0-rc.1", "1.0.0-rc.2", "0.3.0-alpha", "0.3.0-beta" ];
	 * table.sort(versions, function(a, b) {
	 * 	return Semver.cmp(a, "<", b);
	 * })
	 * ```
	 */
	export const cmp: (lhs: string, op: "<" | "<=" | "==" | ">" | ">=" | "~=", rhs: string) => boolean;
	/**
	 * Compare the major, minor, patch and [Prerelease](https://tim7775.github.io/luau-cargo-semver/api/Prerelease) value of two [Versions](https://tim7775.github.io/luau-cargo-semver/api/Version),
	 * disregarding [BuildMetadata](https://tim7775.github.io/luau-cargo-semver/api/BuildMetadata). [Versions](https://tim7775.github.io/luau-cargo-semver/api/Version) that differ only in [BuildMetadata](https://tim7775.github.io/luau-cargo-semver/api/BuildMetadata)
	 * are considered equal. This comparison is what the SemVer spec refers to
	 * as "precedence".
	 *
	 * **Usage:**
	 * ```ts
	 * assert(Semver.cmpPrecedence(newVersion, ">=", oldVersion), "newVersion must be >= oldVersion");
	 * ```
	 */
	export const cmpPrecedence: (lhs: string, op: "<" | "<=" | "==" | ">" | ">=" | "~=", rhs: string) => boolean;
	/**
	 * **Usage:**
	 * ```ts
	 * const versions = { "3.1.2", "0.3.0", "1.0.0", "1.6.0" };
	 * print(Semver.getMaxMatching(versions, "^1.0.0")); //--> 1.6.0
	 * ```
	 */
	export const getMaxMatching: (versions: Array<string>, versionReq: string) => string | undefined;
	/**
	 * **Usage:**
	 * ```ts
	 * const versions = { "3.1.2", "0.3.0", "1.0.0", "1.6.0" };
	 * print(Semver.getMinMatching(versions, "^1.0.0")); //--> 1.0.0
	 * ```
	 */
	export const getMinMatching: (versions: Array<string>, versionReq: string) => string | undefined;
	/**
	 * **Usage:**
	 * ```ts
	 * assert(Semver.matches(versionStr, "^1.0.0"), "version does not match requirement");
	 * ```
	 */
	export const matches: (version: string, versionReq: string) => boolean;
	/**
	 * Registers a memoization function for [Version.parse](https://tim7775.github.io/luau-cargo-semver/api/Version#parse) or [VersionReq.parse](https://tim7775.github.io/luau-cargo-semver/api/VersionReq#parse),
	 * this can prevent repeated parsing of semver strings and greatly improve the performance of the [Semver](https://tim7775.github.io/luau-cargo-semver/api/Semver/) library.
	 *
	 * **💡 Tip:**
	 * Memoization functions can be found in the [luau-caching-and-memoization](https://github.com/tim7775/luau-caching-and-memoization) repository.
	 *
	 * **Usage:**
	 * ```ts
	 * import memoizeRecentlyUsed from "@rbxts/memoize-recently-used";
	 * import Semver from "@rbxts/cargo-semver";
	 *
	 * Semver.setMemoizationFunc("Version", function(parseFunc) {
	 * 	return memoizeRecentlyUsed(20, parseFunc);
	 * })
	 * ```
	 */
	export const setMemoizationFunc: <T>(
		objToMemoize: "Version" | "VersionReq",
		memoizationFunc: (parseFunc: (str: string) => T) => (str: string) => T,
	) => void;
	/**
	 * **Usage:**
	 * ```ts
	 * const [ok, message] = Semver.validateVersion("1.0");
	 * if (!ok) {
	 * 	error(message); //--> Error: unexpected end of input while parsing minor version number
	 * }
	 * ```
	 */
	export const validateVersion: (version: string) => LuaTuple<[true, undefined] | [false, string]>;
	/**
	 * **Usage:**
	 * ```ts
	 * const [ok, message] = Semver.validateVersionReq("1.0.a");
	 * if (!ok) {
	 * 	error(message); //--> Error: unexpected character 'a' while parsing patch version number
	 * }
	 * ```
	 */
	export const validateVersionReq: (versionReq: string) => LuaTuple<[true, undefined] | [false, string]>;
}

export = Semver;
