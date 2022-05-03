--define the class
ACF_DefineRackClass("RK", {
    spread = 1,
    name = "Munitions Rack",
    desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
    muzzleflash = "40mm_muzzleflash_noscale",
    rofmod = 1,

    reloadmul       = 8,
} )




--add a gun to the class
ACF_DefineRack("1xRK", {
    name = "Single Universal Rack",
    desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
    model       = "models/missiles/rkx1.mdl",
    gunclass = "RK",
    weight = 50,
    rofmod = 2,
    year = 1915,
    magsize = 1,
    armour  = 20,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0, 0, 2), ["scaledir"] = Vector(0, 0, -1)}
    }
} )

--add a gun to the class
ACF_DefineRack("1xRK_small", {
    name = "Single Small Universal Rack",
    desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
    model       = "models/missiles/rkx1_sml.mdl",
    gunclass = "RK",
    weight = 50,
    rofmod = 2,
    year = 1915,
    magsize = 1,
    armour  = 20,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0, 0, 2), ["scaledir"] = Vector(0, 0, -1)}
    }
} )



ACF_DefineRack("2xRK", {
    name = "Dual Universal Rack",
    desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
    model       = "models/missiles/rack_double.mdl",
    gunclass = "RK",
    weight = 75,
    year = 1915,
    magsize = 2,
    armour  = 20,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,-15,0), ["offset"] = Vector(4, -1.5, -1.7), ["scaledir"] = Vector(0, -1, 0)},
        ["missile2"] = { ["pos"] = Vector(0,15,0),  ["offset"] = Vector(4, 1.5, -1.7),  ["scaledir"] = Vector(0, 1, 0)}
    }
} )

ACF_DefineRack("3xRK", {
    name = "BRU-42 Rack",
    desc = "A lightweight rack for bombs which is vulnerable to shots and explosions.",
    model       = "models/missiles/bomb_3xrk.mdl",
    gunclass = "RK",
    weight = 100,
    year = 1936,
    armour  = 20,
    magsize = 3,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(-3.601,0,-8.1),       ["offset"] = Vector(5.5,0,-4.5),    ["scaledir"] = Vector(-0.2,0,-0.3)},
        ["missile2"] = { ["pos"] = Vector(-3.241,3.419,-3.6),   ["offset"] = Vector(5.5,3,0),       ["scaledir"] = Vector(-0.2,0.3,-0.1)},
        ["missile3"] = { ["pos"] = Vector(-3.241,-3.42,-3.6),   ["offset"] = Vector(5.5,-3,0),      ["scaledir"] = Vector(-0.2,-0.3,-0.1)},
    }
} )

ACF_DefineRack("4xRK", {
    name = "Quad Universal Rack",
    desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
    model       = "models/missiles/rack_quad.mdl",
    gunclass = "RK",
    weight = 125,
    year = 1936,
    armour  = 20,
    magsize = 4,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,12.5,9),    ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,1,0)},
        ["missile2"] = { ["pos"] = Vector(0,-12.5,9),   ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,-1,0)},
        ["missile3"] = { ["pos"] = Vector(0,-12.5,-5),  ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
        ["missile4"] = { ["pos"] = Vector(0,12.5,-5),   ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)}
    }
} )

ACF_DefineRack("2x AGM-114", {
    name = "Dual AGM-114 Rack",
    desc = "An AGM-114 rack designed to carry 2 missiles.",
    model       = "models/missiles/agm_114_2xrk.mdl",
    gunclass = "RK",
    weight = 50,
    year = 1984,
    magsize = 2,
    armour  = 20,
    caliber = 16,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,-8.1,5.4),  ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
        ["missile2"] = { ["pos"] = Vector(0,8.1,5.4),   ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
    }
} )

ACF_DefineRack("4x AGM-114", {
    name = "Quad AGM-114 Rack",
    desc = "An AGM-114 rack designed to carry 4 missiles.",
    model       = "models/missiles/agm_114_4xrk.mdl",
    gunclass = "RK",
    weight = 100,
    year = 1984,
    magsize = 4,
    armour  = 20,
    caliber = 16,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,-8.1,5.4),  ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
        ["missile2"] = { ["pos"] = Vector(0,8.1,5.4),   ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
        ["missile3"] = { ["pos"] = Vector(0,-8.1,-12.6),    ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
        ["missile4"] = { ["pos"] = Vector(0,8.1,-12.6),     ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)}
    }
} )


ACF_DefineRack("1xAT3RK", {
    name = "Single AT-3 Missile Rack",
    desc = "An AT-3 anti tank missile handheld rack",
    model       = "models/missiles/at3rk.mdl",
    gunclass = "RK",
    weight = 30,
    rofmod = 1.4,
    year = 1969,
    magsize = 1,
    armour  = 15,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,0,2.4), ["offset"] = Vector(3.2, 0, 1), ["scaledir"] = Vector(0, 0, -1)}
    }
} )

ACF_DefineRack("1xAT3RKS", {
    name = "Single AT-3 Missile Rack designed for AFV",
    desc = "An AT-3 anti tank missile handheld rack",
    model       = "models/missiles/at3rs.mdl",
    gunclass = "RK",
    weight = 40,
    rofmod = 1.0,
    year = 1972,
    magsize = 1,
    armour  = 15,

    mountpoints =
    {
        ["missile1"] = { ["pos"] = Vector(0,0,2.4), ["offset"] = Vector(21, 0, 6.2),    ["scaledir"] = Vector(0, 0, -1)}
    }
} )
