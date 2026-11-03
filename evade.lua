local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")

local LP = Players.LocalPlayer

if CoreGui:FindFirstChild("EvadePanel_v1") then
    CoreGui.EvadePanel_v1:Destroy()
end

local State = {
    esp = false, aimbot = false, dodge = false, speed = false,
    noclip = false, auto_obj = false, candy = false, safe = false,
    farm = false, auto_revive = false, anti_ban = true, auto_hop = true, anti_tp = false,
    aim_fov = 250, aim_smooth = 0.35, speed_value = 32,
}

local Theme = {
    bg = Color3.fromRGB(18, 18, 24), bg_secondary = Color3.fromRGB(26, 26, 34),
    bg_tertiary = Color3.fromRGB(34, 34, 44), stroke = Color3.fromRGB(48, 48, 60),
    text = Color3.fromRGB(230, 230, 240), text_dim = Color3.fromRGB(140, 140, 160),
    accent = Color3.fromRGB(120, 100, 255), accent_dim = Color3.fromRGB(80, 70, 180),
    green = Color3.fromRGB(80, 220, 130), red = Color3.fromRGB(230, 80, 100),
}

local Font = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function pad(parent, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "EvadePanel_v1"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 340)
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Theme.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = Gui
corner(Main, 10)
stroke(Main, Theme.stroke, 1, 0)

local FloatLogo = Instance.new("TextButton")
FloatLogo.Size = UDim2.new(0, 46, 0, 46)
FloatLogo.Position = UDim2.new(0, 50, 0.5, -23)
FloatLogo.BackgroundColor3 = Theme.bg
FloatLogo.BorderSizePixel = 0
FloatLogo.Text = "K"
FloatLogo.TextColor3 = Theme.accent
FloatLogo.Font = FontBold
FloatLogo.TextSize = 20
FloatLogo.Visible = false
FloatLogo.Active = true
FloatLogo.Draggable = true
FloatLogo.Parent = Gui
corner(FloatLogo, 23)
stroke(FloatLogo, Theme.accent, 2, 0)

FloatLogo.MouseButton1Click:Connect(function()
    FloatLogo.Visible = false
    Main.Visible = true
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Theme.bg_secondary
Header.BorderSizePixel = 0
Header.Parent = Main

local TitleBox = Instance.new("Frame")
TitleBox.Size = UDim2.new(1, -100, 1, 0)
TitleBox.Position = UDim2.new(0, 14, 0, 0)
TitleBox.BackgroundTransparency = 1
TitleBox.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.Position = UDim2.new(0, 0, 0, 6)
Title.BackgroundTransparency = 1
Title.Font = FontBold
Title.TextSize = 15
Title.TextColor3 = Theme.text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "EVADE PANEL"
Title.Parent = TitleBox

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 16)
Subtitle.Position = UDim2.new(0, 0, 0, 24)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Font
Subtitle.TextSize = 11
Subtitle.TextColor3 = Theme.text_dim
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Text = "v2.0  •  hit and run edition"
Subtitle.Parent = TitleBox

local function iconButton(parent, xOffset, symbol, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, xOffset, 0, 8)
    b.BackgroundColor3 = Theme.bg_tertiary
    b.BorderSizePixel = 0
    b.Text = symbol
    b.TextColor3 = color
    b.Font = FontBold
    b.TextSize = 14
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 6)
    b.MouseButton1Click:Connect(callback)
    return b
end

iconButton(Header, -72, "—", Theme.text_dim, function()
    Main.Visible = false
    FloatLogo.Visible = true
end)
iconButton(Header, -40, "✕", Theme.red, function()
    Gui:Destroy()
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundColor3 = Theme.bg_secondary
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 6)
stroke(TabBar, Theme.stroke, 1, 0.5)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.Parent = TabBar
pad(TabBar, 2, 2, 2, 2)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -142)
ContentArea.Position = UDim2.new(0, 10, 0, 92)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 26)
Footer.Position = UDim2.new(0, 0, 1, -26)
Footer.BackgroundColor3 = Theme.bg_secondary
Footer.BorderSizePixel = 0
Footer.Parent = Main

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 14, 0.5, -4)
StatusDot.BackgroundColor3 = Theme.green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Footer
corner(StatusDot, 4)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -60, 1, 0)
StatusText.Position = UDim2.new(0, 28, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Font = Font
StatusText.TextSize = 11
StatusText.TextColor3 = Theme.text_dim
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Text = "ready"
StatusText.Parent = Footer

local function createToggle(parent, text, initial, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Theme.bg_secondary
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 6)
    pad(row, 12, 12, 0, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Font
    lbl.TextSize = 13
    lbl.TextColor3 = Theme.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = row

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 40, 0, 22)
    switchBg.Position = UDim2.new(1, -40, 0.5, -11)
    switchBg.BackgroundColor3 = initial and Theme.accent or Theme.bg_tertiary
    switchBg.BorderSizePixel = 0
    switchBg.Parent = row
    corner(switchBg, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = initial and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switchBg
    corner(knob, 8)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = row

    local state = initial
    clickArea.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switchBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.accent or Theme.bg_tertiary
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if callback then callback(state) end
    end)
end

local Tabs = {}
local function createTab(name, displayName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.BackgroundColor3 = Theme.bg_secondary
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = displayName
    btn.TextColor3 = Theme.text_dim
    btn.Font = FontBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    corner(btn, 4)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = ContentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = page

    Tabs[name] = {button = btn, page = page}
    btn.MouseButton1Click:Connect(function()
        for tname, tdata in pairs(Tabs) do
            tdata.page.Visible = (tname == name)
            tdata.button.TextColor3 = (tname == name) and Theme.text or Theme.text_dim
        end
    end)
    return page
end

local tabCombat = createTab("combat", "COMBAT")
createToggle(tabCombat, "ESP Highlight", false, function(v) State.esp = v end)
createToggle(tabCombat, "Aimbot", false, function(v) State.aimbot = v end)

local tabMovement = createTab("movement", "MOVEMENT")
createToggle(tabMovement, "Speed Hack", false, function(v)
    State.speed = v
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and State.speed_value or 16 end
    end
end)
createToggle(tabMovement, "Noclip", false, function(v) State.noclip = v end)

local tabFarm = createTab("farm", "FARM")
createToggle(tabFarm, "Auto Candy (Wisps)", false, function(v) State.candy = v end)
createToggle(tabFarm, "Farm Level (Basecamp)", false, function(v) State.farm = v end)
createToggle(tabFarm, "Auto Revive (Hit & Run)", false, function(v) State.auto_revive = v end)

local tabConfig = createTab("config", "CONFIG")
createToggle(tabConfig, "Auto Server Hop", true, function(v) State.auto_hop = v end)

Tabs["farm"].page.Visible = true
Tabs["farm"].button.TextColor3 = Theme.text
StatusText.Text = "loaded v2.0"

_G.ev = _G.ev or {}
_G.ev.State = State

-- ==========================================
-- AUTO REVIVE (HIT AND RUN)
-- ==========================================
local isReviving = false

local function getSafeGroundSpot()
    local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
    if spawn then return spawn.Position + Vector3.new(0, 5, 0) end
    return Vector3.new(0, 50, 0)
end

task.spawn(function()
    while task.wait(0.1) do
        if not State.auto_revive or isReviving then continue end
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local pChar = p.Character
            
            if pChar then
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                
                if pHum and pHum.Health <= 0 then
                    local targetPart = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Head") or pChar:FindFirstChildWhichIsA("BasePart")
                    
                    if targetPart then
                        isReviving = true
                        
                        local offset = CFrame.new(math.random(-2,2), 2, math.random(-2,2))
                        hrp.CFrame = targetPart.CFrame * offset
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        
                        local prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt", true) 
                                    or pChar:FindFirstChildWhichIsA("ProximityPrompt", true)
                        
                        if not prompt then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") and obj.Parent:IsA("BasePart") then
                                    if (obj.Parent.Position - targetPart.Position).Magnitude < 15 then
                                        prompt = obj
                                        break
                                    end
                                end
                            end
                        end

                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                            if prompt.HoldDuration > 0 then
                                local holdEnd = tick() + prompt.HoldDuration
                                while tick() < holdEnd do
                                    hrp.CFrame = targetPart.CFrame * offset
                                    task.wait(0.05)
                                end
                                pcall(function() fireproximityprompt(prompt) end)
                            else
                                task.wait(0.2)
                            end
                        else
                            task.wait(0.3)
                        end
                        
                        task.wait(0.2)
                        if State.farm then
                            hrp.CFrame = CFrame.new(Vector3.new(0, 1500, 0) + Vector3.new(0, 4, 0))
                        else
                            hrp.CFrame = CFrame.new(getSafeGroundSpot())
                        end
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        
                        task.wait(0.5)
                        isReviving = false
                        break
                    end
                end
            end
        end
    end
end)
