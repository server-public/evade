local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local OWNER_IDS = { 209546354, 49468107 }
local HEX_GROUPS = { 5693735 }

local function check(p)
    for _, id in ipairs(OWNER_IDS) do
        if p.UserId == id then return true end
    end
    local ok, roles = pcall(function() return p:GetRoles() end)
    if ok then
        for _, r in ipairs(roles) do
            for _, gid in ipairs(HEX_GROUPS) do
                if r.GroupId == gid then return true end
            end
        end
    end
    return false
end

local function hop()
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100", game.PlaceId)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or not res then return end
    local data = HttpService:JSONDecode(res)
    for _, s in ipairs(data.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
            end)
            return
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    local s = _G.ev and _G.ev.State
    if s and s.auto_hop and check(p) then hop() end
end)