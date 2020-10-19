
rhynia.u.selectify = function(...)
    local val = {}
    for n = 1, select("#",...) do
        val[n] = select(n,...)
    end
    return val
end

rhynia.u.sh = function(thing)return minetest.chat_send_all(minetest.serialize(thing)) end
rhynia.u.gn = function(pos)return minetest.get_node(pos) end
rhynia.u.sn = function(pos,nam,p2)return minetest.set_node(pos, {name = nam, param2 = p2 or 1}) end
rhynia.u.swn = function(pos,nam,p2)return minetest.swap_node(pos, {name = nam, param2 = p2 or 1}) end
rhynia.u.sna = function(p,nam,p2) return rhynia.u.sn({x = p.x, y = p.y+1, z = p.z},nam,p2) end
rhynia.u.rn = function(pos) return minetest.remove_node(pos) or true end
rhynia.u.tc = function(t) local t2 = {} for k,v in pairs(t) do t2[k] = v end return t2 end

-- F-Block Utils

-- -- -- -- -- -- -- -- Wind
rhynia.f.ghibli = function()
    local mag = rhynia.wind[2]
    return {x = math.random(-mag,mag), y = 0+math.random(), z = math.random(-mag,mag)}
end

rhynia.f.poppyh = function()
    rhynia.wind[1],rhynia.wind[2] = rhynia.f.ghibli(),math.random(1,3)
end
-- -- -- -- -- -- -- ---- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- Plant
rhynia.f.nominate = function(name)
    -- Returns a table containing string-genus[1] and int-state[2] from the very end of a string. Causes naming convention requirement ("modname:genus_int").
    local function get_genus(name)
        local n = name
        n = string.sub(n,string.find(n,":")+1)
        n = string.sub(n,1,string.find(n,"_")-1)
        return n
    end

    local function get_state(name)
        local name = name
        for _ in string.gmatch(name, "_")do
            name = string.sub(name,string.find(name,"_")+1)
        end return name
    end
    return {genus = get_genus(name),stage = tonumber(get_state(name))}
end

rhynia.f.select = function(pos) -- Performs the above nomination query on a position.
    return rhynia.f.nominate(rhynia.u.gn(pos).name)
end
