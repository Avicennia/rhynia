


rhynia.f.propagate = function(pos, genus, dir, mag)
    local pos, genus = {x = pos.x, y = pos.y, z = pos.z}, genus or rhynia.f.select(pos).genus
    local sdr,dir,mag = rhynia.genera[genus].spore_dis_rad, dir or rhynia.wind[1], mag or rhynia.wind[2]

    local function proj(pos)
        local dir,mag,pos = {x = dir.x, y = 0, z = dir.z}, mag*math.random(1,8),{x = pos.x, y = pos.y, z = pos.z}
        pos = vector.add(pos,dir)
        dir = {x = dir.x * mag, y = dir.y, z = dir.z * mag}
        local pos2 = {x = pos.x + dir.x, y = pos.y, z = pos.z + dir.z}
        pos2 = {minetest.line_of_sight(pos, pos2)}
        pos2 = type(pos2[1]) == "boolean" and {x = pos.x + dir.x, y = pos.y, z = pos.z + dir.z} or type(pos2[1]) == "table" and pos2[1][2]
        return pos2
    end

    local function toground(p)
        local pos = vector.add({x = p.x, y = p.y, z = p.z},{x = dir.x, y = 0, z = dir.z})
        local val = {minetest.line_of_sight(pos, {x = pos.x, y = pos.y - 63, z = pos.z})}
        val = val and #val == 2 and val[2] or nil
        val.y = val.y + 1
        return val
    end

    local function sow(pos)
        local pos = {x = pos.x, y = pos.y, z = pos.z}
        local pos2 = vector.add(pos,{x = math.random(-sdr,sdr), y = -1, z = math.random(-sdr,sdr)})
        local function ifair(p)
            return rhynia.u.gn(p).name == "air"
        end
        return pos and ifair({x = pos2.x, y = pos2.y + 1, z = pos2.z}) and rhynia.f.is_substrate(pos2) and
            minetest.set_node({x = pos2.x, y = pos2.y + 1, z = pos2.z}, {name = rhynia.genera[genus].structure[1][1] or rhynia.genera[genus].structure[1]})
    end
    sow(toground(proj(pos)))
end

rhynia.f.attempt_propagate = function(pos,interval,point,tex,frames)
    rhynia.f.pollen(pos,_,_,tex or "leiodora_spore.png",frames or 5)
    local num = math.random(interval or 1000)
    return num > (point or 998) and rhynia.f.propagate(pos)
end