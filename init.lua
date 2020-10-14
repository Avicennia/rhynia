-- luacheck: globals minetest rhynia shout
local thismod = minetest.get_current_modname()
local modpath = minetest.get_modpath(thismod)
local tm = thismod..":"
local pumswitch = minetest.registered_nodes["nc_lode:block_annealed"] -- Checks if the only decent minetest game is loaded, using a not-so-decently-named variable

rhynia = {c = {}, f = {},count = {},modules = {}, nodes = {}, genera = {}, wind = {{x = 0, y = 0, z = 0},0,3}}
rhynia.count.ind = 0
function shout(thing)
    return minetest.chat_send_all(minetest.serialize(thing))
end

local function loadfiles() -- Load in files using builtin lua function or stylishly convenient nodecore wrapper depending on availability.
    local files = {"comp","particle","logic","ledger"}
    local function loadup(a, tf)
        return tf and include(a..".lua") or dofile(modpath.."/"..a..".lua")
    end
    for n = 1, #files do
        loadup(files[n], pumswitch)
    end
return
end

loadfiles()

rhynia.wind[1] = rhynia.f.ghibli()
rhynia.wind[2] =1.1
minetest.register_chatcommand("de", {
    params = "<name> <privilege>", 
    description = "Remove privilege from player", 
    privs = {privs=true},
    func = function(name, param)
        rhynia.f.poppyh()
        shout(rhynia.f.calc_condition(3))
    end
})