local Plugin = script.Parent.Parent.Parent.Parent

local Actions = Plugin.Core.Actions
local NetworkError = require(Actions.NetworkError)
local SetLoading = require(Actions.SetLoading)

local GetItemDetails = require(Plugin.Core.Networking.Requests.GetItemDetails)
local GetCreatorName = require(Plugin.Core.Networking.Requests.GetCreatorName)

local Util = Plugin.Core.Util
local PagedRequestCursor = require(Util.PagedRequestCursor)
local Constants = require(Util.Constants)
local CreatorInfoHelper = require(Util.CreatorInfoHelper)
local PageInfoHelper = require(Util.PageInfoHelper)

local FFlagToolboxNewResponseFreshChecks = game:GetFastFlag("ToolboxNewResponseFreshChecks")

return function(networkInterface, category, audioSearchInfo, pageInfo, settings, nextPageCursor)
	return function(store)
		store:dispatch(SetLoading(true))

		local creator = pageInfo.creator
		local isCreatorSearchEmpty = creator and creator.Id == -1
		local creatorTargetId = (not isCreatorSearchEmpty) and creator and creator.Id or nil

		local assetStore = store:getState().assets
		local currentCursor = assetStore.currentCursor

		if creator and (not CreatorInfoHelper.isCached(store, creatorTargetId, creator.Type)) then
			store:dispatch(GetCreatorName(networkInterface, creatorTargetId, creator.Type))
		end

		-- Get from API
		if PagedRequestCursor.isNextPageAvailable(currentCursor) then
			local nextPageCursor = currentCursor.nextPageCursor
			local sort = pageInfo.sorts[pageInfo.sortIndex]
			local sortName
			if sort then
				sortName = sort.name
			else
				sortName = sort
			end
			return networkInterface:getToolboxItems(
				category,
				sortName,
				pageInfo.creatorType,
				audioSearchInfo and audioSearchInfo.minDuration or nil,
				audioSearchInfo and audioSearchInfo.maxDuration or nil,
				creatorTargetId,
				pageInfo.searchTerm or "",
				nextPageCursor,
				Constants.TOOLBOX_ITEM_SEARCH_LIMIT
			):andThen(
				function(result)
					if FFlagToolboxNewResponseFreshChecks and PageInfoHelper.isPageInfoStale(pageInfo, store) then
						return
					end
					store:dispatch(SetLoading(false))

					local data = result.responseBody
					local cursor = PagedRequestCursor.createCursor(data)

					if data and data.totalResults > 0 then
						store:dispatch(GetItemDetails(
							networkInterface,
							data.data,
							data.totalResults,
							audioSearchInfo,
							pageInfo.targetPage,
							cursor,
							pageInfo
						))
					end
				end,
				function(err)
					store:dispatch(SetLoading(false))
					store:dispatch(NetworkError(err))
				end
			)
		end
	end
end