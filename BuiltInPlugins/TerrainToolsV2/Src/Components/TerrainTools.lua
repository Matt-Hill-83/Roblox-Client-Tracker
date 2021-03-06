game:DefineFastFlag("TerrainToolsFixPluginActivationOnWidgetOpen", false)

local FFlagTerrainToolsFixPluginActivationOnWidgetOpen = game:GetFastFlag("TerrainToolsFixPluginActivationOnWidgetOpen")

local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local Roact = require(Plugin.Packages.Roact)

local ContextServices = Framework.ContextServices

local StudioUI = Framework.StudioUI
local DockWidget = StudioUI.DockWidget
local PluginToolbar = StudioUI.PluginToolbar
local PluginButton = StudioUI.PluginButton

local Manager = require(Plugin.Src.Components.Manager)
local ToolSelectionListener = require(Plugin.Src.Components.ToolSelectionListener)

local Constants = require(Plugin.Src.Util.Constants)

local EDITOR_META_NAME = "Editor"
local TOOLBAR_NAME = "TerrainToolsLuaToolbarName"

local INITIAL_WIDGET_SIZE = Vector2.new(300, 600)

local ABTEST_SHOWHIDEV2_NAME = "AllUsers.RobloxStudio.ShowHideV2"
local FFlagStudioShowHideABTestV2 = game:GetFastFlag("StudioShowHideABTestV2")

local TerrainTools = Roact.PureComponent:extend("TerrainTools")

function TerrainTools:init()
	local initiallyEnabled = true

	if FFlagStudioShowHideABTestV2 then
		local variation = Framework.Util.getTestVariation(ABTEST_SHOWHIDEV2_NAME)
		if variation == 2 then
			initiallyEnabled = false
		end
	end

	self.state = {
		enabled = initiallyEnabled,
	}

	self.toggleEnabled = function()
		self:setState(function(state)
			local newEnabled = not state.enabled
			self:sendWindowEnabledAnalytics(newEnabled)
			return {
				enabled = newEnabled,
			}
		end)
	end

	self.onClose = function()
		local initiatedByUser = true
		self:setEnabled(false, initiatedByUser)
	end

	self.onRestore = function(enabled)
		local initiatedByUser = false
		self:setEnabled(enabled, initiatedByUser)
	end

	self.onWidgetEnabledChanged = function(widget)
		local initiatedByUser = true
		self:setEnabled(widget.Enabled, initiatedByUser)
	end

	self.onFocused = function()
		self.props.pluginActivationController:restoreSelectedTool()
	end

	self.renderButtons = function(toolbar)
		local enabled = self.state.enabled

		return {
			Toggle = Roact.createElement(PluginButton, {
				Toolbar = toolbar,
				Active = enabled,

				Title = EDITOR_META_NAME,
				Tooltip = self.props.localization:get():getText("Main", "PluginButtonEditorTooltip"),
				Icon = "rbxasset://textures/TerrainTools/icon_terrain_big.png",

				OnClick = self.toggleEnabled,
			}),
		}
	end
end

function TerrainTools:sendWindowEnabledAnalytics(enabled)
	if not self.props.analytics then
		return
	end
	self.props.analytics:report("toggleWidget")
	self.props.analytics:report(enabled and "openWidget" or "closeWidget")
end

function TerrainTools:setEnabled(newEnabled, initiatedByUser)
	self:setState(function(state)
		if state.enabled == newEnabled then
			return nil
		end

		if initiatedByUser then
			self:sendWindowEnabledAnalytics(newEnabled)
		end

		return {
			enabled = newEnabled,
		}
	end)
end

function TerrainTools:didUpdate(prevProps, prevState)
	if FFlagTerrainToolsFixPluginActivationOnWidgetOpen then
		if prevState.enabled ~= self.state.enabled then
			if self.state.enabled then
				self.props.pluginActivationController:restoreSelectedTool()
			else
				self.props.pluginActivationController:pauseActivatedTool()
			end
		end
	else
		-- Pause the tool when hiding the dock widget
		if prevState.enabled ~= self.state.enabled and not self.state.enabled then
			self.props.pluginActivationController:pauseActivatedTool()
		end
	end
end

function TerrainTools:render()
	local enabled = self.state.enabled

	local plugin = self.props.plugin
	local mouse = self.props.mouse
	local store = self.props.store

	local theme = self.props.theme
	local devFrameworkThemeItem = self.props.devFrameworkThemeItem
	local localization = self.props.localization
	local analytics = self.props.analytics

	local terrain = self.props.terrain

	local pluginActivationController = self.props.pluginActivationController
	local terrainImporter = self.props.terrainImporter
	local terrainGeneration = self.props.terrainGeneration
	local seaLevel = self.props.seaLevel
	local partConverter = self.props.partConverter

	local imageLoader = self.props.imageLoader

	local calloutController = self.props.calloutController

	return ContextServices.provide({
		plugin,
		mouse,
		store,
		theme,
		devFrameworkThemeItem,
		localization,
		analytics,
		terrain,
		pluginActivationController,
		terrainImporter,
		terrainGeneration,
		seaLevel,
		-- partConverter will be nil if FFlagTerrainToolsConvertPartTool is false
		partConverter,
		-- imageLoader will be nil if FFlagTerrainToolsHeightmapUseLoadingImage is false
		imageLoader,
		-- calloutController will be nil if FFlagTerrainToolsColormapCallout is false
		calloutController,
	}, {
		Toolbar = Roact.createElement(PluginToolbar, {
			Title = TOOLBAR_NAME,
			RenderButtons = self.renderButtons,
		}),

		TerrainTools = Roact.createElement(DockWidget, {
			Title = localization:get():getText("Main", "Title"),
			Enabled = enabled,

			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			InitialDockState = Enum.InitialDockState.Left,
			Size = INITIAL_WIDGET_SIZE,
			MinSize = Constants.MIN_WIDGET_SIZE,

			OnClose = self.onClose,

			ShouldRestore = true,
			OnWidgetRestored = self.onRestore,
			OnWidgetFocused = self.onFocused,

			[Roact.Change.Enabled] = self.onWidgetEnabledChanged,
		}, enabled and {
			UIManager = Roact.createElement(Manager),
			ToolSelectionListener = Roact.createElement(ToolSelectionListener),
		} or nil),
	})
end

return TerrainTools
