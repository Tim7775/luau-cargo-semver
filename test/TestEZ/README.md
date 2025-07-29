<h1 align="center">Lune-TestEZ</h1>
<div align="center">
	BDD-style Luau testing framework
</div>

<div>&nbsp;</div>

This is a fork of the Roblox testing framework [TestEZ](https://github.com/Roblox/testez) modified to run in [Lune](https://github.com/lune-org/lune) for testing standalone [Luau](https://github.com/luau-lang/luau) projects on CI systems. It still runs within Roblox as normal.

It provides an API that can run all of your tests with a single method call as well as a more granular API that exposes each step of the pipeline.

## Inspiration and Prior Work
The `describe` and `it` syntax in TestEZ is based on the [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) methodology, notably as implemented in RSpec (Ruby), busted (Lua), Mocha (JavaScript), and Ginkgo (Go).

The `expect` syntax is based on Chai, a JavaScript assertion library commonly used with Mocha. Similar expectation systems are also used in RSpec and Ginkgo, with slightly different syntax.

## License
TestEZ is available under the Apache 2.0 license. See [LICENSE](LICENSE) for details.
