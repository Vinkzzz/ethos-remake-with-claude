--[[
    Ethos UI Library — Components Module
    All reusable UI primitives built with Fusion 0.3.
    Every component receives a `scope` (Fusion scope) and returns
    a Roblox Instance (already parented to nil — caller parents it).
--]]

local Components = {}

-- These will be injected by main.lua after Fusion is loaded
local Fusion, Theme, Scope

function Components.init(fusionLib, themeLib, rootScope)
    Fusion  = fusionLib
    Theme   = themeLib
    Scope   = rootScope
end

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function New(className)
    return function(props)
        return Fusion.New(Scope, className)(props)
    end
end

local function Spring(goal, config)
    config = config or Theme.Springs.Responsive
    return Fusion.Spring(Scope, goal, config.stiffness, config.dampingRatio)
end

local function Tween(goal, info)
    info = info or Theme.Tweens.Base
    return Fusion.Tween(Scope, goal, info)
end

local function Value(initial)
    return Fusion.Value(Scope, initial)
end

local function Computed(fn)
    return Fusion.Computed(Scope, fn)
end

local function Observer(state, fn)
    return Fusion.Observer(Scope, state):onChange(fn)
end

-- Convenience: create UICorner
local function Corner(radius)
    return New("UICorner") { CornerRadius = radius or Theme.Radius.Base }
end

-- UIStroke convenience
local function Stroke(color, thickness, transparency)
    return New("UIStroke") {
        Color           = color or Theme.Colors.SurfaceBorder,
        Thickness       = thickness or 1,
        Transparency    = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }
end

-- Dropshadow via nested ImageLabel trick
local function DropShadow(parent, radius, opacity)
    opacity = opacity or 0.6
    return New("ImageLabel") {
        Name                = "DropShadow",
        Parent              = parent,
        AnchorPoint         = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position            = UDim2.fromScale(0.5, 0.5),
        Size                = UDim2.new(1, 24, 1, 24),
        ZIndex              = -1,
        Image               = "rbxassetid://6014261993",   -- standard roblox rounded shadow sheet
        ImageColor3         = Theme.Colors.Shadow,
        ImageTransparency   = 1 - opacity,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = Rect.new(49, 49, 450, 450),
    }
end

-- ─── Padding helper ──────────────────────────────────────────────────────────

local function Padding(all, horizontal, vertical)
    if all then
        return New("UIPadding") {
            PaddingLeft   = UDim.new(0, all),
            PaddingRight  = UDim.new(0, all),
            PaddingTop    = UDim.new(0, all),
            PaddingBottom = UDim.new(0, all),
        }
    end
    horizontal = horizontal or 0
    vertical   = vertical   or 0
    return New("UIPadding") {
        PaddingLeft   = UDim.new(0, horizontal),
        PaddingRight  = UDim.new(0, horizontal),
        PaddingTop    = UDim.new(0, vertical),
        PaddingBottom = UDim.new(0, vertical),
    }
end

-- ─── List Layout ─────────────────────────────────────────────────────────────

local function ListLayout(dir, pad, ha, va)
    return New("UIListLayout") {
        FillDirection   = dir or Enum.FillDirection.Vertical,
        Padding         = UDim.new(0, pad or 0),
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Top,
        SortOrder       = Enum.SortOrder.LayoutOrder,
    }
end

-- ─── GridLayout ──────────────────────────────────────────────────────────────

local function GridLayout(cellSize, cellPadding)
    return New("UIGridLayout") {
        CellSize        = cellSize  or UDim2.fromOffset(120, 32),
        CellPaddingX    = UDim.new(0, cellPadding or 6),
        CellPaddingY    = UDim.new(0, cellPadding or 6),
        SortOrder       = Enum.SortOrder.LayoutOrder,
    }
end

-- ─── Components.Label ────────────────────────────────────────────────────────

function Components.Label(props)
    return New("TextLabel") {
        BackgroundTransparency = 1,
        TextColor3  = props.Color    or Theme.Colors.TextPrimary,
        Font        = props.Font     or Theme.Fonts.Body,
        TextSize    = props.Size     or Theme.TextSize.Base,
        Text        = props.Text     or "",
        TextXAlignment = props.AlignX or Enum.TextXAlignment.Left,
        TextYAlignment = props.AlignY or Enum.TextYAlignment.Center,
        TextTruncate   = Enum.TextTruncate.AtEnd,
        RichText       = props.Rich  or false,
        Size        = props.FrameSize or UDim2.new(1, 0, 0, 16),
        Position    = props.Position  or UDim2.new(0, 0, 0, 0),
        ZIndex      = props.ZIndex    or 1,
        Name        = props.Name      or "Label",
    }
end

-- ─── Components.Icon ─────────────────────────────────────────────────────────

function Components.Icon(props)
    return New("ImageLabel") {
        BackgroundTransparency = 1,
        Image       = props.Icon    or "",
        ImageColor3 = props.Color   or Theme.Colors.TextSecondary,
        ImageTransparency = props.Transparency or 0,
        Size        = props.Size    or UDim2.fromOffset(18, 18),
        Position    = props.Position or UDim2.new(0,0,0,0),
        AnchorPoint = props.Anchor  or Vector2.new(0, 0),
        ZIndex      = props.ZIndex  or 1,
        Name        = props.Name    or "Icon",
        ScaleType   = Enum.ScaleType.Fit,
    }
end

-- ─── Components.Button ───────────────────────────────────────────────────────

function Components.Button(props)
    local isHovered  = Value(false)
    local isPressed  = Value(false)

    local bgColor = Computed(function(use)
        if use(isPressed) then return props.PressColor  or Theme.Colors.ButtonActive end
        if use(isHovered) then return props.HoverColor  or Theme.Colors.ButtonHover  end
        return props.BgColor or Theme.Colors.ButtonBg
    end)
    local borderColor = Computed(function(use)
        if use(isHovered) or use(isPressed) then
            return props.BorderHover or Theme.Colors.AccentPrimaryDim
        end
        return props.BorderColor or Theme.Colors.ButtonBorder
    end)

    local bgSpring     = Spring(bgColor,     Theme.Springs.Hover)
    local borderSpring = Spring(borderColor, Theme.Springs.Hover)

    local btn = New("TextButton") {
        Name                = props.Name   or "Button",
        Size                = props.Size   or UDim2.new(1, 0, 0, 32),
        Position            = props.Position or UDim2.new(0,0,0,0),
        BackgroundColor3    = bgSpring,
        AutoButtonColor     = false,
        Text                = "",
        ZIndex              = props.ZIndex or 1,

        [Fusion.OnEvent "MouseEnter"]  = function() isHovered:set(true)  end,
        [Fusion.OnEvent "MouseLeave"]  = function() isHovered:set(false) isPressed:set(false) end,
        [Fusion.OnEvent "MouseButton1Down"] = function() isPressed:set(true) end,
        [Fusion.OnEvent "MouseButton1Up"]   = function()
            isPressed:set(false)
            if props.OnClick then props.OnClick() end
        end,

        Corner(props.Radius or Theme.Radius.Base),
        Stroke(borderSpring, 1),
        DropShadow(nil, 8, 0.3),

        New("TextLabel") {
            BackgroundTransparency = 1,
            Text        = props.Text    or "",
            TextColor3  = props.TextColor or Theme.Colors.TextPrimary,
            Font        = props.Font    or Theme.Fonts.Label,
            TextSize    = props.TextSize or Theme.TextSize.Base,
            Size        = UDim2.fromScale(1, 1),
            ZIndex      = 2,
        },
    }

    if props.Icon then
        local icon = New("ImageLabel") {
            BackgroundTransparency = 1,
            Image       = props.Icon,
            ImageColor3 = props.IconColor or Theme.Colors.TextSecondary,
            Size        = UDim2.fromOffset(16, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Position    = UDim2.new(0, 10, 0.5, 0),
            ZIndex      = 3,
            ScaleType   = Enum.ScaleType.Fit,
        }
        icon.Parent = btn
    end

    return btn
end

-- ─── Components.IconButton (sidebar / toolbar) ───────────────────────────────

function Components.IconButton(props)
    local isHovered = Value(false)
    local isActive  = props.Active or Value(false)

    local bgColor = Computed(function(use)
        if use(isActive) then return Theme.Colors.SidebarActive end
        if use(isHovered) then return Theme.Colors.SidebarHover end
        return Color3.fromRGB(0,0,0)
    end)
    local iconColor = Computed(function(use)
        if use(isActive) then return Theme.Colors.AccentPrimary end
        if use(isHovered) then return Theme.Colors.TextPrimary  end
        return Theme.Colors.TextMuted
    end)
    local accentBarTrans = Computed(function(use)
        return use(isActive) and 0 or 1
    end)

    local bgSpring   = Spring(bgColor,   Theme.Springs.Hover)
    local icSpring   = Spring(iconColor, Theme.Springs.Hover)
    local barSpring  = Spring(accentBarTrans, Theme.Springs.Hover)

    return New("TextButton") {
        Name             = props.Name or "IconButton",
        Size             = props.Size or UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = bgSpring,
        AutoButtonColor  = false,
        Text             = "",
        ZIndex           = props.ZIndex or 11,

        [Fusion.OnEvent "MouseEnter"]  = function() isHovered:set(true)  end,
        [Fusion.OnEvent "MouseLeave"]  = function() isHovered:set(false) end,
        [Fusion.OnEvent "MouseButton1Up"] = function()
            if props.OnClick then props.OnClick() end
        end,

        -- Left active bar glow
        New("Frame") {
            Name             = "ActiveBar",
            Size             = UDim2.new(0, 2, 0.55, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Theme.Colors.AccentPrimary,
            BackgroundTransparency = barSpring,
            ZIndex           = 12,
            Corner(Theme.Radius.Full),
        },

        -- Icon
        New("ImageLabel") {
            Name             = "Icon",
            BackgroundTransparency = 1,
            Image            = props.Icon or "",
            ImageColor3      = icSpring,
            Size             = UDim2.fromOffset(22, 22),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.fromScale(0.5, 0.5),
            ZIndex           = 12,
            ScaleType        = Enum.ScaleType.Fit,
        },

        -- Tooltip label
        New("TextLabel") {
            Name             = "Tooltip",
            BackgroundTransparency = 0.15,
            BackgroundColor3 = Theme.Colors.Surface,
            TextColor3       = Theme.Colors.TextPrimary,
            Font             = Theme.Fonts.Label,
            TextSize         = Theme.TextSize.Small,
            Text             = props.Tooltip or props.Name or "",
            Size             = UDim2.fromOffset(90, 24),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(1, 8, 0.5, 0),
            Visible          = Computed(function(use) return use(isHovered) end),
            ZIndex           = 30,
            Corner(Theme.Radius.Small),
            Stroke(Theme.Colors.SurfaceBorder, 1),
        },
    }
end

-- ─── Components.Toggle ───────────────────────────────────────────────────────

function Components.Toggle(props)
    local enabled   = props.Value or Value(false)
    local isHovered = Value(false)

    local trackColor = Computed(function(use)
        return use(enabled) and Theme.Colors.ToggleOn or Theme.Colors.ToggleOff
    end)
    local knobPos = Computed(function(use)
        return use(enabled)
            and UDim2.new(1, -18, 0.5, 0)
            or  UDim2.new(0, 4,   0.5, 0)
    end)
    local knobColor = Computed(function(use)
        return use(enabled) and Theme.Colors.White or Theme.Colors.TextMuted
    end)

    local trackSpr  = Spring(trackColor, Theme.Springs.Snappy)
    local knobPosSpr= Spring(knobPos,    Theme.Springs.Snappy)
    local knobColSpr= Spring(knobColor,  Theme.Springs.Snappy)

    local container = New("Frame") {
        Name             = props.Name or "Toggle",
        Size             = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex           = props.ZIndex or 1,

        -- Label
        New("TextLabel") {
            BackgroundTransparency = 1,
            Text        = props.Label or "",
            TextColor3  = Theme.Colors.TextPrimary,
            Font        = Theme.Fonts.Body,
            TextSize    = Theme.TextSize.Base,
            Size        = UDim2.new(1, -52, 1, 0),
            ZIndex      = 2,
        },

        -- Track
        New("TextButton") {
            Name             = "Track",
            Size             = UDim2.fromOffset(40, 20),
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = trackSpr,
            AutoButtonColor  = false,
            Text             = "",
            ZIndex           = 2,

            [Fusion.OnEvent "MouseEnter"]  = function() isHovered:set(true)  end,
            [Fusion.OnEvent "MouseLeave"]  = function() isHovered:set(false) end,
            [Fusion.OnEvent "MouseButton1Up"] = function()
                local v = not enabled:get()
                enabled:set(v)
                if props.OnToggle then props.OnToggle(v) end
            end,

            Corner(Theme.Radius.Full),

            -- Knob
            New("Frame") {
                Name             = "Knob",
                Size             = UDim2.fromOffset(14, 14),
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = knobPosSpr,
                BackgroundColor3 = knobColSpr,
                ZIndex           = 3,
                Corner(Theme.Radius.Full),
            },
        },
    }

    return container, enabled
end

-- ─── Components.Slider ───────────────────────────────────────────────────────

function Components.Slider(props)
    local minVal  = props.Min   or 0
    local maxVal  = props.Max   or 100
    local step    = props.Step  or 1
    local value   = props.Value or Value(props.Default or minVal)
    local isDrag  = Value(false)

    local fillPct = Computed(function(use)
        local v = use(value)
        return (v - minVal) / (maxVal - minVal)
    end)
    local fillSpring = Spring(Computed(function(use)
        return UDim2.fromScale(use(fillPct), 1)
    end), Theme.Springs.Snappy)

    local function clampStep(v)
        v = math.clamp(v, minVal, maxVal)
        if step > 0 then
            v = math.round(v / step) * step
        end
        return v
    end

    local trackRef = Value(nil)

    local function updateFromInput(input)
        local track = trackRef:get()
        if not track then return end
        local absPos  = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        local relX    = (input.Position.X - absPos.X) / absSize.X
        local newVal  = minVal + clampStep((maxVal - minVal) * math.clamp(relX, 0, 1))
        newVal = clampStep(newVal)
        value:set(newVal)
        if props.OnChange then props.OnChange(newVal) end
    end

    return New("Frame") {
        Name             = props.Name or "Slider",
        Size             = props.Size or UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        ZIndex           = props.ZIndex or 1,

        -- Label row
        New("Frame") {
            Name             = "LabelRow",
            Size             = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            ZIndex           = 2,

            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = props.Label or "Slider",
                TextColor3 = Theme.Colors.TextPrimary,
                Font       = Theme.Fonts.Body,
                TextSize   = Theme.TextSize.Base,
                Size       = UDim2.new(1, -50, 1, 0),
                ZIndex     = 2,
            },
            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = Computed(function(use)
                    return tostring(use(value))
                end),
                TextColor3 = Theme.Colors.AccentPrimary,
                Font       = Theme.Fonts.Mono,
                TextSize   = Theme.TextSize.Base,
                TextXAlignment = Enum.TextXAlignment.Right,
                AnchorPoint    = Vector2.new(1, 0),
                Size       = UDim2.new(0, 48, 1, 0),
                Position   = UDim2.new(1, 0, 0, 0),
                ZIndex     = 2,
            },
        },

        -- Track
        New("TextButton") {
            Name             = "Track",
            Size             = UDim2.new(1, 0, 0, 6),
            AnchorPoint      = Vector2.new(0, 0),
            Position         = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = Theme.Colors.SliderTrack,
            AutoButtonColor  = false,
            Text             = "",
            ZIndex           = 2,
            [Fusion.Ref]     = trackRef,

            [Fusion.OnEvent "MouseButton1Down"] = function(_, input)
                isDrag:set(true)
                updateFromInput(input)
            end,
            [Fusion.OnEvent "MouseButton1Up"]   = function() isDrag:set(false) end,
            [Fusion.OnEvent "MouseMoved"]        = function(_, input)
                if isDrag:get() then updateFromInput(input) end
            end,

            Corner(Theme.Radius.Full),

            -- Fill
            New("Frame") {
                Name             = "Fill",
                Size             = fillSpring,
                BackgroundColor3 = Theme.Colors.SliderFill,
                ZIndex           = 3,
                Corner(Theme.Radius.Full),
            },

            -- Knob
            New("Frame") {
                Name             = "Knob",
                Size             = UDim2.fromOffset(14, 14),
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = Computed(function(use)
                    return UDim2.new(use(fillPct), 0, 0.5, 0)
                end),
                BackgroundColor3 = Theme.Colors.SliderKnob,
                ZIndex           = 4,
                Corner(Theme.Radius.Full),
                Stroke(Theme.Colors.AccentPrimaryGlow, 1.5),
            },
        },
    }, value
end

-- ─── Components.Textbox ──────────────────────────────────────────────────────

function Components.Textbox(props)
    local isFocused = Value(false)
    local text      = props.Value or Value(props.Default or "")

    local borderColor = Computed(function(use)
        return use(isFocused)
            and Theme.Colors.InputBorderFocus
            or  Theme.Colors.InputBorder
    end)
    local borderSpr = Spring(borderColor, Theme.Springs.Snappy)

    return New("Frame") {
        Name             = props.Name or "Textbox",
        Size             = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Colors.InputBg,
        ZIndex           = props.ZIndex or 1,

        Corner(Theme.Radius.Base),
        Stroke(borderSpr, 1),
        Padding(nil, 10, 0),

        -- Icon
        props.Icon and New("ImageLabel") {
            BackgroundTransparency = 1,
            Image       = props.Icon,
            ImageColor3 = Theme.Colors.TextMuted,
            Size        = UDim2.fromOffset(14, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            Position    = UDim2.new(0, 0, 0.5, 0),
            ZIndex      = 2,
            ScaleType   = Enum.ScaleType.Fit,
        } or nil,

        New("TextBox") {
            Name             = "Input",
            BackgroundTransparency = 1,
            PlaceholderText  = props.Placeholder or "",
            PlaceholderColor3= Theme.Colors.Placeholder,
            Text             = text,
            TextColor3       = Theme.Colors.TextPrimary,
            Font             = Theme.Fonts.Body,
            TextSize         = Theme.TextSize.Base,
            ClearTextOnFocus = props.ClearOnFocus or false,
            Size             = props.Icon
                and UDim2.new(1, -22, 1, 0)
                or  UDim2.fromScale(1, 1),
            Position         = props.Icon
                and UDim2.new(0, 22, 0, 0)
                or  UDim2.new(0, 0, 0, 0),
            ZIndex           = 2,

            [Fusion.OnEvent "Focused"]     = function() isFocused:set(true)  end,
            [Fusion.OnEvent "FocusLost"]   = function(_, ent)
                isFocused:set(false)
                if props.OnSubmit then props.OnSubmit(text:get(), ent) end
            end,
            [Fusion.OnChange "Text"]       = function(val)
                text:set(val)
                if props.OnChange then props.OnChange(val) end
            end,
        },
    }, text
end

-- ─── Components.Dropdown ─────────────────────────────────────────────────────

function Components.Dropdown(props)
    local isOpen    = Value(false)
    local selected  = props.Value or Value(props.Default or (props.Options and props.Options[1]) or "")

    local arrowRot  = Computed(function(use)
        return use(isOpen) and 180 or 0
    end)
    local arrowSpr  = Spring(arrowRot, Theme.Springs.Snappy)

    local listHeight = Computed(function(use)
        local opts = props.Options or {}
        return use(isOpen) and (#opts * 28 + 4) or 0
    end)
    local listSpr   = Spring(listHeight, Theme.Springs.Gentle)

    local container = New("Frame") {
        Name             = props.Name or "Dropdown",
        Size             = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex           = props.ZIndex or 1,

        -- Selected display / toggle button
        New("TextButton") {
            Name             = "Header",
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Colors.InputBg,
            AutoButtonColor  = false,
            Text             = "",
            ZIndex           = 2,

            [Fusion.OnEvent "MouseButton1Up"] = function()
                isOpen:set(not isOpen:get())
            end,

            Corner(Theme.Radius.Base),
            Stroke(Theme.Colors.InputBorder, 1),
            Padding(nil, 10, 0),

            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = Computed(function(use) return use(selected) end),
                TextColor3 = Theme.Colors.TextPrimary,
                Font       = Theme.Fonts.Body,
                TextSize   = Theme.TextSize.Base,
                Size       = UDim2.new(1, -24, 1, 0),
                ZIndex     = 3,
            },
            New("ImageLabel") {
                Name             = "Arrow",
                BackgroundTransparency = 1,
                Image       = Theme.Icons.Chevron,
                ImageColor3 = Theme.Colors.TextMuted,
                Size        = UDim2.fromOffset(14, 14),
                AnchorPoint = Vector2.new(1, 0.5),
                Position    = UDim2.new(1, -2, 0.5, 0),
                ZIndex      = 3,
                Rotation    = arrowSpr,
                ScaleType   = Enum.ScaleType.Fit,
            },
        },

        -- Dropdown list
        New("ScrollingFrame") {
            Name             = "List",
            Size             = Computed(function(use)
                return UDim2.new(1, 0, 0, use(listSpr))
            end),
            Position         = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Theme.Colors.DropdownBg,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex           = Theme.ZIndex.Dropdown,

            Corner(Theme.Radius.Base),
            Stroke(Theme.Colors.SurfaceBorder, 1),

            ListLayout(nil, 0),
            Padding(2),

            -- Populate options
            (function()
                local items = {}
                for _, opt in ipairs(props.Options or {}) do
                    local isSel = Computed(function(use) return use(selected) == opt end)
                    local isHov = Value(false)
                    local itemBg = Computed(function(use)
                        if use(isSel) then return Theme.Colors.DropdownSelected end
                        if use(isHov) then return Theme.Colors.DropdownHover end
                        return Color3.fromRGB(0,0,0)
                    end)
                    table.insert(items, New("TextButton") {
                        Name             = "Option_"..opt,
                        Size             = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = Spring(itemBg, Theme.Springs.Hover),
                        AutoButtonColor  = false,
                        Text             = "",
                        ZIndex           = Theme.ZIndex.Dropdown + 1,

                        [Fusion.OnEvent "MouseEnter"]  = function() isHov:set(true)  end,
                        [Fusion.OnEvent "MouseLeave"]  = function() isHov:set(false) end,
                        [Fusion.OnEvent "MouseButton1Up"] = function()
                            selected:set(opt)
                            isOpen:set(false)
                            if props.OnSelect then props.OnSelect(opt) end
                        end,

                        Corner(Theme.Radius.Small),

                        New("TextLabel") {
                            BackgroundTransparency = 1,
                            Text       = opt,
                            TextColor3 = Computed(function(use)
                                return use(isSel) and Theme.Colors.AccentPrimary or Theme.Colors.TextPrimary
                            end),
                            Font     = Theme.Fonts.Body,
                            TextSize = Theme.TextSize.Base,
                            Size     = UDim2.new(1, -24, 1, 0),
                            Position = UDim2.new(0, 10, 0, 0),
                            ZIndex   = Theme.ZIndex.Dropdown + 2,
                        },
                    })
                end
                return table.unpack(items)
            end)(),
        },
    }

    return container, selected
end

-- ─── Components.Keybind ──────────────────────────────────────────────────────

function Components.Keybind(props)
    local keyValue   = props.Value or Value(props.Default or Enum.KeyCode.Unknown)
    local isListening= Value(false)

    local displayText = Computed(function(use)
        if use(isListening) then return "..." end
        local k = use(keyValue)
        if k == Enum.KeyCode.Unknown then return "None" end
        return k.Name
    end)
    local borderColor = Computed(function(use)
        return use(isListening) and Theme.Colors.AccentRed or Theme.Colors.InputBorder
    end)

    local conn

    return New("Frame") {
        Name             = props.Name or "Keybind",
        Size             = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex           = props.ZIndex or 1,

        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = props.Label or "Keybind",
            TextColor3 = Theme.Colors.TextPrimary,
            Font       = Theme.Fonts.Body,
            TextSize   = Theme.TextSize.Base,
            Size       = UDim2.new(1, -90, 1, 0),
            ZIndex     = 2,
        },

        New("TextButton") {
            Name             = "Bind",
            Size             = UDim2.fromOffset(80, 24),
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = Theme.Colors.InputBg,
            AutoButtonColor  = false,
            Text             = displayText,
            TextColor3       = Computed(function(use)
                return use(isListening) and Theme.Colors.AccentRed or Theme.Colors.TextPrimary
            end),
            Font             = Theme.Fonts.Mono,
            TextSize         = Theme.TextSize.Small,
            ZIndex           = 2,

            [Fusion.OnEvent "MouseButton1Up"] = function()
                if isListening:get() then return end
                isListening:set(true)
                conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        keyValue:set(inp.KeyCode)
                        if props.OnBind then props.OnBind(inp.KeyCode) end
                    end
                    isListening:set(false)
                    if conn then conn:Disconnect() conn = nil end
                end)
            end,

            Corner(Theme.Radius.Small),
            Stroke(Spring(borderColor, Theme.Springs.Snappy), 1),
        },
    }, keyValue
end

-- ─── Components.ColorPicker ──────────────────────────────────────────────────

function Components.ColorPicker(props)
    local colorValue = props.Value or Value(props.Default or Color3.fromRGB(180, 50, 220))
    local isOpen     = Value(false)
    local hue        = Value(0)
    local sat        = Value(1)
    local val        = Value(1)

    -- Compute colour from HSV sliders
    local function updateColor()
        local c = Color3.fromHSV(hue:get(), sat:get(), val:get())
        colorValue:set(c)
        if props.OnChange then props.OnChange(c) end
    end

    -- Swatch preview
    local swatch = New("TextButton") {
        Name             = props.Name or "ColorPicker",
        Size             = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = props.ZIndex or 1,

        [Fusion.OnEvent "MouseButton1Up"] = function()
            isOpen:set(not isOpen:get())
        end,

        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = props.Label or "Color",
            TextColor3 = Theme.Colors.TextPrimary,
            Font       = Theme.Fonts.Body,
            TextSize   = Theme.TextSize.Base,
            Size       = UDim2.new(1, -42, 1, 0),
            ZIndex     = 2,
        },

        New("Frame") {
            Name             = "Swatch",
            Size             = UDim2.fromOffset(32, 18),
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = colorValue,
            ZIndex           = 2,
            Corner(Theme.Radius.Small),
            Stroke(Theme.Colors.SurfaceBorder, 1),
        },
    }

    -- Compact HSV panel (open state)
    local panel = New("Frame") {
        Name             = "HSVPanel",
        Size             = UDim2.new(1, 0, 0, 100),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.Colors.Surface,
        Visible          = Computed(function(use) return use(isOpen) end),
        ZIndex           = Theme.ZIndex.Dropdown,

        Corner(Theme.Radius.Base),
        Stroke(Theme.Colors.SurfaceBorder, 1),
        Padding(8),
        ListLayout(nil, 6),

        -- Hue
        (function()
            local _, hueVal = Components.Slider {
                Label = "Hue", Min = 0, Max = 1, Step = 0.01, Value = hue,
                Size = UDim2.new(1, 0, 0, 32),
                OnChange = function() updateColor() end,
            }
            return _, hueVal
        end)(),
        (function()
            local _, satVal = Components.Slider {
                Label = "Sat", Min = 0, Max = 1, Step = 0.01, Value = sat,
                Size = UDim2.new(1, 0, 0, 32),
                OnChange = function() updateColor() end,
            }
            return _, satVal
        end)(),
        (function()
            local _, brightVal = Components.Slider {
                Label = "Val", Min = 0, Max = 1, Step = 0.01, Value = val,
                Size = UDim2.new(1, 0, 0, 32),
                OnChange = function() updateColor() end,
            }
            return _, brightVal
        end)(),
    }

    -- Wrap both in a container
    local container = New("Frame") {
        Name             = "ColorPickerContainer",
        Size             = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex           = props.ZIndex or 1,
        swatch,
        panel,
    }
    return container, colorValue
end

-- ─── Components.Section ──────────────────────────────────────────────────────

function Components.Section(props)
    return New("Frame") {
        Name             = props.Name or "Section",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Colors.Surface,
        ZIndex           = props.ZIndex or 2,

        Corner(Theme.Radius.Large),
        Stroke(Theme.Colors.SurfaceBorder, 1),
        Padding(Theme.Spacing.Medium),

        -- Section header
        props.Title and New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = props.Title,
            TextColor3 = Theme.Colors.TextAccent,
            Font       = Theme.Fonts.Heading,
            TextSize   = Theme.TextSize.Small,
            Size       = UDim2.new(1, 0, 0, 18),
            LayoutOrder= -1,
            ZIndex     = 3,
        } or nil,

        ListLayout(nil, Theme.Spacing.Base),
        table.unpack(props.Children or {}),
    }
end

-- ─── Components.Notification ─────────────────────────────────────────────────

local notifCount = 0

function Components.Notification(parent, opts)
    opts = opts or {}
    notifCount = notifCount + 1

    local typeColors = {
        info    = Theme.Colors.NotifInfo,
        success = Theme.Colors.NotifSuccess,
        warning = Theme.Colors.NotifWarning,
        error   = Theme.Colors.NotifError,
    }
    local accent = typeColors[opts.Type or "info"] or Theme.Colors.NotifInfo

    local progress = Value(1)
    local visible  = Value(true)
    local yOffset  = Value(-80)

    local ySpring  = Spring(yOffset, Theme.Springs.Notification)
    local alphaSpring = Spring(Computed(function(use)
        return use(visible) and 0 or 1
    end), Theme.Springs.Gentle)

    local notif = New("Frame") {
        Name             = "Notification_"..notifCount,
        Parent           = parent,
        Size             = UDim2.fromOffset(280, 68),
        AnchorPoint      = Vector2.new(1, 1),
        Position         = Computed(function(use)
            return UDim2.new(1, -12, 1, use(ySpring) - (notifCount - 1) * 76)
        end),
        BackgroundColor3 = Theme.Colors.NotifBg,
        BackgroundTransparency = alphaSpring,
        ZIndex           = Theme.ZIndex.Notification,
        ClipsDescendants = true,

        Corner(Theme.Radius.Medium),

        New("Frame") {
            Name             = "AccentBar",
            Size             = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = accent,
            ZIndex           = Theme.ZIndex.Notification + 1,
            Corner(Theme.Radius.Full),
        },

        Stroke(Computed(function() return accent end), 1, 0.6),
        DropShadow(nil, 12, 0.5),

        New("Frame") {
            Name             = "Content",
            Size             = UDim2.new(1, -18, 1, 0),
            Position         = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            ZIndex           = Theme.ZIndex.Notification + 1,
            Padding(nil, 4, 8),
            ListLayout(nil, 2),

            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = opts.Title   or "Notification",
                TextColor3 = Theme.Colors.TextPrimary,
                Font       = Theme.Fonts.Heading,
                TextSize   = Theme.TextSize.Base,
                Size       = UDim2.new(1, 0, 0, 18),
                ZIndex     = Theme.ZIndex.Notification + 2,
            },
            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = opts.Message or "",
                TextColor3 = Theme.Colors.TextSecondary,
                Font       = Theme.Fonts.Body,
                TextSize   = Theme.TextSize.Small,
                Size       = UDim2.new(1, 0, 0, 28),
                TextWrapped = true,
                ZIndex     = Theme.ZIndex.Notification + 2,
            },
        },

        -- Progress bar
        New("Frame") {
            Name             = "ProgressBar",
            Size             = UDim2.new(1, 0, 0, 2),
            AnchorPoint      = Vector2.new(0, 1),
            Position         = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = accent,
            ZIndex           = Theme.ZIndex.Notification + 2,
            Tween(Computed(function(use) return UDim2.fromScale(use(progress), 1) end), Theme.Tweens.Slow),
        },
    }

    -- Animate in
    task.defer(function()
        yOffset:set(0)
    end)

    -- Auto-dismiss
    local duration = opts.Duration or 4
    task.delay(0.05, function()
        -- Animate progress bar
        progress:set(0)
    end)
    task.delay(duration, function()
        visible:set(false)
        yOffset:set(-80)
        task.delay(0.5, function()
            notifCount = notifCount - 1
            notif:Destroy()
        end)
    end)

    return notif
end

-- ─── Components.Separator ────────────────────────────────────────────────────

function Components.Separator(props)
    return New("Frame") {
        Name             = "Separator",
        Size             = props.Size or UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Colors.SurfaceBorder,
        BorderSizePixel  = 0,
        ZIndex           = props.ZIndex or 1,
        LayoutOrder      = props.Order or 0,
    }
end

-- ─── Components.Badge ────────────────────────────────────────────────────────

function Components.Badge(props)
    return New("Frame") {
        Name             = "Badge",
        Size             = UDim2.fromOffset(0, 16),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundColor3 = props.Color or Theme.Colors.AccentRed,
        ZIndex           = props.ZIndex or 5,
        Padding(nil, 5, 0),

        Corner(Theme.Radius.Full),
        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = props.Text or "",
            TextColor3 = Theme.Colors.White,
            Font       = Theme.Fonts.Heading,
            TextSize   = Theme.TextSize.XSmall,
            Size       = UDim2.fromOffset(0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex     = props.ZIndex and props.ZIndex + 1 or 6,
        },
    }
end

-- ─── Components.ScriptCard ───────────────────────────────────────────────────

function Components.ScriptCard(props)
    local isHovered = Value(false)
    local bgColor = Computed(function(use)
        return use(isHovered) and Theme.Colors.SurfaceAlt or Theme.Colors.Surface
    end)
    local bgSpring = Spring(bgColor, Theme.Springs.Hover)

    return New("TextButton") {
        Name             = props.Name or "ScriptCard",
        Size             = props.Size or UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = bgSpring,
        AutoButtonColor  = false,
        Text             = "",
        ZIndex           = props.ZIndex or 2,
        LayoutOrder      = props.Order or 0,

        [Fusion.OnEvent "MouseEnter"]  = function() isHovered:set(true)  end,
        [Fusion.OnEvent "MouseLeave"]  = function() isHovered:set(false) end,
        [Fusion.OnEvent "MouseButton1Up"] = function()
            if props.OnExecute then props.OnExecute() end
        end,

        Corner(Theme.Radius.Large),
        Stroke(Theme.Colors.SurfaceBorder, 1),
        DropShadow(nil, 6, 0.2),

        -- Left accent glow bar
        New("Frame") {
            Size             = UDim2.new(0, 3, 0.7, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = props.AccentColor or Theme.Colors.AccentPrimary,
            ZIndex           = 3,
            Corner(Theme.Radius.Full),
        },

        -- Icon
        New("Frame") {
            Size             = UDim2.fromOffset(42, 42),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 16, 0.5, 0),
            BackgroundColor3 = props.IconBg or Theme.Colors.SidebarActive,
            ZIndex           = 3,
            Corner(Theme.Radius.Medium),

            New("ImageLabel") {
                BackgroundTransparency = 1,
                Image       = props.Icon or Theme.Icons.Scripts,
                ImageColor3 = props.AccentColor or Theme.Colors.AccentPrimary,
                Size        = UDim2.fromOffset(22, 22),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position    = UDim2.fromScale(0.5, 0.5),
                ZIndex      = 4,
                ScaleType   = Enum.ScaleType.Fit,
            },
        },

        -- Text
        New("Frame") {
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -120, 0.8, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 68, 0.5, 0),
            ZIndex           = 3,
            ListLayout(nil, 2),

            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = props.Title or "Script",
                TextColor3 = Theme.Colors.TextPrimary,
                Font       = Theme.Fonts.Heading,
                TextSize   = Theme.TextSize.Medium,
                Size       = UDim2.new(1, 0, 0, 18),
                ZIndex     = 4,
            },
            New("TextLabel") {
                BackgroundTransparency = 1,
                Text       = props.Description or "",
                TextColor3 = Theme.Colors.TextSecondary,
                Font       = Theme.Fonts.Body,
                TextSize   = Theme.TextSize.Small,
                Size       = UDim2.new(1, 0, 0, 14),
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex     = 4,
            },
        },

        -- Execute button
        New("TextButton") {
            Name             = "ExecBtn",
            Text             = "Execute",
            Font             = Theme.Fonts.Heading,
            TextSize         = Theme.TextSize.Small,
            TextColor3       = Theme.Colors.White,
            Size             = UDim2.fromOffset(68, 24),
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -12, 0.5, 0),
            BackgroundColor3 = props.AccentColor or Theme.Colors.AccentPrimary,
            AutoButtonColor  = false,
            ZIndex           = 4,

            [Fusion.OnEvent "MouseButton1Up"] = function()
                if props.OnExecute then props.OnExecute() end
            end,

            Corner(Theme.Radius.Small),
        },
    }
end

-- Expose utilities for use by main.lua
Components._utils = {
    New       = New,
    Spring    = Spring,
    Tween     = Tween,
    Value     = Value,
    Computed  = Computed,
    Observer  = Observer,
    Corner    = Corner,
    Stroke    = Stroke,
    DropShadow= DropShadow,
    Padding   = Padding,
    ListLayout= ListLayout,
    GridLayout= GridLayout,
}

return Components
