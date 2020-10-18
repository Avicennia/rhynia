-- luacheck: globals minetest rhynia nodecore

rhynia.subs = {}
rhynia.subs.soils,rhynia.subs.waters,rhynia.subs.values = {},{},{}

local function register_substrates()
    local function assign_soil(s,p)
        local function soilgroup()
            local groups = p.groups
            local soilp = groups.soil
            groups["rhynia_subs_soil"] = soilp
            minetest.override_item(s, {groups = groups})
            rhynia.subs.soils[#rhynia.subs.soils + 1], rhynia.subs.values[s] = s, soilp
        end

        return soilgroup(s,p)
    end

    local function assign_water(s,p)
        local function watergroup()
            local groups = p.groups
            groups["rhynia_subs_water"] = 1 -- Later use abmmux key to differentiate flowing from source
            minetest.override_item(s, {groups = groups})
            rhynia.subs.waters[#rhynia.subs.waters + 1],rhynia.subs.values[s] = s, 1
        end
        return watergroup(s,p)
    end
    local function assign_soils_normal()
        for k,v in pairs(minetest.registered_nodes)do
            local function label()
                return v.groups.soil and assign_soil(k,v) or v.groups.water and assign_water(k,v)
            end
            label()
        end
    end
    assign_soils_normal()

end
register_substrates()

local rand = function(n,v)
    local num = math.random(n)
    if(num > v)then
        rhynia.f.poppyh()
    end
end

nodecore.interval(20, function() rand(1000,math.random(965)) end)


