local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local isSweeping = false
local lastPos = nil

-- 1. Sapu Jagat Wisp (Auto Teleport & Collect)
task.spawn(function()
    while task.wait(0.2) do
        if not State.candy or isSweeping then continue end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Kumpulin semua Wisp di map
        local targets = {}
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                local n = d.Name:lower()
                local pName = d.Parent and d.Parent.Name:lower() or ""
                
                -- Cari nama Wisp / Event
                if n:find("wisp") or pName:find("wisp") or n:find("event") or pName:find("halloween") then
                    -- Skip kalo itu bagian dari karakter player
                    local model = d:FindFirstAncestorOfClass("Model")
                    if not (model and Players:GetPlayerFromCharacter(model)) then
                        table.insert(targets, d)
                    end
                end
            end
        end

        if #targets > 0 then
            isSweeping = true
            lastPos = hrp.Position -- Simpen posisi awal lo

            -- Kumpulin RemoteEvent buat nembak server
            local remotes = {}
            for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                if r:IsA("RemoteEvent") then
                    local rn = r.Name:lower()
                    if rn:find("collect") or rn:find("wisp") or rn:find("pickup") or rn:find("claim") or rn:find("event") then
                        table.insert(remotes, r)
                    end
                end
            end

            -- Mulai teleport ke tiap Wisp
            for _, target in ipairs(targets) do
                if not State.candy then break end
                
                hrp.CFrame = target.CFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.03) -- Delay super singkat

                -- A. Pencet ProximityPrompt (kalau ada)
                local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end

                -- B. Sentuh fisik
                if firetouchinterest then
                    pcall(function() firetouchinterest(target, hrp, 0) end)
                    pcall(function() firetouchinterest(target, hrp, 1) end)
                end

                -- C. Tembak RemoteEvent (Bypass UI)
                for _, remote in ipairs(remotes) do
                    pcall(function()
                        remote:FireServer(target)
                        remote:FireServer(target.Name)
                        remote:FireServer()
                    end)
                end
                
                task.wait(0.05) -- Jeda sebelum ke Wisp berikutnya
            end

            -- Balik ke posisi awal atau Basecamp
            if State.farm then
                hrp.CFrame = CFrame.new(0, 1500, 0)
            else
                hrp.CFrame = CFrame.new(lastPos) -- Balik ke tempat lo berdiri sebelumnya
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            
            isSweeping = false
        end
    end
end)

-- 2. Kunci Posisi Farm (Anti Nexbot)
local basePart = nil
RunService.Heartbeat:Connect(function()
    if not State.farm then 
        if basePart and basePart.Parent then
            basePart:Destroy()
            basePart = nil
        end
        return 
    end

    if not basePart or not basePart.Parent then
        local p = Instance.new("Part")
        p.Name = "ev_personal_base"
        p.Size = Vector3.new(30, 2, 30)
        p.Position = Vector3.new(0, 1500, 0)
        p.Anchored = true
        p.CanCollide = true
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(120, 100, 255)
        p.Transparency = 0.5
        p.Parent = Workspace
        basePart = p
    end

    if not isSweeping then
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - Vector3.new(0, 1500, 0)).Magnitude > 15 then
                hrp.CFrame = CFrame.new(0, 1504, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)
