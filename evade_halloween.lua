local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local State = _G.ev and _G.ev.State or {}

-- 1. KUNCI POSISI FARM (Anti Geter)
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

    -- Kunci di atas cuma kalau gak ada player mati yang mau di-revive
    if not State.auto_revive then 
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

-- 2. TARIK WISP KE ATAS (Tarikan Magnet)
RunService.Heartbeat:Connect(function()
    if not State.candy then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myPos = hrp.Position

    -- Tarik semua Wisp ke posisi lo
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.Name ~= "ev_personal_base" then
            -- Jangan tarik karakter player
            local model = d:FindFirstAncestorOfClass("Model")
            if model and Players:GetPlayerFromCharacter(model) then continue end
            
            local n = d.Name:lower()
            local pName = d.Parent and d.Parent.Name:lower() or ""
            
            -- Filter: Nama Wisp
            if n:find("wisp") or pName:find("wisp") or pName:find("halloween") then
                
                -- TARIK WISP NYA KE POSISI KITA
                d.CFrame = CFrame.new(myPos + Vector3.new(0, 3, 0))
                
                -- Suruh server "Eh, gw nyentuh Wisp nih"
                local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                
                if firetouchinterest then
                    pcall(function() firetouchinterest(d, hrp, 0) end)
                    pcall(function() firetouchinterest(d, hrp, 1) end)
                end
            end
        end
    end
end)
