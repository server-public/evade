local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local SAFE_Y = 1500
local basePart = nil
local lockPos = Vector3.new(0, SAFE_Y, 0)
local isSweeping = false

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

-- 1. Kunci Posisi (ANTI NEXBOT TP)
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

    if not isSweeping then
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - lockPos).Magnitude > 10 then
                hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- 2. WISP SWEEP (Dengan Remote Bypass & Anti-Loop)
task.spawn(function()
    while task.wait(0.5) do
        if State.candy then
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- Kumpulin daftar Wisp
                local targets = {}
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("BasePart") then
                        local n = d.Name:lower()
                        local pName = d.Parent and d.Parent.Name:lower() or ""
                        
                        if n:find("wisp") or pName:find("wisp") or n:find("event") or pName:find("halloween") or n:find("treat") then
                            if d.Name ~= "ev_personal_base" then
                                table.insert(targets, d)
                            end
                        end
                    end
                end

                -- Kumpulin RemoteEvent (Buat nembak server)
                local remotes = {}
                for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                    if r:IsA("RemoteEvent") then
                        local rn = r.Name:lower()
                        if rn:find("collect") or rn:find("wisp") or rn:find("pickup") or rn:find("claim") or rn:find("event") then
                            table.insert(remotes, r)
                        end
                    end
                end

                if #targets > 0 then
                    isSweeping = true
                    for _, target in ipairs(targets) do
                        if not State.candy then break end
                        
                        -- Pindah ke lokasi Wisp
                        hrp.CFrame = target.CFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.05)
                        
                        -- A. Eksekusi ProximityPrompt kalau ada
                        local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                        
                        -- B. Sentuh Fisik (Touch)
                        if firetouchinterest then
                            pcall(function() firetouchinterest(target, hrp, 0) end)
                            task.wait(0.02)
                            pcall(function() firetouchinterest(target, hrp, 1) end)
                        end

                        -- C. Tembak RemoteEvent (Server-Side Collector)
                        for _, remote in ipairs(remotes) do
                            pcall(function()
                                -- Tembak pakai target part, atau nama, atau ID (spam semua kemungkinan)
                                remote:FireServer(target)
                                remote:FireServer(target.Name)
                                remote:FireServer()
                            end)
                        end
                        
                        -- Jeda napas biar server gak nge-flag sebagai spam
                        task.wait(0.1)
                    end
                    
                    -- Balik ke posisi aman
                    if State.farm then
                        hrp.CFrame = CFrame.new(lockPos + Vector3.new(0, 4, 0))
                    end
                    -- Kalau Farm OFF, lo dibiarin di Wisp terakhir (gak ditarik balik)
                    
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    isSweeping = false
                end
            end
        end
    end
end)
