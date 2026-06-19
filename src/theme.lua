--[[
    Ethos UI Library — Theme Module
    Dark cyber/goth aesthetic with purple/red neon accents.
    All colours, typography, spacing, animation springs defined here.
--]]

local Theme = {}

-- ─── Colour Palette ──────────────────────────────────────────────────────────

Theme.Colors = {
    -- Base backgrounds
    Background          = Color3.fromHex("0F0F12"),   -- deepest black
    Surface             = Color3.fromHex("141418"),   -- card / panel bg
    SurfaceAlt          = Color3.fromHex("1A1A20"),   -- slightly lighter panel
    SurfaceBorder       = Color3.fromHex("252530"),   -- subtle border

    -- Sidebar
    SidebarBg           = Color3.fromHex("0C0C0F"),
    SidebarActive       = Color3.fromHex("1C1624"),   -- active icon bg
    SidebarHover        = Color3.fromHex("161620"),

    -- Accent — purple neon
    AccentPrimary       = Color3.fromHex("B432DC"),
    AccentPrimaryDim    = Color3.fromHex("7A1F99"),
    AccentPrimaryGlow   = Color3.fromHex("CC55F0"),

    -- Accent — red/pink
    AccentRed           = Color3.fromHex("DC284E"),
    AccentRedDim        = Color3.fromHex("991C36"),
    AccentRedGlow       = Color3.fromHex("F04070"),

    -- Text
    TextPrimary         = Color3.fromHex("F0EEF8"),
    TextSecondary       = Color3.fromHex("8B89A0"),
    TextMuted           = Color3.fromHex("55536A"),
    TextAccent          = Color3.fromHex("C860F0"),

    -- Interactive
    ButtonBg            = Color3.fromHex("1E1E28"),
    ButtonHover         = Color3.fromHex("2A1E35"),
    ButtonActive        = Color3.fromHex("3A1F4A"),
    ButtonBorder        = Color3.fromHex("3D1D55"),

    -- Input
    InputBg             = Color3.fromHex("161620"),
    InputBorder         = Color3.fromHex("2A2A38"),
    InputBorderFocus    = Color3.fromHex("B432DC"),
    Placeholder         = Color3.fromHex("44425A"),

    -- Toggle
    ToggleOff           = Color3.fromHex("2A2A38"),
    ToggleOn            = Color3.fromHex("B432DC"),
    ToggleKnob          = Color3.fromHex("F0EEF8"),

    -- Slider
    SliderTrack         = Color3.fromHex("1E1E28"),
    SliderFill          = Color3.fromHex("B432DC"),
    SliderKnob          = Color3.fromHex("D055F5"),

    -- Notification
    NotifBg             = Color3.fromHex("1A1422"),
    NotifBorder         = Color3.fromHex("B432DC"),
    NotifSuccess        = Color3.fromHex("2DC96E"),
    NotifWarning        = Color3.fromHex("E8A020"),
    NotifError          = Color3.fromHex("DC284E"),
    NotifInfo           = Color3.fromHex("B432DC"),

    -- Dropdown
    DropdownBg          = Color3.fromHex("141418"),
    DropdownHover       = Color3.fromHex("1E1830"),
    DropdownSelected    = Color3.fromHex("261840"),

    -- Shadow (used in dropshadow UIGradients)
    Shadow              = Color3.fromHex("000000"),

    -- Titlebar
    TitleBarBg          = Color3.fromHex("0C0C10"),
    TitleBarBorder      = Color3.fromHex("2A1840"),
    TitleText           = Color3.fromHex("E0D8F8"),

    -- Tab
    TabBg               = Color3.fromHex("141418"),
    TabActive           = Color3.fromHex("B432DC"),
    TabHover            = Color3.fromHex("1E1828"),

    White               = Color3.fromHex("FFFFFF"),
    Transparent         = Color3.fromHex("000000"),
}

-- ─── Typography ──────────────────────────────────────────────────────────────

Theme.Fonts = {
    Title       = Enum.Font.GothamBold,
    Heading     = Enum.Font.GothamSemibold,
    Body        = Enum.Font.Gotham,
    Mono        = Enum.Font.Code,
    Label       = Enum.Font.GothamMedium,
}

Theme.TextSize = {
    XSmall  = 10,
    Small   = 11,
    Base    = 13,
    Medium  = 14,
    Large   = 16,
    XLarge  = 20,
    Title   = 22,
    Display = 28,
}

-- ─── Spacing ─────────────────────────────────────────────────────────────────

Theme.Spacing = {
    XSmall  = 4,
    Small   = 6,
    Base    = 8,
    Medium  = 12,
    Large   = 16,
    XLarge  = 24,
    XXLarge = 32,
}

-- ─── Corner Radii ────────────────────────────────────────────────────────────

Theme.Radius = {
    Small   = UDim.new(0, 4),
    Base    = UDim.new(0, 6),
    Medium  = UDim.new(0, 8),
    Large   = UDim.new(0, 12),
    XLarge  = UDim.new(0, 16),
    Full    = UDim.new(0, 999),
}

-- ─── Window Defaults ─────────────────────────────────────────────────────────

Theme.Window = {
    DefaultSize     = Vector2.new(720, 480),
    MinSize         = Vector2.new(560, 380),
    MaxSize         = Vector2.new(1100, 720),
    TitleBarHeight  = 36,
    SidebarWidth    = 56,
    TopBarHeight    = 40,
    ResizeHandleSize= 14,
}

-- ─── Spring Configs ──────────────────────────────────────────────────────────
-- Used with Fusion Spring objects: {stiffness, dampingRatio}

Theme.Springs = {
    Snappy      = {stiffness = 500, dampingRatio = 1},
    Responsive  = {stiffness = 250, dampingRatio = 0.9},
    Gentle      = {stiffness = 120, dampingRatio = 0.85},
    Elastic     = {stiffness = 300, dampingRatio = 0.7},
    Hover       = {stiffness = 400, dampingRatio = 1},
    Window      = {stiffness = 200, dampingRatio = 0.95},
    Notification= {stiffness = 350, dampingRatio = 0.85},
}

-- ─── Tween Configs ───────────────────────────────────────────────────────────

Theme.Tweens = {
    Fast    = TweenInfo.new(0.12, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
    Base    = TweenInfo.new(0.22, Enum.EasingStyle.Quart,  Enum.EasingDirection.Out),
    Smooth  = TweenInfo.new(0.35, Enum.EasingStyle.Quint,  Enum.EasingDirection.Out),
    Spring  = TweenInfo.new(0.4,  Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    Slow    = TweenInfo.new(0.55, Enum.EasingStyle.Sine,   Enum.EasingDirection.Out),
}

-- ─── Z-Index Layers ──────────────────────────────────────────────────────────

Theme.ZIndex = {
    Background  = 1,
    Window      = 10,
    Sidebar     = 11,
    Content     = 12,
    Overlay     = 20,
    Dropdown    = 30,
    Notification= 40,
    Modal       = 50,
}

-- ─── Asset IDs ───────────────────────────────────────────────────────────────
-- Replace with your real asset IDs after uploading to Roblox or use rbxassetid://
-- Using placeholder decal IDs — swap for real Ethos assets

Theme.Icons = {
    Home            = "rbxassetid://10723406961",
    Scripts         = "rbxassetid://10723422917",
    Settings        = "rbxassetid://10723425165",
    Credits         = "rbxassetid://10723427890",
    ClientControl   = "rbxassetid://10723430213",
    CloudConfigs    = "rbxassetid://10723432741",
    ModPanel        = "rbxassetid://10723435298",

    Search          = "rbxassetid://10723437820",
    Bell            = "rbxassetid://10723439956",
    User            = "rbxassetid://10723442388",
    Close           = "rbxassetid://10723444634",
    Minimize        = "rbxassetid://10723447052",
    Resize          = "rbxassetid://10723449372",
    Chevron         = "rbxassetid://10723451834",
    Check           = "rbxassetid://10723453982",
    Copy            = "rbxassetid://10723456201",
    Refresh         = "rbxassetid://10723458423",

    Logo            = "rbxassetid://10723460812",
}

-- ─── Glow Configs ────────────────────────────────────────────────────────────

Theme.Glow = {
    SidebarActiveSize   = UDim.new(0, 2),   -- left accent bar width
    ButtonGlowOpacity   = 0.15,
    IconGlowOpacity     = 0.35,
    NeonOpacity         = 0.55,
}

return Theme
