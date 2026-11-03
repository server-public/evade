local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")

local LP = Players.LocalPlayer

if CoreGui:FindFirstChild("EvadePanel_v1") then
    CoreGui.EvadePanel_v1:Destroy()
end

local Theme = {
    bg = Color3.fromRGB(10, 10, 15), bg_secondary = Color3.fromRGB(20, 20, 30),
    bg_tertiary = Color3.fromRGB(35, 35, 50), stroke = Color3.fromRGB(50, 50, 70),
    text = Color3.fromRGB(255, 255, 255), text_dim = Color3.fromRGB(150, 150, 150),
    accent = Color3.fromRGB(0, 255, 150), red = Color3.fromRGB(255, 50, 50),
}

local Font = Enum.Font.Code
local FontBold = Enum.Font.GothamBold

local function corner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 6); c.Parent = parent; return c
end
local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = thickness or 1; s.Parent = parent; return s
end
local function pad(parent, l, r, t, b)
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, l or 0); p.PaddingRight = UDim.new(0, r or 0); p.PaddingTop = UDim.new(0, t or 0); p.PaddingBottom = UDim.new(0, b or 0); p.Parent = parent; return p
end

local Gui = Instance.new("ScreenGui"); Gui.Name = "EvadePanel_v1"; Gui.ResetOnSpawn = false; Gui.IgnoreGuiInset = true; Gui.Parent = CoreGui

-- ==========================================
-- 1. PANEL UTAMA
-- ==========================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 400); Main.Position = UDim2.new(0.5, -250, 0.5, -200)
Main.BackgroundColor3 = Theme.bg; Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.ClipsDescendants = true; Main.Parent = Gui
corner(Main, 8); stroke(Main, Theme.stroke, 2)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Theme.bg_secondary; Header.Parent = Main
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.Font = FontBold; Title.TextSize = 16; Title.TextColor3 = Theme.accent; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Text = " > CLIENT OBJECT INJECTOR"; Title.Parent = Header; pad(Title, 14, 0, 0, 0)

-- ==========================================
-- 2. TOMBOL FLOATING "K"
-- ==========================================
local FloatLogo = Instance.new("TextButton")
FloatLogo.Size = UDim2.new(0, 50, 0, 50)
FloatLogo.Position = UDim2.new(0, 20, 0.5, -25)
FloatLogo.BackgroundColor3 = Theme.bg
FloatLogo.BorderSizePixel = 0
FloatLogo.Text = "K"
FloatLogo.TextColor3 = Theme.accent
FloatLogo.Font = FontBold
FloatLogo.TextSize = 24
FloatLogo.Visible = false
FloatLogo.Active = true
FloatLogo.Draggable = true
FloatLogo.Parent = Gui
corner(FloatLogo, 25)
stroke(FloatLogo, Theme.accent, 2)

-- ==========================================
-- 3. FUNGSI MINIMIZE / MAXIMIZE
-- ==========================================
local function iconBtn(parent, x, txt, col, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 24, 0, 24); b.Position = UDim2.new(1, x, 0.5, -12); b.BackgroundColor3 = Theme.bg_tertiary; b.Text = txt; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 14; b.Parent = parent; corner(b, 4); b.MouseButton1Click:Connect(cb)
end

-- Tombol Minimize (—)
iconBtn(Header, -70, "—", Theme.text_dim, function() 
    Main.Visible = false 
    FloatLogo.Visible = true 
end)

-- Tombol Close (X)
iconBtn(Header, -40, "✕", Theme.red, function() 
    Gui:Destroy() 
end)

-- Pas tombol K diklik, panel balik muncul
FloatLogo.MouseButton1Click:Connect(function()
    FloatLogo.Visible = false
    Main.Visible = true
end)

-- ==========================================
-- 4. KONTEN & FITUR
-- ==========================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60); Content.Position = UDim2.new(0, 10, 0, 50); Content.BackgroundTransparency = 1; Content.Parent = Main
local ListLayout = Instance.new("UIListLayout"); ListLayout.Padding = UDim.new(0, 8); ListLayout.Parent = Content

local function createActionBtn(parent, text, col, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42); b.BackgroundColor3 = Theme.bg_secondary; b.Text = text; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 14; b.Parent = parent; corner(b, 4); stroke(b, Theme.stroke, 1)
    b.MouseButton1Click:Connect(callback)
end

local function getPos()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart.Position
    end
    return Vector3.new(0, 0, 0)
end

-- FITUR 1: ORBITAL STRIKE
createActionBtn(Content, "[ SUMMON ORBITAL STRIKE ]", Color3.fromRGB(0, 255, 255), function()
    local pos = getPos()
    for i = 1, 5 do
        local beam = Instance.new("Part")
        beam.Size = Vector3.new(10, 500, 10)
        beam.Position = pos + Vector3.new(math.random(-20, 20), 250, math.random(-20, 20))
        beam.Anchored = true; beam.CanCollide = false; beam.Material = Enum.Material.Neon; beam.Color = Color3.fromRGB(0, 255, 255); beam.Transparency = 0.3
        beam.Parent = Workspace
        
        local pointLight = Instance.new("PointLight", beam)
        pointLight.Brightness = 5; pointLight.Range = 50; pointLight.Color = Color3.fromRGB(0, 255, 255)
        
        TweenService:Create(beam, TweenInfo.new(2), {Size = Vector3.new(0, 500, 0), Transparency = 1}):Play()
        task.delay(2, function() beam:Destroy() end)
    end
end)

-- FITUR 2: FAKE GLOBAL MESSAGE
createActionBtn(Content, "[ BROADCAST GLOBAL MESSAGE ]", Color3.fromRGB(255, 0, 0), function()
    local part = Instance.new("Part")
    part.Size = Vector3.new(200, 50, 2); part.Position = getPos() + Vector3.new(0, 100, 0)
    part.Anchored = true; part.CanCollide = false; part.Transparency = 1; part.Parent = Workspace
    
    local sg = Instance.new("SurfaceGui", part)
    sg.Face = Enum.NormalId.Front
    local txt = Instance.new("TextLabel", sg)
    txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundColor3 = Color3.fromRGB(0, 0, 0); txt.BackgroundTransparency = 0.5
    txt.Text = "SYSTEM: ALL PLAYERS HAVE BEEN HACKED."; txt.TextColor3 = Color3.fromRGB(255, 0, 0); txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.Code; txt.TextSize = 50
    
    task.delay(8, function() part:Destroy() end)
end)

-- FITUR 3: BLACK HOLE
createActionBtn(Content, "[ SUMMON BLACK HOLE ]", Color3.fromRGB(150, 0, 255), function()
    local pos = getPos() + Vector3.new(0, 20, 0)
    local hole = Instance.new("Part")
    hole.Size = Vector3.new(50, 50, 50); hole.Shape = Enum.PartType.Ball; hole.Position = pos
    hole.Anchored = true; hole.CanCollide = false; hole.Material = Enum.Material.Neon; hole.Color = Color3.fromRGB(20, 0, 30); hole.Parent = Workspace
    
    local sg = Instance.new("SurfaceGui", hole)
    local txt = Instance.new("TextLabel", sg)
    txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = "SINGULARITY"; txt.TextColor3 = Color3.fromRGB(200, 0, 255); txt.TextScaled = true; txt.Font = Enum.Font.Code
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj ~= hole and not obj.Anchored then
                local dist = (obj.Position - hole.Position).Magnitude
                if dist < 100 then
                    obj.CFrame = obj.CFrame + (hole.CFrame.Position - obj.Position).Unit * 2
                end
            end
        end
    end)
    
    task.delay(10, function() conn:Disconnect(); hole:Destroy() end)
end)

-- FITUR 4: PET CUBE
createActionBtn(Content, "[ SPAWN SPINNING PET ]", Color3.fromRGB(255, 200, 0), function()
    local char = LP.Character
    if not char then return end
    
    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 4, 4); cube.Material = Enum.Material.Neon; cube.Color = Color3.fromRGB(255, 200, 0); cube.CanCollide = false; cube.Anchored = true; cube.Parent = Workspace
    
    local angle = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            conn:Disconnect(); cube:Destroy(); return
        end
        angle = angle + 0.1
        local hrp = char.HumanoidRootPart
        cube.CFrame = CFrame.new(hrp.Position + Vector3.new(math.cos(angle)*8, 5, math.sin(angle)*8))
    end)
    
    task.delay(20, function() conn:Disconnect(); cube:Destroy() end)
end)

-- FITUR 5: EARTHQUAKE
createActionBtn(Content, "[ TRIGGER EARTHQUAKE ]", Color3.fromRGB(255, 100, 0), function()
    local cam = Workspace.CurrentCamera
    local origType = cam.CameraType
    cam.CameraType = Enum.CameraType.Scriptable
    
    for i = 1, 50 do
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(math.random(-2,2), 10, math.random(-2,2)), hrp.Position)
        end
        task.wait(0.05)
    end
    
    cam.CameraType = origType
end)

print("[@alpin67] Client Injector Loaded.")
