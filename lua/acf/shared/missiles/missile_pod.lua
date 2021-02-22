
--define the class
ACF_defineGunClass("FFAR", {
    type            = "missile",
	spread          = 1,
	name            = "[FFAR] - Folding-Fin Aerial Rockets",
	desc            = ACFTranslation.MissileClasses[7],
	muzzleflash     = "40mm_muzzleflash_noscale",
	rofmod          = 1,
	year = 1960,
	sound           = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance   = " ",
	soundNormal     = " ",
    effect          = "Rocket Motor FFAR",

    ammoBlacklist   = {"AP", "APHE", "FL"} -- Including FL would mean changing the way round classes work.
} )




ACF_defineGun("40mmFFAR", { --id

	name		= "40mm Pod Rocket",
	desc		= "A tiny, unguided rocket.  Useful for anti-infantry, smoke and suppression.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model		= "models/missiles/launcher7_40mm.mdl",
	caliber		= 4,
	gunclass	= "FFAR",
    rack        = "40mm7xPOD",  -- Which rack to spawn this missile on?
	weight		= 6,
    length	    = 2, -- Length affects inertia calculations
    rofmod		= 0.8,
	year		= 1960,
	round		=
	{
		model		= "models/missiles/ffar_40mm.mdl",
		rackmdl		= "models/missiles/ffar_40mm_closed.mdl",
		maxlength	= 60,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 4,			-- effective armour thickness of casing, in mm
		propweight	= 0.2,			-- motor mass - motor casing
		thrust		= 10000,		-- average thrust - kg*in/s^2
		burnrate	= 120,			-- cm^3/s at average chamber pressure
        starterpct	= 0.15,         -- percentage of the propellant consumed in the starter motor.
        minspeed	= 5000,			-- minimum speed beyond which the fins work at 100% efficiency
        dragcoef	= 0.001,		-- drag coefficient while falling
        dragcoefflight  = 0.02,                 -- drag coefficient during flight
		finmul		= 0.003,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul		= math.sqrt(1)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb"},
    fuses       = {"Contact", "Timed"},

    racks       = {["40mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    armdelay    = 0.00     -- minimum fuse arming delay
} )




ACF_defineGun("70mmFFAR", { --id

	name		= "70mm Pod Rocket",
	desc		= "A small, unguided rocket.  Useful against light vehicles and infantry.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model		= "models/missiles/launcher7_70mm.mdl",
	caliber		= 7,
	gunclass	= "FFAR",
    rack        = "70mm7xPOD",  -- Which rack to spawn this missile on?
    weight		= 12,
    length	    = 15,
	year		= 1960,
	rofmod		= 0.6,
	roundclass	= "Rocket",
	round		=
	{
		model		= "models/missiles/ffar_70mm.mdl",
		rackmdl		= "models/missiles/ffar_70mm_closed.mdl",
		maxlength	= 90,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 6,			-- effective armour thickness of casing, in mm
		propweight	= 0.7,			-- motor mass - motor casing
		thrust		= 15000,		-- average thrust - kg*in/s^2
		burnrate	= 300,			-- cm^3/s at average chamber pressure
		starterpct	= 0.15,
        minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
        dragcoef	= 0.001,		-- drag coefficient while falling
        dragcoefflight  = 0.02,                 -- drag coefficient during flight
	finmul		= 0.004,			-- fin multiplier (mostly used for unpropelled guidance)
        penmul      = math.sqrt(0.8)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb"},
    fuses       = {"Contact", "Timed"},

    racks       = {["70mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    armdelay    = 0.00     -- minimum fuse arming delay
} )

ACF_defineGun("70mmFFARDAGR", { --id

	name		= "70mm DAGR Pod Rocket",
	desc		= "A 70mm FFAR, this one has a seeker built onto it.",
	model		= "models/missiles/launcher7_70mm.mdl",
	caliber		= 7,
	gunclass	= "FFAR",
    rack        = "70mm7xPOD",  -- Which rack to spawn this missile on?
    weight		= 12,
    length	    = 15,
	year		= 1960,
	rofmod		= 0.6,
	roundclass	= "Rocket",
	round		=
	{
		model		= "models/missiles/ffar_70mm.mdl",
		rackmdl		= "models/missiles/ffar_70mm_closed.mdl",
		maxlength	= 90,
		casing		= 0.3,			-- thickness of missile casing, cm
		armour		= 8,			-- effective armour thickness of casing, in mm
		propweight	= 0.7,			-- motor mass - motor casing
		thrust		= 15000,		-- average thrust - kg*in/s^2
		burnrate	= 300,			-- cm^3/s at average chamber pressure
		starterpct	= 0.2,
        minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
        dragcoef	= 0.001,		-- drag coefficient while falling
        dragcoefflight  = 0.02,                 -- drag coefficient during flight
	finmul		= 0.004,			-- fin multiplier (mostly used for unpropelled guidance)
        penmul      = math.sqrt(0.8)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb", "Infrared", "Laser"},
    fuses       = {"Contact", "Timed"},

    racks       = {["70mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    agility     = 0.08,     -- multiplier for missile turn-rate.

    seekcone    = 30,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
    viewcone    = 30,   -- getting outside this cone will break the lock.  Divided by 2.
	seeksensitivity = 0.5, --Less sophisticated seeker is better at close range
    armdelay    = 0.00     -- minimum fuse arming delay
} )

--[[
ACF_defineGun("40mmFFAR", { --id

	name		= "40mm Pod Rocket",
	desc		= "A tiny, unguided rocket.  Useful for anti-infantry, smoke and suppression.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model		= "models/missiles/launcher7_40mm.mdl",
	caliber		= 4,
	gunclass	= "FFAR",
    rack        = "40mm7xPOD",  -- Which rack to spawn this missile on?
	weight		= 6,
    length	    = 2, -- Length affects inertia calculations
    rofmod		= 0.6,
	year		= 1960,
	round		=
	{
		model		= "models/missiles/ffar_40mm.mdl",
		rackmdl		= "models/missiles/ffar_40mm_closed.mdl",
		maxlength	= 60,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 4,			-- effective armour thickness of casing, in mm
		propweight	= 0.2,			-- motor mass - motor casing
		thrust		= 8000,		-- average thrust - kg*in/s^2
		burnrate	= 180,			-- cm^3/s at average chamber pressure
        starterpct	= 0.15,         -- percentage of the propellant consumed in the starter motor.
        minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
        dragcoef	= 0.003,		-- drag coefficient of the missile
		finmul		= 0.001,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul		= math.sqrt(1)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb"},
    fuses       = {"Contact", "Timed"},

    racks       = {["40mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 35,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
    viewcone    = 55,   -- getting outside this cone will break the lock.  Divided by 2.

    agility     = 1,     -- multiplier for missile turn-rate.
    armdelay    = 0.00     -- minimum fuse arming delay
} )


ACF_defineGun("70mmFFAR", { --id

	name		= "70mm Pod Rocket",
	desc		= "A small, unguided rocket.  Useful against light vehicles and infantry.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model		= "models/missiles/launcher7_70mm.mdl",
	caliber		= 7,
	gunclass	= "FFAR",
    rack        = "70mm7xPOD",  -- Which rack to spawn this missile on?
    weight		= 12,
    length	    = 15,
	year		= 1960,
	rofmod		= 0.5,
	roundclass	= "Rocket",
	round		=
	{
		model		= "models/missiles/ffar_70mm.mdl",
		rackmdl		= "models/missiles/ffar_70mm_closed.mdl",
		maxlength	= 90,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 6,			-- effective armour thickness of casing, in mm
		propweight	= 0.7,			-- motor mass - motor casing
		thrust		= 8000,		-- average thrust - kg*in/s^2
		burnrate	= 400,			-- cm^3/s at average chamber pressure
		starterpct	= 0.15,
        minspeed	= 5000,			-- minimum speed beyond which the fins work at 100% efficiency
        dragcoef	= 0.004,		-- drag coefficient of the missile
		finmul		= 0.002,			-- fin multiplier (mostly used for unpropelled guidance)
        penmul      = math.sqrt(0.8)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb"},
    fuses       = {"Contact", "Timed"},

    racks       = {["70mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 35,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
    viewcone    = 55,   -- getting outside this cone will break the lock.  Divided by 2.

    agility     = 1,     -- multiplier for missile turn-rate.
    armdelay    = 0.00     -- minimum fuse arming delay
} )
]]--