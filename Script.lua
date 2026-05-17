-- ==========================================
--        PROJECT AEGIS - ABSOLUTE FIXED
-- ==========================================

local Aegis = {
    Title = "PROJECT AEGIS",
    Theme = {
        MainBG = Color3.fromRGB(18, 18, 24),
        HeaderBG = Color3.fromRGB(12, 12, 16),
        Accent = Color3.fromRGB(0, 210, 255),
        ButtonBG = Color3.fromRGB(28, 28, 36),
        ButtonActive = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(245, 245, 250)
    },
    States = {
        AutoGetGun = false,
        AimLock = false,
        ESP = false,
        KillFocus = false
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Karakter ve Bileşen Kontrolleri
if not LocalPlayer then return end

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

-- FONKSİYONLAR
local function bombJump()
    Workspace.Gravity = 60
    task.wait(1.5)
    Workspace.Gravity = 196
end

local function autoShoot()
    local char = LocalPlayer.Character
    local gun = char and (char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun"))
    if gun then
        gun.Parent = char
        task.wait(0.1)
        gun:Activate()
    end
end

local function getGunInstant()
    local gunDrop = getGunOnGround()
    if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local currentPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
        task.wait(0.2)
        LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos
    end
end

-- DÖNGÜLER VE EVENTLER
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

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" or child.Name == "Gun" then
        local Notif = Instance.new("Message", Workspace)
        Notif.Text = "⚠️ WARNING: GUN DROPPED ON THE GROUND! ⚠️"
        task.wait(3)
        Notif:Destroy()
    end
end)

RunService.RenderStepped:Connect(function()
    local murderer = getMurderer()
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        if Aegis.States.AimLock or Aegis.States.KillFocus then
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CFrame = CFrame.new(cam.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

local espHighlights = {}
local function applyESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Aegis.States.ESP then
                if not espHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(0, 255, 100)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    
                    task.spawn(function()
                        while Aegis.States.ESP and player.Character and player.Character.Parent do
                            if player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
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

local function setShiftlockStyle(styleType)
    LocalPlayer.DevEnableMouseLock = true
end

-- ==========================================
--  GARANTİLİ VE SABİTLENMİŞ GUI MOTORU
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aegis_V2_Final"
ScreenGui.ResetOnSpawn = false

-- Executor tipine göre en güvenli yere enjekte etme
local targetParent = LocalPlayer:FindFirstChild("PlayerGui")
if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui")
end
ScreenGui.Parent = targetParent

-- Ana Menü Çerçevesi (Genişletildi ve Sabitlendi)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 220, 0, 380) -- Tüm butonların sığacağı net yükseklik
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -190)
MainFrame.BackgroundColor3 = Aegis.Theme.MainBG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

-- Başlık Alanı
local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Aegis.Theme.HeaderBG
Header.BorderSizePixel = 0
Header.Text = Aegis.Title
Header.TextColor3 = Aegis.Theme.Accent
Header.Font = Enum.Font.GothamBold
Header.TextSize = 15

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 8)

-- Butonları Alt Alta Düzgünce Sıralayan Liste Sistemi
local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5) -- Butonlar arası boşluk
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Başlığın listeden etkilenmemesi ve en üstte kalması için hizalama pedi
local Padding = Instance.new("UIPadding")
Padding.Parent = MainFrame
Padding.PaddingTop = UDim.new(0, 45) 

-- KESİN ÇALIŞAN BUTON OLUŞTURUCULAR
local function AddClickButton(text, order, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0, 200, 0, 30) -- Sabit boyutlar
    Button.BackgroundColor3 = Aegis.Theme.ButtonBG
    Button.Text = text
    Button.TextColor3 = Aegis.Theme.Text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 12
    Button.LayoutOrder = order
    Button.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Button)
    Corner.CornerRadius = UDim.new(0, 4)
    
    Button.MouseButton1Click:Connect(callback)
end

local function AddToggleButton(text, order, stateKey, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0, 200, 0, 30) -- Sabit boyutlar
    Button.BackgroundColor3 = Aegis.Theme.ButtonBG
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Aegis.Theme.Text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 12
    Button.LayoutOrder = order
    Button.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Button)
    Corner.CornerRadius = UDim.new(0, 4)
    
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

-- BUTONLARIN MENÜYE YÜKLENMESİ
AddClickButton("💥 Bomb Jump", 1, bombJump)
AddClickButton("🎯 Shoot Murderer", 2, autoShoot)
AddClickButton("🔫 Grab Gun (Instant)", 3, getGunInstant)
AddToggleButton("🤖 Auto Grab Gun", 4, "AutoGetGun")
AddToggleButton("👁️ Player ESP", 5, "ESP", function(state) if not state then applyESP() end end)
AddToggleButton("🔒 Aim Lock", 6, "AimLock")
AddToggleButton("😡 Focus Murderer", 7, "KillFocus")
AddClickButton("⚡ [Shiftlock: Classic]", 8, function() setShiftlockStyle("Classic") end)
AddClickButton("🔮 [Shiftlock: Cyber Neon]", 9, function() setShiftlockStyle("Neon") end)

print("Aegis V2 başarıyla yüklendi! Butonlar aktif.")
