local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local MaterialSettings = require(script.Parent.MaterialSettings)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(MaterialSettings)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
