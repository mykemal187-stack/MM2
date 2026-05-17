-- ==========================================
--     PROJECT MATRIX - OVERDRIVE EDITION
-- ==========================================

local Matrix = {
    Title = " [!] MATRIX_OVERDRIVE_V5 ",
    Theme = {
        MainBG = Color3.fromRGB(5, 5, 5),          
        HeaderBG = Color3.fromRGB(15, 15, 15),     
        Accent = Color3.fromRGB(0, 255, 100),       
        ButtonBG = Color3.fromRGB(12, 12, 12),
        Border = Color3.fromRGB(35, 35, 35)
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
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then return end

-- GELİŞMİŞ ALGORİTMALAR (SİLAH VE ROL BULUCULAR)
local function getGunOnGround()
    local directGun = Workspace:FindFirstChild("GunDrop") or Workspace:FindFirstChild("Gun")
    if directGun then return directGun end
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            if string.find(string.lower(child.Name), "gun") or string.find(string.lower(child.Name), "revolver") then
                return child
            end
        end
    end
    return nil
end

local function getMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and (player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife"))) then
            return player
        end
    end
    return nil
end

-- MEKANİKLER (BYPASS VE TWEEN MOTORU)
local function bombJump()
    Workspace.Gravity = 60
    task.wait(1.5)
    Workspace.Gravity = 196
end

local function autoShoot()
    local char = LocalPlayer.Character
    local gun = char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Revolver"))
    local murderer = getMurderer()
    
    if gun and murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        gun.Parent = char
        task.wait(0.05)
        char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, murderer.Character.HumanoidRootPart.Position)
        task.wait(0.05)
        gun:Activate()
    end
end

local function getGunTween()
    local gunDrop = getGunOnGround()
    local char = LocalPlayer.Character
    if gunDrop and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local targetCFrame = gunDrop:IsA("Model") and (gunDrop.PrimaryPart and gunDrop.PrimaryPart.CFrame or gunDrop:FindFirstChildWhichIsA("BasePart").CFrame) or gunDrop.CFrame
        
        if targetCFrame then
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        end
    end
end

-- OTO SİLAH TOPLAMA DÖNGÜSÜ
task.spawn(function()
    while task.wait(0.5) do
        if Matrix.States.AutoGetGun then
            getGunTween()
        end
    end
end)

-- KAMERA TAKİBİ
RunService.RenderStepped:Connect(function()
    local murderer = getMurderer()
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        if Matrix.States.AimLock or Matrix.States.KillFocus then
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CFrame = CFrame.new(cam.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

-- ŞERİF & KATİL DESTEKLİ ESP MOTORU
local espHighlights = {}
local function applyESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Matrix.States.ESP then
                if not espHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    
                    task.spawn(function()
                        while Matrix.States.ESP and player.Character and player.Character.Parent do
                            local char = player.Character
                            local pack = player.Backpack
                            
                            if char:FindFirstChild("Knife") or (pack and pack:FindFirstChild("Knife")) then
                                highlight.FillColor = Color3.fromRGB(255, 0, 50) 
                            elseif char:FindFirstChild("Gun") or (pack and pack:FindFirstChild("Gun")) or char:FindFirstChild("Revolver") or (pack and pack:FindFirstChild("Revolver")) then
                                highlight.FillColor = Color3.fromRGB(0, 150, 255) 
                            else
                                highlight.FillColor = Color3.fromRGB(0, 255, 100) 
                            end
                            task.wait(0.8)
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
    if Matrix.States.ESP then applyESP() end
end)

-- ==========================================
--  ARAYÜZ OLUŞTURMA (MATRIX ENGINE)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Matrix_Overdrive"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -170)
MainFrame.BackgroundColor3 = Matrix.Theme.MainBG
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Matrix.Theme.Accent
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 0) 

local Header = Instance.new("TextLabel")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Matrix.Theme.HeaderBG
Header.BorderSizePixel = 0
Header.Text = Matrix.Title
Header.TextColor3 = Matrix.Theme.Accent
Header.Font = Enum.Font.Code
Header.TextSize = 13
Header.TextXAlignment = Enum.TextXAlignment.Left

local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Padding = Instance.new("UIPadding")
Padding.Parent = MainFrame
Padding.PaddingTop = UDim.new(0, 45)

local function AddClickButton(text, order, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0, 220, 0, 30)
    Button.BackgroundColor3 = Matrix.Theme.ButtonBG
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Matrix.Theme.Border
    Button.Text = "  >> " .. text
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.Code
    Button.TextSize = 11
    Button.LayoutOrder = order
    
    Button.MouseEnter:Connect(function() 
        Button.BorderColor3 = Matrix.Theme.Accent 
        Button.TextColor3 = Matrix.Theme.Accent
    end)
    Button.MouseLeave:Connect(function() 
        Button.BorderColor3 = Matrix.Theme.Border 
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    Button.MouseButton1Click:Connect(callback)
end

local function AddToggleButton(text, order, stateKey, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0, 220, 0, 30)
    Button.BackgroundColor3 = Matrix.Theme.ButtonBG
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Matrix.Theme.Border
    Button.Text = "  [X] " .. text
    Button.TextColor3 = Color3.fromRGB(130, 130, 130)
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.Code
    Button.TextSize = 11
    Button.LayoutOrder = order
    
    Button.MouseButton1Click:Connect(function()
        Matrix.States[stateKey] = not Matrix.States[stateKey]
        if Matrix.States[stateKey] then
            Button.BorderColor3 = Matrix.Theme.Accent
            Button.Text = "  [O] " .. text .. " _RUNNING"
            Button.TextColor3 = Matrix.Theme.Accent
        else
            Button.BorderColor3 = Matrix.Theme.Border
            Button.Text = "  [X] " .. text
            Button.TextColor3 = Color3.fromRGB(130, 130, 130)
        end
        if callback then callback(Matrix.States[stateKey]) end
    end)
end

-- TÜM ÖZELLİKLERİN BAĞLANMASI
AddClickButton("SYS_BOMB_JUMP", 1, bombJump)
AddClickButton("EXECUTE_AUTO_SHOOT", 2, autoShoot)
AddClickButton("TWEEN_TO_REVOLVER", 3, getGunTween)
AddToggleButton("AUTO_HARVEST_REVOLVER", 4, "AutoGetGun")
AddToggleButton("SENSORY_ESP_MATRIX", 5, "ESP", function(state) if not state then applyESP() end end)
AddToggleButton("AIM_LOCK_ASSIST", 6, "AimLock")
AddToggleButton("KILLER_FOCUS_LOOP", 7, "KillFocus")

print("Matrix Overdrive V5 başarıyla yüklendi. Tüm entegrasyon tamamlandı.")
