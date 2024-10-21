declare namespace Semver {
	export const cmp: (lhs: string, op: "<" | "<=" | "==" | ">" | ">=" | "~=", rhs: string) => boolean;
	export const cmpPrecedence: (lhs: string, op: "<" | "<=" | "==" | ">" | ">=" | "~=", rhs: string) => boolean;
	export const getMaxMatching: (versions: Array<string>, versionReq: string) => string | undefined;
	export const getMinMatching: (versions: Array<string>, versionReq: string) => string | undefined;
	export const matches: (version: string, versionReq: string) => boolean;
	export const setMemoizationFunc: <T>(
		objToMemoize: "Version" | "VersionReq",
		memoizationFunc: (parseFunc: (str: string) => T) => (str: string) => T,
	) => void;
	export const validateVersion: (version: string) => LuaTuple<[true, undefined] | [false, string]>;
	export const validateVersionReq: (versionReq: string) => LuaTuple<[true, undefined] | [false, string]>;
}

export = Semver;
