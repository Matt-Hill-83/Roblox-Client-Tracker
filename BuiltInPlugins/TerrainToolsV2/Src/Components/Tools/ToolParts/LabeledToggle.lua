local FFlagTerrainEditorUpdateFontToSourceSans = game:GetFastFlag("TerrainEditorUpdateFontToSourceSans")
local FFlagTerrainToolsFixLabeledElementPair = game:GetFastFlag("TerrainToolsFixLabeledElementPair")

local Plugin = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local ToolParts = script.Parent
local LabeledElementPair = require(ToolParts.LabeledElementPair)
local ToggleButton = require(ToolParts.ToggleButtons).ToggleButton

local function LabeledToggle(props)
	local layoutOrder = props.LayoutOrder
	local text = props.Text

	local isOn = props.IsOn
	local setIsOn = props.SetIsOn
	local disabled = props.Disabled

	return Roact.createElement(LabeledElementPair, {
		Size = UDim2.new(1, 0, 0, 18),
		Text = text,
		LayoutOrder = layoutOrder
	}, {
		ToggleButton = Roact.createElement(ToggleButton, {
			IsOn = isOn,
			SetIsOn = setIsOn,
			Disabled = disabled,
			Position = FFlagTerrainEditorUpdateFontToSourceSans and
				UDim2.new(0, 0, 0, FFlagTerrainToolsFixLabeledElementPair and 3 or 6)
				or nil
		}),
	})
end

return LabeledToggle
