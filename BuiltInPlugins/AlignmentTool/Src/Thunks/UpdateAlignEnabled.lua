--[[
	Updates the align enabled state. Align is enabled when one or more objects
	are selected and there is at least one axis to align on.
]]

local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")

local Plugin = script.Parent.Parent.Parent

local getEngineFeatureActiveInstanceHighlight = require(Plugin.Src.Flags.getEngineFeatureActiveInstanceHighlight)
local getFFlagAlignInLocalSpace = require(Plugin.Src.Flags.getFFlagAlignInLocalSpace)

local SetAlignEnabled = require(Plugin.Src.Actions.SetAlignEnabled)
local AlignToolError = require(Plugin.Src.Utility.AlignToolError)
local RelativeTo = require(Plugin.Src.Utility.RelativeTo)

local function hasEnabledAxis(axes)
	if getFFlagAlignInLocalSpace() then
		return axes.X or axes.Y or axes.Z
	else
		return axes.WorldX or axes.WorldY or axes.WorldZ
	end
end

return function()
	local terrain = Workspace.Terrain

	local function isAlignable(object)
		if object:IsA("BasePart") and object ~= terrain then
			return true
		elseif object:IsA("Model") then
			return true
		else
			return false
		end
	end

	return function(store)
		local state = store:getState()

		local objects = state.alignableObjects
		local axes = state.enabledAxes

		local alignEnabled = #objects > 1 and hasEnabledAxis(axes)
		local reason

		if getEngineFeatureActiveInstanceHighlight() then
			if alignEnabled and state.relativeTo == RelativeTo.Active then
				local target = Selection.ActiveInstance
				if not isAlignable(target) then
					alignEnabled = false
					reason = {
						errorCode = AlignToolError.InvalidActiveObject,
						formatParameters = {
							name = target.Name
						},
					}
				end
			end
		end

		store:dispatch(SetAlignEnabled(alignEnabled, reason))
	end
end
