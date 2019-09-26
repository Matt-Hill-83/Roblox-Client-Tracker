local HttpService = game:GetService("HttpService")

local Plugin = script.Parent.Parent.Parent.Parent
local Promise = require(Plugin.Packages.Promise)

local GameToPublish = require(Plugin.Src.Network.Models.GameToPublish)
local Http = require(Plugin.Src.Network.Http)

local FETCH_GAMES_URL = "v2/groups/%d/games"
local FETCH_GAMES_TYPE = "games"

return function(searchArguments, optionalSettings)
	local groupId = searchArguments.groupId
	if not groupId then
		return Promise.reject("NO GROUP ID - ApiFetchGamesByGroupId")
	end
	local limit = optionalSettings.limit or 10
	local sortOrder = optionalSettings.sortOrder or "Desc"
	local cursor = optionalSettings.cursor

	local requestInfo = {
		Url = Http.BuildRobloxUrl(FETCH_GAMES_TYPE, FETCH_GAMES_URL, groupId),
		Method = "GET",
		Params = {
			limit = limit,
			sortOrder = sortOrder,
			cursor = cursor,
		},
	}
	return Http.Request(requestInfo):andThen(function(jsonResult)
		local result = HttpService:JSONDecode(jsonResult)

		local page = {}
		if result.previousPageCursor then
			page.previousPageCursor = result.previousPageCursor
		end
		if result.nextPageCursor then
			page.nextPageCursor = result.nextPageCursor
		end

		page.games = {}
		for _, gameToPublish in pairs(result.data) do
			local ok, val = GameToPublish.fromJsonData(gameToPublish)
			if ok then
				table.insert(page.games, val)
			else
				error("Parsing error for ApiFetchGamesByGroupId: " .. val)
			end
		end
		return page
	end)
end