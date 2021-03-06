return function()
	local Plugin = script.Parent.Parent.Parent.Parent

	local Libs = Plugin.Libs
	local Roact = require(Libs.Roact)

	local MockWrapper = require(Plugin.Core.Util.MockWrapper)

	local LiveSearchDropdown = require(Plugin.Core.Components.SearchOptions.LiveSearchDropdown)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MockWrapper, {}, {
			Dropdown = Roact.createElement(LiveSearchDropdown, {
				Items = {
					{Name = "Name", Thumbnail = "rbxassetid://0"},
				},
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
