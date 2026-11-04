
-- AIMBOT + ESP + MOVEMENT HUB
-- Combined GitHub loader

local scripts = {
    "https://raw.githubusercontent.com/thegamerkid2440-cell/hihf/main/aimbotandesp.lua",
    "https://raw.githubusercontent.com/thegamerkid2440-cell/hihf/main/moving.lua"
}

for _, url in ipairs(scripts) do
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        local execute = loadstring(source)
        assert(execute, "Could not compile script")
        execute()
    end)

    if success then
        print("LOADED:", url)
    else
        warn("FAILED:", url, result)
    end
end
