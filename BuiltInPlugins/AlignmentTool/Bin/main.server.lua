local Plugin = script.Parent.Parent
local getFFlagEnableAlignmentToolPlugin = require(Plugin.Src.Flags.getFFlagEnableAlignmentToolPlugin)

if not getFFlagEnableAlignmentToolPlugin() then
	return
end

local getFFlagEnableAlignToolStylizer = require(Plugin.Src.Flags.getFFlagEnableAlignToolStylizer)
local RefactorFlags = require(Plugin.Packages.Framework.Util.RefactorFlags)
RefactorFlags.THEME_REFACTOR = getFFlagEnableAlignToolStylizer()

local getFFlagAlignToolTeachingCallout = require(Plugin.Src.Flags.getFFlagAlignToolTeachingCallout)

local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)
local ContextServices = require(Plugin.Packages.Framework.ContextServices)
local Analytics = ContextServices.Analytics
local Localization = ContextServices.Localization
local Mouse = ContextServices.Mouse
local Store = ContextServices.Store

local AlignmentToolPlugin = require(Plugin.Src.Components.AlignmentToolPlugin)

local MainReducer = require(Plugin.Src.Reducers.MainReducer)
local MakeTheme = require(Plugin.Src.Resources.MakeTheme)
local analyticsHandlers = require(Plugin.Src.Resources.AnalyticsHandlers)

local TranslationDevelopmentTable = Plugin.Src.Resources.Localization.TranslationDevelopmentTable
local TranslationReferenceTable = Plugin.Src.Resources.Localization.TranslationReferenceTable

local localization = Localization.new({
	pluginName = "AlignmentTool",
	stringResourceTable = TranslationDevelopmentTable,
	translationResourceTable = TranslationReferenceTable,
})

local store = Rodux.Store.new(MainReducer, nil, { Rodux.thunkMiddleware })

local calloutController
if getFFlagAlignToolTeachingCallout() then
	local CalloutController = require(Plugin.Src.Utility.CalloutController)
	calloutController = CalloutController.new()

	local definitionId = "AlignToolCallout"

	local title = localization:getText("Callout", "Title")
	local description = localization:getText("Callout", "Description")
	local learnMoreUrl = "https://developer.roblox.com/en-us/resources/studio/Align-Tool"

	calloutController:defineCallout(definitionId, title, description, learnMoreUrl)
end

local function main()
	local pluginHandle = nil

	local function onPluginUnloading()
		if pluginHandle then
			Roact.unmount(pluginHandle)
			pluginHandle = nil
		end
	end

	local pluginGui = ContextServices.provide({
		ContextServices.Plugin.new(plugin),
		localization,
		MakeTheme(),
		Mouse.new(plugin:GetMouse()),
		Store.new(store),
		Analytics.new(analyticsHandlers),
		calloutController, -- nil if FFlagAlignToolTeachingCallout is false
	}, {
		AlignTool = Roact.createElement(AlignmentToolPlugin),
	})

	pluginHandle = Roact.mount(pluginGui)

	plugin.Unloading:Connect(onPluginUnloading)
end

main()
