--[[
    Ethos UI Library — Main Module
    Builds the full draggable/resizable window, sidebar, tab system,
    and all tab content (Home, Scripts, Settings, Credits, ClientControl).
    
    Usage:
        local Ethos = require(path.to.main)
        local window = Ethos.new()
        window:addScript({ title="My Script", description="Does stuff", onExecute=function() end })
        window:show()
--]]

-- ─── Module Bootstrap ────────────────────────────────────────────────────────

local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer

-- Load Fusion (expected alongside main.lua or at ReplicatedStorage.Fusion)
local function tryRequire(path)
    local ok, result = pcall(require, path)
    return ok and result or nil
end

local Fusion = (
    tryRequire(script.Parent.Fusion) or
    tryRequire(game:GetService("ReplicatedStorage"):FindFirstChild("Fusion")) or
    error("[Ethos] Fusion module not found. Place Fusion.lua next to main.lua or in ReplicatedStorage.")
)

local Theme      = require(script.Parent.theme)
local Components = require(script.Parent.components)

-- Create root Fusion scope
local Scope = Fusion.scoped(Fusion)
Components.init(Fusion, Theme, Scope)

local u = Components._utils
local New       = u.New
local Spring    = u.Spring
local Tween     = u.Tween
local Value     = u.Value
local Computed  = u.Computed
local Observer  = u.Observer
local Corner    = u.Corner
local Stroke    = u.Stroke
local DropShadow= u.DropShadow
local Padding   = u.Padding
local ListLayout= u.ListLayout

-- ─── State ───────────────────────────────────────────────────────────────────

local activeTab     = Value("Home")
local windowVisible = Value(true)
local windowSize    = Value(Vector2.new(
    Theme.Window.DefaultSize.X,
    Theme.Window.DefaultSize.Y
))
local windowPos     = Value(Vector2.new(
    (workspace.CurrentCamera.ViewportSize.X - Theme.Window.DefaultSize.X) / 2,
    (workspace.CurrentCamera.ViewportSize.Y - Theme.Window.DefaultSize.Y) / 2
))
local searchText    = Value("")
local registeredScripts = Value({})

-- ─── Tabs definition ─────────────────────────────────────────────────────────

local TABS = {
    { id = "Home",          icon = Theme.Icons.Home,          tooltip = "Home"           },
    { id = "Scripts",       icon = Theme.Icons.Scripts,       tooltip = "Scripts"        },
    { id = "ClientControl", icon = Theme.Icons.ClientControl, tooltip = "Client Control" },
    { id = "CloudConfigs",  icon = Theme.Icons.CloudConfigs,  tooltip = "Cloud Configs"  },
    { id = "ModPanel",      icon = Theme.Icons.ModPanel,      tooltip = "Mod Panel"      },
    { id = "Settings",      icon = Theme.Icons.Settings,      tooltip = "Settings"       },
    { id = "Credits",       icon = Theme.Icons.Credits,       tooltip = "Credits"        },
}

-- ─── Drag System ─────────────────────────────────────────────────────────────

local function makeDraggable(handle, getPos, setPos)
    local dragging   = false
    local dragStart  = Vector2.zero
    local startPos   = Vector2.zero

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging  = true
        dragStart = Vector2.new(inp.Position.X, inp.Position.Y)
        startPos  = getPos()
    end)

    UserInput.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = Vector2.new(inp.Position.X, inp.Position.Y) - dragStart
        local vp    = workspace.CurrentCamera.ViewportSize
        local sz    = windowSize:get()
        local newX  = math.clamp(startPos.X + delta.X, 0, vp.X - sz.X)
        local newY  = math.clamp(startPos.Y + delta.Y, 0, vp.Y - sz.Y)
        setPos(Vector2.new(newX, newY))
    end)

    UserInput.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── Resize System ───────────────────────────────────────────────────────────

local function makeResizable(handle)
    local resizing  = false
    local startMouse= Vector2.zero
    local startSize = Vector2.zero

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        resizing   = true
        startMouse = Vector2.new(inp.Position.X, inp.Position.Y)
        startSize  = windowSize:get()
    end)

    UserInput.InputChanged:Connect(function(inp)
        if not resizing then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = Vector2.new(inp.Position.X, inp.Position.Y) - startMouse
        local newW  = math.clamp(startSize.X + delta.X, Theme.Window.MinSize.X, Theme.Window.MaxSize.X)
        local newH  = math.clamp(startSize.Y + delta.Y, Theme.Window.MinSize.Y, Theme.Window.MaxSize.Y)
        windowSize:set(Vector2.new(newW, newH))
    end)

    UserInput.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

-- ─── Notification Host ───────────────────────────────────────────────────────

local notifHost

local function sendNotification(opts)
    if notifHost then
        Components.Notification(notifHost, opts)
    end
end

-- ─── Tab Content Builders ────────────────────────────────────────────────────

local function buildHomeTab(parent)
    local container = New("ScrollingFrame") {
        Name             = "HomeTab",
        Parent           = parent,
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible          = Computed(function(use) return use(activeTab) == "Home" end),
        ZIndex           = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Large),
        ListLayout(nil, Theme.Spacing.Medium),
    }

    -- Welcome banner
    local banner = New("Frame") {
        Name             = "Banner",
        Parent           = container,
        Size             = UDim2.new(1, 0, 0, 100),
        BackgroundColor3 = Theme.Colors.SurfaceAlt,
        LayoutOrder      = 0,
        ZIndex           = Theme.ZIndex.Content + 1,
        Corner(Theme.Radius.XLarge),
        DropShadow(nil, 12, 0.4),

        -- Purple gradient overlay
        New("Frame") {
            Size             = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0.85,
            BackgroundColor3 = Theme.Colors.AccentPrimary,
            ZIndex           = Theme.ZIndex.Content + 1,
            Corner(Theme.Radius.XLarge),
        },

        Stroke(Theme.Colors.AccentPrimaryDim, 1, 0.4),

        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = "ETHOS // RE",
            TextColor3 = Theme.Colors.TextPrimary,
            Font       = Theme.Fonts.Title,
            TextSize   = Theme.TextSize.Display,
            Size       = UDim2.new(1, -120, 1, 0),
            Position   = UDim2.new(0, 20, 0, 0),
            ZIndex     = Theme.ZIndex.Content + 2,
        },
        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = "SCRIPT HUB",
            TextColor3 = Theme.Colors.AccentPrimary,
            Font       = Theme.Fonts.Heading,
            TextSize   = Theme.TextSize.Base,
            AnchorPoint = Vector2.new(0, 0),
            Size       = UDim2.new(1, 0, 0, 18),
            Position   = UDim2.new(0, 22, 0, 62),
            ZIndex     = Theme.ZIndex.Content + 2,
        },

        -- Version badge
        Components.Badge {
            Text   = "v2.0",
            Color  = Theme.Colors.AccentPrimaryDim,
            ZIndex = Theme.ZIndex.Content + 3,
        }
    }

    -- Player info card
    local infoCard = Components.Section {
        Name  = "PlayerCard",
        Title = "PLAYER INFO",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            New("Frame") {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 48),
                ZIndex = Theme.ZIndex.Content + 2,

                -- Avatar icon placeholder
                New("Frame") {
                    Size             = UDim2.fromOffset(40, 40),
                    AnchorPoint      = Vector2.new(0, 0.5),
                    Position         = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = Theme.Colors.SidebarActive,
                    ZIndex           = Theme.ZIndex.Content + 3,
                    Corner(Theme.Radius.Full),
                    New("ImageLabel") {
                        BackgroundTransparency = 1,
                        Image       = Theme.Icons.User,
                        ImageColor3 = Theme.Colors.AccentPrimary,
                        Size        = UDim2.fromOffset(22, 22),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position    = UDim2.fromScale(0.5, 0.5),
                        ZIndex      = Theme.ZIndex.Content + 4,
                        ScaleType   = Enum.ScaleType.Fit,
                    },
                },

                New("Frame") {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -52, 1, 0),
                    Position = UDim2.new(0, 52, 0, 0),
                    ZIndex   = Theme.ZIndex.Content + 3,
                    ListLayout(nil, 2),

                    New("TextLabel") {
                        BackgroundTransparency = 1,
                        Text       = LocalPlayer and LocalPlayer.Name or "Player",
                        TextColor3 = Theme.Colors.TextPrimary,
                        Font       = Theme.Fonts.Heading,
                        TextSize   = Theme.TextSize.Medium,
                        Size       = UDim2.new(1, 0, 0, 18),
                        ZIndex     = Theme.ZIndex.Content + 4,
                    },
                    New("TextLabel") {
                        BackgroundTransparency = 1,
                        Text       = "Rank: Owner",
                        TextColor3 = Theme.Colors.AccentPrimary,
                        Font       = Theme.Fonts.Body,
                        TextSize   = Theme.TextSize.Small,
                        Size       = UDim2.new(1, 0, 0, 14),
                        ZIndex     = Theme.ZIndex.Content + 4,
                    },
                },
            },
        }
    }
    infoCard.Parent = container
    infoCard.LayoutOrder = 1

    -- Quick stats
    local statsSection = Components.Section {
        Name  = "QuickStats",
        Title = "QUICK STATS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local stats = {
                    { label = "Game",    value = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or tostring(game.PlaceId) },
                    { label = "Job ID",  value = tostring(game.JobId):sub(1,8).."…" },
                    { label = "Players", value = tostring(#Players:GetPlayers()) },
                    { label = "FPS",     value = "60" },
                }
                local rows = {}
                for _, s in ipairs(stats) do
                    table.insert(rows, New("Frame") {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = Theme.ZIndex.Content + 2,

                        New("TextLabel") {
                            BackgroundTransparency = 1,
                            Text       = s.label,
                            TextColor3 = Theme.Colors.TextSecondary,
                            Font       = Theme.Fonts.Body,
                            TextSize   = Theme.TextSize.Base,
                            Size       = UDim2.new(0.5, 0, 1, 0),
                            ZIndex     = Theme.ZIndex.Content + 3,
                        },
                        New("TextLabel") {
                            BackgroundTransparency = 1,
                            Text       = s.value,
                            TextColor3 = Theme.Colors.TextPrimary,
                            Font       = Theme.Fonts.Mono,
                            TextSize   = Theme.TextSize.Base,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Size       = UDim2.new(0.5, 0, 1, 0),
                            Position   = UDim2.fromScale(0.5, 0),
                            ZIndex     = Theme.ZIndex.Content + 3,
                        },
                    })
                end
                return table.unpack(rows)
            end)(),
        }
    }
    statsSection.Parent = container
    statsSection.LayoutOrder = 2

    return container
end

local function buildScriptsTab(parent)
    local container = New("Frame") {
        Name    = "ScriptsTab",
        Parent  = parent,
        Size    = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = Computed(function(use) return use(activeTab) == "Scripts" end),
        ZIndex  = Theme.ZIndex.Content,
    }

    -- Search bar at top
    local searchBox, _ = Components.Textbox {
        Placeholder = "Search scripts…",
        Icon        = Theme.Icons.Search,
        Size        = UDim2.new(1, 0, 0, 34),
        Value       = searchText,
        OnChange    = function(v) searchText:set(v) end,
    }
    searchBox.Parent   = container
    searchBox.Position = UDim2.new(0, 0, 0, 0)

    -- Scripts list
    local list = New("ScrollingFrame") {
        Name             = "ScriptList",
        Parent           = container,
        Size             = UDim2.new(1, 0, 1, -46),
        Position         = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex           = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Base),
        ListLayout(nil, Theme.Spacing.Base),
    }

    -- Reactive: rebuild list when scripts or search changes
    local function rebuildList()
        -- clear old cards
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local query  = searchText:get():lower()
        local scripts= registeredScripts:get()
        for i, sc in ipairs(scripts) do
            local title = sc.title or ("Script "..i)
            if query == "" or title:lower():find(query, 1, true) then
                local card = Components.ScriptCard {
                    Title       = title,
                    Description = sc.description or "",
                    Icon        = sc.icon or Theme.Icons.Scripts,
                    AccentColor = sc.accent or Theme.Colors.AccentPrimary,
                    OnExecute   = function()
                        if sc.onExecute then
                            local ok, err = pcall(sc.onExecute)
                            if ok then
                                sendNotification { Type="success", Title="Executed", Message=title }
                            else
                                sendNotification { Type="error",   Title="Error",    Message=tostring(err) }
                            end
                        end
                    end,
                    Order = i,
                    ZIndex= Theme.ZIndex.Content + 1,
                }
                card.Parent = list
            end
        end
    end

    Observer(searchText,       function() rebuildList() end)
    Observer(registeredScripts,function() rebuildList() end)
    task.defer(rebuildList)

    return container
end

local function buildSettingsTab(parent)
    local container = New("ScrollingFrame") {
        Name    = "SettingsTab",
        Parent  = parent,
        Size    = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = Computed(function(use) return use(activeTab) == "Settings" end),
        ZIndex  = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Large),
        ListLayout(nil, Theme.Spacing.Medium),
    }

    -- Appearance section
    local appearanceSection = Components.Section {
        Name  = "Appearance",
        Title = "APPEARANCE",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local _, toggleState = Components.Toggle {
                    Label = "Glassmorphism Effects",
                    ZIndex= Theme.ZIndex.Content + 2,
                    OnToggle = function(v)
                        sendNotification { Type="info", Title="Setting Updated", Message="Glassmorphism: " .. (v and "On" or "Off") }
                    end,
                }
                return _, toggleState
            end)(),
            (function()
                local _, toggleState = Components.Toggle {
                    Label = "Neon Glow",
                    Value = Value(true),
                    ZIndex= Theme.ZIndex.Content + 2,
                }
                return _, toggleState
            end)(),
            (function()
                local _, toggleState = Components.Toggle {
                    Label = "Drop Shadows",
                    Value = Value(true),
                    ZIndex= Theme.ZIndex.Content + 2,
                }
                return _, toggleState
            end)(),
            Components.Separator { Order = 10 },
            (function()
                local slider, _ = Components.Slider {
                    Label   = "UI Scale",
                    Min     = 70, Max = 130, Step = 5, Default = 100,
                    ZIndex  = Theme.ZIndex.Content + 2,
                    OnChange= function(v)
                        -- scale logic would go here
                    end,
                }
                return slider
            end)(),
            (function()
                local slider, _ = Components.Slider {
                    Label   = "Background Blur",
                    Min     = 0, Max = 20, Step = 1, Default = 8,
                    ZIndex  = Theme.ZIndex.Content + 2,
                }
                return slider
            end)(),
        },
    }
    appearanceSection.Parent = container
    appearanceSection.LayoutOrder = 0

    -- Keybinds section
    local keybindsSection = Components.Section {
        Name  = "Keybinds",
        Title = "KEYBINDS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local kb, _ = Components.Keybind {
                    Label   = "Toggle UI",
                    Default = Enum.KeyCode.RightShift,
                    ZIndex  = Theme.ZIndex.Content + 2,
                    OnBind  = function(key)
                        sendNotification { Type="info", Title="Keybind Set", Message="Toggle UI → "..key.Name }
                    end,
                }
                return kb
            end)(),
            (function()
                local kb, _ = Components.Keybind {
                    Label   = "Minimize",
                    Default = Enum.KeyCode.M,
                    ZIndex  = Theme.ZIndex.Content + 2,
                }
                return kb
            end)(),
        },
    }
    keybindsSection.Parent = container
    keybindsSection.LayoutOrder = 1

    -- Color section
    local colorSection = Components.Section {
        Name  = "Colors",
        Title = "ACCENT COLORS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local cp, _ = Components.ColorPicker {
                    Label   = "Primary Accent",
                    Default = Theme.Colors.AccentPrimary,
                    ZIndex  = Theme.ZIndex.Content + 2,
                }
                return cp
            end)(),
            (function()
                local cp, _ = Components.ColorPicker {
                    Label   = "Secondary Accent",
                    Default = Theme.Colors.AccentRed,
                    ZIndex  = Theme.ZIndex.Content + 2,
                }
                return cp
            end)(),
        },
    }
    colorSection.Parent = container
    colorSection.LayoutOrder = 2

    -- Notifications section
    local notifSection = Components.Section {
        Name  = "Notifications",
        Title = "NOTIFICATIONS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local _, v = Components.Toggle { Label = "Show Notifications", Value = Value(true), ZIndex = Theme.ZIndex.Content + 2 }
                return _, v
            end)(),
            (function()
                local slider, _ = Components.Slider {
                    Label = "Duration (s)", Min = 1, Max = 10, Step = 0.5, Default = 4,
                    ZIndex = Theme.ZIndex.Content + 2,
                }
                return slider
            end)(),
            Components.Button {
                Text    = "Test Notification",
                BgColor = Theme.Colors.ButtonBg,
                ZIndex  = Theme.ZIndex.Content + 2,
                OnClick = function()
                    sendNotification { Type="success", Title="Test Notification", Message="This is a test notification from Ethos!", Duration = 3 }
                end,
            },
        },
    }
    notifSection.Parent = container
    notifSection.LayoutOrder = 3

    return container
end

local function buildClientControlTab(parent)
    local container = New("ScrollingFrame") {
        Name    = "ClientControlTab",
        Parent  = parent,
        Size    = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = Computed(function(use) return use(activeTab) == "ClientControl" end),
        ZIndex  = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Large),
        ListLayout(nil, Theme.Spacing.Medium),
    }

    -- Player Controls
    local playerSection = Components.Section {
        Name  = "PlayerControls",
        Title = "PLAYER CONTROLS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local _, v = Components.Toggle {
                    Label  = "Infinite Jump",
                    ZIndex = Theme.ZIndex.Content + 2,
                    OnToggle = function(enabled)
                        local UIS = game:GetService("UserInputService")
                        if enabled then
                            LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and
                                -- Hook jump
                                pcall(function()
                                    UIS.JumpRequest:Connect(function()
                                        if LocalPlayer.Character then
                                            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                                            if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                                                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                            end
                                        end
                                    end)
                                end)
                        end
                    end,
                }
                return _, v
            end)(),
            (function()
                local _, v = Components.Toggle { Label = "No Clip", ZIndex = Theme.ZIndex.Content + 2 }
                return _, v
            end)(),
            (function()
                local _, v = Components.Toggle { Label = "Speed Hack", ZIndex = Theme.ZIndex.Content + 2 }
                return _, v
            end)(),
            (function()
                local s, _ = Components.Slider {
                    Label = "Walk Speed", Min = 16, Max = 200, Step = 2, Default = 16,
                    ZIndex = Theme.ZIndex.Content + 2,
                    OnChange = function(v)
                        if LocalPlayer.Character then
                            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum.WalkSpeed = v end
                        end
                    end,
                }
                return s
            end)(),
            (function()
                local s, _ = Components.Slider {
                    Label = "Jump Power", Min = 50, Max = 400, Step = 10, Default = 50,
                    ZIndex = Theme.ZIndex.Content + 2,
                    OnChange = function(v)
                        if LocalPlayer.Character then
                            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum.JumpPower = v end
                        end
                    end,
                }
                return s
            end)(),
        },
    }
    playerSection.Parent = container
    playerSection.LayoutOrder = 0

    -- Camera Controls
    local cameraSection = Components.Section {
        Name  = "CameraControls",
        Title = "CAMERA",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local s, _ = Components.Slider {
                    Label = "FOV", Min = 30, Max = 120, Step = 5, Default = 70,
                    ZIndex = Theme.ZIndex.Content + 2,
                    OnChange = function(v)
                        workspace.CurrentCamera.FieldOfView = v
                    end,
                }
                return s
            end)(),
            (function()
                local dd, _ = Components.Dropdown {
                    Label   = "Camera Mode",
                    Options = { "Default", "Classic", "Follow", "Attach", "Watch" },
                    Default = "Default",
                    ZIndex  = Theme.ZIndex.Content + 2,
                }
                return dd
            end)(),
        },
    }
    cameraSection.Parent = container
    cameraSection.LayoutOrder = 1

    -- Rendering
    local renderSection = Components.Section {
        Name  = "Rendering",
        Title = "RENDERING",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local dd, _ = Components.Dropdown {
                    Options = { "Automatic", "Level01", "Level02", "Level03", "Level04", "Level05", "Level06", "Level07", "Level08", "Level09", "Level10" },
                    Default = "Automatic",
                    ZIndex  = Theme.ZIndex.Content + 2,
                    OnSelect = function(v)
                        if v ~= "Automatic" then
                            game:GetService("Lighting").GlobalShadows = false
                        end
                    end,
                }
                return dd
            end)(),
            (function()
                local _, v = Components.Toggle { Label = "Fullbright", ZIndex = Theme.ZIndex.Content + 2,
                    OnToggle = function(en)
                        game:GetService("Lighting").Brightness = en and 2 or 1
                    end,
                }
                return _, v
            end)(),
        },
    }
    renderSection.Parent = container
    renderSection.LayoutOrder = 2

    return container
end

local function buildCloudConfigsTab(parent)
    local container = New("ScrollingFrame") {
        Name    = "CloudConfigsTab",
        Parent  = parent,
        Size    = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = Computed(function(use) return use(activeTab) == "CloudConfigs" end),
        ZIndex  = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Large),
        ListLayout(nil, Theme.Spacing.Medium),
    }

    local configSection = Components.Section {
        Name  = "CloudSync",
        Title = "CLOUD CONFIGURATION",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            Components.Label {
                Text       = "Sync your settings across sessions with cloud storage.",
                Color      = Theme.Colors.TextSecondary,
                FrameSize  = UDim2.new(1, 0, 0, 28),
                Size       = Theme.TextSize.Base,
                Rich       = false,
            },
            (function()
                local tb, _ = Components.Textbox {
                    Placeholder = "Config Name",
                    Size   = UDim2.new(1, 0, 0, 32),
                    ZIndex = Theme.ZIndex.Content + 2,
                }
                return tb
            end)(),
            New("Frame") {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                ZIndex = Theme.ZIndex.Content + 2,

                Components.Button {
                    Text    = "Save Config",
                    Size    = UDim2.new(0.48, 0, 1, 0),
                    BgColor = Theme.Colors.AccentPrimaryDim,
                    ZIndex  = Theme.ZIndex.Content + 3,
                    OnClick = function()
                        sendNotification { Type="success", Title="Config Saved", Message="Configuration saved to cloud." }
                    end,
                },
                (function()
                    local btn = Components.Button {
                        Text     = "Load Config",
                        Size     = UDim2.new(0.48, 0, 1, 0),
                        Position = UDim2.new(0.52, 0, 0, 0),
                        BgColor  = Theme.Colors.ButtonBg,
                        ZIndex   = Theme.ZIndex.Content + 3,
                        OnClick  = function()
                            sendNotification { Type="info", Title="Config Loaded", Message="Configuration loaded from cloud." }
                        end,
                    }
                    return btn
                end)(),
            },
        },
    }
    configSection.Parent = container
    configSection.LayoutOrder = 0

    return container
end

local function buildModPanelTab(parent)
    local container = New("ScrollingFrame") {
        Name    = "ModPanelTab",
        Parent  = parent,
        Size    = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = Computed(function(use) return use(activeTab) == "ModPanel" end),
        ZIndex  = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Large),
        ListLayout(nil, Theme.Spacing.Medium),
    }

    local modSection = Components.Section {
        Name  = "ModTools",
        Title = "MODERATION TOOLS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = {
            (function()
                local dd, _ = Components.Dropdown {
                    Label   = "Target Player",
                    Options = (function()
                        local names = {}
                        for _, p in ipairs(Players:GetPlayers()) do
                            table.insert(names, p.Name)
                        end
                        return names
                    end)(),
                    ZIndex = Theme.ZIndex.Content + 2,
                }
                return dd
            end)(),
            New("Frame") {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                ZIndex = Theme.ZIndex.Content + 2,

                Components.Button {
                    Text   = "Kick",
                    Size   = UDim2.new(0.3, -4, 1, 0),
                    BgColor= Theme.Colors.AccentRedDim,
                    ZIndex = Theme.ZIndex.Content + 3,
                    OnClick= function()
                        sendNotification { Type="error", Title="Kick", Message="Action sent." }
                    end,
                },
            },
            (function()
                local _, v = Components.Toggle { Label = "Spectate Mode", ZIndex = Theme.ZIndex.Content + 2 }
                return _, v
            end)(),
        },
    }
    modSection.Parent = container
    modSection.LayoutOrder = 0

    return container
end

local function buildCreditsTab(parent)
    local container = New("ScrollingFrame") {
        Name    = "CreditsTab",
        Parent  = parent,
        Size    = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.AccentPrimaryDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = Computed(function(use) return use(activeTab) == "Credits" end),
        ZIndex  = Theme.ZIndex.Content,
        Padding(Theme.Spacing.Large),
        ListLayout(nil, Theme.Spacing.Medium),
    }

    local credits = {
        { role = "Developer",       name = "laderite",    color = Theme.Colors.AccentPrimary },
        { role = "UI Design",       name = "Ethos Team",  color = Theme.Colors.AccentPrimary },
        { role = "Framework",       name = "dphfox (Fusion 0.3)", color = Theme.Colors.TextSecondary },
        { role = "Special Thanks",  name = "Community",   color = Theme.Colors.TextSecondary },
    }

    -- Hero logo section
    local heroSection = New("Frame") {
        Name   = "Hero",
        Parent = container,
        Size   = UDim2.new(1, 0, 0, 110),
        BackgroundColor3 = Theme.Colors.SurfaceAlt,
        LayoutOrder = 0,
        ZIndex = Theme.ZIndex.Content + 1,
        Corner(Theme.Radius.XLarge),
        Stroke(Theme.Colors.AccentPrimaryDim, 1, 0.5),
        DropShadow(nil, 12, 0.35),

        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = "ETHOS // RE",
            TextColor3 = Theme.Colors.AccentPrimary,
            Font       = Theme.Fonts.Title,
            TextSize   = Theme.TextSize.Display,
            AnchorPoint= Vector2.new(0.5, 0.4),
            Position   = UDim2.fromScale(0.5, 0.4),
            Size       = UDim2.new(1, 0, 0, 36),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex     = Theme.ZIndex.Content + 2,
        },
        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = "by laderite & the Ethos Team",
            TextColor3 = Theme.Colors.TextSecondary,
            Font       = Theme.Fonts.Body,
            TextSize   = Theme.TextSize.Small,
            AnchorPoint= Vector2.new(0.5, 0),
            Position   = UDim2.new(0.5, 0, 0, 72),
            Size       = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex     = Theme.ZIndex.Content + 2,
        },
    }

    -- Credit rows
    local creditsSection = Components.Section {
        Name  = "Credits",
        Title = "CREDITS",
        ZIndex= Theme.ZIndex.Content + 1,
        Children = (function()
            local rows = {}
            for _, c in ipairs(credits) do
                table.insert(rows, New("Frame") {
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(1, 0, 0, 26),
                    ZIndex = Theme.ZIndex.Content + 2,

                    New("TextLabel") {
                        BackgroundTransparency = 1,
                        Text       = c.role,
                        TextColor3 = Theme.Colors.TextSecondary,
                        Font       = Theme.Fonts.Body,
                        TextSize   = Theme.TextSize.Base,
                        Size       = UDim2.new(0.5, 0, 1, 0),
                        ZIndex     = Theme.ZIndex.Content + 3,
                    },
                    New("TextLabel") {
                        BackgroundTransparency = 1,
                        Text       = c.name,
                        TextColor3 = c.color,
                        Font       = Theme.Fonts.Heading,
                        TextSize   = Theme.TextSize.Base,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        AnchorPoint= Vector2.new(1, 0),
                        Size       = UDim2.new(0.5, 0, 1, 0),
                        Position   = UDim2.new(1, 0, 0, 0),
                        ZIndex     = Theme.ZIndex.Content + 3,
                    },
                })
            end
            return rows
        end)(),
    }
    creditsSection.Parent = container
    creditsSection.LayoutOrder = 1

    -- Discord link
    local discordBtn = Components.Button {
        Text    = "Join Discord",
        BgColor = Color3.fromRGB(88, 101, 242),
        ZIndex  = Theme.ZIndex.Content + 2,
        OnClick = function()
            sendNotification { Type="info", Title="Discord", Message="discord.gg/ethos (placeholder)" }
        end,
    }
    discordBtn.Parent = container
    discordBtn.LayoutOrder = 2
    discordBtn.Size = UDim2.new(1, 0, 0, 34)

    return container
end

-- ─── Window Builder ──────────────────────────────────────────────────────────

local function buildWindow(screenGui)
    -- Main window frame
    local window = New("Frame") {
        Name             = "EthosWindow",
        Parent           = screenGui,
        Size             = Computed(function(use)
            local s = use(windowSize)
            return UDim2.fromOffset(s.X, s.Y)
        end),
        Position         = Computed(function(use)
            local p = use(windowPos)
            return UDim2.fromOffset(p.X, p.Y)
        end),
        BackgroundColor3 = Theme.Colors.Background,
        Visible          = Computed(function(use) return use(windowVisible) end),
        ZIndex           = Theme.ZIndex.Window,
        ClipsDescendants = true,

        Corner(Theme.Radius.Large),
        Stroke(Theme.Colors.TitleBarBorder, 1),
        DropShadow(nil, 24, 0.7),
    }

    -- ── Title Bar ────────────────────────────────────────────────────────────

    local titleBar = New("Frame") {
        Name             = "TitleBar",
        Parent           = window,
        Size             = UDim2.new(1, 0, 0, Theme.Window.TitleBarHeight),
        BackgroundColor3 = Theme.Colors.TitleBarBg,
        ZIndex           = Theme.ZIndex.Window + 2,

        -- Bottom border
        New("Frame") {
            Size             = UDim2.new(1, 0, 0, 1),
            AnchorPoint      = Vector2.new(0, 1),
            Position         = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Colors.TitleBarBorder,
            ZIndex           = Theme.ZIndex.Window + 3,
        },

        -- Logo / Title
        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = "ETHOS // RE",
            TextColor3 = Theme.Colors.TitleText,
            Font       = Theme.Fonts.Title,
            TextSize   = Theme.TextSize.Large,
            Size       = UDim2.new(1, -90, 1, 0),
            Position   = UDim2.new(0, 14, 0, 0),
            ZIndex     = Theme.ZIndex.Window + 3,
        },
        New("TextLabel") {
            BackgroundTransparency = 1,
            Text       = "SCRIPT HUB",
            TextColor3 = Theme.Colors.AccentPrimary,
            Font       = Theme.Fonts.Body,
            TextSize   = Theme.TextSize.XSmall,
            AnchorPoint= Vector2.new(0, 0.5),
            Size       = UDim2.new(0, 80, 0, 12),
            Position   = UDim2.new(0, 14, 0, 22),
            ZIndex     = Theme.ZIndex.Window + 3,
        },

        -- Window controls (X and —)
        New("Frame") {
            Name             = "WindowControls",
            BackgroundTransparency = 1,
            Size             = UDim2.fromOffset(56, 22),
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -10, 0.5, 0),
            ZIndex           = Theme.ZIndex.Window + 3,

            -- Minimize
            (function()
                local isHov = Value(false)
                return New("TextButton") {
                    Name             = "Minimize",
                    Size             = UDim2.fromOffset(22, 22),
                    BackgroundColor3 = Spring(Computed(function(use)
                        return use(isHov) and Color3.fromRGB(60,60,75) or Color3.fromRGB(35,35,45)
                    end), Theme.Springs.Hover),
                    AutoButtonColor  = false,
                    Text             = "—",
                    TextColor3       = Theme.Colors.TextSecondary,
                    Font             = Theme.Fonts.Heading,
                    TextSize         = 12,
                    ZIndex           = Theme.ZIndex.Window + 4,

                    [Fusion.OnEvent "MouseEnter"]  = function() isHov:set(true)  end,
                    [Fusion.OnEvent "MouseLeave"]  = function() isHov:set(false) end,
                    [Fusion.OnEvent "MouseButton1Up"] = function()
                        windowVisible:set(false)
                    end,

                    Corner(Theme.Radius.Small),
                }
            end)(),

            -- Close
            (function()
                local isHov = Value(false)
                return New("TextButton") {
                    Name             = "Close",
                    Size             = UDim2.fromOffset(22, 22),
                    Position         = UDim2.fromOffset(28, 0),
                    BackgroundColor3 = Spring(Computed(function(use)
                        return use(isHov) and Theme.Colors.AccentRed or Color3.fromRGB(35,35,45)
                    end), Theme.Springs.Hover),
                    AutoButtonColor  = false,
                    Text             = "✕",
                    TextColor3       = Spring(Computed(function(use)
                        return use(isHov) and Theme.Colors.White or Theme.Colors.TextSecondary
                    end), Theme.Springs.Hover),
                    Font             = Theme.Fonts.Heading,
                    TextSize         = 12,
                    ZIndex           = Theme.ZIndex.Window + 4,

                    [Fusion.OnEvent "MouseEnter"]  = function() isHov:set(true)  end,
                    [Fusion.OnEvent "MouseLeave"]  = function() isHov:set(false) end,
                    [Fusion.OnEvent "MouseButton1Up"] = function()
                        windowVisible:set(false)
                    end,

                    Corner(Theme.Radius.Small),
                }
            end)(),
        },
    }

    -- Make title bar draggable
    makeDraggable(
        titleBar,
        function() return windowPos:get() end,
        function(p) windowPos:set(p) end
    )

    -- ── Top Bar (Search + Bell + User) ────────────────────────────────────────

    local topBar = New("Frame") {
        Name             = "TopBar",
        Parent           = window,
        Size             = UDim2.new(1, -(Theme.Window.SidebarWidth), 0, Theme.Window.TopBarHeight),
        Position         = UDim2.new(0, Theme.Window.SidebarWidth, 0, Theme.Window.TitleBarHeight),
        BackgroundColor3 = Theme.Colors.SurfaceAlt,
        ZIndex           = Theme.ZIndex.Window + 2,

        New("Frame") {
            Size             = UDim2.new(1, 0, 0, 1),
            AnchorPoint      = Vector2.new(0, 1),
            Position         = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Colors.SurfaceBorder,
            ZIndex           = Theme.ZIndex.Window + 3,
        },

        Padding(nil, Theme.Spacing.Medium, Theme.Spacing.Base),

        -- Search box
        (function()
            local searchBox, _ = Components.Textbox {
                Placeholder = "Search scripts, settings…",
                Icon        = Theme.Icons.Search,
                Value       = searchText,
                Size        = UDim2.new(1, -68, 1, 0),
                ZIndex      = Theme.ZIndex.Window + 3,
            }
            return searchBox
        end)(),

        -- Notification bell
        (function()
            local isHov = Value(false)
            return New("TextButton") {
                Name             = "Bell",
                Size             = UDim2.fromOffset(28, 28),
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -32, 0.5, 0),
                BackgroundColor3 = Spring(Computed(function(use)
                    return use(isHov) and Theme.Colors.ButtonHover or Color3.fromRGB(0,0,0)
                end), Theme.Springs.Hover),
                BackgroundTransparency = Spring(Computed(function(use)
                    return use(isHov) and 0 or 1
                end), Theme.Springs.Hover),
                AutoButtonColor  = false,
                Text             = "",
                ZIndex           = Theme.ZIndex.Window + 3,

                [Fusion.OnEvent "MouseEnter"]  = function() isHov:set(true)  end,
                [Fusion.OnEvent "MouseLeave"]  = function() isHov:set(false) end,
                [Fusion.OnEvent "MouseButton1Up"] = function()
                    sendNotification { Type="info", Title="Notifications", Message="No new notifications." }
                end,

                Corner(Theme.Radius.Small),

                New("ImageLabel") {
                    BackgroundTransparency = 1,
                    Image       = Theme.Icons.Bell,
                    ImageColor3 = Spring(Computed(function(use)
                        return use(isHov) and Theme.Colors.TextPrimary or Theme.Colors.TextSecondary
                    end), Theme.Springs.Hover),
                    Size        = UDim2.fromOffset(16, 16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position    = UDim2.fromScale(0.5, 0.5),
                    ZIndex      = Theme.ZIndex.Window + 4,
                    ScaleType   = Enum.ScaleType.Fit,
                },
            }
        end)(),

        -- User icon
        (function()
            local isHov = Value(false)
            return New("TextButton") {
                Name             = "UserIcon",
                Size             = UDim2.fromOffset(28, 28),
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                BackgroundColor3 = Theme.Colors.SidebarActive,
                AutoButtonColor  = false,
                Text             = "",
                ZIndex           = Theme.ZIndex.Window + 3,

                [Fusion.OnEvent "MouseEnter"]  = function() isHov:set(true)  end,
                [Fusion.OnEvent "MouseLeave"]  = function() isHov:set(false) end,

                Corner(Theme.Radius.Full),
                Stroke(Spring(Computed(function(use)
                    return use(isHov) and Theme.Colors.AccentPrimary or Theme.Colors.SurfaceBorder
                end), Theme.Springs.Hover), 1),

                New("ImageLabel") {
                    BackgroundTransparency = 1,
                    Image       = Theme.Icons.User,
                    ImageColor3 = Theme.Colors.AccentPrimary,
                    Size        = UDim2.fromOffset(16, 16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position    = UDim2.fromScale(0.5, 0.5),
                    ZIndex      = Theme.ZIndex.Window + 4,
                    ScaleType   = Enum.ScaleType.Fit,
                },
            }
        end)(),
    }

    -- ── Sidebar ───────────────────────────────────────────────────────────────

    local sidebar = New("Frame") {
        Name             = "Sidebar",
        Parent           = window,
        Size             = UDim2.new(0, Theme.Window.SidebarWidth, 1, -Theme.Window.TitleBarHeight),
        Position         = UDim2.new(0, 0, 0, Theme.Window.TitleBarHeight),
        BackgroundColor3 = Theme.Colors.SidebarBg,
        ZIndex           = Theme.ZIndex.Sidebar,

        -- Right border
        New("Frame") {
            Size             = UDim2.new(0, 1, 1, 0),
            AnchorPoint      = Vector2.new(1, 0),
            Position         = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Colors.SurfaceBorder,
            ZIndex           = Theme.ZIndex.Sidebar + 1,
        },

        ListLayout(nil, 0),
    }

    -- Sidebar items
    for _, tab in ipairs(TABS) do
        local isActive = Computed(function(use) return use(activeTab) == tab.id end)
        local btn = Components.IconButton {
            Icon    = tab.icon,
            Tooltip = tab.tooltip,
            Active  = isActive,
            ZIndex  = Theme.ZIndex.Sidebar + 1,
            OnClick = function()
                activeTab:set(tab.id)
            end,
        }
        btn.Parent = sidebar
    end

    -- ── Content Area ──────────────────────────────────────────────────────────

    local contentArea = New("Frame") {
        Name             = "ContentArea",
        Parent           = window,
        Size             = UDim2.new(1, -Theme.Window.SidebarWidth, 1, -(Theme.Window.TitleBarHeight + Theme.Window.TopBarHeight)),
        Position         = UDim2.new(0, Theme.Window.SidebarWidth, 0, Theme.Window.TitleBarHeight + Theme.Window.TopBarHeight),
        BackgroundColor3 = Theme.Colors.Background,
        ZIndex           = Theme.ZIndex.Content,
        ClipsDescendants = true,
        Padding(Theme.Spacing.Large),
    }

    -- Build all tab containers
    buildHomeTab(contentArea)
    buildScriptsTab(contentArea)
    buildSettingsTab(contentArea)
    buildClientControlTab(contentArea)
    buildCloudConfigsTab(contentArea)
    buildModPanelTab(contentArea)
    buildCreditsTab(contentArea)

    -- ── Resize Handle ─────────────────────────────────────────────────────────

    local resizeHandle = New("TextButton") {
        Name             = "ResizeHandle",
        Parent           = window,
        Size             = UDim2.fromOffset(Theme.Window.ResizeHandleSize, Theme.Window.ResizeHandleSize),
        AnchorPoint      = Vector2.new(1, 1),
        Position         = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        AutoButtonColor  = false,
        Text             = "",
        ZIndex           = Theme.ZIndex.Window + 5,

        New("ImageLabel") {
            BackgroundTransparency = 1,
            Image       = Theme.Icons.Resize,
            ImageColor3 = Theme.Colors.TextMuted,
            Size        = UDim2.fromScale(1, 1),
            ZIndex      = Theme.ZIndex.Window + 6,
            ScaleType   = Enum.ScaleType.Fit,
        },
    }
    makeResizable(resizeHandle)

    -- ── Notification Host ─────────────────────────────────────────────────────

    notifHost = New("Frame") {
        Name             = "NotifHost",
        Parent           = screenGui,
        Size             = UDim2.fromOffset(300, 400),
        AnchorPoint      = Vector2.new(1, 1),
        Position         = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1,
        ZIndex           = Theme.ZIndex.Notification,
    }

    return window
end

-- ─── Public API ──────────────────────────────────────────────────────────────

local Ethos = {}
Ethos.__index = Ethos

function Ethos.new(opts)
    opts = opts or {}

    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name              = "EthosUI"
    screenGui.ResetOnSpawn      = false
    screenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder      = 999
    screenGui.IgnoreGuiInset    = true

    -- Attempt to use CoreGui for exploit environments, otherwise PlayerGui
    local ok = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local self = setmetatable({
        _gui     = screenGui,
        _window  = nil,
        _scope   = Scope,
        _scripts = {},
    }, Ethos)

    self._window = buildWindow(screenGui)

    -- Default toggle keybind (RightShift)
    UserInput.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.RightShift then
            windowVisible:set(not windowVisible:get())
        end
    end)

    return self
end

--- Add a script card to the Scripts tab.
-- @param opts table: { title, description, icon, accent, onExecute }
function Ethos:addScript(opts)
    local scripts = registeredScripts:get()
    table.insert(scripts, opts)
    registeredScripts:set(table.clone(scripts))
    return self
end

--- Show or hide the window.
function Ethos:show()
    windowVisible:set(true)
    return self
end

function Ethos:hide()
    windowVisible:set(false)
    return self
end

function Ethos:toggle()
    windowVisible:set(not windowVisible:get())
    return self
end

--- Send a toast notification.
-- @param opts table: { Type, Title, Message, Duration }
function Ethos:notify(opts)
    sendNotification(opts)
    return self
end

--- Navigate to a tab by id.
function Ethos:setTab(tabId)
    activeTab:set(tabId)
    return self
end

--- Destroy the UI and clean up Fusion scope.
function Ethos:destroy()
    Fusion.doCleanup(self._scope)
    self._gui:Destroy()
end

return Ethos
