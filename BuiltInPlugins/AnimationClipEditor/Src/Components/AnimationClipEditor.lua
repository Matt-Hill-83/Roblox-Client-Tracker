--[[
	The top-level component of the AnimationClip Editor itself.
	Contained within an AnimationClipEditorPlugin.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local EditorController = require(Plugin.Src.Components.EditorController)

local AnimationClipEditor = Roact.PureComponent:extend("AnimationClipEditor")


function AnimationClipEditor:render()
	local theme = self.props.Theme:get("PluginTheme")
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 =theme.backgroundColor,
		}, {
			EditorController = Roact.createElement(EditorController, {
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})
end

ContextServices.mapToProps(AnimationClipEditor, {
	Localization = ContextServices.Localization,
	Plugin = ContextServices.Plugin,
	Theme = ContextServices.Theme,
	Analytics = ContextServices.Analytics,
})


return AnimationClipEditor

