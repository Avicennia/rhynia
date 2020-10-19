-- luacheck: globals minetest rhynia vector _


rhynia.f.set_health = function(pos, val) -- Sets "health" metadata value at pos.
    return minetest.get_meta(pos):set_int("rhynia_h",val)
end

rhynia.f.alter_health = function(pos, val) -- Adds "val" to metadata value "health" at pos.
    local m = minetest.get_meta(pos)
    local h = m:get_int("rhynia_h")
    return m:set_int("rhynia_h", h + val)
end

rhynia.f.check_health = function(pos) -- Returns integer.
    return minetest.get_meta(pos):get_int("rhynia_h")
end

rhynia.f.is_live = function(pos) -- Returns boolean indicating.
    return minetest.get_meta(pos):get_int("rhynia_h") > 0 and true or false
end

rhynia.f.kill_if_health = function(pos, val)
    return minetest.get_meta(pos):get_int("rhynia_h") < val and rhynia.u.rn(pos)
end

rhynia.f.MA13_456 = function(pos,prob)
    return math.random(1000) < prob and rhynia.u.rn(pos)
end

rhynia.f.check_vitals = function(pos, genus)
    return not rhynia.f.is_live(pos) and rhynia.genera[genus].acts.on_wither(pos, genus) and rhynia.f.kill_if_health(pos, 1)
end