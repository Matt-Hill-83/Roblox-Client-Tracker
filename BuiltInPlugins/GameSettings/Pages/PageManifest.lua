local FFlagQ220PermissionsSettings = settings():GetFFlag("Q220PermissionsSettings")
local FFlagGameSettingsPlaceSettings = game:GetFastFlag("GameSettingsPlaceSettings")

local Permissions = require(script.Parent.PermissionsPage.Permissions)
local Avatar = require(script.Parent.AvatarPage.Avatar)
local BasicInfo = require(script.Parent.BasicInfoPage.BasicInfo)
local Monetization = require(script.Parent.MonetizationPage.Monetization)
local Options = require(script.Parent.OptionsPage.Options)
local Places = require(script.Parent.PlacesPage.Places)
local Security = require(script.Parent.SecurityPage.Security)
local World = require(script.Parent.WorldPage.World)
local LocalizationPage = require(script.Parent.LocalizationPage.LocalizationPage)

local pages = {
	BasicInfo,
	Permissions,
	Avatar,
	World,
	Options,
}

table.insert(pages, 3, Monetization)

if FFlagGameSettingsPlaceSettings then
	table.insert(pages, 4, Places)
end

if FFlagQ220PermissionsSettings then
	table.insert(pages, 4, Security)
end

table.insert(pages, 5, LocalizationPage)

return pages
