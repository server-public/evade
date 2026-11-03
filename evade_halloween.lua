local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

local lastWispPos = nil

-- 1. KUNCI POSISI FARM
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

    -- Kunci di atas cuma kalau Auto Candy lagi gak jalan
    if not State.candy then
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

-- 2. WISP COLLECTOR (BRUTEFORCE RADIUS 30)
task.spawn(function()
    while task.wait(0.1) do
        if not State.candy then continue end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Scan semua objek yang ada di map (BasePart atau Model)
        for _, d in ipairs(Workspace:GetChildren()) do
            if d:IsA("BasePart") or d:IsA("Model") then
                -- Jangan tarik/tembak karakter player
                local isPlayer = Players:GetPlayerFromCharacter(d)
                if not isPlayer and d.Name ~= "ev_personal_base" then
                    
                    -- Hitung jarak objek ke pemain
                    local objPos = d:IsA("Model") and d:GetPivot().Position or d.Position
                    local distance = (hrp.Position - objPos).Magnitude
                    
                    -- Kalau objeknya deket (radius 30 meter)
                    if distance < 30 then
                        -- Teleport ke objek itu
                        hrp.CFrame = CFrame.new(objPos + Vector3.new(0, 3, 0))
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        lastWispPos = objPos
                        
                        -- Tembak SEMUA RemoteEvent (Bruteforce)
                        for _, r in ipairs(game:GetDescendants()) do
                            if r:IsA("RemoteEvent") then
                                pcall(function()
                                    r:FireServer(d) -- Kirim objeknya
                                    r:FireServer(d.Name) -- Kirim namanya
                                    r:FireServer() -- Kirim kosongan
                                end)
                            end
                        end
                        
                        -- Sentuh langsung
                        if firetouchinterest then
                            pcall(function() firetouchinterest(d, hrp, 0) end)
                            pcall(function() firetouchinterest(d, hrp, 1) end)
                        end
                        
                        -- Pencet Prompt kalau ada
                        local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                        
                        task.wait(0.1)
                    end
                end
            end
        end
        
        if State.farm then
            hrp.CFrame = CFrame.new(0, 1504, 0)
        end
    end
end)
