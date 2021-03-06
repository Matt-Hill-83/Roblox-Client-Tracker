local FFlagCGELocalizeWindowTitle = game:DefineFastFlag("CGELocalizeWindowTitle", false)
local FFlagCGEDebounceInit = game:DefineFastFlag("CGEDebounceInit", false)

local Root = script.Parent.Parent
local Roact = require(Root.modules.Roact)
local Gui = require(Root.Plugin.Components.Gui)

local MinX = 128
local MinY = 256

local Opened = false

local AnalyticsService = game:GetService("RbxAnalyticsService")

local FFlagSupportPluginDebugging = settings():GetFFlag("SupportPluginDebugging")
local FFlagEnableRoactInspector = settings():GetFFlag("EnableRoactInspector")

local hasInternalPermission = game:GetService("StudioService"):HasInternalPermission()

local function reportOpening()
	if Opened then return end
	AnalyticsService:ReportCounter("cgeOpenings", 1)
	AnalyticsService:SendEventDeferred("studio", "collisionGroupsEditor", "opening", {
		method = 1, --studio tab
		gameId = game.GameId,
		uid = plugin:GetStudioUserId(),
	})
	Opened = true
end

local Toolbar = plugin:CreateToolbar("collisionGroupsEditorToolbar")
local Button = Toolbar:CreateButton("collisionGroupsEditorButton", "Edit collision groups", "rbxasset://textures/CollisionGroupsEditor/ToolbarIcon.png")

local function updateButtonActive(button, pluginGui)
	if pluginGui.Enabled then
	  button:SetActive(true)
	else
	  button:SetActive(false)
	end
end

local Info = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	false,
	false,
	MinX, MinY,
	MinX, MinY
)

local localization = nil
if FFlagCGELocalizeWindowTitle then
	local UILibrary = require(script.Parent.Parent.modules.UILibrary)
	local Resources = script.Parent.Parent.Resources

	localization = UILibrary.Studio.Localization.new({
		stringResourceTable = Resources.TranslationDevelopmentTable,
		translationResourceTable = Resources.TranslationReferenceTable,
		pluginName = "CGE",
	})
end


local Window = nil
local RoactHandle = nil
local inspector

local function handleDMSessionDebounced(dmSession)
	if (Window == nil) then 
		-- Set the initial icon to show while over this plugin's dock widget.
		-- Without this, the cursor will be the odd plugin cursor for a
		-- fraction of a second when entering the DockWidget for the first
		-- time.
		plugin:GetMouse().Icon = "rbxasset://SystemCursors/Arrow"

		Window = plugin:CreateDockWidgetPluginGui("CollisionGroupsEditorWindow", Info)
		
		if FFlagCGELocalizeWindowTitle then
			Window.Title = localization:getText("Main", "Title")
		else
			Window.Title = "Collision Groups Editor"
		end
		
		updateButtonActive(Button, Window)

		-- Listen for changes in plugin gui visibility to keep toolbar button
		-- active state synced.
		Window:GetPropertyChangedSignal("Enabled"):connect(function(property)
			updateButtonActive(Button, Window)
		end)
		if FFlagEnableRoactInspector and hasInternalPermission then
			local DeveloperTools = require(Root.Packages.Dev.DeveloperTools)
			inspector = DeveloperTools.forStandalonePlugin("CollisionGroupsEditor", plugin, {
				rootInstance = Window,
				rootPrefix = {"CollisionGroupEditorGui"}
			})
		end
		if FFlagCGELocalizeWindowTitle then
			RoactHandle = Roact.mount(
				Roact.createElement(Gui, {
					Window = Window,
					plugin = plugin,
					localization = localization
				}),
				Window,
				"CollisionGroupEditorGui"
			)	
		else
			RoactHandle = Roact.mount(
				Roact.createElement(Gui, {
					Window = Window,
					plugin = plugin
				}),
				Window,
				"CollisionGroupEditorGui"
			)	
		end
		if inspector then
			inspector:addRoactTree("Roact tree", RoactHandle)
		end
	end

	-- in case the window was open when the place started, we
	-- can report that the user started the place with it open
	-- note: I don't know if this works, but it should
	if Window.Enabled then
		reportOpening()
	end
end

-- The CreateDockWidgetPluginGui function is yielding and may not complete before a second
-- event to DataModelSessionStarted is triggered. This debouncer prevents us from triggering
-- redundant logic that will fail in that case.
local handleDMSessionDebounce = false
local function handleDMSession(dmSession)
	if not FFlagCGEDebounceInit then
		handleDMSessionDebounced(dmSession)
		return
	end

	if handleDMSessionDebounce then
		return
	end
	handleDMSessionDebounce = true
	local success, err = pcall(handleDMSessionDebounced, dmSession)
	handleDMSessionDebounce = false
	if not success then
		error(err)
	end
end

-- Lurk: wait until we create DM session before creating UI.
plugin.MultipleDocumentInterfaceInstance.DataModelSessionStarted:connect(function(dmSession)
	handleDMSession(dmSession)
end)

if (FFlagSupportPluginDebugging) then 	
	-- Usually standalone plugin scripts are loaded before we've created any place session, 
	-- so listening for "new place session" from MultipleDocumentInterfaceInstance is sufficient.
	-- With the advent of plugin debugging, we load standalone plugins again each time we open 
	-- a place.  So we have a situation where MultipleDocumentInterfaceInstance already has a 
	-- place session before plugin is loaded -> DataModelSessionStarted will never hit.
	-- So we have to explicitly check if we already have a DM session.
	if (plugin.MultipleDocumentInterfaceInstance.FocusedDataModelSession) then 
		handleDMSession(plugin.MultipleDocumentInterfaceInstance.FocusedDataModelSession)
	end
end

local function destroyWindow()
	if (Window ~= nil) then 
		Roact.unmount(RoactHandle)
		RoactHandle = nil
		Window:Destroy()
		Window = nil
		if inspector then
			inspector:destroy()
		end
	end
end

if FFlagEnableRoactInspector then
	plugin.Unloading:connect(destroyWindow)
end

-- If place session ends and we have a gui, destroy it.
plugin.MultipleDocumentInterfaceInstance.DataModelSessionEnded:connect(destroyWindow)

function onClicked()
	-- Theoretically not possible, the button isn't available to users unless 
	-- place session has started, at which point we have a Window.
	-- Still, just to be safe, check for Window == nil.
	if (Window == nil) then 
		return
	end

	Window.Enabled = not Window.Enabled
	if (Window.Enabled) then 
		-- Reasonable time to update view.
		plugin:Invoke("WindowEnabled", "true")
	end

	-- report an opening if we were just opened
	if Window.Enabled then
		reportOpening()
	end
end
Button.Click:Connect(onClicked)

