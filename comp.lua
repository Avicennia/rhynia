-- luacheck: globals minetest rhyn shout

local thismod = minetest.get_current_modname()
local tm = thismod

-- -- -- -- -- -- -- -- FUNCTIONS -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- General

rhyn.f.selectify = function(...)
    local val = {}
    for n = 1, select("#",...) do
        val[n] = select(n,...)
    end
    return val
end

rhyn.gn = function(pos)return minetest.get_node(pos)end
rhyn.sn = function(pos,nam,p2)return minetest.set_node(pos, {name = nam, param2 = p2})end
rhyn.rn = function(pos) return minetest.remove_node(pos) or true end

local acts = {"sprout","tick","grow","stagnate","die","health_change","fruit","propagate"}

for n = 1, #acts do -- Register act wrappers.
    local a = "on_"..acts[n]
rhyn.f[a] = function(pos, genus)
    return rhyn.genera[genus].acts[a] and rhyn.genera[genus].acts[a](pos,genus)
end
end
-- -- -- -- -- -- -- ---- -- -- -- -- -- -- --


-- -- -- -- -- -- -- -- Wind

rhyn.f.ghibli = function()
    local mag = rhyn.wind[2]
    return {x = math.random(-mag,mag), y = 0+math.random(), z = math.random(-mag,mag)}
end

rhyn.f.poppyh = function()
    shout("POPPY")
    rhyn.wind[1],rhyn.wind[2] = rhyn.f.ghibli(),math.random(1,3)
end
-- -- -- -- -- -- -- ---- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- Substrate

rhyn.f.is_substrate = function(pos)
    return minetest.get_item_group(rhyn.gn(pos).name, "rhyn_subs_soil")
end

rhyn.f.is_substrate_alt = function(pos, genus)
    return minetest.get_item_group(rhyn.gn(pos).name, "rhyn_subs_soil_"..genus)
end

rhyn.f.is_rooted = function(pos,genus)
    local pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    return rhyn.f.is_substrate(pos) > 0 or genus and rhyn.f.is_substrate_alt(pos,genus) > 0
end

rhyn.f.assign_soils_alt = function(genus)
    local subs = rhyn.genera[genus].substrates
    if(subs)then
    for k,v in pairs(subs) do
        local groups = minetest.registered_nodes[k].groups
        groups["rhyn_subs_soil_"..genus] = 1
        minetest.override_item(k, {groups = groups})
        rhyn.subs.values[k] = v or 1
        --minetest.after(3, function() shout(rhyn.subs.values)end)
    end
end
end

rhyn.geo_area = function(p,r,t) -- uses vector p and radius r to determine assimilation area for pos p, based on type
    local t,a = t or false, {}
    a[1] = t and {x = p.x + r, y = p.y + r, z = p.z + r} or {x = p.x + r, y = p.y, z = p.z + r}
    a[2] = t and {x = p.x - r, y = p.y - r, z = p.z - r} or {x = p.x - r, y = p.y, z = p.z - r}
    return a
end

rhyn.f.ass_check = function(pos, r, t, genus) -- Grabs soil data underneath pos, to a max radius of r, depending on the shape specifier t(bool)
    local upos = {x = pos.x, y = pos.y - (t and (r+1) or 1), z = pos.z}
    local cals = rhyn.geo_area(upos,r,t)

    local function soilchk()
        local alt_soil_group = genus and "group:rhyn_subs_soil_"..genus
        local area = minetest.find_nodes_in_area(cals[1],cals[2], alt_soil_group or "group:rhyn_subs_soil")
        local v = 0
        for n = 1, #area do
            local name = minetest.get_node(area[n]).name
            v = v + rhyn.subs.values[name]
        end
        return v
    end

    local function waterchk()
        local area = minetest.find_nodes_in_area(cals[1],cals[2], "group:rhyn_subs_water")
        area = area and area[1] and #area+1 or 1
        area = area <= 5 and area or 5 -- Original value was 4, but bumped up to 5 to accomodate upward shift in base [area] value.
        area = 1+(math.log10(area))
        return area
    end


    return soilchk()*waterchk()
end

rhyn.f.condition_tick = function(pos, genus, tf)
    local genus = genus or rhyn.f.nominate(minetest.get_node(pos).name).genus
    local m,root_dim = minetest.get_meta(pos), rhyn.genera[genus].root_dim
    local mci = m:get_int("rhyn_ci")
    local catch = m:get_int("rhyn_gl")
    local matl = rhyn.genera[genus].structure and #rhyn.genera[genus].structure
    catch = catch and catch <= math.ceil(matl/root_dim) and "base" or "ext"
    local v = rhyn.f.ass_check(pos, rhyn.genera[genus].catchments[catch],_, tf and genus)
    v = v + mci
    m:set_int("rhyn_ci", v)
    return v
end

rhyn.f.calc_condition = function(r) -- returns condition value given flat radius r
    --local switch = genus and rhyn.genera[genus].traits["pt2condition"]
    local maxim = {}
    maxim.lowest = ((r*2)+1)^2
    maxim.highest = ((4*((r*2)+1)^2))*(1+math.log10(3))

    local quartiles = {"h","m","l"}
    for n = 1, #quartiles do
        maxim[quartiles[n]]= maxim.highest - (41.495*(n^(1*(1+n/10))))
    end
    return maxim
end

rhyn.f.average_light_spot = function(pos)
    local area = {a = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, b = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}}
    area = minetest.find_nodes_in_area(area.a,area.b,"air")
    local function lux_iterate()
    local lux = 0
    for n = 1, #area do
        local p = area[n]
        lux = lux + minetest.get_node_light(area[n])
    end
    return lux >= 14 and 14 or lux
    end
    return area and area[1] and lux_iterate()
end

rhyn.f.spot_check = function(pos, name, tf) -- Searches for node [name] 1 node around pos, returns integer of # found. If BOOL "tf" is true, returns table of all values of group "name". (some kind of "verbose" search)
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

-- -- -- -- -- -- -- ---- -- -- -- -- -- -- --


-- -- -- -- -- -- -- -- Plant
rhyn.f.nominate = function(name) -- Returns a table containing genus, stage and stage-step if given the name of a node.
    local data = {}
    if(string.find(name,":"))then else error("Name "..name.." missing search pattern ':'!") end
    local name = string.sub(name,string.find(name,":"),string.len(name))
    data.genus = string.sub(name,string.find(name,":")+1,string.find(name, "_")-1)
    data.stage = string.sub(name,string.find(name, "_")+1,string.len(name)-string.find(string.reverse(name), "_"))
    data.step = string.sub(name,string.len(name))
    return data
end

rhyn.f.select = function(pos) -- Performs the above nomination query on a position.
    return rhyn.f.nominate(rhyn.gn(pos).name)
end

rhyn.f.rnode = function(def) -- Registers a node for use in future plant defs. Still WIP. Currently only "plantlike" and "plantlike-rooted" definitions.
    local nme = def.name
    local gps = def.groups or {planty = 1, rhyn = 1, [def.genus] = 1}
    local function inject_traits()
        local trait = rhyn.genera[def.genus].traits
        for k,v in pairs(trait) do
            gps["rhyn_trait_"..k] = 1
        end
    end
    inject_traits()
    minetest.register_node(nme, {
        description = def.description,
        drawtype = def.drawtype,
        mesh = def.drawtype == "mesh" and def.mesh,
        node_box = def.drawtype == "nodebox" and def.node_box,
        connects_to = def.connects_to,
        connect_sides = def.connect_sides,
        paramtype = def.paramtype,
        sunlight_propagates = def.sunlight_propagates,
        paramtype2 = def.drawtype == "plantlike" and "meshoptions" or def.paramtype2,
        waving = def.waving,
        walkable = def.walkable or false,
        light_source = def.light_source,
        tiles = def.tiles,
        selection_box = def.selection_box,
        groups = gps,
        on_construct = def.on_construct,
        on_punch = def.on_punch
    })
    table.insert(rhyn.nodes, nme)
end


rhyn.f.register_emulsion = function(def) -- Registers a plant genus template with given parameters
    local ndef = {
        visual = def.visual or def.drawtype, -- String: "Plantlike" or "Plantlike rooted".
        genus = def.genus, -- String: Name for looking up definition variables.
        health_max = def.health_max,
        root_dim = def.root_dim, -- Int: If used, number of nodes the plant can grow up.
        substrates = def.substrates,
        growth_interval = def.growth_interval, -- Int/Table: Either a table of numbers for the required base growth ticks to step/stage promotion, or a single int if all stages have uniform growth time.
        growth_factor = def.growth_factor, -- Table: Table of strings with keys denoting which nodes contribute to growth and values indicating magnitude of contribution.
        survival_factor = def.survival_factor, -- Table: Same as growth_factor, but for survival. Used to tally health of plant.
        condition_factor = def.condition_factor, -- Table:
        catchments = def.catchments,-- Table: Table containing area widths around base root node that the plant can draw from.
        spore_dis_rad = def.spore_dis_rad, -- Int: variance on jitter distance for propagule placement after wind-determined distance.
        structure = def.structure, -- Table: Table containing structuredefs for the plant at various stages.
        stage = def.stage, -- Table: Contains "stages" table for definint the stages of growth, and "steps" for steps within each stage of growth.
        growth_order = def.growth_order, -- Table: If defined, lays out the sequential order that plants transition through stages and steps defined in "stage".
        traits = def.traits, -- Table: Additional genus template metadata/ analogous to a primitive label table.
        acts = {
            on_sprout = def.acts.on_sprout, on_tick = def.acts.on_tick, on_grow = def.acts.on_grow,
            on_stagnate = def.acts.on_stagnate, on_wither = def.acts.on_wither, on_punch = def.acts.on_punch, on_propagate = def.acts.on_propagate
        } -- Functions defining plant behaviour.
    }
rhyn.genera[def.genus] = ndef
end


-- Plant-Behaviour
rhyn.f.grow_chk = function(pos) -- returns true if growth interval in node meta is >= genus standard for current growth level
    local data = rhyn.f.nominate(rhyn.gn(pos).name)
    data.gl = minetest.get_meta(pos):get_int("rhyn_gl") -- gl = growth_level
    data.gi = minetest.get_meta(pos):get_int("rhyn_gi")
    data.nd = minetest.get_node(pos)
    data.nx = type(rhyn.genera[data.genus].growth_interval) == "number" and rhyn.genera[data.genus].growth_interval --or rhyn.genera[data.genus].growth_interval[data.gl]
    return data.gi and data.gl and data.gi >= data.nx
end

rhyn.f.growth_tick = function(pos, genus)
    local genus = genus or rhyn.f.nominate(minetest.get_node(pos).name).genus
    local mixed_growth = rhyn.genera[genus].traits["growth_opt"]
    local cond = rhyn.f.condition_tick(pos,genus)
    local gv = 1 + (mixed_growth and math.ceil(math.log10(cond)) or 0) -- Not a good way to attempt mixing growth and condition
    local function uptick(pos)
        local m = minetest.get_meta(pos)
        local mgi = m:get_int("rhyn_gi")
        m:set_int("rhyn_gi", mgi+gv)
    end
    return rhyn.f.grow_chk(pos) and rhyn.f.grow(pos) or uptick(pos)
end

rhyn.f.grow = function(pos) -- Rebuilds plant using next genus structure table

    local data = rhyn.f.nominate(rhyn.gn(pos).name)
    data.gl = minetest.get_meta(pos):get_int("rhyn_gl") -- gl = growth_level
    data.nd = minetest.get_node(pos)

    local function despues(val) -- val must always be an integer to reference a value in genus[structure] either directly or proximally via growth_order
        local s,v,g = rhyn.genera[data.genus] ~= nil, val, data.genus
        local tab = rhyn.genera[g].growth_order or rhyn.genera[g].structure
        tab = #tab
        v = s and v and v + 1 <= tab and v + 1 or 1
        return v
    end
    local function plantstruct(pos,v) -- Constructs plant layer-by-layer

        local function airchk(pos)
            return rhyn.gn(pos).name == "air" or minetest.get_item_group(data.nd.name,"rhyn_plant") > 0
        end

        local function build(pos)
            local p2 = math.random(4)--data.nd.param2 -- ToDo: Add support for multiple param2s
            local p, s = pos and {x = pos.x, y = pos.y, z = pos.z},rhyn.genera[data.genus].structure[v]

            for n = 1, #s do
                if(p and s[n] and airchk(p)) then local m = minetest.get_meta(p); local mm = m:get_int("rhyn_gi") ; rhyn.sn(p,s[n],p2) ; m:set_int("rhyn_gi",(mm-rhyn.genera[data.genus].growth_interval))  else end
                p.y = p.y + 1
            end
        end
        build(pos)
        rhyn.f.on_grow(pos,data.genus) -- HOOK:on_grow
    end
    plantstruct(pos, despues(data.gl))
end

rhyn.f.propagate = function(pos, dir, mag)
    local pos, genus = {x = pos.x, y = pos.y, z = pos.z}, rhyn.f.nominate(rhyn.gn(pos).name).genus
    local sdr,dir,mag = rhyn.genera[genus].spore_dis_rad, dir or rhyn.wind[1], mag or rhyn.wind[2]
    local function proj(pos)
        local dir,mag,pos = {x = dir.x, y = 0, z = dir.z}, mag*math.random(1,8),{x = pos.x, y = pos.y, z = pos.z}
        pos = vector.add(pos,dir)
        dir = {x = dir.x * mag, y = dir.y, z = dir.z * mag}
        local pos2 = {x = pos.x + dir.x, y = pos.y, z = pos.z + dir.z}
        pos2 = {minetest.line_of_sight(pos, pos2)}
        pos2 = type(pos2[1]) == "boolean" and {x = pos.x + dir.x, y = pos.y, z = pos.z + dir.z} or type(pos2[1]) == "table" and pos2[1][2]
        return pos2
    end

    local function toground(pos)
        local pos = vector.add({x = pos.x, y = pos.y, z = pos.z},{x = dir.x, y = 0, z = dir.z})
        local val = {minetest.line_of_sight(pos, {x = pos.x, y = pos.y - 64, z = pos.z})}
        val = val and #val == 2 and val[2] or nil
        val.y = val.y + 1
        return val
    end

    local function sow(pos)
        local pos = {x = pos.x, y = pos.y, z = pos.z}
        local pos2 = vector.add(pos,{x = math.random(-sdr,sdr), y = -1, z = math.random(-sdr,sdr)})
        local function ifair(pos)
            return rhyn.gn(pos).name == "air"
        end
        
        return pos and ifair({x = pos2.x, y = pos2.y + 1, z = pos2.z}) and rhyn.f.is_substrate(pos2) > 0 and minetest.set_node({x = pos2.x, y = pos2.y + 1, z = pos2.z}, {name = rhyn.genera[genus].structure[1][1] or rhyn.genera[genus].structure[1]})
    end
    sow(toground(proj(pos)))
    rhyn.f.on_propagate(pos,genus)
    
end

rhyn.f.set_health = function(pos, val) -- Sets "health" metadata value at pos.
    return minetest.get_meta(pos):set_int("rhyn_h",val)
end

rhyn.f.alter_health = function(pos, val) -- Adds "val" to metadata value "health" at pos.
    local m = minetest.get_meta(pos)
    local h = m:get_int("rhyn_h")
    return m:set_int("rhyn_h", h + val)
end

rhyn.f.check_health = function(pos) -- Returns integer.
    return minetest.get_meta(pos):get_int("rhyn_h")
end

rhyn.f.is_live = function(pos) -- Returns boolean indicating.
    return minetest.get_meta(pos):get_int("rhyn_h") > 0 and true or false
end

rhyn.f.kill_if_health = function(pos, val)
    return minetest.get_meta(pos):get_int("rhyn_h") < val and rhyn.rn(pos)
end

rhyn.f.MA13_456 = function(pos,prob) 
    return math.random(1000) < prob and rhyn.rn(pos)
end

rhyn.f.check_vitals = function(pos, genus)
    return not rhyn.f.is_live(pos) and rhyn.genera[genus].acts.on_die(pos, genus) and rhyn.f.kill_if_health(pos, 1)
end
