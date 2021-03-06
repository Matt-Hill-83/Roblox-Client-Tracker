local Plugin = script.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local Add = require(script.Parent.Add)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(Add)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
