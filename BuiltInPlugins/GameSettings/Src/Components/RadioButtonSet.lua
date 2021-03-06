--[[
	A set of an arbitrary number of RadioButtons.

	Props:
		int Selected = The current RadioButton to highlight.
		string Title = The title to place to the left of this RadioButtonSet.
		string Description = An optional secondary title to place above this RadioButtonSet.
		table Buttons = A collection of props for all RadioButtons to add.
		e.g.
		{
			{
				Id = boolean/string, boolean can be used for on/off buttons, strings can be used for sets that
					have more than 2 buttons,
				Title = string, title that this button will have,
				Children = optional, additional child comoponents that belong to this button.
			},
			{
				Id = ...,
				Title = ...,
			},
		}

		function SelectionChanged(index, title) = A callback for when the selected option changes.
		int LayoutOrder = The order this RadioButtonSet will sort to when placed in a UIListLayout.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)

local Framework = Plugin.Framework
local ContextServices = require(Framework.ContextServices)

local UILibrary = require(Plugin.UILibrary)
local DEPRECATED_Constants = require(Plugin.Src.Util.DEPRECATED_Constants)

local RadioButton = require(Plugin.Src.Components.RadioButton)
local TitledFrame = UILibrary.Component.TitledFrame

local FFlagGameSettingsPlaceSettings = game:GetFastFlag("GameSettingsPlaceSettings")
local FFlagFixRadioButtonSeAndTableHeadertForTesting = game:GetFastFlag("FixRadioButtonSeAndTableHeadertForTesting")

local LayoutOrderIterator = require(Framework.Util.LayoutOrderIterator)

local RadioButtonSet = Roact.PureComponent:extend("RadioButtonSet")

function RadioButtonSet:init()
	self.state = {
		maxHeight = 0
	}

	self.layoutRef = Roact.createRef()

	self.onResize = function()
		local currentLayout = self.layoutRef.current
		if not currentLayout then
			return
		end

		self:setState({
			maxHeight = currentLayout.AbsoluteContentSize.Y
		})
	end
end

function RadioButtonSet:render()
	local props = self.props
	local theme = props.Theme:get("Plugin")

	local layoutIndex = LayoutOrderIterator.new()

	local selected
	if props.Selected ~= nil then
		selected = props.Selected
	else
		selected = 1
	end

	local buttons = props.Buttons
	local numButtons = #buttons

	local children = {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, DEPRECATED_Constants.RADIO_BUTTON_PADDING),
			SortOrder = Enum.SortOrder.LayoutOrder,

			[Roact.Change.AbsoluteContentSize] = self.onResize,
			[Roact.Ref] = self.layoutRef,
		})
	}

	if (props.Description) then
		table.insert(children, Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Normal, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, DEPRECATED_Constants.RADIO_BUTTON_SIZE + 5),
			TextTransparency = props.Enabled and 0 or 0.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Text = props.Description,
		})))
	end

	for i, button in ipairs(buttons) do
		if FFlagGameSettingsPlaceSettings then
			if props.RenderItem then
				if FFlagFixRadioButtonSeAndTableHeadertForTesting then
					children = Cryo.Dictionary.join(children, {
						[button.Id] = props.RenderItem(i, button)
					})
				else
					table.insert(children, props.RenderItem(i, button))
				end
			else
				if FFlagFixRadioButtonSeAndTableHeadertForTesting then
					children = Cryo.Dictionary.join(children, {
						[button.Id] = Roact.createElement(RadioButton, {
							Title = button.Title,
							Id = button.Id,
							Description = button.Description,
							Selected = (button.Id == selected) or (i == selected),
							Index = i,
							Enabled = props.Enabled,
							LayoutOrder = layoutIndex:getNextOrder(),
							OnClicked = function()
								props.SelectionChanged(button)
							end,

							Children = button.Children,
						})
					})
				else
					table.insert(children, Roact.createElement(RadioButton, {
						Title = button.Title,
						Id = button.Id,
						Description = button.Description,
						Selected = (button.Id == selected) or (i == selected),
						Index = i,
						Enabled = props.Enabled,
						LayoutOrder = layoutIndex:getNextOrder(),
						OnClicked = function()
							props.SelectionChanged(button)
						end,

						Children = button.Children,
					}))
				end
			end
		else
			if FFlagFixRadioButtonSeAndTableHeadertForTesting then
				children = Cryo.Dictionary.join(children, {
					[button.Id] = Roact.createElement(RadioButton, {
						Title = button.Title,
						Id = button.Id,
						Description = button.Description,
						Selected = (button.Id == selected) or (i == selected),
						Index = i,
						Enabled = props.Enabled,
						LayoutOrder = layoutIndex:getNextOrder(),
						OnClicked = function()
							props.SelectionChanged(button)
						end,

						Children = button.Children,
					})
				})
			else
				table.insert(children, Roact.createElement(RadioButton, {
					Title = button.Title,
					Id = button.Id,
					Description = button.Description,
					Selected = (button.Id == selected) or (i == selected),
					Index = i,
					Enabled = props.Enabled,
					LayoutOrder = layoutIndex:getNextOrder(),
					OnClicked = function()
						props.SelectionChanged(button)
					end,

					Children = button.Children,
				}))
			end
		end
	end

	local maxHeight = numButtons * DEPRECATED_Constants.RADIO_BUTTON_SIZE * 2
		+ numButtons * DEPRECATED_Constants.RADIO_BUTTON_PADDING
		+ (props.Description and DEPRECATED_Constants.RADIO_BUTTON_SIZE + 5 + DEPRECATED_Constants.RADIO_BUTTON_PADDING or 0)

	maxHeight = math.max(self.state.maxHeight, maxHeight)

	return Roact.createElement(TitledFrame, {
		Title = props.Title,
		MaxHeight = maxHeight,
		LayoutOrder = props.LayoutOrder or 1,
		TextSize = theme.fontStyle.Title.TextSize,
	}, children)
end

ContextServices.mapToProps(RadioButtonSet, {
	Theme = ContextServices.Theme,
})

return RadioButtonSet