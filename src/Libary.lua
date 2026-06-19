--[[
╔═══════════════════════════════════════════════════════════════╗
║              ETHOS // RE  —  UI Library  v2.0                 ║
║         by laderite  |  Fusion 0.3  |  Rayfield-style API     ║
╚═══════════════════════════════════════════════════════════════╝

  USAGE:
    local Ethos = loadstring(game:HttpGet(RAW_URL))()
    local Window = Ethos:CreateWindow({ Name = "My Hub" })
    local Tab    = Window:CreateTab("Combat", "rbxassetid://...")
    Tab:CreateToggle({ Name = "Aimbot", Callback = function(v) end })
    Tab:CreateSlider({ Name = "FOV", Range = {1,360}, Increment = 1, CurrentValue = 90, Callback = function(v) end })
    Tab:CreateButton({ Name = "Kill Aura", Callback = function() end })
    Tab:CreateDropdown({ Name = "Part", Options = {"Head","HRP"}, CurrentOption = "Head", Callback = function(v) end })
    Tab:CreateKeybind({ Name = "Toggle", CurrentKeybind = "RightShift", Callback = function() end })
    Tab:CreateColorPicker({ Name = "ESP Color", Color = Color3.fromRGB(180,50,220), Callback = function(c) end })
    Tab:CreateInput({ Name = "Speed", PlaceholderText = "Enter value...", Callback = function(t) end })
    Tab:CreateLabel("Some label text")
    Tab:CreateParagraph({ Title = "Info", Content = "Some description text." })
    Tab:CreateSection("Section Title")
    Ethos:Notify({ Title = "Loaded", Content = "Ready!", Duration = 4, Type = "Success" })
--]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local LocalPlayer    = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  ASSET BASE URL  (raw GitHub)
-- ══════════════════════════════════════════════════════════════

local ASSET_BASE = "https://raw.githubusercontent.com/Vinkzzz/ethos-remake-with-claude/main/assets/"

-- Map logical names → filenames in your repo
local Icons = {
    -- Sidebar tabs
    Home            = ASSET_BASE .. "ChatDefault",          -- placeholder, swap per tab
    ClientControl   = ASSET_BASE .. "ClientControlDefault",
    ClientControlOn = ASSET_BASE .. "ClientControlActive",
    CloudConfigs    = ASSET_BASE .. "CloudConfigsDefault",
    CloudConfigsOn  = ASSET_BASE .. "CloudConfigsActive",
    Credits         = ASSET_BASE .. "CreditsDefault",
    CreditsOn       = ASSET_BASE .. "CreditsActive",
    ModPanel        = ASSET_BASE .. "ModPanelDefault",
    ModPanelOn      = ASSET_BASE .. "ModPanelActive",
    Settings        = ASSET_BASE .. "SettingsIcon",

    -- UI chrome
    Close           = ASSET_BASE .. "Close",
    Minimize        = ASSET_BASE .. "Minimizb",
    ResizeHandle    = ASSET_BASE .. "ResizeHandle",
    DropShadow      = ASSET_BASE .. "Dropshadow",
    DropdownArrow   = ASSET_BASE .. "DropdownArrow",
    Search          = ASSET_BASE .. "SearchIcon",
    Cursor          = ASSET_BASE .. "Cursor",
    Drag            = ASSET_BASE .. "Drag",
    Downloads       = ASSET_BASE .. "Downloads",
    Likes           = ASSET_BASE .. "Likes",

    -- Notifications / chat
    ChatActive      = ASSET_BASE .. "ChatActive",
    ChatDefault     = ASSET_BASE .. "ChatDefault",
    ChatSend        = ASSET_BASE .. "ChatSendIcon",
    ChatWarning     = ASSET_BASE .. "ChatWarningIcon",

    -- Components
    Checkmark       = ASSET_BASE .. "Checkmark",
    Chevron         = ASSET_BASE .. "Chevron",
    ColorPicker     = ASSET_BASE .. "ColorPicker",
    Keyboard        = ASSET_BASE .. "KeyboardIcon",
    Shadow          = ASSET_BASE .. "Shadow",
}

-- ══════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════

local T = {
    -- Backgrounds
    Bg          = Color3.fromHex("0F0F12"),
    Surface     = Color3.fromHex("141418"),
    SurfaceAlt  = Color3.fromHex("1A1A22"),
    Border      = Color3.fromHex("252530"),

    -- Sidebar
    SidebarBg   = Color3.fromHex("0C0C0F"),
    SidebarHov  = Color3.fromHex("161620"),
    SidebarSel  = Color3.fromHex("1C1628"),

    -- Accents
    Purple      = Color3.fromHex("B432DC"),
    PurpleDim   = Color3.fromHex("7A1F99"),
    PurpleGlow  = Color3.fromHex("CC55F0"),
    Red         = Color3.fromHex("DC284E"),
    RedDim      = Color3.fromHex("991C36"),
    Green       = Color3.fromHex("2DC96E"),
    Yellow      = Color3.fromHex("E8A020"),

    -- Text
    TextPri     = Color3.fromHex("F0EEF8"),
    TextSec     = Color3.fromHex("8B89A0"),
    TextMuted   = Color3.fromHex("55536A"),
    TextAccent  = Color3.fromHex("C860F0"),

    -- Input
    InputBg     = Color3.fromHex("161620"),
    InputBorder = Color3.fromHex("2A2A38"),
    Placeholder = Color3.fromHex("44425A"),

    -- Toggle
    ToggleOff   = Color3.fromHex("2A2A38"),
    ToggleOn    = Color3.fromHex("B432DC"),

    -- Slider
    TrackBg     = Color3.fromHex("1E1E28"),

    -- Fonts
    Bold        = Enum.Font.GothamBold,
    Semi        = Enum.Font.GothamSemibold,
    Med         = Enum.Font.GothamMedium,
    Body        = Enum.Font.Gotham,
    Mono        = Enum.Font.Code,

    -- Sizes
    S10 = 10, S11 = 11, S12 = 12, S13 = 13, S14 = 14, S16 = 16, S18 = 18, S20 = 20, S22 = 22,

    -- Tween
    Fast   = TweenInfo.new(0.12, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out),
    Base   = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),

    -- Window
    WinW        = 720,
    WinH        = 480,
    SideW       = 52,
    TitleH      = 34,
    TopBarH     = 38,
    MinW        = 560,
    MinH        = 360,
}

-- ══════════════════════════════════════════════════════════════
--  UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Border
    s.Thickness = thickness or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, all, h, v)
    local p = Instance.new("UIPadding")
    if all then
        p.PaddingLeft   = UDim.new(0, all)
        p.PaddingRight  = UDim.new(0, all)
        p.PaddingTop    = UDim.new(0, all)
        p.PaddingBottom = UDim.new(0, all)
    else
        p.PaddingLeft   = UDim.new(0, h or 0)
        p.PaddingRight  = UDim.new(0, h or 0)
        p.PaddingTop    = UDim.new(0, v or 0)
        p.PaddingBottom = UDim.new(0, v or 0)
    end
    p.Parent = parent
    return p
end

local function listLayout(parent, dir, pad, ha, va)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 0)
    l.HorizontalAlignment = ha or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = va or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function newFrame(props)
    local f = Instance.new("Frame")
    for k, v in pairs(props or {}) do f[k] = v end
    return f
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end

local function newImage(props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.ScaleType = Enum.ScaleType.Fit
    for k, v in pairs(props or {}) do i[k] = v end
    return i
end

local function newButton(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = ""
    for k, v in pairs(props or {}) do b[k] = v end
    return b
end

-- Shadow image using the repo's Dropshadow asset
local function addShadow(parent, size, opacity)
    local s = newImage({
        Name = "Shadow",
        Image = Icons.DropShadow,
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 1 - (opacity or 0.55),
        Size = UDim2.new(1, size or 24, 1, size or 24),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = (parent.ZIndex or 1) - 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent,
    })
    return s
end

-- Hover colour tween helper
local function onHover(btn, normal, hovered, prop)
    prop = prop or "BackgroundColor3"
    btn.MouseEnter:Connect(function()
        tween(btn, T.Fast, { [prop] = hovered })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, T.Fast, { [prop] = normal })
    end)
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════

local NotifHost
local notifStack = {}

local function buildNotifHost(gui)
    NotifHost = newFrame({
        Name = "NotifHost",
        Size = UDim2.fromOffset(300, 600),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -14),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = gui,
    })
    listLayout(NotifHost, Enum.FillDirection.Vertical, 8)
end

local function sendNotif(opts)
    if not NotifHost then return end
    opts = opts or {}

    local typeColor = ({
        Success = T.Green,
        Error   = T.Red,
        Warning = T.Yellow,
        Info    = T.Purple,
    })[opts.Type or "Info"] or T.Purple

    local card = newFrame({
        Name = "Notif",
        Size = UDim2.fromOffset(280, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromHex("17141F"),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = NotifHost,
    })
    corner(card, 10)
    stroke(card, typeColor, 1, 0.5)
    addShadow(card, 20, 0.4)

    -- Left accent bar
    local bar = newFrame({
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = typeColor,
        ZIndex = 101,
        Parent = card,
    })
    corner(bar, 2)

    local inner = newFrame({
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 101,
        Parent = card,
    })
    padding(inner, nil, 4, 10)
    listLayout(inner, nil, 3)

    newLabel({
        Text = opts.Title or "Notification",
        TextColor3 = T.TextPri,
        Font = T.Semi,
        TextSize = T.S13,
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = 102,
        Parent = inner,
    })
    newLabel({
        Text = opts.Content or "",
        TextColor3 = T.TextSec,
        Font = T.Body,
        TextSize = T.S11,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        ZIndex = 102,
        Parent = inner,
    })

    -- Progress bar
    local progTrack = newFrame({
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.fromHex("1E1E28"),
        ZIndex = 102,
        Parent = inner,
    })
    corner(progTrack, 2)
    local progFill = newFrame({
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = typeColor,
        ZIndex = 103,
        Parent = progTrack,
    })
    corner(progFill, 2)

    -- Animate in
    tween(card, T.Base, { BackgroundTransparency = 0 })

    local duration = opts.Duration or 4
    task.delay(0.05, function()
        tween(progFill, TweenInfo.new(duration - 0.05, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
    end)

    task.delay(duration, function()
        tween(card, T.Smooth, { BackgroundTransparency = 1 })
        task.delay(0.35, function() card:Destroy() end)
    end)

    table.insert(notifStack, card)
    return card
end

-- ══════════════════════════════════════════════════════════════
--  DRAG SYSTEM
-- ══════════════════════════════════════════════════════════════

local function makeDraggable(handle, window)
    local dragging, startMouse, startPos = false, nil, nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging   = true
        startMouse = Vector2.new(inp.Position.X, inp.Position.Y)
        startPos   = window.Position
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d  = Vector2.new(inp.Position.X, inp.Position.Y) - startMouse
        local vp = workspace.CurrentCamera.ViewportSize
        local sp = startPos
        window.Position = UDim2.new(
            sp.X.Scale, math.clamp(sp.X.Offset + d.X, 0, vp.X - window.AbsoluteSize.X),
            sp.Y.Scale, math.clamp(sp.Y.Offset + d.Y, 0, vp.Y - window.AbsoluteSize.Y)
        )
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  RESIZE SYSTEM
-- ══════════════════════════════════════════════════════════════

local function makeResizable(handle, window)
    local resizing, startMouse, startSize = false, nil, nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        resizing   = true
        startMouse = Vector2.new(inp.Position.X, inp.Position.Y)
        startSize  = window.AbsoluteSize
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not resizing then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d  = Vector2.new(inp.Position.X, inp.Position.Y) - startMouse
        local nw = math.clamp(startSize.X + d.X, T.MinW, 1100)
        local nh = math.clamp(startSize.Y + d.Y, T.MinH, 720)
        window.Size = UDim2.fromOffset(nw, nh)
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  ELEMENT BUILDERS
-- ══════════════════════════════════════════════════════════════

local Elements = {}

-- ── Section Divider ──────────────────────────────────────────

function Elements.Section(container, opts)
    local f = newFrame({
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    newLabel({
        Text = (opts.Name or opts or ""):upper(),
        TextColor3 = T.TextAccent,
        Font = T.Semi,
        TextSize = T.S10,
        Size = UDim2.fromScale(1, 1),
        ZIndex = f.ZIndex + 1,
        Parent = f,
    })
    local line = newFrame({
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        ZIndex = f.ZIndex + 1,
        Parent = f,
    })
    return f
end

-- ── Label ────────────────────────────────────────────────────

function Elements.Label(container, opts)
    local text = type(opts) == "string" and opts or (opts.Name or opts.Text or "")
    local lbl = newLabel({
        Text = text,
        TextColor3 = T.TextSec,
        Font = T.Body,
        TextSize = T.S12,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    return lbl
end

-- ── Paragraph ────────────────────────────────────────────────

function Elements.Paragraph(container, opts)
    local f = newFrame({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Surface,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    corner(f, 8)
    stroke(f, T.Border)
    padding(f, 10)
    listLayout(f, nil, 4)

    newLabel({
        Text = opts.Title or "",
        TextColor3 = T.TextPri,
        Font = T.Semi,
        TextSize = T.S13,
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = f.ZIndex + 1,
        Parent = f,
    })
    newLabel({
        Text = opts.Content or "",
        TextColor3 = T.TextSec,
        Font = T.Body,
        TextSize = T.S12,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        ZIndex = f.ZIndex + 1,
        Parent = f,
    })
    return f
end

-- ── Button ───────────────────────────────────────────────────

function Elements.Button(container, opts)
    local btn = newButton({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromHex("1C1C26"),
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    corner(btn, 8)
    stroke(btn, T.Border)
    addShadow(btn, 8, 0.2)

    newLabel({
        Text = opts.Name or "Button",
        TextColor3 = T.TextPri,
        Font = T.Med,
        TextSize = T.S13,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = btn.ZIndex + 1,
        Parent = btn,
    })

    onHover(btn, Color3.fromHex("1C1C26"), Color3.fromHex("261C35"))

    btn.MouseButton1Down:Connect(function()
        tween(btn, T.Fast, { BackgroundColor3 = Color3.fromHex("341847") })
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, T.Fast, { BackgroundColor3 = Color3.fromHex("261C35") })
        if opts.Callback then
            task.spawn(opts.Callback)
        end
    end)

    -- Left accent glow line on hover
    local glowBar = newFrame({
        Size = UDim2.new(0, 2, 0.55, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.Purple,
        BackgroundTransparency = 1,
        ZIndex = btn.ZIndex + 2,
        Parent = btn,
    })
    corner(glowBar, 2)
    btn.MouseEnter:Connect(function()
        tween(glowBar, T.Fast, { BackgroundTransparency = 0 })
    end)
    btn.MouseLeave:Connect(function()
        tween(glowBar, T.Fast, { BackgroundTransparency = 1 })
    end)

    return btn
end

-- ── Toggle ───────────────────────────────────────────────────

function Elements.Toggle(container, opts)
    local value = opts.CurrentValue or false

    local row = newFrame({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Surface,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    corner(row, 8)
    stroke(row, T.Border)
    padding(row, nil, 12, 0)

    newLabel({
        Text = opts.Name or "Toggle",
        TextColor3 = T.TextPri,
        Font = T.Body,
        TextSize = T.S13,
        Size = UDim2.new(1, -52, 1, 0),
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })

    -- Track
    local track = newButton({
        Size = UDim2.fromOffset(40, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = value and T.ToggleOn or T.ToggleOff,
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })
    corner(track, 999)

    -- Knob
    local knob = newFrame({
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = track.ZIndex + 1,
        Parent = track,
    })
    corner(knob, 999)

    local function setState(v)
        value = v
        tween(track, T.Base, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff })
        tween(knob, T.Base, { Position = v and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 4, 0.5, 0) })
        if opts.Callback then task.spawn(opts.Callback, v) end
        if opts.Flag then _G["EthosFlags"] = _G["EthosFlags"] or {} _G["EthosFlags"][opts.Flag] = v end
    end

    track.MouseButton1Up:Connect(function() setState(not value) end)
    row.MouseButton1Up:Connect(function() setState(not value) end)

    onHover(row, T.Surface, T.SurfaceAlt)

    local api = {}
    function api:Set(v) setState(v) end
    function api:Get() return value end
    return row, api
end

-- ── Slider ───────────────────────────────────────────────────

function Elements.Slider(container, opts)
    local min     = opts.Range and opts.Range[1] or opts.Min or 0
    local max     = opts.Range and opts.Range[2] or opts.Max or 100
    local step    = opts.Increment or opts.Step or 1
    local value   = math.clamp(opts.CurrentValue or opts.Default or min, min, max)

    local row = newFrame({
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.Surface,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    corner(row, 8)
    stroke(row, T.Border)
    padding(row, nil, 12, 8)
    listLayout(row, nil, 6)

    -- Label row
    local labelRow = newFrame({
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })
    newLabel({
        Text = opts.Name or "Slider",
        TextColor3 = T.TextPri,
        Font = T.Body,
        TextSize = T.S13,
        Size = UDim2.new(1, -40, 1, 0),
        ZIndex = labelRow.ZIndex + 1,
        Parent = labelRow,
    })
    local valLabel = newLabel({
        Text = tostring(value),
        TextColor3 = T.Purple,
        Font = T.Mono,
        TextSize = T.S12,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 38, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        ZIndex = labelRow.ZIndex + 1,
        Parent = labelRow,
    })

    -- Track
    local track = newButton({
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = T.TrackBg,
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })
    corner(track, 999)

    local fill = newFrame({
        Size = UDim2.fromScale((value - min) / (max - min), 1),
        BackgroundColor3 = T.Purple,
        ZIndex = track.ZIndex + 1,
        Parent = track,
    })
    corner(fill, 999)

    local knob = newFrame({
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = T.PurpleGlow,
        ZIndex = track.ZIndex + 2,
        Parent = track,
    })
    corner(knob, 999)
    stroke(knob, T.Purple, 1)

    local function updateValue(v)
        v = math.clamp(v, min, max)
        if step > 0 then v = math.round(v / step) * step end
        value = v
        local pct = (v - min) / (max - min)
        tween(fill,  T.Fast, { Size = UDim2.fromScale(pct, 1) })
        tween(knob,  T.Fast, { Position = UDim2.new(pct, 0, 0.5, 0) })
        valLabel.Text = tostring(v)
        if opts.Callback then task.spawn(opts.Callback, v) end
        if opts.Flag then _G["EthosFlags"] = _G["EthosFlags"] or {} _G["EthosFlags"][opts.Flag] = v end
    end

    local dragging = false
    local function fromInput(input)
        local abs = track.AbsolutePosition
        local sz  = track.AbsoluteSize
        local pct = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
        updateValue(min + (max - min) * pct)
    end

    track.MouseButton1Down:Connect(function(_, inp) dragging = true fromInput(inp) end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then fromInput(inp) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local api = {}
    function api:Set(v) updateValue(v) end
    function api:Get() return value end
    return row, api
end

-- ── Dropdown ─────────────────────────────────────────────────

function Elements.Dropdown(container, opts)
    local options  = opts.Options or {}
    local selected = opts.CurrentOption or options[1] or ""
    local isOpen   = false

    local wrap = newFrame({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })

    -- Header
    local header = newButton({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Surface,
        ZIndex = wrap.ZIndex + 1,
        Parent = wrap,
    })
    corner(header, 8)
    stroke(header, T.Border)
    padding(header, nil, 12, 0)

    newLabel({
        Text = opts.Name or "Dropdown",
        TextColor3 = T.TextSec,
        Font = T.Body,
        TextSize = T.S11,
        Size = UDim2.new(0.5, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 4),
        ZIndex = header.ZIndex + 1,
        Parent = header,
    })
    local selLabel = newLabel({
        Text = selected,
        TextColor3 = T.TextPri,
        Font = T.Med,
        TextSize = T.S13,
        Size = UDim2.new(1, -26, 0, 16),
        Position = UDim2.new(0, 0, 1, -18),
        ZIndex = header.ZIndex + 1,
        Parent = header,
    })
    local arrow = newImage({
        Image = Icons.DropdownArrow,
        ImageColor3 = T.TextMuted,
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        ZIndex = header.ZIndex + 1,
        Parent = header,
    })

    -- List
    local list = newFrame({
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromHex("141418"),
        ClipsDescendants = true,
        ZIndex = 50,
        Parent = wrap,
    })
    corner(list, 8)
    stroke(list, T.Border)

    local listInner = newFrame({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 51,
        Parent = list,
    })
    padding(listInner, 4)
    listLayout(listInner, nil, 2)

    local optionHeight = 28
    for _, opt in ipairs(options) do
        local ob = newButton({
            Size = UDim2.new(1, 0, 0, optionHeight),
            BackgroundColor3 = opt == selected and Color3.fromHex("261840") or Color3.fromRGB(0,0,0),
            BackgroundTransparency = opt == selected and 0 or 1,
            ZIndex = 52,
            Parent = listInner,
        })
        corner(ob, 5)

        -- Checkmark for selected
        local check = newImage({
            Image = Icons.Checkmark,
            ImageColor3 = T.Purple,
            Size = UDim2.fromOffset(12, 12),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 8, 0.5, 0),
            ImageTransparency = opt == selected and 0 or 1,
            ZIndex = 53,
            Parent = ob,
        })
        newLabel({
            Text = opt,
            TextColor3 = opt == selected and T.Purple or T.TextPri,
            Font = T.Body,
            TextSize = T.S13,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 26, 0, 0),
            ZIndex = 53,
            Parent = ob,
        })

        onHover(ob,
            opt == selected and Color3.fromHex("261840") or Color3.fromRGB(0,0,0),
            Color3.fromHex("1E1830")
        )

        ob.MouseButton1Up:Connect(function()
            selected = opt
            selLabel.Text = opt
            -- update all option buttons
            for _, child in ipairs(listInner:GetChildren()) do
                if child:IsA("TextButton") then
                    tween(child, T.Fast, { BackgroundTransparency = 1 })
                    local lbl   = child:FindFirstChildOfClass("TextLabel")
                    local chk   = child:FindFirstChildOfClass("ImageLabel")
                    if lbl then tween(lbl, T.Fast, { TextColor3 = T.TextPri }) end
                    if chk then tween(chk, T.Fast, { ImageTransparency = 1 }) end
                end
            end
            tween(ob, T.Fast, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromHex("261840") })
            local lbl = ob:FindFirstChildOfClass("TextLabel")
            local chk = ob:FindFirstChildOfClass("ImageLabel")
            if lbl then tween(lbl, T.Fast, { TextColor3 = T.Purple }) end
            if chk then tween(chk, T.Fast, { ImageTransparency = 0 }) end

            isOpen = false
            tween(list,  T.Base, { Size = UDim2.new(1, 0, 0, 0) })
            tween(arrow, T.Base, { Rotation = 0 })
            if opts.Callback then task.spawn(opts.Callback, selected) end
            if opts.Flag then _G["EthosFlags"] = _G["EthosFlags"] or {} _G["EthosFlags"][opts.Flag] = selected end
        end)
    end

    local totalHeight = #options * (optionHeight + 2) + 8

    header.MouseButton1Up:Connect(function()
        isOpen = not isOpen
        tween(list,  T.Base, { Size = UDim2.new(1, 0, 0, isOpen and totalHeight or 0) })
        tween(arrow, T.Base, { Rotation = isOpen and 180 or 0 })
        -- expand wrap so it overlaps elements below
        tween(wrap, T.Base, { Size = UDim2.new(1, 0, 0, isOpen and 34 + totalHeight + 8 or 34) })
    end)

    onHover(header, T.Surface, T.SurfaceAlt)

    local api = {}
    function api:Set(v)
        selected = v
        selLabel.Text = v
    end
    function api:Get() return selected end
    return wrap, api
end

-- ── Input / Textbox ──────────────────────────────────────────

function Elements.Input(container, opts)
    local row = newFrame({
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.Surface,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    corner(row, 8)
    stroke(row, T.Border)
    padding(row, nil, 12, 8)
    listLayout(row, nil, 4)

    newLabel({
        Text = opts.Name or "Input",
        TextColor3 = T.TextSec,
        Font = T.Body,
        TextSize = T.S11,
        Size = UDim2.new(1, 0, 0, 14),
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })

    local inputFrame = newFrame({
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = T.InputBg,
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })
    corner(inputFrame, 6)
    local inputStroke = stroke(inputFrame, T.InputBorder)
    padding(inputFrame, nil, 8, 0)

    local box = Instance.new("TextBox")
    box.BackgroundTransparency = 1
    box.PlaceholderText  = opts.PlaceholderText or ""
    box.PlaceholderColor3= T.Placeholder
    box.Text             = opts.CurrentValue or ""
    box.TextColor3       = T.TextPri
    box.Font             = T.Body
    box.TextSize         = T.S13
    box.ClearTextOnFocus = opts.RemoveTextAfterFocusLost or false
    box.Size             = UDim2.fromScale(1, 1)
    box.ZIndex           = row.ZIndex + 2
    box.Parent           = inputFrame

    box.Focused:Connect(function()
        tween(inputStroke, T.Fast, { Color = T.Purple })
    end)
    box.FocusLost:Connect(function(enter)
        tween(inputStroke, T.Fast, { Color = T.InputBorder })
        if opts.Callback then task.spawn(opts.Callback, box.Text, enter) end
        if opts.Flag then _G["EthosFlags"] = _G["EthosFlags"] or {} _G["EthosFlags"][opts.Flag] = box.Text end
        if opts.RemoveTextAfterFocusLost then box.Text = "" end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if opts.OnChange then task.spawn(opts.OnChange, box.Text) end
    end)

    local api = {}
    function api:Set(v) box.Text = v end
    function api:Get() return box.Text end
    return row, api
end

-- ── Keybind ──────────────────────────────────────────────────

function Elements.Keybind(container, opts)
    local key       = opts.CurrentKeybind or "None"
    local listening = false
    local conn

    local row = newFrame({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Surface,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })
    corner(row, 8)
    stroke(row, T.Border)
    padding(row, nil, 12, 0)

    newLabel({
        Text = opts.Name or "Keybind",
        TextColor3 = T.TextPri,
        Font = T.Body,
        TextSize = T.S13,
        Size = UDim2.new(1, -90, 1, 0),
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })

    local bindBtn = newButton({
        Size = UDim2.fromOffset(80, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = T.InputBg,
        Text = key,
        TextColor3 = T.TextPri,
        Font = T.Mono,
        TextSize = T.S11,
        ZIndex = row.ZIndex + 1,
        Parent = row,
    })
    corner(bindBtn, 5)
    local bStroke = stroke(bindBtn, T.InputBorder)

    local function setKey(k)
        key = k
        bindBtn.Text = k
        if opts.Flag then _G["EthosFlags"] = _G["EthosFlags"] or {} _G["EthosFlags"][opts.Flag] = k end
    end

    bindBtn.MouseButton1Up:Connect(function()
        if listening then return end
        listening = true
        bindBtn.Text = "..."
        tween(bStroke, T.Fast, { Color = T.Red })
        conn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                setKey(inp.KeyCode.Name)
                listening = false
                tween(bStroke, T.Fast, { Color = T.InputBorder })
                if conn then conn:Disconnect() conn = nil end
            end
        end)
    end)

    -- Global key listener for callback
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or listening then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            if inp.KeyCode.Name == key then
                if opts.Callback then task.spawn(opts.Callback) end
            end
        end
    end)

    onHover(row, T.Surface, T.SurfaceAlt)

    local api = {}
    function api:Set(v) setKey(v) end
    function api:Get() return key end
    return row, api
end

-- ── ColorPicker ──────────────────────────────────────────────

function Elements.ColorPicker(container, opts)
    local color  = opts.Color or Color3.fromRGB(180, 50, 220)
    local isOpen = false
    local h, s, v = Color3.toHSV(color)

    local wrap = newFrame({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = container.ZIndex + 1,
        Parent = container,
    })

    local header = newButton({
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Surface,
        ZIndex = wrap.ZIndex + 1,
        Parent = wrap,
    })
    corner(header, 8)
    stroke(header, T.Border)
    padding(header, nil, 12, 0)

    newLabel({
        Text = opts.Name or "Color",
        TextColor3 = T.TextPri,
        Font = T.Body,
        TextSize = T.S13,
        Size = UDim2.new(1, -42, 1, 0),
        ZIndex = header.ZIndex + 1,
        Parent = header,
    })

    local swatch = newFrame({
        Size = UDim2.fromOffset(30, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = color,
        ZIndex = header.ZIndex + 1,
        Parent = header,
    })
    corner(swatch, 4)
    stroke(swatch, T.Border)

    -- Panel
    local panel = newFrame({
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = T.Surface,
        ClipsDescendants = true,
        ZIndex = 48,
        Parent = wrap,
    })
    corner(panel, 8)
    stroke(panel, T.Border)

    local panelInner = newFrame({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 49,
        Parent = panel,
    })
    padding(panelInner, 10)
    listLayout(panelInner, nil, 8)

    local function updateColor()
        color = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = color
        if opts.Callback then task.spawn(opts.Callback, color) end
        if opts.Flag then _G["EthosFlags"] = _G["EthosFlags"] or {} _G["EthosFlags"][opts.Flag] = color end
    end

    -- Build HSV sliders inside panel using inline slider logic
    local sliderDefs = {
        { label = "Hue",  get = function() return h end, set = function(x) h = x end, max = 1, step = 0.01 },
        { label = "Sat",  get = function() return s end, set = function(x) s = x end, max = 1, step = 0.01 },
        { label = "Val",  get = function() return v end, set = function(x) v = x end, max = 1, step = 0.01 },
    }

    for _, def in ipairs(sliderDefs) do
        local sf = newFrame({
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            ZIndex = 49,
            Parent = panelInner,
        })
        newLabel({
            Text = def.label,
            TextColor3 = T.TextSec,
            Font = T.Body,
            TextSize = T.S11,
            Size = UDim2.fromOffset(24, 22),
            ZIndex = 50,
            Parent = sf,
        })
        local track = newButton({
            Size = UDim2.new(1, -32, 0, 6),
            Position = UDim2.new(0, 30, 0.5, -3),
            BackgroundColor3 = T.TrackBg,
            ZIndex = 50,
            Parent = sf,
        })
        corner(track, 999)
        local fill = newFrame({
            Size = UDim2.fromScale(def.get(), 1),
            BackgroundColor3 = T.Purple,
            ZIndex = 51,
            Parent = track,
        })
        corner(fill, 999)
        local knob = newFrame({
            Size = UDim2.fromOffset(12, 12),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(def.get(), 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            ZIndex = 52,
            Parent = track,
        })
        corner(knob, 999)

        local draggingCP = false
        local function fromInputCP(inp)
            local abs = track.AbsolutePosition
            local sz  = track.AbsoluteSize
            local pct = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            pct = math.round(pct / def.step) * def.step
            def.set(pct)
            fill.Size = UDim2.fromScale(pct, 1)
            knob.Position = UDim2.new(pct, 0, 0.5, 0)
            updateColor()
        end
        track.MouseButton1Down:Connect(function(_, inp) draggingCP = true fromInputCP(inp) end)
        UserInputService.InputChanged:Connect(function(inp)
            if draggingCP and inp.UserInputType == Enum.UserInputType.MouseMovement then fromInputCP(inp) end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingCP = false end
        end)
    end

    -- Hex display
    local hexRow = newFrame({
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex = 49,
        Parent = panelInner,
    })
    newLabel({
        Text = "HEX",
        TextColor3 = T.TextSec,
        Font = T.Body,
        TextSize = T.S11,
        Size = UDim2.fromOffset(28, 24),
        ZIndex = 50,
        Parent = hexRow,
    })
    local hexBox = Instance.new("TextBox")
    hexBox.Size = UDim2.new(1, -36, 1, 0)
    hexBox.Position = UDim2.new(0, 32, 0, 0)
    hexBox.BackgroundColor3 = T.InputBg
    hexBox.TextColor3 = T.TextPri
    hexBox.Font = T.Mono
    hexBox.TextSize = T.S12
    hexBox.Text = "#" .. color:ToHex():upper()
    hexBox.ZIndex = 50
    hexBox.Parent = hexRow
    corner(hexBox, 4)
    stroke(hexBox, T.InputBorder)
    padding(hexBox, nil, 6, 0)

    local panelH = 3 * 30 + 24 + 10 * 2 + 8 * 4
    header.MouseButton1Up:Connect(function()
        isOpen = not isOpen
        tween(panel, T.Base, { Size = UDim2.new(1, 0, 0, isOpen and panelH or 0) })
        tween(wrap,  T.Base, { Size = UDim2.new(1, 0, 0, isOpen and 34 + panelH + 8 or 34) })
    end)
    onHover(header, T.Surface, T.SurfaceAlt)

    local api = {}
    function api:Set(c)
        color = c
        h, s, v = Color3.toHSV(c)
        swatch.BackgroundColor3 = c
    end
    function api:Get() return color end
    return wrap, api
end

-- ══════════════════════════════════════════════════════════════
--  TAB CONTENT AREA  (scrollable)
-- ══════════════════════════════════════════════════════════════

local function buildTabContent(parent, zindex)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = T.PurpleDim
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = zindex or 10
    scroll.Parent = parent
    padding(scroll, 10)
    listLayout(scroll, nil, 6)
    return scroll
end

-- ══════════════════════════════════════════════════════════════
--  SIDEBAR ICON BUTTON
-- ══════════════════════════════════════════════════════════════

local function buildSidebarBtn(parent, opts)
    local isActive = false
    local btn = newButton({
        Size = UDim2.new(1, 0, 0, T.SideW),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = parent,
    })

    -- Active bar
    local bar = newFrame({
        Size = UDim2.new(0, 2, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.Purple,
        BackgroundTransparency = 1,
        ZIndex = 12,
        Parent = btn,
    })
    corner(bar, 2)

    -- Icon (default/active pair)
    local icon = newImage({
        Image = opts.iconDefault or "",
        Size = UDim2.fromOffset(22, 22),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ImageColor3 = T.TextMuted,
        ZIndex = 12,
        Parent = btn,
    })

    -- Tooltip
    local tip = newFrame({
        Size = UDim2.fromOffset(0, 26),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(1, 8, 0.5, 0),
        BackgroundColor3 = T.SurfaceAlt,
        BackgroundTransparency = 1,
        ZIndex = 35,
        Visible = false,
        Parent = btn,
    })
    corner(tip, 5)
    stroke(tip, T.Border)
    padding(tip, nil, 8, 0)
    newLabel({
        Text = opts.tooltip or "",
        TextColor3 = T.TextPri,
        Font = T.Med,
        TextSize = T.S11,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 36,
        Parent = tip,
    })

    btn.MouseEnter:Connect(function()
        if not isActive then
            tween(btn, T.Fast, { BackgroundTransparency = 0, BackgroundColor3 = T.SidebarHov })
            tween(icon, T.Fast, { ImageColor3 = T.TextPri })
        end
        tip.Visible = true
        tween(tip, T.Fast, { BackgroundTransparency = 0 })
    end)
    btn.MouseLeave:Connect(function()
        if not isActive then
            tween(btn, T.Fast, { BackgroundTransparency = 1 })
            tween(icon, T.Fast, { ImageColor3 = T.TextMuted })
        end
        tip.Visible = false
    end)

    local function setActive(v)
        isActive = v
        if v then
            tween(btn,  T.Base, { BackgroundTransparency = 0, BackgroundColor3 = T.SidebarSel })
            tween(bar,  T.Base, { BackgroundTransparency = 0 })
            tween(icon, T.Base, { ImageColor3 = T.Purple })
            if opts.iconActive then icon.Image = opts.iconActive end
        else
            tween(btn,  T.Base, { BackgroundTransparency = 1 })
            tween(bar,  T.Base, { BackgroundTransparency = 1 })
            tween(icon, T.Base, { ImageColor3 = T.TextMuted })
            if opts.iconDefault then icon.Image = opts.iconDefault end
        end
    end

    return btn, setActive
end

-- ══════════════════════════════════════════════════════════════
--  WINDOW  +  TAB API
-- ══════════════════════════════════════════════════════════════

local function buildWindow(gui, opts)
    opts = opts or {}

    local vp = workspace.CurrentCamera.ViewportSize
    local winW = opts.Size and opts.Size[1] or T.WinW
    local winH = opts.Size and opts.Size[2] or T.WinH

    -- Root window
    local win = newFrame({
        Name = "EthosWindow",
        Size = UDim2.fromOffset(winW, winH),
        Position = UDim2.fromOffset(
            (vp.X - winW) / 2,
            (vp.Y - winH) / 2
        ),
        BackgroundColor3 = T.Bg,
        ZIndex = 10,
        ClipsDescendants = true,
        Parent = gui,
    })
    corner(win, 12)
    stroke(win, Color3.fromHex("2A1840"), 1)
    addShadow(win, 32, 0.65)

    -- ── Title Bar ────────────────────────────────────────────

    local titleBar = newFrame({
        Size = UDim2.new(1, 0, 0, T.TitleH),
        BackgroundColor3 = Color3.fromHex("0C0C10"),
        ZIndex = 12,
        Parent = win,
    })

    -- Bottom border on title bar
    newFrame({
        Size = UDim2.new(1, 0, 0, 1),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromHex("2A1840"),
        ZIndex = 13,
        Parent = titleBar,
    })

    -- Drag icon from assets
    newImage({
        Image = Icons.Drag,
        ImageColor3 = T.TextMuted,
        ImageTransparency = 0.5,
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        ZIndex = 13,
        Parent = titleBar,
    })

    -- Title text
    newLabel({
        Text = "ETHOS",
        TextColor3 = T.TextPri,
        Font = T.Bold,
        TextSize = T.S16,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 34, 0.5, 0),
        Size = UDim2.fromOffset(60, T.TitleH),
        ZIndex = 13,
        Parent = titleBar,
    })
    newLabel({
        Text = "// RE",
        TextColor3 = T.Purple,
        Font = T.Bold,
        TextSize = T.S16,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 92, 0.5, 0),
        Size = UDim2.fromOffset(50, T.TitleH),
        ZIndex = 13,
        Parent = titleBar,
    })

    -- Subtitle
    newLabel({
        Text = opts.LoadingSubtitle or "script hub",
        TextColor3 = T.TextMuted,
        Font = T.Body,
        TextSize = T.S10,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 34, 0.5, 9),
        Size = UDim2.fromOffset(120, 14),
        ZIndex = 13,
        Parent = titleBar,
    })

    -- Window control buttons
    local ctrlFrame = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(52, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        ZIndex = 13,
        Parent = titleBar,
    })

    local function makeCtrlBtn(xPos, icon, hoverColor, callback)
        local b = newButton({
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.fromOffset(xPos, 0),
            BackgroundColor3 = Color3.fromHex("202028"),
            ZIndex = 14,
            Parent = ctrlFrame,
        })
        corner(b, 5)
        newImage({
            Image = icon,
            ImageColor3 = T.TextSec,
            Size = UDim2.fromOffset(12, 12),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = 15,
            Parent = b,
        })
        onHover(b, Color3.fromHex("202028"), hoverColor)
        b.MouseButton1Up:Connect(callback)
        return b
    end

    makeCtrlBtn(0, Icons.Minimize, Color3.fromHex("3A3A4A"), function()
        win.Visible = false
    end)
    makeCtrlBtn(28, Icons.Close, T.RedDim, function()
        win.Visible = false
    end)

    makeDraggable(titleBar, win)

    -- ── Top Bar (Search + extras) ─────────────────────────────

    local topBar = newFrame({
        Size = UDim2.new(1, -T.SideW, 0, T.TopBarH),
        Position = UDim2.new(0, T.SideW, 0, T.TitleH),
        BackgroundColor3 = T.SurfaceAlt,
        ZIndex = 12,
        Parent = win,
    })
    newFrame({
        Size = UDim2.new(1, 0, 0, 1),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Border,
        ZIndex = 13,
        Parent = topBar,
    })
    padding(topBar, nil, 10, 6)

    -- Search box
    local searchBg = newFrame({
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.InputBg,
        ZIndex = 13,
        Parent = topBar,
    })
    corner(searchBg, 6)
    stroke(searchBg, T.InputBorder)
    padding(searchBg, nil, 8, 0)

    newImage({
        Image = Icons.Search,
        ImageColor3 = T.TextMuted,
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        ZIndex = 14,
        Parent = searchBg,
    })

    local searchBox = Instance.new("TextBox")
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = T.Placeholder
    searchBox.Text = ""
    searchBox.TextColor3 = T.TextPri
    searchBox.Font = T.Body
    searchBox.TextSize = T.S12
    searchBox.Size = UDim2.new(1, -20, 1, 0)
    searchBox.Position = UDim2.new(0, 20, 0, 0)
    searchBox.ZIndex = 14
    searchBox.Parent = searchBg

    -- ── Sidebar ───────────────────────────────────────────────

    local sidebar = newFrame({
        Size = UDim2.new(0, T.SideW, 1, -T.TitleH),
        Position = UDim2.new(0, 0, 0, T.TitleH),
        BackgroundColor3 = T.SidebarBg,
        ZIndex = 11,
        Parent = win,
    })
    -- Right border
    newFrame({
        Size = UDim2.new(0, 1, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Border,
        ZIndex = 12,
        Parent = sidebar,
    })
    listLayout(sidebar)

    -- ── Content Area ──────────────────────────────────────────

    local contentArea = newFrame({
        Size = UDim2.new(1, -T.SideW, 1, -(T.TitleH + T.TopBarH)),
        Position = UDim2.new(0, T.SideW, 0, T.TitleH + T.TopBarH),
        BackgroundColor3 = T.Bg,
        ZIndex = 10,
        ClipsDescendants = true,
        Parent = win,
    })

    -- ── Resize Handle ─────────────────────────────────────────

    local resHandle = newButton({
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = win,
    })
    newImage({
        Image = Icons.ResizeHandle,
        ImageColor3 = T.TextMuted,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 21,
        Parent = resHandle,
    })
    makeResizable(resHandle, win)

    -- ── Tab Management ────────────────────────────────────────

    local tabs         = {}
    local activeTabId  = nil
    local sidebarBtns  = {}

    local function switchTab(id)
        if activeTabId == id then return end
        -- Hide all
        for tid, data in pairs(tabs) do
            data.content.Visible = false
            if sidebarBtns[tid] then sidebarBtns[tid](false) end
        end
        -- Show new
        if tabs[id] then
            tabs[id].content.Visible = true
            if sidebarBtns[id] then sidebarBtns[id](true) end
            activeTabId = id
        end
    end

    -- Window API
    local WindowAPI = {}

    function WindowAPI:CreateTab(name, iconDefault, iconActive)
        local id = name .. tostring(#tabs + 1)

        -- Sidebar button
        local sBtn, setActive = buildSidebarBtn(sidebar, {
            iconDefault = iconDefault or "",
            iconActive  = iconActive  or iconDefault or "",
            tooltip     = name,
        })
        sBtn.MouseButton1Up:Connect(function() switchTab(id) end)
        sidebarBtns[id] = setActive

        -- Content scroll
        local scroll = buildTabContent(contentArea, 11)
        scroll.Visible = false

        tabs[id] = { name = name, content = scroll }

        -- Auto-switch to first tab
        if not activeTabId then switchTab(id) end

        -- Tab API
        local TabAPI = {}
        local tabZ   = 11

        function TabAPI:CreateSection(name)
            return Elements.Section(scroll, { Name = name })
        end

        function TabAPI:CreateLabel(text)
            return Elements.Label(scroll, text)
        end

        function TabAPI:CreateParagraph(opts2)
            return Elements.Paragraph(scroll, opts2)
        end

        function TabAPI:CreateButton(opts2)
            return Elements.Button(scroll, opts2)
        end

        function TabAPI:CreateToggle(opts2)
            local frame, api = Elements.Toggle(scroll, opts2)
            return api
        end

        function TabAPI:CreateSlider(opts2)
            local frame, api = Elements.Slider(scroll, opts2)
            return api
        end

        function TabAPI:CreateDropdown(opts2)
            local frame, api = Elements.Dropdown(scroll, opts2)
            return api
        end

        function TabAPI:CreateInput(opts2)
            local frame, api = Elements.Input(scroll, opts2)
            return api
        end

        function TabAPI:CreateKeybind(opts2)
            local frame, api = Elements.Keybind(scroll, opts2)
            return api
        end

        function TabAPI:CreateColorPicker(opts2)
            local frame, api = Elements.ColorPicker(scroll, opts2)
            return api
        end

        -- Search filtering
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower()
            for _, child in ipairs(scroll:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then
                    local lbl = child:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        child.Visible = q == "" or lbl.Text:lower():find(q, 1, true) ~= nil
                    end
                end
            end
        end)

        return TabAPI
    end

    function WindowAPI:ToggleKeybind(key)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == key then
                win.Visible = not win.Visible
            end
        end)
    end

    return WindowAPI, win
end

-- ══════════════════════════════════════════════════════════════
--  LIBRARY  API
-- ══════════════════════════════════════════════════════════════

local Ethos  = {}
local _gui

local function getGui()
    if _gui and _gui.Parent then return _gui end

    local sg = Instance.new("ScreenGui")
    sg.Name           = "EthosUI"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999
    sg.IgnoreGuiInset = true

    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    _gui = sg
    buildNotifHost(sg)
    return sg
end

function Ethos:CreateWindow(opts)
    opts = opts or {}
    local gui = getGui()
    local WindowAPI, win = buildWindow(gui, opts)

    -- Default toggle keybind
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    WindowAPI:ToggleKeybind(toggleKey)

    -- Flags table
    _G["EthosFlags"] = _G["EthosFlags"] or {}

    -- Loading screen (brief flash)
    if opts.LoadingTitle then
        local ls = newFrame({
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = T.Bg,
            ZIndex = 99,
            Parent = win,
        })
        newLabel({
            Text = opts.LoadingTitle,
            TextColor3 = T.Purple,
            Font = T.Bold,
            TextSize = T.S22,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.45),
            Size = UDim2.new(1, 0, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 100,
            Parent = ls,
        })
        newLabel({
            Text = opts.LoadingSubtitle or "",
            TextColor3 = T.TextSec,
            Font = T.Body,
            TextSize = T.S13,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.57),
            Size = UDim2.new(1, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 100,
            Parent = ls,
        })
        task.delay(1.2, function()
            tween(ls, T.Smooth, { BackgroundTransparency = 1 })
            for _, c in ipairs(ls:GetChildren()) do
                if c:IsA("TextLabel") then tween(c, T.Smooth, { TextTransparency = 1 }) end
            end
            task.delay(0.35, function() ls:Destroy() end)
        end)
    end

    return WindowAPI
end

function Ethos:Notify(opts)
    return sendNotif(opts)
end

function Ethos:Destroy()
    if _gui then _gui:Destroy() _gui = nil end
end

-- ══════════════════════════════════════════════════════════════
--  RETURN
-- ══════════════════════════════════════════════════════════════

return Ethos
