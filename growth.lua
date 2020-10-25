

rhynia.f.grow_chk = function(pos)
    -- returns true if growth interval in node meta is >= genus standard for current growth level
    local data = rhynia.f.nominate(rhynia.u.gn(pos).name)
    data.gl = minetest.get_meta(pos):get_int("rhynia_gl") -- gl = growth_level
    data.gi = minetest.get_meta(pos):get_int("rhynia_gi")
    data.nd = minetest.get_node(pos)
    data.nx = type(rhynia.genera[data.genus].growth_interval) == "number" and rhynia.genera[data.genus].growth_interval
    return data.gi and data.gl and data.gi >= data.nx
end


rhynia.f.growth_tick = function(pos, genus)
    local genus = genus or rhynia.f.nominate(minetest.get_node(pos).name).genus
    local mixed_growth = rhynia.genera[genus].traits["growth_opt"]
    local cond = rhynia.f.condition_tick(pos,genus)
    local gv = 1 + (mixed_growth and math.ceil(math.log10(cond)) or 0) -- Not a good way to attempt mixing growth and condition
    local function uptick(pos)
        local m = minetest.get_meta(pos)
        local mgi = m:get_int("rhynia_gi")
        m:set_int("rhynia_gi", mgi+gv)
        gv = m:get_int("gl") -- using gv for gl after use.
    end
    return rhynia.f.grow_chk(pos) and rhynia.f.grow(pos, genus, gv) or uptick(pos)
end

rhynia.f.grow = function(pos, genus, stage) -- Rebuilds plant using next genus structure table

    local data = genus and stage and {genus = genus, stage = stage} or rhynia.f.select(pos)
    data.gl = minetest.get_meta(pos):get_int("rhynia_gl") -- gl = growth_level
    data.nd = minetest.get_node(pos)
    data.stmax = #rhynia.genera[data.genus].structure
    local function is_perennial()
        local s = rhynia.genera[data.genus].traits.brito
        s = s and data.gl >= data.stmax
        return s
    end

    local function is_annual()
        local s = rhynia.genera[data.genus].traits.annual
        s = s and data.gl >= data.stmax
        return s and rhynia.f.senescence_clear(pos,data.genus,data.gl)
    end

    local function despues(val) -- WIP: Definitely in need to a Refactor ~~
        -- val must always be an integer to reference a value in genus[structure] either directly or proximally via growth_order when present.
        local v,g = val, data.genus
        local tab = rhynia.genera[g].structure
        tab = #tab
        v = v and v + 1 <= tab and v + 1 or 1
        return v
    end
    local function ample_space(pos)
        local pos = rhynia.u.tc(pos)
        local hei,hei2 = #rhynia.genera[data.genus].structure[data.gl],#rhynia.genera[data.genus].structure[despues(data.gl)]
        return hei2 > 1 and (data.gl ~= data.stmax) and minetest.line_of_sight({x = pos.x, y = pos.y + hei, z = pos.z},{x = pos.x, y = pos.y + hei2 - 1, z = pos.z})== true or hei2 == 1 and true
    end
    ample_space(pos)
    local function plantstruct(pos,v) -- Constructs plant layer-by-layer upwards.

        local function airchk(pos)
            return rhynia.u.gn(pos).name == "air" or minetest.get_item_group(data.nd.name,"rhynia_plant") > 0
        end

        local function build(pos)
            local m = minetest.get_meta(pos)
            local gl,ci,p2 = m:get_int("rhynia_gl"),m:get_int("rhynia_ci"),data.nd.param2
            local p2 = rhynia.f.calc_condition(ci,gl,p2,_,genus)
            local p, s = pos and {x = pos.x, y = pos.y, z = pos.z},rhynia.genera[data.genus].structure[v]

            for n = 1, #s do
                if(p and s[n] and airchk(p)) then
                    local m = minetest.get_meta(p)
                    rhynia.u.swn(p,s[n],p2)
                    m:set_int("rhynia_gi",0)
                    local newgl = data.gl + 1 < data.stmax and data.gl + 1 or data.stmax
                    m:set_int("rhynia_gl",newgl)
                end
                p.y = p.y + 1
            end
        end
        build(pos)
        rhynia.f.on_grow(pos,data.genus) -- HOOK:on_grow
    end
    return (not is_annual()) and (not is_perennial()) and ample_space(pos) and plantstruct(pos, despues(data.gl))
end

rhynia.f.senescence_clear = function(pos,genus,stage) -- Deletes plant at given stage
    local hei = #rhynia.genera[genus].structure[stage]
    local function airstruct()
        local s,p = 0,{x = pos.x, z = pos.z, y = pos.y}
        for _ = 1, hei do
            rhynia.u.sn(p,"air")
            p.y = p.y + 1
            s = s + 1
        end
        return s == hei
    end
    return airstruct()
end