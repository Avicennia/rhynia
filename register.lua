

rhynia.f.rnode = function(def)
    -- Registers a node for use in future plant defs. Still WIP. Currently only "plantlike" and "plantlike-rooted" definitions.
    local nme = def.name
    local gps = def.groups or {planty = 1, rhynia = 1, [def.genus] = 1}
    local function inject_traits()
        local trait = rhynia.genera[def.genus].traits
        for k in pairs(trait) do
            gps["rhynia_trait_"..k] = 1
        end
    end
    inject_traits()
    gps["rhynia_plant_active"] = 1
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
    table.insert(rhynia.nodes, nme)
end

rhynia.f.register_emulsion = function(def) -- Registers a plant genus template with given parameters
    local ndef = {
        visual = def.visual or def.drawtype,
        genus = def.genus,
        health_max = def.health_max,
        root_dim = def.root_dim,
        substrates = def.substrates,
        growth_interval = def.growth_interval,
        --growth_factor = def.growth_factor,
        survival_factor = def.survival_factor,
        condition_factor = def.condition_factor,
        catchments = def.catchments,
        spore_dis_rad = def.spore_dis_rad,
        structure = def.structure,
        stage = def.stage,
        growth_order = def.growth_order,
        traits = def.traits,
        acts = {
            on_sprout = def.acts.on_sprout, on_tick = def.acts.on_tick, on_grow = def.acts.on_grow,
            on_stagnate = def.acts.on_stagnate, on_wither = def.acts.on_wither,
            on_punch = def.acts.on_punch, on_propagate = def.acts.on_propagate
        } -- Functions defining plant behaviour.
    }
rhynia.genera[def.genus] = ndef
end
