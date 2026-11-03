local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")

local LP = Players.LocalPlayer

if CoreGui:FindFirstChild("EvadePanel_v1") then
    CoreGui.EvadePanel_v1:Destroy()
end

local State = { esp = false, aimbot = false, speed = false, noclip = false, farm = false, candy = false, auto_revive = false }

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

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 400); Main.Position = UDim2.new(0.5, -250, 0.5, -200)
Main.BackgroundColor3 = Theme.bg; Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.ClipsDescendants = true; Main.Parent = Gui
corner(Main, 8); stroke(Main, Theme.stroke, 2)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Theme.bg_secondary; Header.Parent = Main
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.Font = FontBold; Title.TextSize = 16; Title.TextColor3 = Theme.accent; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Text = " > SERVER DOMINANCE // GOD MODE"; Title.Parent = Header; pad(Title, 14, 0, 0, 0)

local function iconBtn(parent, x, txt, col, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 24, 0, 24); b.Position = UDim2.new(1, x, 0.5, -12); b.BackgroundColor3 = Theme.bg_tertiary; b.Text = txt; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 12; b.Parent = parent; corner(b, 4); b.MouseButton1Click:Connect(cb)
end
iconBtn(Header, -70, "─", Theme.text_dim, function() Main.Visible = false end)
iconBtn(Header, -40, "✕", Theme.red, function() Gui:Destroy() end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30); TabBar.Position = UDim2.new(0, 10, 0, 50); TabBar.BackgroundColor3 = Theme.bg_secondary; TabBar.Parent = Main; corner(TabBar, 4)
local TabList = Instance.new("UIListLayout"); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Padding = UDim.new(0, 2); TabList.Parent = TabBar; pad(TabBar, 2, 2, 2, 2)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -142); Content.Position = UDim2.new(0, 10, 0, 88); Content.BackgroundTransparency = 1; Content.Parent = Main

local Tabs = {}
local function createTab(name, disp)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 100, 1, 0); btn.BackgroundTransparency = 1; btn.Text = disp; btn.TextColor3 = Theme.text_dim; btn.Font = FontBold; btn.TextSize = 12; btn.Parent = TabBar; corner(btn, 4)
    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.Visible = false; page.Parent = Content
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 6); ll.Parent = page
    Tabs[name] = {button = btn, page = page}
    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(Tabs) do
            t.page.Visible = (n == name)
            t.button.TextColor3 = (n == name) and Theme.accent or Theme.text_dim
        end
    end)
    return page
end

local function createActionBtn(parent, text, col, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36); b.BackgroundColor3 = Theme.bg_secondary; b.Text = text; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 13; b.Parent = parent; corner(b, 4); stroke(b, Theme.stroke, 1)
    b.MouseButton1Click:Connect(callback)
end

-- FUNGSI BANTUAN: CARI PLAYER TERDEKAT
local function getNearestPlayer()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local closest, dist = nil, math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                closest = p
            end
        end
    end
    return closest
end

-- TAB: PENJARA
local tabJail = createTab("jail", "PENJARA")

createActionBtn(tabJail, "[ PENJARAIN PLAYER TERDEKAT ]", Color3.fromRGB(255, 150, 0), function()
    local target = getNearestPlayer()
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = target.Character.HumanoidRootPart
    local pos = hrp.Position
    
    -- Bikin 5 dinding (kubus berongga)
    local walls = {
        {Size = Vector3.new(10, 15, 1), Offset = Vector3.new(0, 0, -5)}, -- Depan
        {Size = Vector3.new(10, 15, 1), Offset = Vector3.new(0, 0, 5)},  -- Belakang
        {Size = Vector3.new(1, 15, 10), Offset = Vector3.new(-5, 0, 0)}, -- Kiri
        {Size = Vector3.new(1, 15, 10), Offset = Vector3.new(5, 0, 0)},  -- Kanan
        {Size = Vector3.new(10, 1, 10), Offset = Vector3.new(0, -7, 0)}  -- Lantai
    }
    
    for _, w in ipairs(walls) do
        local part = Instance.new("Part")
        part.Size = w.Size
        part.Position = pos + w.Offset
        part.Anchored = true
        part.CanCollide = true
        part.Color = Color3.fromRGB(100, 100, 100)
        part.Material = Enum.Material.Metal
        part.Transparency = 0.3
        part.Parent = Workspace
        
        -- Efek teks di dinding
        local sg = Instance.new("SurfaceGui", part)
        local txt = Instance.new("TextLabel", sg)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "JAILED"
        txt.TextColor3 = Color3.fromRGB(255, 0, 0)
        txt.TextScaled = true
        txt.Font = Enum.Font.Code
        
        -- Hilangin dalam 15 detik
        task.delay(15, function() 
            if part and part.Parent then part:Destroy() end 
        end)
    end
end)

-- TAB: SCALE (TITAN & KECIL)
local tabScale = createTab("scale", "UKURAN")

createActionBtn(tabScale, "[ BIKIN TITAN (RAKSASA) ]", Color3.fromRGB(0, 255, 255), function()
    local target = getNearestPlayer()
    if not target or not target.Character then return end
    
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Perbesar ukuran 10x lipat
            part.Size = part.Size * 10
            part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5, 1, 1) -- Biar gak hancur
        end
    end
end)

createActionBtn(tabScale, "[ BIKIN KECIL (SEMUT) ]", Color3.fromRGB(255, 100, 255), function()
    local target = getNearestPlayer()
    if not target or not target.Character then return end
    
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Perkecil ukuran 5x lipat
            part.Size = part.Size / 5
        end
    end
end)

createActionBtn(tabScale, "[ KEMBALIKAN NORMAL ]", Color3.fromRGB(0, 255, 0), function()
    local target = getNearestPlayer()
    if not target or not target.Character then return end
    
    -- Reset (perlu relog kalau terlalu rusak, tapi ini coba reset default R6)
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Asumsi default R6 size
            if part.Name == "Head" then part.Size = Vector3.new(2, 1, 1)
            elseif part.Name == "Torso" then part.Size = Vector3.new(2, 2, 1)
            elseif part.Name == "HumanoidRootPart" then part.Size = Vector3.new(2, 2, 1)
            elseif string.find(part.Name, "Arm") then part.Size = Vector3.new(1, 2, 1)
            elseif string.find(part.Name, "Leg") then part.Size = Vector3.new(1, 2, 1)
            end
        end
    end
end)

-- TAB: SERVER HACK
local tabServer = createTab("server", "SERVER")

createActionBtn(tabServer, "[ BROADCAST MESSAGE RAKSASA ]", Color3.fromRGB(255, 0, 0), function()
    local msg = "SERVER HACKED BY ADMIN."
    local part = Instance.new("Part")
    part.Size = Vector3.new(200, 40, 2)
    part.Position = Vector3.new(0, 100, 0)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = Workspace
    
    local sg = Instance.new("SurfaceGui", part)
    sg.Face = Enum.NormalId.Front
    local txt = Instance.new("TextLabel", sg)
    txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 0.5; txt.BackgroundColor3 = Color3.new(0,0,0)
    txt.Text = msg; txt.TextColor3 = Color3.fromRGB(255, 0, 0); txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.Code; txt.TextSize = 50
    
    task.delay(10, function() part:Destroy() end)
end)

Tabs["jail"].page.Visible = true
Tabs["jail"].button.TextColor3 = Theme.accent

_G.ev = _G.ev or {}
_G.ev.State = State
