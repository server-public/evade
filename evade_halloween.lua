local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local SAFE_Y = 1500
local lockPos = Vector3.new(0, SAFE_Y, 0)
local basePart = nil
local isBusy = false

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

-- 1. KUNCI POSISI (Hanya jika TIDAK SEDANG BERGANTIAN TUGAS)
RunService.Heartbeat:Connect(function()
    if not State.farm then 
        if basePart and basePart.Parent then
            basePart:Destroy()
            basePart = nil
        end
        return 
    end

    if not basePart or not basePart.Parent then buildPlatform() end

    -- KUNCI MUTLAK: Hanya kunci kalau lagi gak ngerjain apa-apa
    if not isBusy then
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - lockPos).Magnitude > 15 then
                hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- 2. ROTASI KERJA (WISP & REVIVE)
task.spawn(function()
    while task.wait(0.5) do
        if isBusy then continue end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local didAction = false

        -- A. AUTO REVIVE
        if State.auto_revive then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if pHum and pHum.Health <= 0 then
                        local targetPart = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            isBusy = true
                            
                            -- NEMPEL PERSIS DI MAYAT (Biar server ngenalin jaraknya 0)
                            hrp.CFrame = targetPart.CFrame
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            
                            -- Jeda 1 detik biar UI game muncul
                            task.wait(1)
                            
                            -- Tembak Remote yang kemungkinan besar adalah Revive
                            for _, r in ipairs(game:GetDescendants()) do
                                if r:IsA("RemoteEvent") then
                                    local rn = r.Name:lower()
                                    if rn:find("revive") or rn:find("rescue") or rn:find("heal") or rn:find("player") then
                                        pcall(function()
                                            r:FireServer(p) 
                                            r:FireServer(p.Name)
                                            r:FireServer(targetPart)
                                        end)
                                    end
                                end
                            end
                            
                            -- Pencet Prompt fisik
                            local prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then pcall(function() fireproximityprompt(prompt) end) end
                            
                            task.wait(1.5) -- Tunggu server respawn player
                            
                            if State.farm then
                                hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                            end
                            
                            didAction = true
                            isBusy = false
                            break
                        end
                    end
                end
            end
        end

        -- B. AUTO WISP
        if not didAction and State.candy then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("BasePart") and d.Name ~= "ev_personal_base" then
                    local n = d.Name:lower()
                    local pName = d.Parent and d.Parent.Name:lower() or ""
                    
                    if n:find("wisp") or pName:find("wisp") then
                        isBusy = true
                        
                        -- NEMPEL PERSIS DI WISP
                        hrp.CFrame = CFrame.new(d.Position)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.1)
                        
                        -- Tembak Remote Wisp
                        for _, r in ipairs(game:GetDescendants()) do
                            if r:IsA("RemoteEvent") then
                                local rn = r.Name:lower()
                                if rn:find("wisp") or rn:find("collect") or rn:find("pickup") or rn:find("event") then
                                    pcall(function()
                                        r:FireServer(d)
                                        r:FireServer(d.Name)
                                    end)
                                end
                            end
                        end
                        
                        -- Sentuh fisik
                        if firetouchinterest then
                            pcall(function() firetouchinterest(d, hrp, 0) end)
                            pcall(function() firetouchinterest(d, hrp, 1) end)
                        end
                        
                        local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then pcall(function() fireproximityprompt(prompt) end) end
                        
                        task.wait(0.3)
                        
                        if State.farm then
                            hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                        end
                        
                        didAction = true
                        isBusy = false
                        break
                    end
                end
            end
        end
    end
end)
