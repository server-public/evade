local BASE = "https://raw.githubusercontent.com/server-public/evade/main/"

local function run(name)
    local ok, src = pcall(function() return game:HttpGet(BASE .. name, true) end)
    if ok and src then
        local fn = loadstring(src, "=" .. name)
        if fn then pcall(fn) end
    end
end

run("evade_antibanned.lua")
task.wait(0.3)
run("evade.lua")
task.wait(0.3)
run("evade_halloween.lua")
task.wait(0.3)
run("evade_serverhop.lua")