local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local activeAura = nil
local spinConn = nil

if CoreGui:FindFirstChild("PhysicalAccessoryGui") then
    CoreGui.PhysicalAccessoryGui:Destroy()
end

local function clearAura()
    if spinConn then
        spinConn:Disconnect()
        spinConn = nil
    end
    if activeAura then
        activeAura:Destroy()
        activeAura = nil
    end
end

local function equipAura()
    clearAura()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    activeAura = Instance.new("Model")
    activeAura.Name = "ReplicatedAura"
    activeAura.Parent = char
    
    for i = 1, 6 do
        local orb = Instance.new("Part")
        orb.Size = Vector3.new(1.5, 1.5, 1.5)
        orb.Shape = Enum.PartType.Ball
        orb.Material = Enum.Material.Neon
        orb.Color = Color3.fromRGB(255, 0, 255)
        orb.CanCollide = false
        orb.Massless = true
        orb.Parent = activeAura
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = orb
        weld.Parent = orb
        
        orb.CFrame = hrp.CFrame * CFrame.new(math.cos(i) * 4, math.sin(i) * 2, math.sin(i) * 4)
    end
    
    local angle = 0
    spinConn = RunService.Heartbeat:Connect(function()
        if not char.Parent or not hrp.Parent then
            clearAura()
            return
        end
        angle = angle + 0.05
        for i, orb in ipairs(activeAura:GetChildren()) do
            if orb:IsA("BasePart") then
                local offsetAngle = angle + (i * (math.pi * 2 / 6))
                orb.CFrame = hrp.CFrame * CFrame.new(math.cos(offsetAngle) * 4, math.sin(angle) * 2, math.sin(offsetAngle) * 4)
            end
        end
    end)
end

local function equipCrown()
    clearAura()
    local char = LP.Character
    if not char or not char:FindFirstChild("Head") then return end
    
    local head = char.Head
    activeAura = Instance.new("Part")
    activeAura.Name = "ReplicatedCrown"
    activeAura.Size = Vector3.new(3, 3, 3)
    activeAura.Material = Enum.Material.Neon
    activeAura.Color = Color3.fromRGB(0, 255, 255)
    activeAura.CanCollide = false
    activeAura.Massless = true
    activeAura.Parent = char
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = activeAura
    weld.Parent = activeAura
    
    activeAura.CFrame = head.CFrame * CFrame.new(0, 2, 0)
end

local gui = Instance.new("ScreenGui")
gui.Name = "PhysicalAccessoryGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0, 20, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local function createBtn(text, y, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.Text = text
    b.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
end

createBtn("Equip Orb Aura", 10, Color3.fromRGB(255, 0, 255), equipAura)
createBtn("Equip Neon Crown", 50, Color3.fromRGB(0, 255, 255), equipCrown)
createBtn("Clear", 90, Color3.fromRGB(255, 100, 100), clearAura)
