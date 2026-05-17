-- ==========================================
--        PROJECT AEGIS - MM2 EDITION
-- ==========================================

local Aegis = {
    Title = "PROJECT AEGIS",
    Theme = {
        MainBG = Color3.fromRGB(18, 18, 24),
        HeaderBG = Color3.fromRGB(12, 12, 16),
        Accent = Color3.fromRGB(0, 210, 255), -- Neon Cyber Blue
        ButtonBG = Color3.fromRGB(28, 28, 36),
        ButtonActive = Color3.fromRGB(0, 150, 255), -- Active state glow
        Text = Color3.fromRGB(245, 245, 250)
    },
    States = {
        AutoGetGun = false,
        AimLock = false,
        ESP = false,
        KillFocus = false
    }
}

-- ==========================================
--  1. MODULES & EXPLOIT FUNCTIONS
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Helper functions to scan the arena
local function getGunOnGround()
    return Workspace:FindFirstChild("GunDrop") or Workspace:FindFirstChild("Gun")
end

local function getMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and (player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife"))) then
            return player
        end
    end
    return nil
end

-- [1] Bomb Jump
local function bombJump()
    Workspace.Gravity = 60
    task.wait(1.5)
    Workspace.Gravity = 196
end

-- [2] Auto Shoot
local function autoShoot()
    local char = LocalPlayer.Character
    local gun = char and (char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun"))
    if gun then
        gun.Parent = char
        task.wait(0.1)
        gun:Activate()
    end
end

-- [3] Get Gun (Instant Teleport & Return)
local function getGunInstant()
    local gunDrop = getGunOnGround()
    if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local currentPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
        task.wait(0.2)
        LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos
    end
end

-- [4] Auto Get Gun (Looping Thread)
task.spawn(function()
    while task.wait(0.5) do
        if Aegis.States.AutoGetGun then
            local gunDrop = getGunOnGround()
            if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
            end
        end
    end
end)

-- [5] Get Gun Notifier (Triggers when Sheriff dies)
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" or child.Name == "Gun" then
        local Notif = Instance.new("Message", Workspace)
        Notif.Text = "⚠️ WARNING: GUN DROPPED ON THE GROUND! ⚠️"
        task.wait(3)
        Notif:Destroy()
    end
end)

-- [6] & [8] Aim Lock & Murderer Focus (Camera Tracking)
RunService.RenderStepped:Connect(function()
    local murderer = getMurderer()
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        if Aegis.States.AimLock or Aegis.States.KillFocus then
            local cam = Workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
        end
    end
end)

-- [7] ESP Engine
local espHighlights = {}
local function applyESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Aegis.States.ESP then
                if not espHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Innocents: Green
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    
                    -- Threat detection loop
                    task.spawn(function()
                        while Aegis.States.ESP and player.Character do
                            if player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
                                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Murderer: Red
                            end
                            task.wait(1)
                        end
                    end)
                    espHighlights[player] = highlight
                end
            else
                if espHighlights[player] then
                    espHighlights[player]:Destroy()
                    espHighlights[player] = nil
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Aegis.States.ESP then applyESP() end
end)

-- Custom Shiftlock Selection Mod
local function setShiftlockStyle(styleType)
    if styleType == "Neon" then
        LocalPlayer.DevEnableMouseLock = true
    elseif styleType == "Classic" then
        LocalPlayer.DevEnableMouseLock = true
    end
end


-- ==========================================
--  2. UI CORE ENGINE & SCROLLING FRAME
-- ==========================================

-- DÜZELTME: Güvenli çalışması için PlayerGui klasörüne yönlendirildi.
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aegis_V2_EN"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 190, 0, 260)
MainFrame.Position = UDim2.new(0.5, -95, 0.4, 0)
MainFrame.BackgroundColor3 = Aegis.Theme.MainBG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Header bar
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Aegis.Theme.HeaderBG
Header.Text = Aegis.Title
Header.TextColor3 = Aegis.Theme.Accent
Header.Font = Enum.Font.InterBold
Header.TextSize = 16
Header.ZIndex = 2

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

-- Scrolling Container
local ScrollPage = Instance.new("ScrollingFrame", MainFrame)
ScrollPage.Size = UDim2.new(1, 0, 1, -45)
ScrollPage.Position = UDim2.new(0, 0, 0, 45)
ScrollPage.BackgroundTransparency = 1
ScrollPage.BorderSizePixel = 0
ScrollPage.ScrollBarThickness = 4
ScrollPage.ZIndex = 2

local UIList = Instance.new("UIListLayout", ScrollPage)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- DÜZELTME: Butonlar eklendikçe kaydırma alanının boyutunu otomatik hesaplar.
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollPage.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 15)
end)

-- ==========================================
--  3. COMPONENT CONSTRUCTORS
-- ==========================================

-- Basic Click Button Creator
local function AddClickButton(text, order, callback)
    local Button = Instance.new("TextButton", ScrollPage)
    Button.Size = UDim2.new(0, 160, 0, 35)
    Button.BackgroundColor3 = Aegis.Theme.ButtonBG
    Button.Text = text
    Button.TextColor3 = Aegis.Theme.Text
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 14
    Button.LayoutOrder = order
    Button.ZIndex = 3 -- DÜZELTME: Arka planın önünde kalması sağlandı.
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    Button.MouseButton1Click:Connect(callback)
end

-- Toggle Switch Button Creator
local function AddToggleButton(text, order, stateKey, callback)
    local Button = Instance.new("TextButton", ScrollPage)
    Button.Size = UDim2.new(0, 160, 0, 35)
    Button.BackgroundColor3 = Aegis.Theme.ButtonBG
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Aegis.Theme.Text
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 14
    Button.LayoutOrder = order
    Button.ZIndex = 3 -- DÜZELTME: Arka planın önünde kalması sağlandı.
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    Button.MouseButton1Click:Connect(function()
        Aegis.States[stateKey] = not Aegis.States[stateKey]
        if Aegis.States[stateKey] then
            Button.BackgroundColor3 = Aegis.Theme.ButtonActive
            Button.Text = text .. ": ON"
        else
            Button.BackgroundColor3 = Aegis.Theme.ButtonBG
            Button.Text = text .. ": OFF"
        end
        if callback then callback(Aegis.States[stateKey]) end
    end)
end

-- ==========================================
--  4. INITIALIZATION & LAYOUT
-- ==========================================

-- Standard Action Buttons
AddClickButton("💥 Bomb Jump", 1, bombJump)
AddClickButton("🎯 Shoot Murderer", 2, autoShoot)
AddClickButton("🔫 Grab Gun (Instant)", 3, getGunInstant)

-- Toggleable Switches
AddToggleButton("🤖 Auto Grab Gun", 4, "AutoGetGun")
AddToggleButton("👁️ Player ESP", 5, "ESP", function(state) if not state then applyESP() end end)
AddToggleButton("🔒 Aim Lock", 6, "AimLock")
AddToggleButton("😡 Focus Murderer", 7, "KillFocus")

-- Advanced Shiftlock Modules
AddClickButton("⚡ [Shiftlock: Classic]", 8, function() setShiftlockStyle("Classic") end)
AddClickButton("🔮 [Shiftlock: Cyber Neon]", 9, function() setShiftlockStyle("Neon") end)

