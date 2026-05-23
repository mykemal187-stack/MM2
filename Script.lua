-- ================================================
-- DOUBLE JUMP + ELÄ°MDEKÄ° EÅYAYI FIRLATMA
-- StarterCharacterScripts > LocalScript
-- ================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp       = character:WaitForChild("HumanoidRootPart")
local humanoid  = character:WaitForChild("Humanoid")

local CONFIG = {
    Jump1Force  = 40,   -- 1. zÄ±plama
    Jump2Force  = 40,   -- 2. zÄ±plama
    Jump2Delay  = 0.3,
    Cooldown    = 1.5,
    ThrowForce  = 60,
    ThrowUp     = 10,
}

-- ================================================
-- GUI
-- ================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "DJThrowGui"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.Parent         = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size                   = UDim2.new(0, 200, 0, 70)
frame.Position               = UDim2.new(1, -220, 0, 20)
frame.BackgroundColor3       = Color3.fromRGB(8, 8, 8)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel        = 0
frame.Parent                 = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 200); stroke.Thickness = 2.5

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, -8, 0, 18)
title.Position               = UDim2.new(0, 4, 0, 4)
title.BackgroundTransparency = 1
title.Text                   = "DOUBLE JUMP + FIRLATMA"
title.TextColor3             = Color3.fromRGB(0, 255, 200)
title.TextSize               = 11
title.Font                   = Enum.Font.GothamBold
title.Parent                 = frame

local btn = Instance.new("TextButton")
btn.Size             = UDim2.new(1, -16, 1, -28)
btn.Position         = UDim2.new(0, 8, 0, 22)
btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
btn.BorderSizePixel  = 0
btn.Text             = "JUMP + AT"
btn.TextColor3       = Color3.fromRGB(0, 255, 200)
btn.TextSize         = 18
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
cdLbl.TextSize               = 20
cdLbl.Font                   = Enum.Font.GothamBold
cdLbl.ZIndex                 = 3
cdLbl.Visible                = false
cdLbl.Parent                 = btn

-- ================================================
-- SÃœRÃœKLEME
-- ================================================
local dragging   = false
local dragStart  = Vector2.new()
local frameStart = UDim2.new()
local moved      = false

frame.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    dragging   = true
    moved      = false
    dragStart  = Vector2.new(i.Position.X, i.Position.Y)
    frameStart = frame.Position
end)

frame.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local d = Vector2.new(i.Position.X - dragStart.X, i.Position.Y - dragStart.Y)
    if d.Magnitude > 6 then
        moved = true
        local vp = gui.AbsoluteSize
        frame.Position = UDim2.new(0,
            math.clamp(frameStart.X.Offset + d.X, 0, vp.X - frame.AbsoluteSize.X),
            0,
            math.clamp(frameStart.Y.Offset + d.Y, 0, vp.Y - frame.AbsoluteSize.Y)
        )
    end
end)

frame.InputEnded:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    dragging = false
end)

-- ================================================
-- ELÄ°MDEKÄ° EÅYAYI FIRLATMA
-- ================================================
local function throwItem()
    -- Elindeki aktif tool'u bul
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end -- elde eÅŸya yoksa hiÃ§bir ÅŸey yapma

    -- Tool'u karakterden Ã§Ä±kar (dÃ¼ÅŸÃ¼r)
    tool.Parent = workspace

    -- Tool'un ana part'Ä±nÄ± bul
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end

    -- BaktÄ±ÄŸÄ±n yÃ¶ne + biraz yukarÄ± fÄ±rlat
    local throwDir = (hrp.CFrame.LookVector + Vector3.new(0, CONFIG.ThrowUp / CONFIG.ThrowForce, 0)).Unit
    handle.AssemblyLinearVelocity = throwDir * CONFIG.ThrowForce
end

-- ================================================
-- DOUBLE JUMP + FIRLATMA
-- ================================================
local onCooldown = false

local function doAction()
    if onCooldown or moved then return end
    onCooldown = true

    -- EÅŸyayÄ± hemen fÄ±rlat
    throwItem()

    -- 1. zÄ±plama
    local bv1 = Instance.new("BodyVelocity")
    bv1.Velocity = Vector3.new(hrp.Velocity.X, CONFIG.Jump1Force, hrp.Velocity.Z)
    bv1.MaxForce = Vector3.new(0, 1e5, 0)
    bv1.P        = 1e4
    bv1.Parent   = hrp
    task.delay(0.08, function() if bv1 and bv1.Parent then bv1:Destroy() end end)

    -- 2. zÄ±plama
    task.delay(CONFIG.Jump2Delay, function()
        if not hrp or not hrp.Parent then return end
        local bv2 = Instance.new("BodyVelocity")
        bv2.Velocity = Vector3.new(hrp.Velocity.X, CONFIG.Jump2Force, hrp.Velocity.Z)
        bv2.MaxForce = Vector3.new(0, 1e5, 0)
        bv2.P        = 1e4
        bv2.Parent   = hrp
        task.delay(0.08, function() if bv2 and bv2.Parent then bv2:Destroy() end end)
    end)

    -- Buton efekti
    TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(0,40,30)}):Play()
    task.delay(0.2, function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(8,8,8)}):Play()
    end)

    -- Cooldown
    btn.TextTransparency = 0.6
    cdLbl.Visible = true
    local s = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local left = CONFIG.Cooldown - (tick() - s)
        if left <= 0 then
            conn:Disconnect()
            onCooldown           = false
            cdLbl.Visible        = false
            cdLbl.Text           = ""
            btn.TextTransparency = 0
        else
            cdLbl.Text = math.ceil(left) .. "s"
        end
    end)
end

btn.MouseButton1Click:Connect(doAction)
btn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        doAction()
    end
end)

player.CharacterAdded:Connect(function(c)
    character  = c
    hrp        = c:WaitForChild("HumanoidRootPart")
    humanoid   = c:WaitForChild("Humanoid")
    onCooldown = false
    cdLbl.Visible        = false
    btn.TextTransparency = 0
end)
