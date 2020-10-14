-- luacheck: globals minetest rhynia shout

rhynia.f.pollen = function(pos,dir,mag,tex,h)
    local tex = tex
    local dir,mag,bas = dir or rhynia.wind[1], mag or rhynia.wind[2], {x = 1, y = 1, z = 1}
minetest.add_particlespawner({
    amount = 10,
    time = 1,
    minpos = {x=pos.x-0.2, y=pos.y, z=pos.z-0.2},
    maxpos = {x=pos.x+0.3, y=pos.y+0.3, z=pos.z+0.3},
    minvel = dir,
    maxvel = vector.multiply(dir,mag/10),
    minacc = {x = 0, y = 0, z = 0},
    maxacc = vector.multiply(bas,mag/10),
    minexptime = 0.2,
    maxexptime = 1.2,
    minsize = 0.1,
    maxsize = 0.3,

    collisiondetection = false,
    collision_removal = false,
    vertical = true,
    texture = tex,
    animation = {
        type = "vertical_frames",
        aspect_w = 4,
        aspect_h = 4,
        length = 0.5},
        {
            type = "sheet_2d",
            frames_w = 1,
            frames_h = h,
            frame_length = 1,
        },
    glow = 12
})
return true
end