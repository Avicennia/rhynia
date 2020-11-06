-- luacheck: globals minetest rhynia nodecore

nodecore.register_limited_abm({
    label = "rhynia plant tick",
    nodenames = {"group:rhynia_plant_active"},
    interval = 1,
    chance = 1,
    ignore_stasis = false,
    action = function(pos, node)
        local dat,switch_s = node.name and rhynia.f.nominate(node.name),nil -- Identity check, is_alive switch
        -- check for can_exist
        -- kill if no, continue if yes
        -- if kill, do on wither. if not kill, continue to survival check
        -- survival check returns loop back to step 2 above
        -- If survive then do on_tick behaviour
        -- on_tick behaviour should contain other on_behaviour such as propagate and grow
        if(dat)then
        switch_s = rhynia.f.check_vitals(pos,dat.genus) -- plant life state
        end
        return switch_s and rhynia.genera[dat.genus].acts.on_tick(pos,dat.genus),rhynia.f.on_propagate(pos,dat.genus)
    end
})