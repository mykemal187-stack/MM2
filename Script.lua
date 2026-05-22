-- ================================================
-- MM2 TARZI BOMBA FIRLATMA + OTOMATİK DOUBLE JUMP
-- StarterCharacterScripts > LocalScript olarak koy
-- ================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Debris       = game:GetService("Debris")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp       = character:WaitForChild("HumanoidRootPart")
local humanoid  = character:WaitForChild("Humanoid")

-- ================================================
-- AYARLAR
-- ================================================
local CONFIG = {
    BombCooldown   = 4,      -- Buton bekleme süresi
    BombSpeed      = 60,     -- Bombayı fırlatma hızı
    BombLifetime   = 3,      -- Bomba kaç saniyede patlar
    ExplosionRadius = 14,    -- Patlama yarıçapı

    Jump1Force     = 120,    -- 1. zıplama gücü
    Jump1Delay     = 0.05,   -- 1. zıplama gecikme
    Jump2Force     = 100,    -- 2. zıplama gücü
    Jump2Delay     = 0.45,   -- 2. zıplama gecikme (1. den sonra)
}

-- ================================================
-- GUI - MOBİL BUTON
-- ================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "BombGui"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = player.PlayerGui

local frame = Instance.new("Frame")
frame.Name                   = "BombFrame"
frame.Size                   = UDim2.new(0, 85, 0, 85)
frame.Position               = UDim2.new(1, -120, 1, -140)
frame.AnchorPoint            = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 1
frame.Parent                 = gui

local ring = Instance.new("Frame")
ring.Size             = UDim2.new(1, 12, 1, 12)
ring.Position         = UDim2.new(0, -6, 0, -6)
ring.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
ring.BorderSizePixel  = 0
ring.ZIndex           = 1
ring.Parent           = frame
Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

local btn = Instance.new("TextButton")
btn.Name             = "BombBtn"
btn.Size             = UDim2.new(1, 0, 1, 0)
btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
btn.BorderSizePixel  = 0
btn.Text             = "💣"
btn.TextSize         = 38
btn.AutoButtonColor  = false
btn.ZIndex           = 2
btn.Parent           = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local subLbl = Instance.new("TextLabel")
subLbl.Size                   = UDim2.new(1, 0, 0, 14)
subLbl.Position               = UDim2.new(0, 0, 1, -16)
subLbl.BackgroundTransparency = 1
subLbl.Text                   = "BOMB"
subLbl.TextColor3             = Color3.fromRGB(255, 80, 0)
subLbl.TextSize               = 9
subLbl.Font                   = Enum.Font.GothamBold
subLbl.ZIndex                 = 3
subLbl.Parent                 = btn

local cdLbl = Instance.new("TextLabel")
cdLbl.Size                   = UDim2.new(1, 0, 1, 0)
cdLbl.BackgroundTransparency = 1
cdLbl.Text                   = ""
cdLbl.TextColor3             = Color3.fromRGB(255, 120, 0)
cdLbl.TextSize               = 28
cdLbl.Font                   = Enum.Font.GothamBold
cdLbl.ZIndex                 = 4
cdLbl.Visible                = false
cdLbl.Parent                 = btn

-- Zıplama göstergesi
local jumpLbl = Instance.new("TextLabel")
jumpLbl.Size                   = UDim2.new(0, 100, 0, 26)
jumpLbl.Position               = UDim2.new(0.5, -50, 0, -36)
jumpLbl.BackgroundColor3       = Color3.fromRGB(255, 80, 0)
jumpLbl.BackgroundTransparency = 0.1
jumpLbl.Text                   = "⬆ ZIPLANIYOR!"
jumpLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
jumpLbl.TextSize               = 11
jumpLbl.Font                   = Enum.Font.GothamBold
jumpLbl.ZIndex                 = 5
jumpLbl.Visible                = false
jumpLbl.Parent                 = frame
Instance.new("UICorner", jumpLbl).CornerRadius = UDim.new(0, 6)

-- ================================================
-- BOMBA FIRLATMA + OTOMATİK DOUBLE JUMP
-- ================================================
local onCooldown = false

local function flingBomb()
    -- Bombayı karakterin baktığı yöne doğru fırlat
    local bomb = Instance.new("Part")
    bomb.Name        = "MM2Bomb"
    bomb.Shape       = Enum.PartType.Ball
    bomb.Size        = Vector3.new(1.4, 1.4, 1.4)
    bomb.Color       = Color3.fromRGB(20, 20, 20)
    bomb.Material    = Enum.Material.SmoothPlastic
    bomb.CFrame      = CFrame.new(hrp.Position + Vector3.new(0, 0.5, 0))
    bomb.CanCollide  = true
    bomb.Parent      = workspace

    -- Fırlatma yönü: karakterin baktığı yön + biraz yukarı
    local lookDir = hrp.CFrame.LookVector
    local flingVelocity = (lookDir + Vector3.new(0, 0.4, 0)).Unit * CONFIG.BombSpeed
    bomb.AssemblyLinearVelocity = flingVelocity

    -- Fitil ışığı
    local light = Instance.new("PointLight")
    light.Brightness = 5
    light.Range      = 8
    light.Color      = Color3.fromRGB(255, 140, 0)
    light.Parent     = bomb

    -- Tik tak sesi
    local tick_ = Instance.new("Sound")
    tick_.SoundId = "rbxassetid://9120386436"
    tick_.Volume  = 0.7
    tick_.Looped  = true
    tick_.Parent  = bomb
    tick_:Play()

    -- Titreşim
    local shaking = true
    task.spawn(function()
        while shaking and bomb.Parent do
            local t1 = TweenService:Create(bomb, TweenInfo.new(0.1), {Size = Vector3.new(1.7,1.7,1.7)})
            local t2 = TweenService:Create(bomb, TweenInfo.new(0.1), {Size = Vector3.new(1.4,1.4,1.4)})
            t1:Play() t1.Completed:Wait()
            t2:Play() t2.Completed:Wait()
        end
    end)

    -- Patlama
    task.delay(CONFIG.BombLifetime, function()
        shaking = false
        if not bomb or not bomb.Parent then return end

        local pos = bomb.Position
        tick_:Stop()

        -- Patlama sesi
        local boom = Instance.new("Sound")
        boom.SoundId = "rbxassetid://3264793735"
        boom.Volume  = 1
        boom.Parent  = workspace
        boom:Play()
        Debris:AddItem(boom, 3)

        -- Patlama efekti
        local exp = Instance.new("Explosion")
        exp.Position                    = pos
        exp.BlastRadius                 = CONFIG.ExplosionRadius
        exp.BlastPressure               = 0
        exp.DestroyJointRadiusPercent   = 0
        exp.Parent                      = workspace

        bomb:Destroy()

        -- Karaktere mesafe kontrolü
        local dist = (hrp.Position - pos).Magnitude
        if dist > CONFIG.ExplosionRadius then return end

        -- Zıplama göstergesi aç
        jumpLbl.Visible = true
        TweenService:Create(ring, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        }):Play()

        -- 1. ZIPLA
        task.delay(CONFIG.Jump1Delay, function()
            if not hrp or not hrp.Parent then return end
            local bv1 = Instance.new("BodyVelocity")
            bv1.Velocity  = Vector3.new(hrp.Velocity.X * 0.5, CONFIG.Jump1Force, hrp.Velocity.Z * 0.5)
            bv1.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
            bv1.P         = 1e4
            bv1.Parent    = hrp
            task.delay(0.1, function() if bv1 and bv1.Parent then bv1:Destroy() end end)
        end)

        -- 2. ZIPLA (otomatik, 1. den kısa süre sonra)
        task.delay(CONFIG.Jump2Delay, function()
            if not hrp or not hrp.Parent then return end
            local bv2 = Instance.new("BodyVelocity")
            bv2.Velocity  = Vector3.new(hrp.Velocity.X * 0.6, CONFIG.Jump2Force, hrp.Velocity.Z * 0.6)
            bv2.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
            bv2.P         = 1e4
            bv2.Parent    = hrp
            task.delay(0.1, function() if bv2 and bv2.Parent then bv2:Destroy() end end)

            -- Göstergeyi kapat
            task.delay(0.5, function()
                jumpLbl.Visible = false
                TweenService:Create(ring, TweenInfo.new(0.3), {
                    BackgroundColor3 = Color3.fromRGB(255, 80, 0)
                }):Play()
            end)
        end)
    end)

    Debris:AddItem(bomb, CONFIG.BombLifetime + 1)
end

-- ================================================
-- COOLDOWN
-- ================================================
local function startCooldown()
    onCooldown           = true
    btn.TextTransparency = 0.5
    cdLbl.Visible        = true

    local s = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local left = CONFIG.BombCooldown - (tick() - s)
        if left <= 0 then
            conn:Disconnect()
            onCooldown           = false
            cdLbl.Visible        = false
            cdLbl.Text           = ""
            btn.TextTransparency = 0
            TweenService:Create(ring, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0,255,80)}):Play()
            task.delay(0.5, function()
                TweenService:Create(ring, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(255,80,0)}):Play()
            end)
        else
            cdLbl.Text = math.ceil(left) .. "s"
        end
    end)
end

-- ================================================
-- SÜRÜKLEME + DOKUNMA
-- ================================================
local dragging   = false
local dragStart  = Vector2.new()
local frameStart = UDim2.new()
local moved      = false

btn.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    dragging   = true
    moved      = false
    dragStart  = Vector2.new(input.Position.X, input.Position.Y)
    frameStart = frame.Position
end)

btn.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local d = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
    if d.Magnitude > 8 then
        moved = true
        local vp = gui.AbsoluteSize
        frame.Position = UDim2.new(0,
            math.clamp(frameStart.X.Offset + d.X, 45, vp.X - 45),
            0,
            math.clamp(frameStart.Y.Offset + d.Y, 45, vp.Y - 45)
        )
    end
end)

btn.InputEnded:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    dragging = false
    if not moved and not onCooldown then
        flingBomb()
        startCooldown()
        TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(60,30,10)}):Play()
        task.delay(0.15, function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22,22,22)}):Play()
        end)
    end
end)

-- Ölünce yeniden bağla
player.CharacterAdded:Connect(function(c)
    character  = c
    humanoid   = c:WaitForChild("Humanoid")
    hrp        = c:WaitForChild("HumanoidRootPart")
    onCooldown = false
    cdLbl.Visible        = false
    btn.TextTransparency = 0
    jumpLbl.Visible      = false
end)
