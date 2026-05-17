-- Ekran Arayüzü Oluşturma
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 130) -- Küçük ve kibar boyut
MainFrame.Position = UDim2.new(0.5, -80, 0.7, 0) -- Ekranın alt-orta kısmında başlar
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Koyu şık tema
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true -- Tablette parmağınla istediğin yere taşıyabilirsin

-- BAŞLIK: Kemal Hub
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Kemal Hub"
Title.TextColor3 = Color3.fromRGB(255, 170, 0) -- Altın sarısı yazı
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Butonları Hizalamak İçin Liste Düzeni
local UIList = Instance.new("UIListLayout", MainFrame)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- 1. BUTON: Katili Vur
local ShootBtn = Instance.new("TextButton", MainFrame)
ShootBtn.Size = UDim2.new(1, 0, 0.35, 0)
ShootBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ShootBtn.Text = "Katili Vur"
ShootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootBtn.Font = Enum.Font.SourceSans
ShootBtn.TextSize = 16

ShootBtn.MouseButton1Click:Connect(function()
    local plr = game.Players.LocalPlayer
    local gun = plr.Character and plr.Character:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun")
    if gun then
        gun.Parent = plr.Character
        wait(0.1)
        gun:Activate()
    end
end)

-- 2. BUTON: Bomba Zıplaması
local JumpBtn = Instance.new("TextButton", MainFrame)
JumpBtn.Size = UDim2.new(1, 0, 0.35, 0)
JumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
JumpBtn.Text = "Bomba Zıplaması"
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Font = Enum.Font.SourceSans
JumpBtn.TextSize = 16

JumpBtn.MouseButton1Click:Connect(function()
    game.Workspace.Gravity = 60 -- Yerçekimini azalt (Bomba etkisi)
    wait(1.5)
    game.Workspace.Gravity = 196 -- Normal yerçekimine dön
end)
