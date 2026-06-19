--[[
    Ethos UI Library — Loader
    ─────────────────────────────────────────────────────────────────────────────
    One-line executor entry point. Fetches all modules from the GitHub repo,
    injects them into a module cache, and returns the fully-initialised Ethos API.

    Usage (in any executor):
        local Ethos = loadstring(game:HttpGet("https://raw.githubusercontent.com/laderite/Ethos/main/loader.lua"))()

    Or with options:
        local Ethos = loadstring(...)()
        Ethos:addScript({ title = "Auto Farm", onExecute = function() ... end })
        Ethos:show()
    ─────────────────────────────────────────────────────────────────────────────
--]]

-- ─── Configuration ────────────────────────────────────────────────────────────

local BASE_URL   = "https://raw.githubusercontent.com/laderite/Ethos/main/"
local BRANCH     = "main"

-- Module paths relative to BASE_URL
local MODULES = {
    Fusion     = "Fusion.lua",
    theme      = "src/theme.lua",
    components = "src/components.lua",
    main       = "src/main.lua",
}

-- ─── HTTP Fetch ──────────────────────────────────────────────────────────────

local HttpService = game:GetService("HttpService")

local function fetch(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        error(("[Ethos Loader] Failed to fetch: %s\n%s"):format(url, tostring(result)))
    end
    return result
end

-- ─── Module Cache & Loader ───────────────────────────────────────────────────

local moduleCache  = {}
local rawSources   = {}

-- Pre-fetch all sources
print("[Ethos] Fetching modules…")
for name, path in pairs(MODULES) do
    rawSources[name] = fetch(BASE_URL .. path)
    print(("[Ethos] Fetched: %s"):format(name))
end

-- Custom require that resolves local dependencies from cache
local function buildRequire(moduleName)
    return function(ref)
        -- ref can be a string name or an Instance
        local name
        if type(ref) == "string" then
            name = ref
        elseif typeof(ref) == "Instance" then
            name = ref.Name
        else
            name = tostring(ref)
        end

        if moduleCache[name] then
            return moduleCache[name]
        end

        local src = rawSources[name]
        if not src then
            -- Fall back to standard require for Roblox built-ins
            return require(ref)
        end

        local fn, err = loadstring(src, "@Ethos/" .. name .. ".lua")
        if not fn then
            error(("[Ethos Loader] Failed to compile module '%s': %s"):format(name, tostring(err)))
        end

        -- Each module runs in an env where `require` resolves from our cache
        -- and `script` has a `.Parent` pointing at a virtual script object
        local fakeScript = Instance.new("ModuleScript")
        fakeScript.Name = name

        setfenv(fn, setmetatable({
            require = function(r) return buildRequire(name)(r) end,
            script  = fakeScript,
        }, { __index = getfenv(0) }))

        local result = fn()
        moduleCache[name] = result
        fakeScript:Destroy()
        return result
    end
end

-- Build all modules in dependency order
local req = buildRequire("loader")
local Fusion     = req("Fusion")
local Theme      = req("theme")
local Components = req("components")
local Ethos      = req("main")

moduleCache["Fusion"]     = Fusion
moduleCache["theme"]      = Theme
moduleCache["components"] = Components
moduleCache["main"]       = Ethos

print("[Ethos] All modules loaded. Initialising UI…")

-- ─── Auto-Initialise & Return ────────────────────────────────────────────────

local window = Ethos.new()

-- Add some example scripts to showcase the Scripts tab
window:addScript({
    title       = "Blox Fruits — Auto Farm",
    description = "Automated fruit farming with anti-afk.",
    icon        = "rbxassetid://10723422917",
    accent      = Color3.fromHex("B432DC"),
    onExecute   = function()
        print("[Ethos] Blox Fruits Auto Farm executed!")
    end,
})

window:addScript({
    title       = "Da Hood — God Mode",
    description = "Anti-damage and infinite health client-side.",
    icon        = "rbxassetid://10723422917",
    accent      = Color3.fromHex("DC284E"),
    onExecute   = function()
        local lp = game:GetService("Players").LocalPlayer
        if lp.Character then
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.MaxHealth = math.huge hum.Health = math.huge end
        end
    end,
})

window:addScript({
    title       = "Arsenal — Aimbot",
    description = "Smooth FOV-based aim assist.",
    icon        = "rbxassetid://10723422917",
    accent      = Color3.fromHex("E8A020"),
    onExecute   = function()
        print("[Ethos] Arsenal Aimbot executed!")
    end,
})

window:addScript({
    title       = "Pet Simulator — Auto Hatch",
    description = "Auto-click eggs and collect pets.",
    icon        = "rbxassetid://10723422917",
    accent      = Color3.fromHex("2DC96E"),
    onExecute   = function()
        print("[Ethos] Pet Sim Auto Hatch executed!")
    end,
})

window:notify({
    Type    = "success",
    Title   = "Ethos Loaded",
    Message = "Welcome back! Press RightShift to toggle the UI.",
    Duration= 4,
})

print("[Ethos] UI ready. Press RightShift to toggle.")

return window
