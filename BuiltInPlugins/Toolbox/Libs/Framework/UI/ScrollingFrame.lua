--[[
	A scrolling frame with a colored background, providing a consistent look
	with the native Studio Start Page.

	Optional Props:
		callback OnScrollUpdate: A callback function that will update the index change.
		UDim2 Position: The position of the scrolling frame.
		UDim2 Size: The size of the scrolling frame.
		integer LayoutOrder: The order this component will display in a UILayout.
		boolean AutoSizeCanvas: When true, will automatically resize the canvas size of the scrolling frame.
		Enum.ScrollingDirection ScrollingDirection: The direction to scroll in (default = XY)
		Enum.AutomaticSize AutomaticCanvasSize: The automatic size of the scrolling frame canvas.
		callback OnCanvasResize: Called when content size is updated. Only called when AutoSizeCanvas is true.
			OnCanvasResize(absSize: Vector2)
		table AutoSizeLayoutOptions: The options of the UILayout instance if auto-sizing.
		UDim2 CanvasSize: The size of the scrolling frame's canvas.
		integer ElementPadding: The padding between children when AutoSizeCanvas is true.
		boolean ScrollingEnabled: Whether scrolling in this frame will change the CanvasPosition.
		Style Style: a style table supplied from props and theme:getStyle()
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps
		Theme Theme: the theme supplied from mapToProps()

	Style Values:
		string BottomImage: The image that appears in the bottom 3rd of the scrollbar
		string MidImage: The image that appears in the middle 3rd of the scrollbar
		string TopImage: The image that appears in the top 3rd of the scrollbar
		UDim2 CanvasSize: The size of the scrolling frame's canvas.
		integer ScrollBarPadding: The padding which appears on either side of the scrollbar.
		integer ScrollBarThickness: The horizontal width of the scrollbar.
		integer ZIndex: The draw index of the frame.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local FlagsList = Util.Flags.new({
	FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
	FFlagFixContentNotFullyShownAfterResize = {"FixContentNotFullyShownAfterResize"},
})
local Cryo
local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)
if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() then
	Cryo = require(Framework.Parent.Cryo)
else
	local Packages = Framework.packages
	Cryo = require(Packages.Cryo)
end

local FFlagEnableDevFrameworkAutomaticSize = ("EnableDevFrameworkAutomaticSize")

local ContextServices = require(Framework.ContextServices)
local Container = require(script.Parent.Container)
local prioritize = Util.prioritize
local Typecheck = Util.Typecheck

local ScrollingFrame = Roact.PureComponent:extend("ScrollingFrame")
Typecheck.wrap(ScrollingFrame, script)

local function getStyle(self)
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end
	return style
end

function ScrollingFrame:init()
	self.scrollingRef = Roact.createRef()
	self.layoutRef = Roact.createRef()

	self.onScroll = function(rbx)
		if self.props.OnScrollUpdate then
			self.props.OnScrollUpdate(rbx.CanvasPosition)
		end
	end

	self.updateCanvasSize = function(rbx)
		local hasAutomaticSize = FFlagEnableDevFrameworkAutomaticSize and self.props.AutomaticCanvasSize
		if self.scrollingRef.current and self.layoutRef.current then
			local contentSize = self.layoutRef.current.AbsoluteContentSize
			local contentSizeX = contentSize.X
			local contentSizeY = contentSize.Y
			if not hasAutomaticSize then
				if FlagsList:get("FFlagFixContentNotFullyShownAfterResize") then
					local props = self.props
					local style = getStyle(self)
					local scrollingFrameProps = self.getScrollingFrameProps(props, style)
					-- for vertical scroll, canvas size on x axis should not update when content size changes
					-- for horizon one, y axis should not change
					-- for both scrolling, canvas size can be fully controlled by content
					if scrollingFrameProps.ScrollingDirection == Enum.ScrollingDirection.Y then
						contentSizeX = 0
					elseif scrollingFrameProps.ScrollingDirection == Enum.ScrollingDirection.X then
						contentSizeY = 0
					end
				end
			end

			self.scrollingRef.current.CanvasSize = UDim2.new(0, contentSizeX, 0, contentSizeY)

			if self.props.OnCanvasResize then
				self.props.OnCanvasResize(Vector2.new(contentSizeX, contentSizeY))
			end
		end
	end

	self.propFilters = {
		parentContainerProps = {
			Position = Cryo.None,
			Size = Cryo.None,
			LayoutOrder = Cryo.None,
			AutoSizeCanvas = Cryo.None,
			AutoSizeLayoutElement = Cryo.None,
			AutoSizeLayoutOptions = Cryo.None,
			OnCanvasResize = Cryo.None,
			Theme = Cryo.None,
			Style = Cryo.None,
			Stylizer = Cryo.None,
			getUILibraryTheme = Cryo.None,
		},
	}

	self.getScrollingFrameProps = function(props, style)
		
		local scaleX = 1
		local scaleY = 1
		if FFlagEnableDevFrameworkAutomaticSize then
			local automaticSize = props.AutomaticCanvasSize
			if automaticSize then
				if automaticSize == Enum.AutomaticSize.X or automaticSize == Enum.AutomaticSize.XY then
					scaleX = 0
				end
				if automaticSize == Enum.AutomaticSize.Y or automaticSize == Enum.AutomaticSize.XY then
					scaleY = 0
				end
			end
		end

		-- after filtering out parent's props and other component specific props,
		-- what is left should be ScrollingFrame specific props
		return Cryo.Dictionary.join(
			style,
			props,
			self.propFilters.parentContainerProps,
			{
				Size = UDim2.fromScale(scaleX, scaleY),
				[Roact.Children] = Cryo.None,
				[Roact.Change.CanvasPosition] = self.onScroll,
				[Roact.Change.AbsoluteSize] = FlagsList:get("FFlagFixContentNotFullyShownAfterResize") and self.updateCanvasSize or nil,
				[Roact.Ref] = self.scrollingRef,
			})
	end
end

function ScrollingFrame:didMount()
	self.updateCanvasSize()
end

function ScrollingFrame:render()
	local props = self.props
	local style = getStyle(self)

	local position = props.Position
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	
	local autoSizeCanvas = prioritize(props.AutoSizeCanvas, style.AutoSizeCanvas, false)
	local autoSizeElement = prioritize(props.AutoSizeLayoutElement, style.AutoSizeLayoutElement, "UIListLayout")
	local layoutOptions = prioritize(props.AutoSizeLayoutOptions, style.AutoSizeLayoutOptions, {})
	
	local automaticSize = props.AutomaticCanvasSize
	if automaticSize then
		autoSizeCanvas = false
	end

	local children = self.props[Roact.Children]
	local scrollingFrameProps = self.getScrollingFrameProps(self.props, style)

	if autoSizeCanvas then
		children = {
			Layout = Roact.createElement(autoSizeElement, Cryo.Dictionary.join(layoutOptions, {
				[Roact.Change.AbsoluteContentSize] = self.updateCanvasSize,
				[Roact.Ref] = self.layoutRef,
			})),
			Children = Roact.createFragment(children),
		}
	end

	local scrollingFrame = Roact.createElement("ScrollingFrame", scrollingFrameProps, children)

	return Roact.createElement(Container, {
		Position = position,
		Size = size,
		LayoutOrder = layoutOrder,
	}, {
		Scroller = scrollingFrame,
	})
end

ContextServices.mapToProps(ScrollingFrame, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return ScrollingFrame
