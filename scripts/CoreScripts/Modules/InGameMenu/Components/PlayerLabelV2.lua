local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local UIBlox = InGameMenuDependencies.UIBlox
local Cryo = InGameMenuDependencies.Cryo
local t = InGameMenuDependencies.t

local withStyle = UIBlox.Core.Style.withStyle

local InGameMenu = script.Parent.Parent

local ThemedTextLabel = require(InGameMenu.Components.ThemedTextLabel)

local ImageSetLabel = UIBlox.Core.ImageSet.Label

local CONTAINER_FRAME_HEIGHT = 71
local PLAYER_ICON_SIZE = 56
local PLAYER_ICON_PADDING_LEFT = 24
local USERNAME_WIDTH = 219
local USERNAME_HEIGHT = 22
local USERNAME_LEFT_PADDING = 24
local USERNAME_TOP_PADDING = 14
local USERNAME_X_OFFSET = PLAYER_ICON_PADDING_LEFT + PLAYER_ICON_SIZE + USERNAME_LEFT_PADDING

local BUTTONS_RIGHT_PADDING = 24
local BUTTONS_PADDING = 12

local iconPos = {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, PLAYER_ICON_PADDING_LEFT, 1, 1),
	Size = UDim2.new(0, PLAYER_ICON_SIZE, 0, PLAYER_ICON_SIZE),
}

local PlayerLabel = Roact.PureComponent:extend("PlayerLabelV2")

PlayerLabel.validateProps = t.strictInterface({
	userId = t.number,
	username = t.string,
	displayName = t.string,
	isOnline = t.boolean,
	isSelected = t.boolean,
	LayoutOrder = t.integer,
	Visible = t.optional(t.boolean),

	onActivated = t.optional(t.callback),

	[Roact.Children] = t.optional(t.table),
	[Roact.Change.AbsolutePosition] = t.optional(t.callback),
	[Roact.Ref] = t.optional(t.callback),
})

PlayerLabel.defaultProps = {
	Visible = true,
}

function PlayerLabel:renderButtons()
	local children = self.props[Roact.Children] or {}
	local buttons = Cryo.Dictionary.join(children, {
		List = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, BUTTONS_PADDING)
		})
	})

	return buttons
end

function PlayerLabel:render()
	local props = self.props

	return withStyle(function(style)
		local backgroundStyle = style.Theme.BackgroundContrast
		if self.props.isSelected then
			backgroundStyle = style.Theme.BackgroundOnHover
		end

		return Roact.createElement("TextButton", {
			BackgroundTransparency = backgroundStyle.Transparency,
			BackgroundColor3 = backgroundStyle.Color,
			BorderSizePixel = 0,
			LayoutOrder = props.LayoutOrder,
			Size = UDim2.new(1, 0, 0, CONTAINER_FRAME_HEIGHT),
			Visible = props.Visible,
			Text = "",
			AutoButtonColor = false,

			[Roact.Event.Activated] = self.props.onActivated,
			[Roact.Change.AbsolutePosition] = self.props[Roact.Change.AbsolutePosition],
			[Roact.Ref] = self.props[Roact.Ref],
		}, {
			PlayerIcon = Roact.createElement(ImageSetLabel, Cryo.Dictionary.join(iconPos, {
				ImageColor3 = props.isOnline and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(115, 115, 115),
				BackgroundTransparency = 1,
				Image = props.userId > 0 and "rbxthumb://type=AvatarHeadShot&id=" ..props.userId.. "&w=60&h=60" or "",
				ZIndex = 2,
			})),
			DisplayNameLabel = Roact.createElement(ThemedTextLabel, {
				fontKey = "Header2",
				themeKey = "TextEmphasis",

				Position = UDim2.new(0, USERNAME_X_OFFSET, 0, USERNAME_TOP_PADDING),
				Size = UDim2.new(0, USERNAME_WIDTH, 0, USERNAME_HEIGHT),
				Text = props.displayName ~= "" and props.displayName or props.username,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),

			UsernameLabel = Roact.createElement(ThemedTextLabel, {
				fontKey = "Header2",
				themeKey = "TextDefault",

				Position = UDim2.new(0, USERNAME_X_OFFSET, 0, USERNAME_TOP_PADDING + USERNAME_HEIGHT),
				Size = UDim2.new(0, USERNAME_WIDTH, 0, USERNAME_HEIGHT),
				Text = "@" .. props.username,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),

			ButtonContainer = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -BUTTONS_RIGHT_PADDING, 0, 0),
				Size = UDim2.new(0, 0, 1, 0),
			}, self:renderButtons())
		})
	end)
end

return PlayerLabel