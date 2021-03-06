local Plugin = script.Parent.Parent.Parent.Parent
local Cryo = require(Plugin.Libs.Cryo)
local RobloxAPI = require(Plugin.Libs.Framework).RobloxAPI

local Category = require(Plugin.Core.Types.Category)
local RequestReason = require(Plugin.Core.Types.RequestReason)

local UpdatePageInfoAndSendRequest = require(Plugin.Core.Networking.Requests.UpdatePageInfoAndSendRequest)

local ClearAssets = require(Plugin.Core.Actions.ClearAssets)
local SetLiveSearch = require(Plugin.Core.Actions.SetLiveSearch)
local SetLoading = require(Plugin.Core.Actions.SetLoading)
local StopPreviewSound = require(Plugin.Core.Actions.StopPreviewSound)

local Analytics = require(Plugin.Core.Util.Analytics.Analytics)
local CreatorInfoHelper = require(Plugin.Core.Util.CreatorInfoHelper)

local FFlagToolboxShowRobloxCreatedAssetsForLuobu = game:GetFastFlag("ToolboxShowRobloxCreatedAssetsForLuobu")
local FFlagFixCreatorTypeParameterForAssetRequest = game:DefineFastFlag("FixCreatorTypeParameterForAssetRequest", false)

local function searchUsers(networkInterface, searchTerm, store)
	return networkInterface:getUsers(searchTerm, 1):andThen(function(result)
		local data = result.responseBody
		if data then
			local userSearchResults = data.UserSearchResults
			if userSearchResults and #userSearchResults > 0 then
				local info = userSearchResults[1]
				return {
					Name = info.Name,
					Id = info.UserId,
					Type = FFlagFixCreatorTypeParameterForAssetRequest and CreatorInfoHelper.clientToBackend(Enum.CreatorType.User.Value) or Enum.CreatorType.User.Value,
				}
			end
		end

		return {
			Name = searchTerm,
			Id = -1,
			Type = FFlagFixCreatorTypeParameterForAssetRequest and CreatorInfoHelper.clientToBackend(Enum.CreatorType.User.Value) or Enum.CreatorType.User.Value,
		}
	end)
end

return function(networkInterface, settings, options)
	return function(store)
		store:dispatch(SetLoading(true))
		store:dispatch(ClearAssets())

		local audioSearchInfo = options.AudioSearch or Cryo.None

		local sound = store:getState().sound
		if sound ~= nil and sound.isPlaying then
			store:dispatch(StopPreviewSound())
		end

		if options.Creator and options.Creator ~= "" then
			searchUsers(networkInterface, options.Creator, store):andThen(
				function(results)
					store:dispatch(SetLoading(false))
					store:dispatch(UpdatePageInfoAndSendRequest(networkInterface, settings, {
						audioSearchInfo = audioSearchInfo,
						targetPage = 1,
						currentPage = 0,
						creator = results,
						sortIndex = options.SortIndex or 1, -- defualt to 1
						requestReason = RequestReason.StartSearch,
					}))

					Analytics.onCreatorSearched(options.Creator, results.Id)
				end,
				function(err)
					-- We should still handle the error if searchUser fails.
				end)

		else
			local creator = Cryo.None
			if FFlagToolboxShowRobloxCreatedAssetsForLuobu and RobloxAPI:baseURLHasChineseHost() then
				local currentTab = store:getState().pageInfo.currentTab
				if currentTab == Category.MARKETPLACE_KEY then
					creator = Category.CREATOR_ROBLOX
				end
			end

			store:dispatch(SetLoading(false))
			store:dispatch(SetLiveSearch("", {}))
			store:dispatch(UpdatePageInfoAndSendRequest(networkInterface, settings, {
				audioSearchInfo = audioSearchInfo,
				targetPage = 1,
				currentPage = 0,
				sortIndex = options.SortIndex or 1, -- defualt to 1
				creator = creator,
				requestReason = RequestReason.StartSearch,
			}))
		end
	end
end
