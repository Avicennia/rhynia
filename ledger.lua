-- luacheck: globals minetest rhynia shout

rhynia.subs = {}
rhynia.subs.soils,rhynia.subs.waters,rhynia.subs.values = {},{},{}

local function register_substrates()
    local function assign_soil(k,v)
        local function soilgroup(k,v)
        local groups = v.groups
        local soilv = groups.soil
        groups["rhynia_subs_soil"] = soilv
        minetest.override_item(k, {groups = groups})
        rhynia.subs.soils[#rhynia.subs.soils + 1], rhynia.subs.values[k] = k, soilv
        end

    return soilgroup(k,v)
    end

   

    local function assign_water(k,v)
        local function watergroup(k,v)
            local groups = v.groups
            groups["rhynia_subs_water"] = 1 -- Later use abmmux key to differentiate flowing from source
            minetest.override_item(k, {groups = groups})
            rhynia.subs.waters[#rhynia.subs.waters + 1],rhynia.subs.values[k] = k, 1
        end
        return watergroup(k,v)
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
    shout(num.."||"..n.."|||"..v)
    shout(num > v)
    if(num > v)then
        rhynia.f.poppyh()
    end
end

nodecore.interval(20, function() rand(1000,math.random(965)) end)
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing) local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z})shout(minetest.registered_nodes[node.name].groups)end)


