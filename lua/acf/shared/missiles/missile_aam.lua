
--define the class
ACF_defineGunClass("AAM", {
    type            = "missile",
    spread          = 1,
    name            = "[AAM] - Air-To-Air Missile",
    desc            = ACFTranslation.MissileClasses[1],
    muzzleflash     = "40mm_muzzleflash_noscale",
    rofmod          = 1,
    sound           = "acf_extra/airfx/rocket_fire2.wav",
    soundDistance   = " ",
    soundNormal     = " ",
    effect          = "Rocket Motor Missile1",
    year = 1953,
    reloadmul       = 8,

    ammoBlacklist   = {"AP", "APHE", "FL", "HEAT","THEAT"} -- Including FL would mean changing the way round classes work.
} )

-- The AIM-9 Sidewinder. The perfect choice for dogfights at short range. Although respectable payload, still tiny.
ACF_defineGun("AIM-9 AAM", {                                -- id
    name            = "AIM-9 Missile",
    desc            = "The gold standard in airborne jousting sticks. Agile and reliable with a rather underwhelming effective range, this homing missile is the weapon of choice for dogfights.\nSeeks 20 degrees, so well suited to dogfights.",
    model           = "models/missiles/aim9m.mdl",
    gunclass        = "AAM",
    rack            = "1xRK",                               -- Which rack to spawn this missile on?
    length          = 200,
    caliber         = 8,
    weight          = 75,                                   -- Don't scale down the weight though!
    rofmod          = 0.5,
    year            = 1953,
    round = {
        model           = "models/missiles/aim9m.mdl",
        rackmdl         = "models/missiles/aim9m.mdl",
        maxlength       = 302,
        casing          = 0.1,                              -- thickness of missile casing, cm
        armour          = 10,                               -- effective armour thickness of casing, in mm
        propweight      = 1,                                -- motor mass - motor casing
        thrust          = 25000,                            -- average thrust - kg*in/s^2       --was 100000
        burnrate        = 700,                              -- cm^3/s at average chamber pressure   --was 650
        starterpct      = 0.1,                              -- percentage of the propellant consumed in the starter motor.  --was 0.2
        minspeed        = 12000,                            -- minimum speed beyond which the fins work at 100% efficiency. Affects how agility is applied only
        dragcoef        = 0.002,                            -- drag coefficient while falling
        dragcoefflight  = 0.03,                             -- drag coefficient during flight
        finmul          = 0.025                             -- fin multiplier (mostly used for unpropelled guidance)
    },

    ent             = "acf_missile_to_rack",                -- A workaround ent which spawns an appropriate rack for the missile.
    guidance        = {"Dumb", "Infrared"},
    fuses           = {"Contact", "Radio"},

    racks           = {                                     -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
                        ["1xRK"] = true,  
                        ["2xRK"] = true, 
                        ["3xRK"] = true, 
                        ["1xRK_small"] = true
                    },   

    seekcone        = 10,                                   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)    --was 25
    viewcone        = 50,                                   -- getting outside this cone will break the lock.  Divided by 2.        --was 30

    agility         = 3,                                    -- multiplier for missile turn-rate.      --was 5
    armdelay        = 0.00,                                 -- minimum fuse arming delay        --was 0.4
    SeekSensitivity = 3
} )

--AIM-120 Sparrow. A medium-Range AAM missile, perfect for those who really need a decent boom in a single pass. Just remember that this is not an AIM-9 and is better to aim before.
ACF_defineGun("AIM-120 AAM", {                              -- id
    name            = "AIM-120 Missile",
    desc            = "Faster than the AIM-9, but also a lot heavier. Burns hot and fast, with a good reach, but harder to lock with.  This long-range missile is sure to deliver one heck of a blast upon impact.\nSeeks only 10 degrees and less agile than its smaller stablemate, so choose your shots carefully.",
    model           = "models/missiles/aim120c.mdl",
    gunclass        = "AAM",
    rack            = "1xRK",                               -- Which rack to spawn this missile on?
    length          = 1000,
    caliber         = 12,
    weight          = 125,                                  -- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
    year            = 1991,
    rofmod          = 0.35,
    modeldiameter   = 7.1 * 2.54,                           -- in cm
    round = {
        model           = "models/missiles/aim120c.mdl",
        rackmdl         = "models/missiles/aim120c.mdl",
        maxlength       = 370,
        casing          = 0.1,                              -- thickness of missile casing, cm
        armour          = 10,                               -- effective armour thickness of casing, in mm
        propweight      = 1,                                -- motor mass - motor casing
        thrust          = 50000,                            -- average thrust - kg*in/s^2       --was 25000
        burnrate        = 700,                              -- cm^3/s at average chamber pressure   --was 450
        starterpct      = 0.02,                             -- percentage of the propellant consumed in the starter motor.
        minspeed        = 23000,                            -- minimum speed beyond which the fins work at 100% efficiency   --was 3000
        dragcoef        = 0.002,                            -- drag coefficient while falling
        dragcoefflight  = 0.05,                             -- drag coefficient during flight
        finmul          = 0.025                             -- fin multiplier (mostly used for unpropelled guidance)
    },

    ent             = "acf_missile_to_rack",                -- A workaround ent which spawns an appropriate rack for the missile.
    guidance        = {"Dumb", "Radar"},
    fuses           = {"Contact", "Radio"},

    racks           = {                                     -- a whitelist for racks that this missile can load into.
                        ["1xRK"] = true, 
                        ["2xRK"] = true
                    },   

    seekcone        = 10,                                   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)    --was 20
    viewcone        = 50,                                   -- getting outside this cone will break the lock.  Divided by 2.    --was 25

    agility         = 3,                                    -- multiplier for missile turn-rate. -- was 2
    armdelay        = 0.00,                                 -- minimum fuse arming delay --was 0.3
    SeekSensitivity = 2.5
} )

--AIM-54 phoenix. Being faster and bigger than AIM-120, can deliver a single big blast against the target, however, this 300kgs piece of aerial destruction has a serious trouble 
--with its seek cone and is suggested to AIM before launching.
ACF_defineGun("AIM-54 AAM", {                               -- id
    name            = "AIM-54 Missile",
    desc            = "A supersonic long-range air to air missile, a early generation to AIM-120. This 300kgs beast is decided to reduce your first opponent that it faces to ashes, of course, if its tiny seek cone is able to see it.",
    model           = "models/missiles/aim54.mdl",
    gunclass        = "AAM",
    rack            = "1xRK",                               -- Which rack to spawn this missile on?
    length          = 1000,
    caliber         = 22,
    weight          = 463,                                  -- Don't scale down the weight though!
    year            = 1974,
    rofmod          = 0.32,
    modeldiameter   = 9.0 * 2.54,                           -- in cm
    round = {
        model           = "models/missiles/aim54.mdl",
        rackmdl         = "models/missiles/aim54.mdl",
        maxlength       = 396,
        casing          = 0.1,                              -- thickness of missile casing, cm
        armour          = 10,                               -- effective armour thickness of casing, in mm
        propweight      = 5,                                -- motor mass - motor casing
        thrust          = 140000,                           -- average thrust - kg*in/s^2       --was 10000
        burnrate        = 200,                              -- cm^3/s at average chamber pressure   --was 800
        starterpct      = 0.1,                              -- percentage of the propellant consumed in the starter motor.
        minspeed        = 32000,                            -- minimum speed beyond which the fins work at 100% efficiency  --was 1000
        dragcoef        = 0.01,                             -- drag coefficient while falling
        dragcoefflight  = 0.1,                              -- drag coefficient during flight
        finmul          = 0.05                              -- fin multiplier (mostly used for unpropelled guidance)
    },

    ent             = "acf_missile_to_rack",                -- A workaround ent which spawns an appropriate rack for the missile.
    guidance        = {"Dumb", "Radar"},
    fuses           = {"Contact", "Radio"},

    racks           = {["1xRK"] = true},                    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone        = 10,                                       -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)  --was 4
    viewcone        = 50,                                   -- getting outside this cone will break the lock.  Divided by 2.

    agility         = 3,                                    -- multiplier for missile turn-rate.  --was 0.7
    armdelay        = 0.00,                                 -- minimum fuse arming delay --was 0.3
    SeekSensitivity = 3
} )
