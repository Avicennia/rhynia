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
    local switch_s = not rhynia.f.is_live(pos)
    local wire_s = switch_s and rhynia.f.on_wither(pos, genus)
    local wire_s2 = wire_s and rhynia.f.kill_if_health(pos, 1)
    return not wire_s2 -- to return true if plant is living and false if plant is dead
end

rhynia.f.spot_check = function(pos, name, tf) -- Searches for node [name] 1 node around pos, returns integer of # found. If BOOL "tf" is true, returns table of all values of group "name". (some kind of "verbose" search)
    
    local area = rhynia.nc and nodecore.find_nodes_around(pos, name) or {a = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, b = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}}
    area = minetest.find_nodes_in_area(area.a,area.b,name)
    local function tags_on_erryting()
        if(not tf)then return end
        local v = 0
        for n = 1, #area do
            local name = string.gsub(name, "group:","")
            v = v + minetest.get_item_group(minetest.get_node(area[n]).name,name)
        end
        return v
    end
    return tags_on_erryting() or #area
end

