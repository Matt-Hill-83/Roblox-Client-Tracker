local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Immutable = require(Modules.Common.Immutable)

local ActionType = require(Modules.LuaChat.ActionType)
local AddUser = require(Modules.LuaApp.Actions.AddUser)
local SetUserIsFriend = require(Modules.LuaApp.Actions.SetUserIsFriend)
local SetUserPresence = require(Modules.LuaApp.Actions.SetUserPresence)
local FetchingUser = require(Modules.LuaChat.Actions.FetchingUser)
local SetUserThumbnail = require(Modules.LuaApp.Actions.SetUserThumbnail)
local UserModel = require(Modules.LuaChat.Models.User)

return function(state, action)
	state = state or {}

	if action.type == AddUser.name then
		local user = action.user
		state = Immutable.Set(state, user.id, user)
	elseif action.type == SetUserIsFriend.name then
		local user = state[action.userId]
		if user then
			local newUser = Immutable.Set(user, "isFriend", action.isFriend)
			state = Immutable.Set(state, user.id, newUser)
		else
			warn("Setting isFriend on user", action.userId, "who doesn't exist yet")
		end
	elseif action.type == SetUserPresence.name then
		local user = state[action.userId]
		if user then
			local newUser = Immutable.JoinDictionaries(user, {
				presence = action.presence,
				lastLocation = action.lastLocation,
			})
			state = Immutable.Set(state, user.id, newUser)
		else
			warn("Setting presence on user", action.userId, "who doesn't exist yet")
		end
	elseif action.type == ActionType.ReceivedUserPresence then
		local user = state[action.userId]
		if user then
			state = Immutable.JoinDictionaries(state, {
				[action.userId] = Immutable.JoinDictionaries(user, {
					presence = action.presence,
					lastLocation = action.lastLocation,
				}),
			})
		end
	elseif action.type == FetchingUser.name then
		local newUser = UserModel.fromData(action.userId, nil, nil)
		newUser.isFetching = true
		state = Immutable.Set(state, action.userId, newUser)
	elseif action.type == SetUserThumbnail.name then
		local user = state[action.userId]
		if user then
			state = Immutable.JoinDictionaries(state, {
				[action.userId] = Immutable.JoinDictionaries(user, {
					thumbnails = Immutable.JoinDictionaries(user.thumbnails, {
						[action.thumbnailType] = Immutable.JoinDictionaries(user.thumbnails[action.thumbnailType] or {}, {
							[action.thumbnailSize] = action.image,
						}),
					}),
				}),
			})
		end
	end

	return state
end