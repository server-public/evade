local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")

local LP = Players.LocalPlayer
local SelectedPlayer = nil

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

-- PANEL UTAMA
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 400); Main.Position = UDim2.new(0.5, -240, 0.5, -200)
Main.BackgroundColor3 = Theme.bg; Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.ClipsDescendants = true; Main.Parent = Gui
corner(Main, 8); stroke(Main, Theme.stroke, 2)

-- TOMBOL FLOATING "K"
local FloatLogo = Instance.new("TextButton")
FloatLogo.Size = UDim2.new(0, 50, 0, 50); FloatLogo.Position = UDim2.new(0, 20, 0.5, -25)
FloatLogo.BackgroundColor3 = Theme.bg; FloatLogo.BorderSizePixel = 0; FloatLogo.Text = "K"
FloatLogo.TextColor3 = Theme.accent; FloatLogo.Font = FontBold; FloatLogo.TextSize = 24
FloatLogo.Visible = false; FloatLogo.Active = true; FloatLogo.Draggable = true; FloatLogo.Parent = Gui
corner(FloatLogo, 25); stroke(FloatLogo, Theme.accent, 2)

FloatLogo.MouseButton1Click:Connect(function() FloatLogo.Visible = false; Main.Visible = true end)

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Theme.bg_secondary; Header.Parent = Main
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.Font = FontBold; Title.TextSize = 16; Title.TextColor3 = Theme.accent; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Text = " > NETWORK REPLICATOR"; Title.Parent = Header; pad(Title, 14, 0, 0, 0)

local function iconBtn(parent, x, txt, col, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 24, 0, 24); b.Position = UDim2.new(1, x, 0.5, -12); b.BackgroundColor3 = Theme.bg_tertiary; b.Text = txt; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 14; b.Parent = parent; corner(b, 4); b.MouseButton1Click:Connect(cb)
end
iconBtn(Header, -70, "—", Theme.text_dim, function() Main.Visible = false; FloatLogo.Visible = true end)
iconBtn(Header, -40, "✕", Theme.red, function() Gui:Destroy() end)

-- KONTEN
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60); Content.Position = UDim2.new(0, 10, 0, 50); Content.BackgroundTransparency = 1; Content.Parent = Main
local ListLayout = Instance.new("UIListLayout"); ListLayout.Padding = UDim.new(0, 6); ListLayout.Parent = Content

-- INFO TARGET
local TargetInfo = Instance.new("TextLabel")
TargetInfo.Size = UDim2.new(1, 0, 0, 30); TargetInfo.BackgroundColor3 = Theme.bg_secondary; TargetInfo.Text = " Target: BELUM DIPILIH"
TargetInfo.TextColor3 = Theme.red; TargetInfo.Font = FontBold; TargetInfo.TextXAlignment = Enum.TextXAlignment.Left; TargetInfo.Parent = Content
corner(TargetInfo, 4); pad(TargetInfo, 10, 0, 0, 0)

-- LIST PLAYER
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, 0, 0, 100); PlayerList.BackgroundColor3 = Theme.bg_tertiary; PlayerList.BorderSizePixel = 0; PlayerList.ScrollBarThickness = 4
PlayerList.Parent = Content; corner(PlayerList, 4)

local function refreshList()
    for _, v in ipairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    local yPos = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 28); btn.Position = UDim2.new(0, 3, 0, yPos)
            btn.BackgroundColor3 = (p == SelectedPlayer) and Theme.accent or Theme.bg_secondary
            btn.Text = " " .. p.Name; btn.TextColor3 = Theme.text; btn.Font = Font; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = PlayerList; corner(btn, 2)
            
            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = p
                TargetInfo.Text = " Target: " .. p.Name
                TargetInfo.TextColor3 = Theme.accent
                refreshList()
            end)
            yPos = yPos + 30
        end
    end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

task.spawn(function()
    while Gui.Parent do
        refreshList()
        task.wait(3)
    end
end)

-- FUNGSI EKSEKUSI
local function createActionBtn(parent, text, col, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Theme.bg_secondary; b.Text = text; b.TextColor3 = col; b.Font = FontBold; b.TextSize = 14; b.Parent = parent; corner(b, 4); stroke(b, Theme.stroke, 1)
    b.MouseButton1Click:Connect(callback)
end

local function takeOwnershipAndModify(target, mode)
    if not target or not target.Character then return end
    local char = target.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Coba ambil Network Ownership
    local success = pcall(function()
        hrp:SetNetworkOwner(LP)
    end)
    
    if success then
        if mode == "TITAN" then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 2.5
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5, 1, 1)
                end
            end
        elseif mode == "JAIL" then
            local jail_anchor = Instance.new("Part")
            jail_anchor.Anchored = true; jail_anchor.Size = Vector3.new(1, 1, 1); jail_anchor.Transparency = 1; jail_anchor.CFrame = hrp.CFrame; jail_anchor.Parent = Workspace
            
            local weld = Instance.new("WeldConstraint"); weld.Part0 = hrp; weld.Part1 = jail_anchor; weld.Parent = hrp
            
            for i = 1, 4 do
                local wall = Instance.new("Part")
                wall.Size = Vector3.new(15, 20, 1); wall.Anchored = false; wall.Transparency = 0.3
                wall.Color = Color3.fromRGB(100, 100, 100); wall.Material = Enum.Material.ForceField; wall.Parent = Workspace
                
                local wall_weld = Instance.new("WeldConstraint"); wall_weld.Part0 = jail_anchor; wall_weld.Part1 = wall; wall_weld.Parent = wall
                
                if i == 1 then wall.CFrame = jail_anchor.CFrame * CFrame.new(0, 0, -7) 
                elseif i == 2 then wall.CFrame = jail_anchor.CFrame * CFrame.new(0, 0, 7) 
                elseif i == 3 then wall.CFrame = jail_anchor.CFrame * CFrame.new(-7, 0, 0) 
                elseif i == 4 then wall.CFrame = jail_anchor.CFrame * CFrame.new(7, 0, 0) end
            end
        end
    else
        warn("[Evade] Gagal ambil Network Ownership. Server menolak.")
    end
end

-- BUTTON AKSI
createActionBtn(Content, "[ EXECUTE: TITAN ]", Color3.fromRGB(0, 255, 255), function()
    if SelectedPlayer then takeOwnershipAndModify(SelectedPlayer, "TITAN") end
end)

createActionBtn(Content, "[ EXECUTE: JAIL ]", Color3.fromRGB(255, 150, 0), function()
    if SelectedPlayer then takeOwnershipAndModify(SelectedPlayer, "JAIL") end
end)

print("[@alpin67] Full Network Replicator Loaded.")
