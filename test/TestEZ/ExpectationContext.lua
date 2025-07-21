local Expectation = require("./Expectation")
local checkMatcherNameCollisions = Expectation.checkMatcherNameCollisions

local ExpectationContext = {}
ExpectationContext.__index = ExpectationContext

function ExpectationContext.new(parent)
	local self = {
		_extensions = parent and table.clone(parent._extensions) or {},
	}

	return setmetatable(self, ExpectationContext)
end

function ExpectationContext:startExpectationChain(...)
	return Expectation.new(...):extend(self._extensions)
end

function ExpectationContext:extend(config)
	for key, value in pairs(config) do
		assert(self._extensions[key] == nil, string.format("Cannot reassign %q in expect.extend", key))
		assert(checkMatcherNameCollisions(key), string.format("Cannot overwrite matcher %q; it already exists", key))

		self._extensions[key] = value
	end
end

return ExpectationContext
