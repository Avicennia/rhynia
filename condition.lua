

rhynia.f.condition_tick = function(pos, genus, tf)
    genus = genus or rhynia.f.select(pos).genus
    local m,root_dim = minetest.get_meta(pos), rhynia.genera[genus].root_dim
    local mci = m:get_int("rhynia_ci")
    local catch = m:get_int("rhynia_gl")
    local matl = rhynia.genera[genus].structure and #rhynia.genera[genus].structure
    catch = catch and catch <= math.ceil(matl/root_dim) and "base" or "ext"
    local v = rhynia.f.ass_check(pos, rhynia.genera[genus].catchments[catch],_, tf and genus)
    v = v + mci
    m:set_int("rhynia_ci", v)
    return v
end

rhynia.f.calc_condition = function(r) -- returns condition value given flat radius r
    --local switch = genus and rhynia.genera[genus].traits["pt2condition"]
    local maxim = {}
    maxim.lowest = ((r*2)+1)^2
    maxim.highest = ((4*((r*2)+1)^2))*(1+math.log10(3))

    local quartiles = {"h","m","l"}
    for n = 1, #quartiles do
        maxim[quartiles[n]]= maxim.highest - (41.495*(n^(1*(1+n/10))))
    end
    return maxim
end

rhynia.f.average_light_spot = function(pos)
    local area = {a = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, b = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}}
    area = minetest.find_nodes_in_area(area.a,area.b,"air")
    local function lux_iterate()
        local lux = 0
        for n = 1, #area do
            lux = lux + minetest.get_node_light(area[n])
        end
        return lux >= 14 and 14 or lux
    end
    return area and area[1] and lux_iterate()
end

rhynia.f.spot_check = function(pos, name, tf) -- Searches for node [name] 1 node around pos, returns integer of # found. If BOOL "tf" is true, returns table of all values of group "name". (some kind of "verbose" search)
    local area = {a = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, b = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}}
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