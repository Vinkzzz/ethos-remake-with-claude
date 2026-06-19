# Ethos // RE — UI Library

A production-ready Roblox UI library replicating the **Ethos Ghoul Re** script hub aesthetic, built entirely with **Fusion 0.3** (by dphfox/elttob).

---

## 📁 Folder Structure

```
Ethos/
├── loader.lua              ← One-line remote executor entry point
├── Fusion.lua              ← Fusion 0.3 module (from dphfox/Fusion)
├── example_usage.lua       ← Full API usage demo
├── assets/                 ← Icon PNGs (upload to Roblox, update Theme.Icons)
│   ├── home.png
│   ├── scripts.png
│   ├── settings.png
│   └── ...
└── src/
    ├── theme.lua           ← All colours, fonts, springs, spacing, asset IDs
    ├── components.lua      ← All reusable UI primitives
    └── main.lua            ← Window builder + public Ethos API
```

---

## 🚀 Quick Start

### Remote (Executor)
```lua
local Ethos = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_FORK/Ethos/main/loader.lua"
))()
```

### Local (Roblox Studio / Rojo)
```lua
local Ethos = require(script.Parent.src.main)
local window = Ethos.new()
window:show()
```

---

## 🎨 Visual Style

| Property | Value |
|---|---|
| Background | `#0F0F12` — deep space black |
| Primary Accent | `#B432DC` — purple neon |
| Secondary Accent | `#DC284E` — red/crimson |
| Font | Gotham family (Bold/SemiBold/Medium/Regular) |
| Aesthetic | Dark cyber/goth, glassmorphism, heavy dropshadows, neon glows |

---

## 🪟 Window Features

- **Draggable** — grab the title bar to reposition anywhere on screen
- **Resizable** — drag the bottom-right handle; min `560×380`, max `1100×720`
- **Minimizable** — `—` button hides the window
- **Closeable** — `✕` button dismisses (RightShift to re-open)
- **Keyboard toggle** — RightShift (rebindable in Settings)

---

## 📑 Tabs

| Tab | Description |
|---|---|
| 🏠 Home | Welcome banner, player info, quick game stats |
| 📜 Scripts | Searchable card grid, one-click execute with success/error toast |
| 🎮 Client Control | Walk speed, jump power, FOV, fullbright, no-clip toggles |
| ☁️ Cloud Configs | Save/load named configuration sets |
| 🛡️ Mod Panel | Player targeting, kick, spectate tools |
| ⚙️ Settings | Appearance, keybinds, color pickers, notification prefs |
| ℹ️ Credits | Team credits, Discord link |

---

## 🧩 Component API

### Button
```lua
local btn = Components.Button {
    Text     = "Click Me",
    BgColor  = Theme.Colors.AccentPrimaryDim,
    OnClick  = function() print("clicked!") end,
}
btn.Parent = someFrame
```

### Toggle
```lua
local frame, valueState = Components.Toggle {
    Label    = "Enable Feature",
    OnToggle = function(enabled) print(enabled) end,
}
```

### Slider
```lua
local frame, valueState = Components.Slider {
    Label    = "Walk Speed",
    Min = 16, Max = 200, Step = 2, Default = 16,
    OnChange = function(v) humanoid.WalkSpeed = v end,
}
```

### Dropdown
```lua
local frame, selectedState = Components.Dropdown {
    Options  = { "Option A", "Option B", "Option C" },
    Default  = "Option A",
    OnSelect = function(v) print(v) end,
}
```

### Textbox
```lua
local frame, textState = Components.Textbox {
    Placeholder = "Enter text…",
    Icon        = Theme.Icons.Search,
    OnChange    = function(v) print(v) end,
}
```

### Keybind
```lua
local frame, keyState = Components.Keybind {
    Label   = "Fly Toggle",
    Default = Enum.KeyCode.F,
    OnBind  = function(key) print(key.Name) end,
}
```

### ColorPicker
```lua
local frame, colorState = Components.ColorPicker {
    Label    = "Accent Color",
    Default  = Color3.fromHex("B432DC"),
    OnChange = function(c) print(c) end,
}
```

### Section (groups components with a title)
```lua
local section = Components.Section {
    Title    = "PLAYER SETTINGS",
    Children = { toggle1, slider1, dropdown1 },
}
section.Parent = scrollFrame
```

### Notification / Toast
```lua
window:notify({
    Type    = "success",  -- "success" | "error" | "warning" | "info"
    Title   = "Done!",
    Message = "Script executed successfully.",
    Duration= 4,          -- seconds
})
```

---

## 📦 Ethos API

```lua
local window = Ethos.new()         -- Create and build the full UI

window:addScript({
    title       = "My Script",
    description = "Short description",
    icon        = "rbxassetid://...",
    accent      = Color3.fromHex("B432DC"),
    onExecute   = function() ... end,
})

window:show()                      -- Show the window
window:hide()                      -- Hide the window
window:toggle()                    -- Toggle visibility
window:setTab("Scripts")           -- Jump to a tab
window:notify({ ... })             -- Fire a toast notification
window:destroy()                   -- Clean up Fusion scope + destroy GUI
```

---

## 🎛️ Customising the Theme

All visual constants live in `src/theme.lua`. Change colours, fonts, spacing, and spring configs there — every component reads from Theme, so changes propagate everywhere.

```lua
-- src/theme.lua
Theme.Colors.AccentPrimary = Color3.fromHex("00BFFF")  -- swap purple → blue
Theme.Springs.Hover = { stiffness = 600, dampingRatio = 1 }  -- snappier
```

---

## 🖼️ Updating Icons

1. Upload your PNG icons to Roblox (or use existing asset IDs).
2. Open `src/theme.lua` and replace the `Theme.Icons` table with your real IDs:

```lua
Theme.Icons = {
    Home    = "rbxassetid://YOUR_ID_HERE",
    Scripts = "rbxassetid://YOUR_ID_HERE",
    -- ...
}
```

---

## 📐 Architecture Notes

- **Fusion Scoping** — one root `Scope` is created in `main.lua` and passed to `Components.init()`. All reactive objects (`Value`, `Computed`, `Spring`, `Tween`) are created through this scope for proper cleanup via `Fusion.doCleanup`.
- **Spring animations** — all hover, press, tab transitions, and notification slide-ins use `Fusion.Spring` so they interrupt and blend naturally.
- **Zero TweenService** — only `Fusion.Spring` and `Fusion.Tween` are used inside reactive state; no manual `TweenService:Create` calls in component code.
- **Modular tabs** — each tab is a self-contained builder function. Add a new tab by adding an entry to `TABS` and a `buildXTab()` function in `main.lua`.

---

## ⚠️ Notes

- This library is for **educational and personal use**. Exploiting may violate Roblox's Terms of Service.
- Replace placeholder `rbxassetid://` values with real uploaded assets before publishing.
- Tested against **Fusion 0.3** API (`Fusion.scoped`, `Fusion.Value`, `Fusion.Computed`, `Fusion.Spring`, `Fusion.Tween`, `Fusion.New`, `Fusion.OnEvent`, `Fusion.OnChange`, `Fusion.Ref`).

---

*Built with ❤️ using [Fusion](https://github.com/dphfox/Fusion) by elttob.*
