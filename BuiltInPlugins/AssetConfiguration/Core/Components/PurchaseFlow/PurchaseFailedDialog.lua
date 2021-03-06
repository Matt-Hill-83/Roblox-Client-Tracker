--[[
	A dialog to display that a purchase has failed.

	Props:
		string Name = The name of the product to purchase.

		function OnButtonClicked = A callback for when a button is clicked.
			Passes true if the user wants to retry the purchase.
		function OnClose = A callback for when the dialog is closed.
]]

local FFlagToolboxUseDevFrameworkDialogs = game:GetFastFlag("ToolboxUseDevFrameworkDialogs")

local Plugin = script.Parent.Parent.Parent.Parent
local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextServices = require(Libs.Framework).ContextServices
local THEME_REFACTOR = require(Libs.Framework.Util.RefactorFlags).THEME_REFACTOR

local StyledDialog
if FFlagToolboxUseDevFrameworkDialogs then
	local StudioUI = require(Libs.Framework).StudioUI
	StyledDialog = StudioUI.StyledDialog
else
	local UILibrary = require(Libs.UILibrary)
	StyledDialog = UILibrary.Component.StyledDialog
end

local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Constants = require(Plugin.Core.Util.Constants)
local Dialog = Constants.Dialog

local withTheme = ContextHelper.withTheme
local withLocalization = ContextHelper.withLocalization

local PurchaseDialog = Roact.PureComponent:extend("PurchaseDialog")

function PurchaseDialog:render()
	return withLocalization(function(localization, localizedContent)
		if FFlagToolboxUseDevFrameworkDialogs then
			return self:renderContent(nil, localization, localizedContent)
		else
			return withTheme(function(theme)
				return self:renderContent(theme, localization, localizedContent)
			end)
		end
	end)
end

function PurchaseDialog:renderContent(theme, localization, localizedContent)
		local props = self.props
		local onButtonClicked = props.OnButtonClicked
		local onClose = props.OnClose
		local name = props.Name

		if FFlagToolboxUseDevFrameworkDialogs then
			if THEME_REFACTOR then
				theme = self.props.Stylizer
			else
				theme = self.props.Theme:get("Plugin")
			end
		end

		local styledDialogProps
		if FFlagToolboxUseDevFrameworkDialogs then
			styledDialogProps = {
				Title = localizedContent.PurchaseFlow.BuyTitle,
				MinContentSize = Vector2.new(Dialog.PROMPT_SIZE.X.Offset, Dialog.DETAILS_SIZE.Y.Offset),
				Buttons = {
					{Key = false, Text = localizedContent.PurchaseFlow.Cancel},
					{Key = true, Text = localizedContent.PurchaseFlow.Retry, Style = "RoundPrimary"},
				},
				OnButtonPressed = onButtonClicked,
				OnClose = onClose,
			}
		else
			styledDialogProps = {
				Buttons = {
					{Key = false, Text = localizedContent.PurchaseFlow.Cancel},
					{Key = true, Text = localizedContent.PurchaseFlow.Retry, Style = "Primary"},
				},
				OnButtonClicked = onButtonClicked,
				OnClose = onClose,
				Size = Dialog.SIZE,
				Resizable = false,
				BorderPadding = Dialog.BORDER_PADDING,
				ButtonHeight = Dialog.BUTTON_SIZE.Y,
				ButtonWidth = Dialog.BUTTON_SIZE.X,
				ButtonPadding = Dialog.BUTTON_PADDING,
				TextSize = Constants.FONT_SIZE_LARGE,
				Title = localizedContent.PurchaseFlow.BuyTitle,
				Modal = false,
			}
		end

		return Roact.createElement(StyledDialog, styledDialogProps, {
			Header = Roact.createElement("TextLabel", {
				Size = Dialog.HEADER_SIZE,
				BackgroundTransparency = 1,

				Text = localizedContent.PurchaseFlow.FailedHeader,
				TextSize = Constants.FONT_SIZE_TITLE,
				Font = Constants.FONT_BOLD,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = theme.purchaseDialog.promptText,
			}),

			Details = Roact.createElement("TextLabel", {
				Size = Dialog.DETAILS_SIZE,
				Position = Dialog.DETAILS_POSITION,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,

				Text = localization:getPurchaseFailedDetails(name),
				TextSize = Constants.FONT_SIZE_LARGE,
				Font = Constants.FONT,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.purchaseDialog.promptText,
				TextWrapped = true,
			}),
		})
end

if FFlagToolboxUseDevFrameworkDialogs then
	ContextServices.mapToProps(PurchaseDialog, {
		Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
		Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
	})
end

return PurchaseDialog
