local Players = game:GetService("Players")
local LP = Players.LocalPlayer

if hookfunction then
    pcall(function()
        hookfunction(LP.Kick, function() return end)
    end)
end

local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" then return end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end