--[[
	An entry in an InfoPanel that renders a component's example,
	or nothing if the component does not have an example.

	Required Props:
		string Name: The name of the component to render an example for.

	Optional Props:
		number LayoutOrder: The sort order of this component.
]]

local SelectionService = game:GetService("Selection")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Render = require(Plugin.Packages.Framework).Examples.Render

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Util = Framework.Util
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local UI = Framework.UI
local Container = UI.Container
local Decoration = UI.Decoration

local PanelEntry = require(Plugin.Src.Components.PanelEntry)

--[[
	Component examples are often functional components.
	Those rerender when their parent component does, but we don't want this behaviour.
	This wrapper ensures that the example only rerenders when it needs to, vs. when RenderExample component changes
]]
local PureWrapper = Roact.PureComponent:extend("PureWrapper")

function PureWrapper:render()
	return Roact.createElement(self.props.Component)
end

local RenderExample = Roact.PureComponent:extend("RenderExample")

function RenderExample:init()
	self.containerRef = Roact.createRef()
	self.state = {
		extents = Vector2.new(),
		ExampleComponent = nil,
	}

	self.updateExtents = function(extents)
		self:setState({
			extents = extents,
		})
	end
end

function RenderExample:loadExampleComponent()
	-- Fallback to None: if there is no Name prop provided, or if there is no result returned from Render
	self:setState({
		ExampleComponent = self.props.Name and Render(self.props.Name) or Roact.None
	})
end

function RenderExample:didMount()
	self:loadExampleComponent()

	-- Focus the example container Frame in the Explorer
	-- Not having this in a spawn can result in rare crashes of Studio
	spawn(function()
		if self.containerRef.current then
			SelectionService:Set({self.containerRef.current})
		end
	end)
end

function RenderExample:didUpdate(prevProps)
	if prevProps.Name ~= self.props.Name then
		self:loadExampleComponent()
	end
end

function RenderExample:render()
	local props = self.props
	local state = self.state

	local extents = state.extents
	local ExampleComponent = state.ExampleComponent

	local layoutOrder = props.LayoutOrder
	local sizes
	local style = props.Stylizer
	if THEME_REFACTOR then
		sizes = style.Sizes
	else
		sizes = props.Theme:get("Sizes")
	end
	if not ExampleComponent then
		return nil
	end

	return Roact.createElement(PanelEntry, {
		Header = "Example",
		LayoutOrder = layoutOrder,
	}, {
		Container = Roact.createElement(Container, {
			Size = UDim2.new(1, 0, 0, extents.Y + (sizes.OuterPadding * 2)),
			Background = Decoration.RoundBox,
			BackgroundStyle = "__Example",
			Padding = sizes.OuterPadding,
			[Roact.Ref] = self.containerRef
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				[Roact.Change.AbsoluteContentSize] = function(rbx)
					self.updateExtents(rbx.AbsoluteContentSize)
				end,
			}),

			Example = Roact.createElement(PureWrapper, {
				Component = ExampleComponent,
			}),
		})
	})
end

ContextServices.mapToProps(RenderExample, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return RenderExample
