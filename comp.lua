-- luacheck: globals minetest rhynia vector _

-- -- -- -- -- -- -- -- General

local function register_on_hooks()
    local acts = {"sprout","tick","grow","stagnate","wither","health_change","fruit","propagate"}

    for n = 1, #acts do -- Register act wrappers.
        local a = "on_"..acts[n]
        rhynia.f[a] = function(pos, genus)
            if(rhynia.genera[genus].acts[a]) then rhynia.genera[genus].acts[a](pos,genus) return true end
            return false
        end
    end
end
register_on_hooks()
-- -- -- -- -- -- -- ---- -- -- -- -- -- -- --
