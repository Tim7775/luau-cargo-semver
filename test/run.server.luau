--!nocheck
--# selene: allow(undefined_variable)
local TestEZ = require(game:GetService("TestService").Packages.TestEZ)
TestEZ.TestBootstrap:run({
	game:GetService("ReplicatedStorage")["luau-cargo-semver"],
})
