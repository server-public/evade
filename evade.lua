local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")

local LP = Players.LocalPlayer

if CoreGui:FindFirstChild("EvadePanel_v1") then
    CoreGui.EvadePanel_v1:Destroy()
end

local State = { farm = false, candy = false, auto_revive = false }
local SelectedPlayer = nil

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
Main.Size = UDim2.new(0, 500, 0, 420); Main.Position = UDim2.new(0.5, -250, 0.5, -210)
Main.BackgroundColor3 = Theme.bg; Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.ClipsDescendants = true; Main.Parent = Gui
corner(Main, 8); stroke(Main, Theme.stroke, 2)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Theme.bg_secondary; Header.Parent = Main
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.Font = FontBold; Title.TextSize = 16; Title.TextColor3 = Theme.accent; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Text = " > TARGET SYSTEM // GOD MODE"; Title.Parent = Header; pad(Title, 14, 0, 0, 0)

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

-- ==========================================
-- TAB TARGET SELECTOR
-- ==========================================
local tabTarget = createTab("target", "PILIH TARGET")

local TargetInfo = Instance.new("TextLabel")
TargetInfo.Size = UDim2.new(1, 0, 0, 30)
TargetInfo.BackgroundColor3 = Theme.bg_secondary
TargetInfo.Text = " Target: BELUM DIPILIH"
TargetInfo.TextColor3 = Theme.red
TargetInfo.Font = FontBold
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
TargetInfo.Parent = tabTarget
corner(TargetInfo, 4)
pad(TargetInfo, 10, 0, 0, 0)

local PlayerContainer = Instance.new("Frame")
PlayerContainer.Size = UDim2.new(1, 0, 0, 150)
PlayerContainer.BackgroundColor3 = Theme.bg
PlayerContainer.BackgroundTransparency = 0.5
PlayerContainer.Parent = tabTarget
corner(PlayerContainer, 4)

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, 0, 1, 0)
PlayerList.BackgroundTransparency = 1
PlayerList.ScrollBarThickness = 4
PlayerList.Parent = PlayerContainer
local PListLayout = Instance.new("UIListLayout")
PListLayout.Padding = UDim.new(0, 2)
PListLayout.Parent = PlayerList

local function refreshPlayerList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 32)
            btn.BackgroundColor3 = Theme.bg_tertiary
            btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = (p == SelectedPlayer) and Theme.accent or Theme.text
            btn.Font = Font
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = PlayerList
            corner(btn, 2)

            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = p
                TargetInfo.Text = " Target: " .. p.Name
                TargetInfo.TextColor3 = Theme.accent
                refreshPlayerList() -- Refresh warna
            end)
        end
    end
end

-- Auto Refresh list tiap 2 detik
task.spawn(function()
    while Gui.Parent do
        refreshPlayerList()
        task.wait(2)
    end
end)

local function createActionBtn(parent, text, col, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36); b.BackgroundColor3 = Theme.bg_secondary; b.Text = text; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 13; b.Parent = parent; corner(b, 4); stroke(b, Theme.stroke, 1)
    b.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- AKSI HACK (DENGAN PENGAMAN)
-- ==========================================
createActionBtn(tabTarget, "[ KURUNG TARGET DI PENJARA ]", Color3.fromRGB(255, 150, 0), function()
    if not SelectedPlayer then return end
    local char = SelectedPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end -- Karakter belum spawn
    
    local pos = hrp.Position
    local walls = {
        {Size = Vector3.new(12, 15, 1), Offset = Vector3.new(0, 0, -6)},
        {Size = Vector3.new(12, 15, 1), Offset = Vector3.new(0, 0, 6)},
        {Size = Vector3.new(1, 15, 12), Offset = Vector3.new(-6, 0, 0)},
        {Size = Vector3.new(1, 15, 12), Offset = Vector3.new(6, 0, 0)},
        {Size = Vector3.new(12, 1, 12), Offset = Vector3.new(0, -7, 0)}
    }
    for _, w in ipairs(walls) do
        local part = Instance.new("Part")
        part.Size = w.Size; part.Position = pos + w.Offset; part.Anchored = true; part.CanCollide = true
        part.Color = Color3.fromRGB(100, 100, 100); part.Material = Enum.Material.Metal; part.Transparency = 0.3; part.Parent = Workspace
        local sg = Instance.new("SurfaceGui", part)
        local txt = Instance.new("TextLabel", sg); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = "JAILED"; txt.TextColor3 = Color3.fromRGB(255, 0, 0); txt.TextScaled = true; txt.Font = Enum.Font.Code
        task.delay(15, function() if part and part.Parent then part:Destroy() end end)
    end
end)

createActionBtn(tabTarget, "[ JADIKAN TARGET TITAN ]", Color3.fromRGB(0, 255, 255), function()
    if not SelectedPlayer then return end
    local char = SelectedPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Pengaman: Hanya perbesar 5x biar gak crash
            part.Size = part.Size * 5 
            part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5, 1, 1)
        end
    end
end)

createActionBtn(tabTarget, "[ JADIKAN TARGET KECIL ]", Color3.fromRGB(255, 100, 255), function()
    if not SelectedPlayer then return end
    local char = SelectedPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then 
            part.Size = part.Size / 3 
        end
    end
end)

-- ==========================================
-- TAB FARM
-- ==========================================
local tabFarm = createTab("farm", "FARM")
createActionBtn(tabFarm, "Toggle Farm Level", Theme.text, function() State.farm = not State.farm end)
createActionBtn(tabFarm, "Toggle Auto Candy", Theme.text, function() State.candy = not State.candy end)
createActionBtn(tabFarm, "Toggle Auto Revive", Theme.text, function() State.auto_revive = not State.auto_revive end)

Tabs["target"].page.Visible = true
Tabs["target"].button.TextColor3 = Theme.accent

_G.ev = _G.ev or {}
_G.ev.State = State
