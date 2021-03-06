--[[
	Used to set the playhead's location.
	Accepts an integer for the frame to
	set the playhead's location to.
]]

local Action = require(script.Parent.Action)

return Action(script.Name, function(scroll, zoom)
	return {
		scroll = scroll,
		zoom = zoom,
	}
end)