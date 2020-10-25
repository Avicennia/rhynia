

-- -- -- -- -- -- -- -- Substrate

rhynia.f.is_substrate = function(pos)
    return minetest.get_item_group(rhynia.u.gn(pos).name, "rhynia_subs_soil") > 0
end

rhynia.f.is_substrate_alt = function(pos, genus)
    return minetest.get_item_group(rhynia.u.gn(pos).name, "rhynia_subs_soil_"..genus) > 0
end

rhynia.f.is_rooted = function(pos,genus)
    local p = {x = pos.x, y = pos.y - 1, z = pos.z}
    return rhynia.f.is_substrate(p) or genus and rhynia.f.is_substrate_alt(p,genus)
end

rhynia.f.assign_soils_alt = function(genus)
    local subs = rhynia.genera[genus].substrates
    if(subs)then
        for k,v in pairs(subs) do
            local grps = minetest.registered_nodes[k].groups
            grps["rhynia_subs_soil_"..genus] = 1
            minetest.override_item(k, {groups = grps})
            rhynia.subs.values[k] = v or 1
        end
    end
end

rhynia.f.geo_area = function(p,r,t) -- uses vector p and radius r to determine assimilation area for pos p based on type
    local a = {}
    a[1] = t and {x = p.x + r, y = p.y + r, z = p.z + r} or {x = p.x + r, y = p.y, z = p.z + r}
    a[2] = t and {x = p.x - r, y = p.y - r, z = p.z - r} or {x = p.x - r, y = p.y, z = p.z - r}
    return a
end

rhynia.f.ass_check = function(pos, r, t, genus) -- WIP: Unnecessary internal function definition, logic should also be simplifiable, rewrite soon. ~~
    -- Grabs soil data underneath pos, to a max radius of r, depending on the shape specifier t(bool)
    local upos = {x = pos.x, y = pos.y - (t and (r+1) or 1), z = pos.z}
    local cals = rhynia.f.geo_area(upos,r,t)

    local function soilchk()
        local alt_soil_group = genus and "group:rhynia_subs_soil_"..genus
        local area = minetest.find_nodes_in_area(cals[1],cals[2], alt_soil_group or "group:rhynia_subs_soil")
        local v = 0
        for n = 1, #area do
            local name = minetest.get_node(area[n]).name
            v = v + rhynia.subs.values[name]
        end
        return v
    end

    local function waterchk()
        local area = minetest.find_nodes_in_area(cals[1],cals[2], "group:rhynia_subs_water")
        area = area and area[1] and #area+1 or 1
        area = area <= 5 and area or 5--Original value was 4, but bumped up to 5 to accomodate upward shift in base [area] value.
        area = 1+(math.log10(area))
        return area
    end


    return soilchk()*waterchk()
end
