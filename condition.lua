

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

rhynia.f.calc_condition_limits = function(r,min,max)
--local switch = genus and rhynia.genera[genus].traits["pt2condition"]
    min,max = min or 1, max or 4
    local maxim = {}
    maxim[1] = math.floor((((r*min)*2)+1)^2) -- previously maxim.lowest
    maxim[5] = math.floor(((max*((r*2)+1)^2))*(1+math.log10(3))) -- Replace 4 here with the value of the highest value substrate, here maxim[5] was maxim.highest

    
    for s = 4, 2, -1  do
        local n = 5 - s
        maxim[s]= math.floor(maxim[5] - (n/math.pi*(maxim[5]/10)*(n*(1+(n/math.sqrt(maxim[5]))))))
    end
    return maxim
end

rhynia.f.calc_condition = function(ci,gl,p2,r) -- returns condition value given flat radius r
    local lims = rhynia.f.calc_condition_limits(r or 1)
    rhynia.u.sh(lims)
    local p2 = p2 > 0 and p2 or 1
    local cs = lims[p2]
    local v = ci-(cs*(gl-2 >-1 and gl-2 or 0)) -- where ci = condition index, gl = growth level, cs = condition standard (the value at the level for that condition as calculated)
    local function incr_chk(a) -- Logical comparison of current ci with standard condition values, checks value incrementally and stops when ci isnt higher than the next number
        local ind = 1
        local function igi(a,b) return a >= b and ind+1 or ind end
        for s = 1, 3 do
            local ind_s = ind
            ind = igi(a,lims[s])
            if(ind_s == ind)then return ind end
        end
        ind = ind > 4 and 4 or ind
        --rhynia.u.sh(ind)
        return ind
    end
    return incr_chk(v)
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

