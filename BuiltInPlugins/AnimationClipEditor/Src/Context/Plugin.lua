local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Roact)
local Symbol = require(Plugin.Roact.Symbol)
local pluginKey = Symbol.named("Plugin")

local PluginProvider = Roact.PureComponent:extend("PluginProvider")
function PluginProvider:init()
	local plugin = self.props.plugin
	assert(plugin ~= nil, "No plugin was given to this PluginProvider.")

	self._context[pluginKey] = plugin
end
function PluginProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

-- Gets the plugin at the passed in component's context.
local function getPlugin(component)
	assert(component._context[pluginKey] ~= nil, "No PluginProvider found.")
	local plugin = component._context[pluginKey]
	return plugin
end

return {
	Provider = PluginProvider,
	getPlugin = getPlugin,
}