local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local SAFE_Y = 1500
local basePart = nil
local lockPos = Vector3.new(0, SAFE_Y, 0)

local function buildPlatform()
    if basePart and basePart.Parent then basePart:Destroy() end
    local p = Instance.new("Part")
    p.Name = "ev_personal_base"
    p.Size = Vector3.new(30, 2, 30)
    p.Position = lockPos
    p.Anchored = true
    p.CanCollide = true
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(120, 100, 255)
    p.Transparency = 0.5
    p.Parent = Workspace
    basePart = p
end

RunService.Heartbeat:Connect(function()
    if not State.farm then 
        if basePart and basePart.Parent then
            basePart:Destroy()
            basePart = nil
        end
        return 
    end

    if not basePart or not basePart.Parent then
        buildPlatform()
    end

    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if (hrp.Position - lockPos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not State.candy or not State.farm then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myPos = hrp.Position

    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.Name ~= "ev_personal_base" then
            local model = d:FindFirstAncestorOfClass("Model")
            if model and Players:GetPlayerFromCharacter(model) then continue end
            
            local n = d.Name:lower()
            local isWisp = n:find("wisp") or n:find("event") or n:find("halloween") or n:find("orb") or n:find("light")
            
            if isWisp then
                d.CFrame = CFrame.new(myPos + Vector3.new(0, 3, 0))
                
                local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                
                local tool = d:FindFirstAncestorOfClass("Tool")
                if tool then
                    tool.Parent = char
                end
            end
        end
    end
end)
