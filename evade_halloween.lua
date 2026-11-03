local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local isSweeping = false
local claimedWisps = {} -- Nyatet Wisp yang udah ditembak biar gak spam

-- 1. SAPU JAGAT WISP
task.spawn(function()
    while task.wait(0.5) do
        if not State.candy or isSweeping then continue end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local targets = {}
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                local n = d.Name:lower()
                local pName = d.Parent and d.Parent.Name:lower() or ""
                
                -- Filter ketat: Harus ada kata Wisp, dan BUKAN Baseplate/Tanah
                local isWisp = n:find("wisp") or pName:find("wisp") or pName:find("halloween")
                local isGround = n:find("baseplate") or n:find("ground") or n:find("floor") or n:find("part")
                
                if isWisp and not isGround then
                    -- Cek udah pernah di-claim belum di sesi ini
                    if not claimedWisps[d] then
                        local model = d:FindFirstAncestorOfClass("Model")
                        -- Jangan tarik karakter player
                        if not (model and Players:GetPlayerFromCharacter(model)) then
                            table.insert(targets, d)
                        end
                    end
                end
            end
        end

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

            for _, target in ipairs(targets) do
                if not State.candy then break end
                if not target.Parent then continue end -- Skip kalau udah hilang
                
                -- Pindah ke Wisp
                hrp.CFrame = target.CFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.05) 

                -- Tandain udah ditembak biar gak spam "Already claimed"
                claimedWisps[target] = true

                -- A. Tembak RemoteEvent (Bypass)
                for _, remote in ipairs(remotes) do
                    pcall(function()
                        remote:FireServer(target)
                        remote:FireServer(target.Name)
                        remote:FireServer()
                    end)
                end

                -- B. Sentuh fisik & Prompt
                local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                if firetouchinterest then
                    pcall(function() firetouchinterest(target, hrp, 0) end)
                    pcall(function() firetouchinterest(target, hrp, 1) end)
                end
                
                task.wait(0.1)
            end

            -- Selesai nyapu: Berhenti di tempat!
            if State.farm then
                hrp.CFrame = CFrame.new(0, 1504, 0) -- Balik ke basecamp
            end
            -- Kalau Farm mati, lo dibiarin di Wisp terakhir (Gak di-teleport kemana-mana)
            
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(2) -- Jeda biar server adem
            isSweeping = false
        end
    end
end)

-- 2. KUNCI POSISI FARM
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
