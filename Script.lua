-- ================================================
-- DOUBLE JUMP BUTONU - MOBİL/TABLET
-- StarterCharacterScripts > LocalScript
-- ================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp       = character:WaitForChild("HumanoidRootPart")

-- ================================================
-- AYARLAR
-- ================================================
local CONFIG = {
    Jump1Force = 80,   -- 1. zıplama gücü
    Jump2Force = 75,   -- 2. zıplama gücü
    Jump2Delay = 0.35, -- 1. ve 2. zıplama arası süre (saniye)
    Cooldown   = 2,    -- tekrar kullanım süresi
}

-- ================================================
-- GUI
-- ================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "DoubleJumpGui"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.Parent         = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size                   = UDim2.new(0, 260, 0, 80)
frame.Position               = UDim2.new(1, -280, 0, 20)
frame.BackgroundColor3       = Color3.fromRGB(8, 8, 8)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel        = 0
frame.Parent                 = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 200); stroke.Thickness = 2.5

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, -12, 0, 20)
title.Position               = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Text                   = "KDML SCRIPTS | DOUBLE JUMP"
title.TextColor3             = Color3.fromRGB(0, 255, 200)
title.TextSize               = 12
title.Font                   = Enum.Font.GothamBold
title.Parent                 = frame

local btn = Instance.new("TextButton")
btn.Size             = UDim2.new(1, -16, 1, -34)
btn.Position         = UDim2.new(0, 8, 0, 28)
btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
btn.BorderSizePixel  = 0
btn.Text             = "JUMP"
btn.TextColor3       = Color3.fromRGB(0, 255, 200)
btn.TextSize         = 22
btn.Font             = Enum.Font.GothamBold
btn.AutoButtonColor  = false
btn.ZIndex           = 2
btn.Parent           = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local bs = Instance.new("UIStroke", btn)
bs.Color = Color3.fromRGB(0, 255, 200); bs.Thickness = 1.5

local cdLbl = Instance.new("TextLabel")
cdLbl.Size                   = UDim2.new(1, 0, 1, 0)
cdLbl.BackgroundTransparency = 1
cdLbl.Text                   = ""
cdLbl.TextColor3             = Color3.fromRGB(255, 120, 0)
cdLbl.TextSize               = 22
cdLbl.Font                   = Enum.Font.GothamBold
cdLbl.ZIndex                 = 3
cdLbl.Visible                = false
cdLbl.Parent                 = btn

-- ================================================
-- DOUBLE JUMP FONKSİYONU
-- ================================================
local onCooldown = false

local function doDoubleJump()
    if onCooldown then return end
    onCooldown = true

    -- 1. ZIPLA
    local bv1 = Instance.new("BodyVelocity")
    bv1.Velocity  = Vector3.new(hrp.Velocity.X * 0.5, CONFIG.Jump1Force, hrp.Velocity.Z * 0.5)
    bv1.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    bv1.P         = 1e4
    bv1.Parent    = hrp
    task.delay(0.1, function() if bv1 and bv1.Parent then bv1:Destroy() end end)

    -- 2. ZIPLA
    task.delay(CONFIG.Jump2Delay, function()
        if not hrp or not hrp.Parent then return end
        local bv2 = Instance.new("BodyVelocity")
        bv2.Velocity  = Vector3.new(hrp.Velocity.X * 0.5, CONFIG.Jump2Force, hrp.Velocity.Z * 0.5)
        bv2.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
        bv2.P         = 1e4
        bv2.Parent    = hrp
        task.delay(0.1, function() if bv2 and bv2.Parent then bv2:Destroy() end end)
    end)

    -- Buton efekti
    TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(0, 40, 30)}):Play()
    task.delay(0.2, function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(8, 8, 8)}):Play()
    end)

    -- Cooldown sayacı
    btn.TextTransparency = 0.6
    cdLbl.Visible = true
    local s = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local left = CONFIG.Cooldown - (tick() - s)
        if left <= 0 then
            conn:Disconnect()
            onCooldown = false
            cdLbl.Visible        = false
            cdLbl.Text           = ""
            btn.TextTransparency = 0
        else
            cdLbl.Text = math.ceil(left) .. "s"
        end
    end)
end

-- ================================================
-- BUTON BAĞLANTISI (Mouse + Touch)
-- ================================================
btn.MouseButton1Click:Connect(doDoubleJump)
btn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        doDoubleJump()
    end
end)

-- Ölünce yeniden bağla
player.CharacterAdded:Connect(function(c)
    character    = c
    hrp          = c:WaitForChild("HumanoidRootPart")
    onCooldown   = false
    cdLbl.Visible        = false
    btn.TextTransparency = 0
end)
