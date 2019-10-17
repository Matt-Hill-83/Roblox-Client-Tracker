--[[

]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

local Constants = require(Plugin.Src.Util.Constants)

local GrowTool = Rodux.createReducer({
	brushShape = "Sphere",
	baseSize = 6,
	height = 6,
	strength = 1,
	pivot = Constants.PivotType.Center,
	planeLock = false,
	snapToGrid = false,
	ignoreWater = true,
	autoMaterial = false,
	material = Enum.Material.Grass,
},
{
	ChooseBrushShape = function(state, action)
		local brushShape = action.brushShape

		return Cryo.Dictionary.join(state, {
			brushShape = brushShape,
		})
	end,
	ChangeBaseSize = function(state, action)
		local baseSize = action.baseSize

		return Cryo.Dictionary.join(state, {
			baseSize = baseSize,
		})
	end,
	ChangeHeight = function(state, action)
		local height = action.height

		return Cryo.Dictionary.join(state, {
			height = height,
		})
	end,
	ChangePivot = function(state, action)
		local pivot = action.pivot

		return Cryo.Dictionary.join(state, {
			pivot = pivot,
		})
	end,
	ChangeStrength = function(state, action)
		local strength = action.strength
		return Cryo.Dictionary.join(state, {
			strength = strength,
		})
	end,
	SetPlaneLock = function(state, action)
		local planeLock = action.planeLock

		return Cryo.Dictionary.join(state, {
			planeLock = planeLock,
		})
	end,
	SetSnapToGrid = function(state, action)
		local snapToGrid = action.snapToGrid

		return Cryo.Dictionary.join(state, {
			snapToGrid = snapToGrid,
		})
	end,
	SetIgnoreWater = function(state, action)
		local ignoreWater = action.ignoreWater

		return Cryo.Dictionary.join(state, {
			ignoreWater = ignoreWater,
		})
	end,
	SetAutoMaterial = function(state, action)
		local autoMaterial = action.autoMaterial

		return Cryo.Dictionary.join(state, {
			autoMaterial = autoMaterial,
		})
	end,
	SetMaterial = function(state, action)
		local material = action.material

		return Cryo.Dictionary.join(state, {
			material = material,
		})
	end,
})

return GrowTool