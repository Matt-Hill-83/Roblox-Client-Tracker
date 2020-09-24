local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = Plugin.Packages.Framework
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local FitFrameOnAxis = Util.FitFrame.FitFrameOnAxis

local UILibrary = require(Plugin.Packages.UILibrary)
local GetTextSize = UILibrary.Util.GetTextSize
local Tooltip = UILibrary.Component.Tooltip
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator

local SetEditingAssets = require(Plugin.Src.Actions.SetEditingAssets)

local OnAssetDoubleClick = require(Plugin.Src.Thunks.OnAssetDoubleClick)
local OnAssetRightClick = require(Plugin.Src.Thunks.OnAssetRightClick)
local OnAssetSingleClick = require(Plugin.Src.Thunks.OnAssetSingleClick)

local AssetManagerService = game:GetService("AssetManagerService")

local ListItem = Roact.PureComponent:extend("ListItem")

local function stripText(text)
    local newText = string.gsub(text, "%s+", "")
    newText = string.gsub(newText, "\n", "")
    newText = string.gsub(newText, "\t", "")
    return newText
end

function ListItem:init()
    self.state = {
        -- StyleModifier must be upper case first character because of how Theme in ContextServices uses it.
        StyleModifier = nil,
        editText = "",
    }

    self.editing = false

    self.textBoxRef = Roact.createRef()

    self.onMouseEnter = function()
        if self.state.StyleModifier == nil then
            self:setState({
                StyleModifier = StyleModifier.Hover,
            })
        end
    end

    self.onMouseLeave = function()
        if self.state.StyleModifier == StyleModifier.Hover then
            self:setState({
                StyleModifier = Roact.None,
            })
        end
    end

    self.onMouseActivated = function(rbx, obj, clickCount)

    end

    self.onMouseButton2Click = function(rbx, x, y)

    end

    self.onTextChanged = function(rbx)
        local text = rbx.Text
        if text ~= self.props.AssetData.name then
            self:setState({
                editText = text,
            })
        end
	end

	self.onTextBoxFocusLost = function(rbx, enterPressed, inputObject)
        local props = self.props
        local assetData = props.AssetData
        local newName = self.state.editText
        if utf8.len(newName) ~= 0 and utf8.len(stripText(newName)) ~= 0 then
            if assetData.assetType == Enum.AssetType.Place then
                AssetManagerService:RenamePlace(assetData.id, newName)
            elseif assetData.assetType == Enum.AssetType.Image
            or assetData.assetType == Enum.AssetType.MeshPart
            or assetData.assetType == Enum.AssetType.Image then
                local prefix
                -- Setting asset type to same value as Enum.AssetType since it cannot be passed into function
                if assetData.assetType == Enum.AssetType.Image then
                    prefix = "Images/"
                elseif assetData.assetType == Enum.AssetType.MeshPart then
                    prefix = "Meshes/"
                elseif assetData.assetType == Enum.AssetType.Lua then
                    prefix = "Scripts/"
                end
                AssetManagerService:RenameAlias(assetData.assetType.Value, assetData.id, prefix .. assetData.name, prefix .. newName)
            end
            props.AssetData.name = newName
        end
        props.dispatchSetEditingAssets({})
        self.editing = false
        -- force re-render to show updated name
        self:setState({
            editText = props.AssetData.name,
        })
	end
end

function ListItem:didMount()
    self:setState({
        editText = self.props.AssetData.name
    })
end

function ListItem:didUpdate(lastProps, lastState)
    local props = self.props
    local assetData = props.AssetData
    local isEditingAsset = props.EditingAssets[assetData.id]
    if isEditingAsset then
        if self.textBoxRef and self.textBoxRef.current and not self.editing then
            local textBox = self.textBoxRef.current
            textBox:CaptureFocus()
            textBox.SelectionStart = 1
            textBox.CursorPosition = #textBox.Text + 1
            self.editing = true
        end
    end
end

function ListItem:render()
    local props = self.props
    local pluginStyle = props.Theme:get("Plugin")

    -- Must use getStyle(namespace, component) for StyleModifiers to work
    -- otherwise functionality equivalent to prop.Theme:get("Plugin").Tile.Default
    local listItemStyle= props.Theme:getStyle("Plugin", self)

    local enabled = props.Enabled

    local size = listItemStyle.Size

    local assetData = props.AssetData

    local backgroundColor = listItemStyle.BackgroundColor
    local backgroundTransparency = listItemStyle.BackgroundTransparency
    local borderSizePixel = listItemStyle.BorderSizePixel
    local padding = listItemStyle.Padding

    local image = listItemStyle.Image.Folder

    local imageFrameSize = listItemStyle.Image.FrameSize
    local imageSize = listItemStyle.Image.ImageSize
    local imagePos = listItemStyle.Image.ImagePosition
    local imageAnchorPos = listItemStyle.Image.ImageAnchorPosition
    local imageBGColor = listItemStyle.Image.BackgroundColor

    local textColor = listItemStyle.Text.Color
    local textFont = pluginStyle.Font
    local textSize = listItemStyle.Text.Size
    local textBGTransparency = listItemStyle.Text.BackgroundTransparency
    local textTruncate = listItemStyle.Text.TextTruncate
    local textXAlignment = listItemStyle.Text.XAlignment
    local textYAlignment = listItemStyle.Text.YAlignment

    local textFrameSize = listItemStyle.Text.Frame.Size

    local editText = self.state.editText
    local isEditingAsset = props.EditingAssets[assetData.id]
    local editTextWrapped = listItemStyle.EditText.TextWrapped
    local editTextClearOnFocus = listItemStyle.EditText.ClearTextOnFocus
    local editTextXAlignment = listItemStyle.Text.XAlignment

    local editTextFrameBackgroundColor = listItemStyle.EditText.Frame.BackgroundColor
    local editTextFrameBorderColor = listItemStyle.EditText.Frame.BorderColor

    local editTextSize = GetTextSize(editText, textSize, textFont, Vector2.new(listItemStyle.Size.X.Offset, math.huge))

    local name = assetData.name
    local displayName = assetData.name
    local nameSize = GetTextSize(assetData.name, textSize, textFont,
        Vector2.new(textFrameSize.X.Offset, math.huge))
    if nameSize.Y > textFrameSize.Y.Offset then
        -- using hardcoded values for now since tile size is constant
        displayName = string.sub(assetData.name, 1, 12) .. "..." ..
            string.sub(assetData.name, string.len(assetData.name) - 5)
    end

    local layoutOrder = props.LayoutOrder
    local layoutIndex = LayoutOrderIterator.new()

    return Roact.createElement("ImageButton", {
        Size = size,
        BackgroundColor3 = backgroundColor,
        BackgroundTransparency = backgroundTransparency,
        BorderSizePixel = borderSizePixel,

        LayoutOrder = layoutOrder,

        [Roact.Event.Activated] = self.onMouseActivated,
        [Roact.Event.MouseButton2Click] = self.onMouseButton2Click,
        [Roact.Event.MouseEnter] = self.onMouseEnter,
        [Roact.Event.MouseLeave] = self.onMouseLeave,
    }, {
        Roact.createElement(FitFrameOnAxis, {
			BackgroundTransparency = 1,
            axis = FitFrameOnAxis.Axis.Vertical,
            FillDirection = Enum.FillDirection.Horizontal,
            minimumSize = size,
			contentPadding = padding,
		}, {
            ImageFrame = Roact.createElement("Frame", {
                Size = imageFrameSize,
                LayoutOrder = layoutIndex:getNextOrder(),

                BackgroundTransparency = 0,
                BackgroundColor3 = imageBGColor,
                BorderSizePixel = 0,
            },{
                Image = Roact.createElement("ImageLabel", {
                    Size = imageSize,
                    Image = image,
                    Position = imagePos,
                    AnchorPoint = imageAnchorPos,

                    BackgroundTransparency = 1,
                })
            }),

            Name = not isEditingAsset and Roact.createElement("TextLabel", {
                Size = textFrameSize,
                LayoutOrder = layoutIndex:getNextOrder(),

                Text = displayName,
                TextColor3 = textColor,
                Font = textFont,
                TextSize = textSize,

                BackgroundTransparency = textBGTransparency,
                TextXAlignment = textXAlignment,
                TextYAlignment = textYAlignment,
                TextTruncate = textTruncate,
                TextWrapped = true,
            }),

            RenameTextBox = isEditingAsset and Roact.createElement("TextBox",{
                Size = UDim2.new(0, editTextSize.X, 0, editTextSize.Y),
                LayoutOrder = layoutIndex:getNextOrder(),

                BackgroundColor3 = editTextFrameBackgroundColor,
                BorderColor3 = editTextFrameBorderColor,

                Text = editText,
                TextColor3 = textColor,
                Font = textFont,
                TextSize = textSize,

                TextXAlignment = editTextXAlignment,
                TextTruncate = textTruncate,
                TextWrapped = editTextWrapped,
                ClearTextOnFocus = editTextClearOnFocus,

                [Roact.Ref] = self.textBoxRef,

                [Roact.Change.Text] = self.onTextChanged,
                [Roact.Event.FocusLost] = self.onTextBoxFocusLost,
            }),
        }),

        Tooltip = enabled and Roact.createElement(Tooltip, {
            Text = name,
            Enabled = true,
        }),
    })
end

ContextServices.mapToProps(ListItem, {
    Analytics = ContextServices.Analytics,
    API = ContextServices.API,
    Localization = ContextServices.Localization,
    Mouse = ContextServices.Mouse,
    Plugin = ContextServices.Plugin,
    Theme = ContextServices.Theme,
})

local function mapStateToProps(state, props)
    local assetManagerReducer = state.AssetManagerReducer
	return {
        EditingAssets = assetManagerReducer.editingAssets,
        SelectedAssets = assetManagerReducer.selectedAssets,
	}
end

local function mapDispatchToProps(dispatch)
	return {
        dispatchOnAssetDoubleClick = function(analytics, assetData)
            dispatch(OnAssetDoubleClick(analytics, assetData))
        end,
        dispatchOnAssetRightClick = function(analytics, apiImpl, assetData, localization, plugin)
            dispatch(OnAssetRightClick(analytics, apiImpl, assetData, localization, plugin))
        end,
        dispatchOnAssetSingleClick = function(obj, assetData)
            dispatch(OnAssetSingleClick(obj, assetData))
        end,
        dispatchSetEditingAssets = function(editingAssets)
            dispatch(SetEditingAssets(editingAssets))
        end,
    }
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ListItem)