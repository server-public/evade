local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

RunService.Heartbeat:Connect(function()
    if not State.candy then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local best, bestD = nil, math.huge
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find("candy") then
            local dist = (d.Position - hrp.Position).Magnitude
            if dist < bestD then best, bestD = d, dist end
        end
    end
    if best and bestD > 4 then
        hrp.CFrame = CFrame.new(best.Position + Vector3.new(0, 3, 0))
    end
end)

RunService.Heartbeat:Connect(function()
    if not State.farm then return end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, 1500, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)