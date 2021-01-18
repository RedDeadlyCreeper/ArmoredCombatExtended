
--define the class
ACF_defineGunClass("AAM", {
    type            = "missile",
	spread          = 1,
	name            = "(Missile) Air-To-Air Missile",
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


-- The sidewinder analogue. we have to scale it down because acf is scaled down.
ACF_defineGun("AIM-9 AAM", { --id
	name = "AIM-9 Missile",
        desc = "The gold standard in airborne jousting sticks. Agile and reliable with a rather underwhelming effective range, this homing missile is the weapon of choice for dogfights.\nSeeks 20 degrees, so well suited to dogfights.",
	model = "models/missiles/aim9m.mdl",
	gunclass = "AAM",
    rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 200,
	caliber = 8,
	weight = 75,    -- Don't scale down the weight though!
	rofmod = 0.5,
	year = 1953,
	round = {
		model		= "models/missiles/aim9m.mdl",
		rackmdl		= "models/missiles/aim9m.mdl",
		maxlength	= 160,
		casing		= 0.1,	        -- thickness of missile casing, cm
		armour		= 15,			-- effective armour thickness of casing, in mm
		propweight	= 1,	        -- motor mass - motor casing
		thrust		= 25000,	    -- average thrust - kg*in/s^2		--was 100000
		burnrate	= 650,	        -- cm^3/s at average chamber pressure	--was 350
		starterpct	= 0.1,          -- percentage of the propellant consumed in the starter motor.	--was 0.2
		minspeed	= 3000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient while falling
                dragcoefflight  = 0.03,                 -- drag coefficient during flight
		finmul		= 0.025			-- fin multiplier (mostly used for unpropelled guidance)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb", "Infrared"},
    fuses       = {"Contact", "Radio"},

	racks       = {["1xRK"] = true,  ["2xRK"] = true, ["3xRK"] = true, ["1xRK_small"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 10,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
    viewcone    = 30,   -- getting outside this cone will break the lock.  Divided by 2.		--was 30

    agility     = 5,  -- multiplier for missile turn-rate.
	armdelay    = 0.00,     -- minimum fuse arming delay		--was 0.4
	SeekSensitivity = 3
} )

-- Sparrow analog.  We have to scale it down because acf is scaled down.  It's also short-range due to AAM guidelines.
-- Balance the round in line with the 70mm pod rocket.
ACF_defineGun("AIM-120 AAM", { --id
	name = "AIM-120 Missile",
	desc = "Faster than the AIM-9, but also a lot heavier. Burns hot and fast, with a good reach, but harder to lock with.  This long-range missile is sure to deliver one heck of a blast upon impact.\nSeeks only 10 degrees and less agile than its smaller stablemate, so choose your shots carefully.",
	model = "models/missiles/aim120c.mdl",
	gunclass = "AAM",
    rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 1000,
	caliber = 12,
	weight = 125,    -- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year = 1991,
	rofmod = 0.35,
    modeldiameter = 7.1 * 2.54, -- in cm
	round = {
		model		= "models/missiles/aim120c.mdl",
		rackmdl		= "models/missiles/aim120c.mdl",
		maxlength	= 220,
		casing		= 0.1,	        -- thickness of missile casing, cm
		armour		= 20,			-- effective armour thickness of casing, in mm
		propweight	= 2,	        -- motor mass - motor casing
		thrust		= 25000,	    -- average thrust - kg*in/s^2		--was 200000
		burnrate	= 450,	        -- cm^3/s at average chamber pressure	--was 800
		starterpct	= 0.02,          -- percentage of the propellant consumed in the starter motor.
		minspeed	= 3000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient while falling
                dragcoefflight  = 0.05,                 -- drag coefficient during flight
		finmul		= 0.01			-- fin multiplier (mostly used for unpropelled guidance)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb", "Radar" , "Infrared"},
    fuses       = {"Contact", "Radio"},

	racks       = {["1xRK"] = true, ["2xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 5,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
    viewcone    = 20,   -- getting outside this cone will break the lock.  Divided by 2.	--was 25

    agility     = 2,    -- multiplier for missile turn-rate.
	armdelay    = 0.00,     -- minimum fuse arming delay --was 0.3
	SeekSensitivity = 2.5
} )

--Phoenix.  Since we've rebalanced missile, and since we're making this a SPECIALIST weapon and scaling it to gmod, we can do it.
--it's heavily based off the sparrow.  Since we made the aim-120 LESS of the "big dick of the air", we'll have this take the more specialized role
--basically split the old aim-120 into the enw one and this.  This is WAY SLOWER than the real Phoenix, to compensate for long flight times.
ACF_defineGun("AIM-54 AAM", { --id
	name = "AIM-54 Missile",
	desc = "A BEEFY god-tier anti-bomber weapon, made with Jimmy Carter's repressed rage.  Getting hit with one of these is a significant emotional event that is hard to avoid if you're flying high, but with a very narrow 8 degree seeker, a thin casing, and a laughable speed, don't expect to be using it vs MIGs.",
	model = "models/missiles/aim54.mdl",
	gunclass = "AAM",
    rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 1000,
	caliber = 22,
	weight = 300,    -- Don't scale down the weight though!
	year = 1974,
	rofmod = 0.32,
    modeldiameter = 9.0 * 2.54, -- in cm
	round = {
		model		= "models/missiles/aim54.mdl",
		rackmdl		= "models/missiles/aim54.mdl",
		maxlength	= 220,
		casing		= 0.2,	        -- thickness of missile casing, cm
		armour		= 4,			-- effective armour thickness of casing, in mm
		propweight	= 5,	        -- motor mass - motor casing
		thrust		= 10000,	    -- average thrust - kg*in/s^2		--was 200000
		burnrate	= 200,	        -- cm^3/s at average chamber pressure	--was 800
		starterpct	= 0.1,          -- percentage of the propellant consumed in the starter motor.
		minspeed	= 1000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.01,		-- drag coefficient while falling
                dragcoefflight  = 0.1,                 -- drag coefficient during flight
		finmul		= 0.05			-- fin multiplier (mostly used for unpropelled guidance)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb", "Radar" , "Infrared"},
    fuses       = {"Contact", "Radio"},

	racks       = {["1xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 4,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
    viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2.

    agility     = 0.7,    -- multiplier for missile turn-rate.
	armdelay    = 0.00,     -- minimum fuse arming delay --was 0.3
	SeekSensitivity = 3
} )
