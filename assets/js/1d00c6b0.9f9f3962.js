"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[781],{6176:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"","params":[{"name":"major","desc":"","lua_type":"number"},{"name":"minor","desc":"","lua_type":"number"},{"name":"patch","desc":"","lua_type":"number"},{"name":"pre","desc":"","lua_type":"Prerelease"},{"name":"build","desc":"","lua_type":"BuildMetadata"}],"returns":[{"desc":"","lua_type":"Version\\n"}],"function_type":"static","source":{"line":96,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"parse","desc":"Possible reasons for the parse to fail include:","params":[{"name":"input","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Version\\n"}],"function_type":"static","errors":[{"lua_type":"UnexpectedEnd (\\"1.0\\")","desc":"too few numeric components. A SemVer version must have exactly three. If you are looking at something that has fewer than three numbers in it, it\u2019s possible it is a VersionReq instead (with an implicit default ^ comparison operator)."},{"lua_type":"LeadingZero (\\"1.0.01\\")","desc":"a numeric component has a leading zero."},{"lua_type":"UnexpectedChar (\\"1.0.unknown\\")","desc":"unexpected character in one of the components."},{"lua_type":"EmptySegment (\\"1.0.0-\\" or \\"1.0.0+\\")","desc":"the pre-release or build metadata are indicated present but empty."},{"lua_type":"UnexpectedCharAfter (\\"1.0.0-alpha_123\\")","desc":"pre-release or build metadata have something outside the allowed characters, which are 0-9, A-Z, a-z, -, and . (dot)."},{"lua_type":"Overflow (\\"9007199254740992.0.0\\")","desc":"value of major, minor or patch exceeds LUAU_MAX_PRECISE_INT (2^53 - 1)."},{"lua_type":"MaxIdentifierLength (\\"1.0.0-\\" .. string.rep(\\"a\\", 513))","desc":"identifier length exceeds MAX_IDENTIFIER_LENGTH (512)."}],"source":{"line":125,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"is","desc":"Returns `true` if `obj` is a [Version].","params":[{"name":"obj","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\n"}],"function_type":"static","source":{"line":156,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"__tostring","desc":"This metamethod transforms `self` into a string.","params":[],"returns":[{"desc":"","lua_type":"string"}],"function_type":"method","source":{"line":166,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"__eq","desc":"This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.","params":[{"name":"other","desc":"","lua_type":"Version"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","source":{"line":186,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"__lt","desc":"This metamethod tests less than (for `self` and `other`) and is used by the operators `<` and `>`.","params":[{"name":"other","desc":"","lua_type":"Version"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","source":{"line":201,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"__le","desc":"This metamethod tests less than or equal to (for `self` and `other`) and is used by the operators `<=` and `>=`.","params":[{"name":"other","desc":"","lua_type":"Version"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","source":{"line":221,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"cmp_precedence","desc":"Compare the major, minor, patch and [Prerelease] value of `self` and `other`. Unlike the relational operators,\\nthis method disregards [BuildMetadata] and considers [Versions](Version) that differ only in [BuildMetadata]\\nequal. This comparison is what the SemVer spec refers to as \\"precedence\\".\\n\\nReturns:\\n- -1 if `self` has lower precedence than `other`\\n- 0 if `self` and `other` have the same precedence\\n- 1 if `self` has higher precedence than `other`\\n\\nThe `CargoSemver.Ordering` enum (with the fields: `Less` = -1, `Equal` = 0, `Greater` = 1) can be used to clarify code using this method.\\n\\n**Usage:**\\n```lua\\nif removedVersion:cmp_precedence(addedVersion) == Ordering.Greater then\\n\\twarn(\\"Downgrading\\", msg)\\nelse\\n\\tprint(\\"Updating\\", msg)\\nend\\n```","params":[{"name":"other","desc":"","lua_type":"Version"}],"returns":[{"desc":"","lua_type":"-1 | 0 | 1"}],"function_type":"method","source":{"line":259,"path":"lib/CargoSemver/src/Version.luau"}}],"properties":[{"name":"major","desc":"","lua_type":"number","readonly":true,"source":{"line":73,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"minor","desc":"","lua_type":"number","readonly":true,"source":{"line":77,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"patch","desc":"","lua_type":"number","readonly":true,"source":{"line":81,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"pre","desc":"","lua_type":"Prerelease","readonly":true,"source":{"line":85,"path":"lib/CargoSemver/src/Version.luau"}},{"name":"build","desc":"","lua_type":"BuildMetadata","readonly":true,"source":{"line":89,"path":"lib/CargoSemver/src/Version.luau"}}],"types":[],"name":"Version","desc":"SemVer version as defined by https://semver.org.\\n\\nSpec: https://docs.rs/semver/1.0.20/semver/struct.Version.html","source":{"line":65,"path":"lib/CargoSemver/src/Version.luau"}}')}}]);