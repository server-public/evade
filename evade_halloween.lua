local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local isSweeping = false
local lastWispPos = nil

-- 1. Sapu Jagat Wisp (Auto Teleport & Collect)
task.spawn(function()
    while task.wait(0.5) do
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
                
                if n:find("wisp") or pName:find("wisp") or n:find("event") or pName:find("halloween") then
                    local model = d:FindFirstAncestorOfClass("Model")
                    if not (model and Players:GetPlayerFromCharacter(model)) then
                        table.insert(targets, d)
                    end
                end
            end
        end

        -- Kalau ada Wisp, mulai sapu
        if #targets > 0 then
            isSweeping = true

            -- Kumpulin RemoteEvent
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
                if not target.Parent then continue end -- Skip kalau Wisp udah hilang
                
                -- Teleport ke Wisp
                hrp.CFrame = target.CFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                lastWispPos = target.CFrame -- Simpen posisi Wisp terakhir
                task.wait(0.05) -- Jeda ambil nafas

                -- Pencet ProximityPrompt (kalau ada)
                local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end

                -- Sentuh fisik
                if firetouchinterest then
                    pcall(function() firetouchinterest(target, hrp, 0) end)
                    pcall(function() firetouchinterest(target, hrp, 1) end)
                end

                -- Tembak RemoteEvent
                for _, remote in ipairs(remotes) do
                    pcall(function()
                        remote:FireServer(target)
                        remote:FireServer(target.Name)
                        remote:FireServer()
                    end)
                end
                
                task.wait(0.1) -- Jeda antar Wisp biar gak dianggap spam bot
            end

            -- Selesai nyapu, tentuin mau ngapain
            task.wait(0.2) -- Tunggu server update
            if State.farm then
                -- Balik ke Awan (Basecamp)
                hrp.CFrame = CFrame.new(0, 1504, 0)
            else
                -- DIEM DI TEMPAT WISP TERAKHIR
                if lastWispPos then
                    hrp.CFrame = lastWispPos
                end
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            
            -- Jeda 2 detik sebelum scan lagi (biar gak error "Already claimed")
            task.wait(2)
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

    -- Cuma kunci posisi kalau lagi GAK nyedot Wisp
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
