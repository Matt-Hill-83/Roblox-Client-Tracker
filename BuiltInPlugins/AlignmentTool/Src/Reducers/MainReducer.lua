local Plugin = script.Parent.Parent.Parent

local getFFlagAlignInLocalSpace = require(Plugin.Src.Flags.getFFlagAlignInLocalSpace)
local getFFlagAlignShowPreview = require(Plugin.Src.Flags.getFFlagAlignShowPreview)

local Cryo = require(Plugin.Packages.Cryo)
local Rodux = require(Plugin.Packages.Rodux)

local AlignmentMode = require(Plugin.Src.Utility.AlignmentMode)
local AlignmentSpace = require(Plugin.Src.Utility.AlignmentSpace)
local RelativeTo = require(Plugin.Src.Utility.RelativeTo)

local initialState = {
	toolEnabled = false,

	alignEnabled = false,
	disabledReason = {},

	alignableObjects = {},
	alignmentMode = AlignmentMode.Center,
	alignmentSpace = getFFlagAlignInLocalSpace() and AlignmentSpace.World or nil,
	enabledAxes = getFFlagAlignInLocalSpace() and {
		X = false,
		Y = false,
		Z = false,
	} or {
		WorldX = false,
		WorldY = false,
		WorldZ = false,
	},
	relativeTo = RelativeTo.Selection,

	previewVisible = false,
}

local MainReducer = Rodux.createReducer(initialState, {
	SetToolEnabled = function(state, action)
		return Cryo.Dictionary.join(state, {
			toolEnabled = action.toolEnabled,
		})
	end,

	SetAlignEnabled = function(state, action)
		return Cryo.Dictionary.join(state, {
			alignEnabled = action.alignEnabled,
			disabledReason = action.disabledReason,
		})
	end,

	SetAlignableObjects = function(state, action)
		return Cryo.Dictionary.join(state, {
			alignableObjects = action.alignableObjects,
		})
	end,

	SetAlignmentMode = function(state, action)
		return Cryo.Dictionary.join(state, {
			alignmentMode = action.alignmentMode,
		})
	end,

	SetAlignmentSpace = getFFlagAlignInLocalSpace() and function(state, action)
		return Cryo.Dictionary.join(state, {
			alignmentSpace = action.alignmentSpace,
		})
	end or nil,

	SetEnabledAxes = function(state, action)
		return Cryo.Dictionary.join(state, {
			enabledAxes = action.enabledAxes,
		})
	end,

	SetRelativeTo = function(state, action)
		return Cryo.Dictionary.join(state, {
			relativeTo = action.relativeTo,
		})
	end,

	SetPreviewVisible = getFFlagAlignShowPreview() and function(state, action)
		return Cryo.Dictionary.join(state, {
			previewVisible = action.visible,
		})
	end or nil,
})

return MainReducer
