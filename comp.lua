-- luacheck: globals minetest rhynia vector _

-- -- -- -- -- -- -- -- General

local function register_on_hooks()
    local acts = {"sprout","tick","grow","stagnate","die","health_change","fruit","propagate"}

    for n = 1, #acts do -- Register act wrappers.
        local a = "on_"..acts[n]
        rhynia.f[a] = function(pos, genus)
            return rhynia.genera[genus].acts[a] and rhynia.genera[genus].acts[a](pos,genus)
        end
    end
end
register_on_hooks()
-- -- -- -- -- -- -- ---- -- -- -- -- -- -- --
