local Page = script.Parent.Parent
local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)

local ContextServices = require(Plugin.Framework.ContextServices)

local PermissionsConstants = require(Page.Util.PermissionsConstants)

local UserHeadshotThumbnail = require(Plugin.Src.Components.AutoThumbnails.UserHeadshotThumbnail)
local CollaboratorItem = require(Page.Components.CollaboratorItem)

local IsUserOwner = require(Page.Selectors.IsUserOwner)
local IsUserCreatorFriend = require(Page.Selectors.IsUserCreatorFriend)
local CanUserAddCollaborators = require(Page.Selectors.CanUserAddCollaborators)
local GetUserName = require(Page.Selectors.GetUserName)
local GetUserPermission = require(Page.Selectors.GetUserPermission)
local SetUserPermission = require(Page.Thunks.SetUserPermission)
local RemoveUserCollaborator = require(Page.Thunks.RemoveUserCollaborator)

local UserCollaboratorItem = Roact.PureComponent:extend("UserCollaboratorItem")

local FFlagUXImprovementsNonTCPlacesAllowedPlay = game:GetFastFlag("UXImprovementsNonTCPlacesAllowedPlay")

local permShortName = {
	[PermissionsConstants.OwnerKey] = "Owner",
	[PermissionsConstants.PlayKey] = "Play",
	[PermissionsConstants.EditKey] = "Edit",
	[PermissionsConstants.NoAccessKey] = "NoAccess",
	[PermissionsConstants.AdminKey] = "Admin"
}

function UserCollaboratorItem:getPermissionForKey(key)
	local props = self.props
	local localization = props.Localization

	if not permShortName[key] then
		-- unrecognized permission
		return { Key = key, Display = tostring(key), Description = "Error: This permission is not recognized." }
	end

	return {
		Key = key,
		Display = localization:getText("AccessPermissions", permShortName[key] .. "Label"),
		Description = localization:getText("AccessPermissions", permShortName[key] .. "Description"),
	}
end

function UserCollaboratorItem:getAvailablePermissions()
	local props = self.props

	local isOwner = props.IsOwner
	local isOwnerFriend = props.IsOwnerFriend
	local canUserAddCollaborators = FFlagUXImprovementsNonTCPlacesAllowedPlay and props.CanUserAddCollaborators
	local ownerType = props.OwnerType

	local localization = props.Localization

	local editable = props.Editable

	if isOwner then
		return {self:getPermissionForKey(PermissionsConstants.OwnerKey),}
	elseif not editable then
		-- if not editable, just show current permission
		return {self:getPermissionForKey(self:getCurrentPermission()),}
	else
		local permissions = {self:getPermissionForKey(PermissionsConstants.PlayKey)}

		if (ownerType == Enum.CreatorType.User and isOwnerFriend and (not FFlagUXImprovementsNonTCPlacesAllowedPlay or canUserAddCollaborators)) then
			table.insert(permissions, self:getPermissionForKey(PermissionsConstants.EditKey))
		end

		return permissions
	end
end

function UserCollaboratorItem:getCurrentPermission()
	local props = self.props

	local isOwner = props.IsOwner

	local currentPermission = props.CurrentPermission

	if isOwner then
		return PermissionsConstants.OwnerKey
	else
		return currentPermission
	end
end

function UserCollaboratorItem:render()
	local props = self.props

	local layoutOrder = props.LayoutOrder

	local id = props.Id
	local writable = props.Writable

	local name = props.UserName
	local isOwner = props.IsOwner

	local setUserPermission = props.SetUserPermission
	local removeUserCollaborator = props.RemoveUserCollaborator

	return Roact.createElement(CollaboratorItem, {
		LayoutOrder = layoutOrder,

		Name = name,
		Icon = Roact.createElement(UserHeadshotThumbnail, {
			Id = id,
			Size = UDim2.fromScale(1, 1),
		}),

		Writable = writable and not isOwner,
		Loading = false,

		Removable = not isOwner,
		OnRemoved = function()
			removeUserCollaborator(id)
		end,

		CurrentPermission = self:getCurrentPermission(),
		AvailablePermissions = self:getAvailablePermissions(),
		OnPermissionChanged = function(newPermission)
			setUserPermission(id, newPermission)
		end,
	})
end

ContextServices.mapToProps(UserCollaboratorItem, {
	Localization = ContextServices.Localization,
})

UserCollaboratorItem = RoactRodux.connect(
	function(state, props)
		return {
			OwnerType = state.GameOwnerMetadata.creatorType,

			IsOwner = IsUserOwner(state, props.Id),
			IsOwnerFriend = IsUserCreatorFriend(state, props.Id),
			CanUserAddCollaborators = FFlagUXImprovementsNonTCPlacesAllowedPlay and CanUserAddCollaborators(),
			UserName = GetUserName(state, props.Id),
			CurrentPermission = GetUserPermission(state, props.Id),
		}
	end,
	function(dispatch)
		return {
			SetUserPermission = function(...)
				dispatch(SetUserPermission(...))
			end,
			RemoveUserCollaborator = function(...)
				dispatch(RemoveUserCollaborator(...))
			end,
		}
	end
)(UserCollaboratorItem)

return UserCollaboratorItem
