local CoreGui = game:GetService("CoreGui")

local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local FFlagTopBarUseNewIcons = require(RobloxGui.Modules.Flags.FFlagTopBarUseNewIcons)

return {
	TopBarHeight = 36,
	TopBarHeightTenFoot = 72,

	ScreenSideOffset = FFlagTopBarUseNewIcons and 16 or 14,
	ScreenSideOffsetTenFoot = 48,

	Padding = FFlagTopBarUseNewIcons and 12 or 16,

	HealthPercentForOverlay = 5 / 100,
	HealthRedColor = Color3.fromRGB(255, 28, 0),
	HealthYellowColor = Color3.fromRGB(250, 235, 0),
	HealthGreenColor = Color3.fromRGB(27, 252, 107),

	InputType = {
		MouseAndKeyBoard = "MouseAndKeyboard",
		Touch = "Touch",
		Gamepad = "Gamepad",
	},
}