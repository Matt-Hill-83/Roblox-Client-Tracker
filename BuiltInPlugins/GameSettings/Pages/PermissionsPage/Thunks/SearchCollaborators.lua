--[[
	Asynchronously loads the local user's friends/groups when they search
	Also loads the web search results for the search query
]]

local Page = script.Parent.Parent

local CollaboratorSearchActions = require(Page.Actions.CollaboratorSearchActions)

local FFlagStudioUXImprovementsLoosenTCPermissions = game:GetFastFlag("StudioUXImprovementsLoosenTCPermissions")

return function(searchText, requestSearch)
	return function(store, contextItems)
		local state = store:getState()

		local gamePermissionsController = contextItems.gamePermissionsController

		store:dispatch(CollaboratorSearchActions.SearchTextChanged(searchText))
		if searchText == "" or not requestSearch then return end

		if not state.CollaboratorSearch.CachedSearchResults[searchText] then
			store:dispatch(CollaboratorSearchActions.LoadingWebResults(searchText))
			spawn(function()
				local success, webResults = pcall(function()
					if FFlagStudioUXImprovementsLoosenTCPermissions then
						return gamePermissionsController:search(searchText)
					else
						return gamePermissionsController:searchUsers(searchText)
					end
				end)
				store:dispatch(CollaboratorSearchActions.LoadedWebResults(success, searchText, webResults))
			end)
		end
	end
end