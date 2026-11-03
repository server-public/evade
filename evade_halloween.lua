local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local SAFE_Y = 1500
local lockPos = Vector3.new(0, SAFE_Y, 0)
local basePart = nil

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

-- 1. KUNCI POSISI (FARM)
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
        if hrp and (hrp.Position - lockPos).Magnitude > 20 then
            hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- 2. LOGIKA WISP & REVIVE
task.spawn(function()
    while task.wait(0.5) do
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local didAction = false

        -- A. AUTO REVIVE (UI CLICK)
        if State.auto_revive then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if pHum and pHum.Health <= 0 then
                        local targetPart = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            hrp.CFrame = targetPart.CFrame
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.2)
                            
                            -- Nge-klik tombol UI (+) di layar
                            for _, gui in ipairs(CoreGui:GetChildren()) do
                                if gui:IsA("ScreenGui") or gui:IsA("Folder") then
                                    for _, obj in ipairs(gui:GetDescendants()) do
                                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                            local name = obj.Name:lower()
                                            if name:find("revive") or name:find("rescue") or name:find("plus") or name == "+" then
                                                if obj.Visible then
                                                    pcall(function()
                                                        if obj.Activate then obj:Activate() end
                                                        obj.MouseButton1Click:Fire()
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            -- Fallback remote
                            for _, r in ipairs(game:GetDescendants()) do
                                if r:IsA("RemoteEvent") then
                                    pcall(function() r:FireServer(p) end)
                                end
                            end
                            
                            task.wait(1.5) 
                            
                            if State.farm then
                                hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                            end
                            
                            didAction = true
                            break 
                        end
                    end
                end
            end
        end

        -- B. AUTO WISP (BLINK)
        if not didAction and State.candy then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("BasePart") and d.Name ~= "ev_personal_base" then
                    local n = d.Name:lower()
                    local pName = d.Parent and d.Parent.Name:lower() or ""
                    
                    if n:find("wisp") or pName:find("wisp") then
                        hrp.CFrame = CFrame.new(d.Position + Vector3.new(0, 3, 0))
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.1)
                        
                        local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then pcall(function() fireproximityprompt(prompt) end) end
                        
                        if firetouchinterest then
                            pcall(function() firetouchinterest(d, hrp, 0) end)
                            pcall(function() firetouchinterest(d, hrp, 1) end)
                        end
                        
                        for _, r in ipairs(game:GetDescendants()) do
                            if r:IsA("RemoteEvent") then
                                pcall(function() r:FireServer(d) end)
                                pcall(function() r:FireServer(d.Name) end)
                            end
                        end
                        
                        task.wait(0.2)
                        
                        if State.farm then
                            hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                        end
                        
                        didAction = true
                        break
                    end
                end
            end
        end
    end
end)
