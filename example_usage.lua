--[[
    Ethos UI Library — Example Usage
    ─────────────────────────────────────────────────────────────────────────────
    Drop this LocalScript into StarterPlayerScripts (or execute directly).
    Assumes Fusion.lua + src/ folder are siblings of this script,
    OR use the loader.lua for remote execution.

    Folder structure expected (when requiring locally):
        YourScript/
        ├── main.lua          (this file or caller)
        ├── Fusion.lua
        └── src/
            ├── theme.lua
            ├── components.lua
            └── main.lua
    ─────────────────────────────────────────────────────────────────────────────
--]]

-- ─── Option A: Local Require (Roblox Studio / Rojo) ──────────────────────────
local Ethos = require(script.Parent.src.main)

-- ─── Option B: Remote Loader (Executor one-liner) ─────────────────────────────
-- local Ethos = loadstring(game:HttpGet(
--     "https://raw.githubusercontent.com/laderite/Ethos/main/loader.lua"
-- ))()

-- ─── Create window ────────────────────────────────────────────────────────────
local window = Ethos.new()

-- ─── Add scripts to the Scripts tab ──────────────────────────────────────────

window:addScript({
    title       = "Universal Auto Farm",
    description = "Works in most farming games. Configurable speed.",
    accent      = Color3.fromHex("B432DC"),
    onExecute   = function()
        -- Your script code here
        print("Universal Auto Farm running!")
    end,
})

window:addScript({
    title       = "ESP / Wallhack",
    description = "Draws boxes and names above all players.",
    accent      = Color3.fromHex("DC284E"),
    onExecute   = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        -- Simple name-tag ESP example
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local char = player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local bb = Instance.new("BillboardGui")
                        bb.Name      = "EthosESP"
                        bb.Size      = UDim2.fromOffset(100, 20)
                        bb.StudsOffset = Vector3.new(0, 2, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent    = head
                        local label  = Instance.new("TextLabel", bb)
                        label.Size   = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.Text   = player.Name
                        label.TextColor3 = Color3.fromHex("DC284E")
                        label.Font   = Enum.Font.GothamBold
                        label.TextSize = 14
                    end
                end
            end
        end
        print("ESP enabled!")
    end,
})

window:addScript({
    title       = "Speed / Fly",
    description = "Toggle fly mode and set walk speed.",
    accent      = Color3.fromHex("2DC96E"),
    onExecute   = function()
        local lp   = game:GetService("Players").LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hum  = char:WaitForChild("Humanoid")
        local hrp  = char:WaitForChild("HumanoidRootPart")
        local UIS  = game:GetService("UserInputService")
        local RS   = game:GetService("RunService")

        hum.WalkSpeed = 60

        local flying    = false
        local bodyVel   = nil
        local bodyGyro  = nil
        local flyConn

        local function toggleFly()
            flying = not flying
            if flying then
                bodyVel        = Instance.new("BodyVelocity", hrp)
                bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
                bodyVel.Velocity = Vector3.zero

                bodyGyro       = Instance.new("BodyGyro", hrp)
                bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)

                flyConn = RS.Heartbeat:Connect(function()
                    local cam   = workspace.CurrentCamera
                    local speed = 50
                    local dir   = Vector3.zero

                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector  end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector  end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis       end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end

                    bodyVel.Velocity  = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
                    bodyGyro.CFrame   = cam.CFrame
                end)
                hum.PlatformStand = true
            else
                if flyConn then flyConn:Disconnect() end
                if bodyVel  then bodyVel:Destroy()  end
                if bodyGyro then bodyGyro:Destroy() end
                hum.PlatformStand = false
            end
        end

        -- Toggle fly on F key
        UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.F then toggleFly() end
        end)

        print("Speed/Fly loaded — press F to toggle fly!")
    end,
})

window:addScript({
    title       = "Anti-AFK",
    description = "Prevents automatic disconnection.",
    accent      = Color3.fromHex("E8A020"),
    onExecute   = function()
        local VirtualUser = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
        end)
        print("Anti-AFK active!")
    end,
})

-- ─── Send a welcome notification ──────────────────────────────────────────────

window:notify({
    Type    = "success",
    Title   = "Ethos // RE",
    Message = "UI loaded successfully. RightShift to toggle.",
    Duration= 5,
})

-- ─── Show the window ──────────────────────────────────────────────────────────

window:show()
