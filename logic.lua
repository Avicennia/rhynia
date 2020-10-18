-- luacheck: globals minetest rhynia

local thismod = minetest.get_current_modname()
local tm = thismod

nodecore.register_limited_abm({
    label = "rhynia plant tick",
    nodenames = {"group:rhynia_plant_active"},
    interval = 0.1,
    chance = 1,
    ignore_stasis = false,
    action = function(pos, node)
        local dat = node.name and rhynia.f.nominate(node.name) -- Identity check
        if(dat)then 
            -- Check vitals
            -- Check if plant needeth to die.
            -- If live then, but not using if statement
        rhynia.genera[dat.genus].acts.on_tick(pos,dat.genus) -- Do tick behaviour
        rhynia.f.on_propagate(pos,dat.genus)
        else end
        return
        
    end
})