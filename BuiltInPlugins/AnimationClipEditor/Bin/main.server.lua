local Plugin = script.Parent.Parent
local DebugFlags = require(Plugin.Src.Util.DebugFlags)
local GetFFlagUseDeveloperFrameworkMigratedSrc = require(Plugin.LuaFlags.GetFFlagUseDeveloperFrameworkMigratedSrc)
local GetFFlagAnimationClipEditorRoactInspector = require(Plugin.LuaFlags.GetFFlagAnimationClipEditorRoactInspector)
local Roact = require(Plugin.Packages.Roact)
local RoactDeprecated = require(Plugin.Roact)
local AnimationClipEditorPlugin = require(Plugin.Src.Components.AnimationClipEditorPlugin)
local AnimationClipEditorPluginDeprecated =  require(Plugin.SrcDeprecated.Components.AnimationClipEditorPlugin)

-- Set THEME_REFACTOR in the DevFramework to false
local RefactorFlags = require(Plugin.Packages.Framework.Util.RefactorFlags)
RefactorFlags.THEME_REFACTOR = false

if DebugFlags.RunTests() or DebugFlags.RunRhodiumTests() then
	return
end

local inspector = nil
local handle = nil

local function init()
	if GetFFlagUseDeveloperFrameworkMigratedSrc() then 
		local mainPlugin = Roact.createElement(AnimationClipEditorPlugin, {
			plugin = plugin,
		})

		handle = Roact.mount(mainPlugin)
	else 
		local mainPlugin = RoactDeprecated.createElement(AnimationClipEditorPluginDeprecated, {
			plugin = plugin,
		})

		handle = RoactDeprecated.mount(mainPlugin)
	end

	if GetFFlagAnimationClipEditorRoactInspector() then
		-- StudioService isn't always available, so ignore if an error is thrown trying to access
		local ok, hasInternalPermission = pcall(function() return game:GetService("StudioService"):HasInternalPermission() end)

		if ok and hasInternalPermission then
			-- TODO FFlagAnimationClipEditorRoactInspector - move these imports to top of file when flag is retired
			local Framework = require(Plugin.Packages.Framework)
			inspector = Framework.DeveloperTools.forPlugin("AnimationClipEditor", plugin)
			inspector:addRoactTree("Roact tree", handle)
		end
	end
end

plugin.Unloading:Connect(function()
	if handle then
		if GetFFlagUseDeveloperFrameworkMigratedSrc() then 
			Roact.unmount(handle)
		else 
			RoactDeprecated.unmount(handle)
		end
	end

	if GetFFlagAnimationClipEditorRoactInspector() and inspector then
		inspector:destroy()
	end
end)

init()