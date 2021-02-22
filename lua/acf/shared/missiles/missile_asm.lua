
--define the class
ACF_defineGunClass("ASM", {
    type            = "missile",
	spread          = 1,
	name            = "[ASM] - Air-To-Surface Missile",
	desc            = ACFTranslation.MissileClasses[3],
	muzzleflash     = "40mm_muzzleflash_noscale",
	year = 1969,
	rofmod          = 1,
	sound           = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance   = " ",
	soundNormal     = " ",
    effect          = "Rocket Motor Missile1", --Small/Medium size missile

    reloadmul       = 8,

    ammoBlacklist   = {"AP", "APHE", "FL", "SM"} -- Including FL would mean changing the way round classes work.
} )


-- The AGM-114, a laser guided missile with high anti-tank effectiveness.
ACF_defineGun("AGM-114 ASM", { --id
	name = "AGM-114 Hellfire Missile",
	desc = "The AGM-114 Hellfire is an air-to-surface missile first developed for anti-armor use, but later models were developed for precision strikes against other target types. Bringer of Hell.",
	model = "models/missiles/agm_114.mdl",
	gunclass = "ASM",
    rack = "2x AGM-114",  -- Which rack to spawn this missile on?
	length = 66,
	caliber = 16,
	weight = 196,    -- Don't scale down the weight though!
    modeldiameter = 17.2 * 1.27, -- in cm
	year = 1984,
	round = {
		model		= "models/missiles/agm_114.mdl",
		rackmdl		= "models/missiles/agm_114.mdl",
		maxlength	= 150,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 8,			-- effective armour thickness of casing, in mm
		propweight	= 1,			-- motor mass - motor casing
		thrust		= 12000,			-- average thrust - kg*in/s^2
		burnrate	= 100,			-- cm^3/s at average chamber pressure
		starterpct	= 0.25,			-- percentage of the propellant consumed in the starter motor.
		minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
        dragcoefflight  = 0.05,                 -- drag coefficient during flight
		finmul		= 0.1,			-- fin multiplier (mostly used for unpropelled guidance)
        penmul      = math.sqrt(0.518)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb", "Laser", "Infrared"},
    fuses       = {"Contact", "Optical"},

    racks       = {["2x AGM-114"] = true, ["4x AGM-114"] = true, ["1xRK"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    viewcone    = 40,   -- getting outside this cone will break the lock.  Divided by 2.

    agility     = 0.07,		-- multiplier for missile turn-rate.
    armdelay    = 0.00     -- minimum fuse arming delay
} )

-- The AGM-45 shrike, a vietnam war-era antiradiation missile built off the AIM-7 airframe.
ACF_defineGun("AGM-45 ASM", { --id
	name = "AGM-45 Shrike Missile",
	desc = "The body of an AIM-7 sparrow, an air-to-ground seeker kit, and a far larger warhead than its ancestor.\nWith its homing radar seeker option, thicker skin, and long range, it is a great weapon for long-range, precision standoff attack versus squishy things, like those pesky sam sites.",
	model = "models/missiles/aim120.mdl",
	gunclass = "ASM",
    rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 1000,
	caliber = 12,
	weight = 354,    -- Don't scale down the weight though!
    modeldiameter = 7.1 * 2.54, -- in cm
	year = 1969,
	rofmod = 0.6,
	round = {
		model		= "models/missiles/aim120.mdl",
		rackmdl		= "models/missiles/aim120.mdl",
		maxlength	= 150,
		casing		= 0.15,			-- thickness of missile casing, cm
		armour		= 8,			-- effective armour thickness of casing, in mm
		propweight	= 3,			-- motor mass - motor casing
		thrust		= 600,		-- average thrust - kg*in/s^2
		burnrate	= 300,			-- cm^3/s at average chamber pressure
		starterpct	= 0.05,			-- percentage of the propellant consumed in the starter motor.
		minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
                dragcoefflight  = 0,                 -- drag coefficient during flight
		finmul		= 0.2,			-- fin multiplier (mostly used for unpropelled guidance)
        penmul      = math.sqrt(0.18)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb", "Radar", "Laser", "Infrared"},
    fuses       = {"Contact", "Timed"}, 

    racks       = {["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["6xUARRK"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone = 5,		--why do you need a big seeker cone if yuo're firing vs a SAM site?
	viewcone = 10,		--I don't think a fucking SAM site should have to dodge much >_>
	
    agility     = 0.08,		-- multiplier for missile turn-rate.
    armdelay    = 0.00     -- minimum fuse arming delay
} )

--Sidearm, a lightweight anti-radar missile used by helicopters in the 80s
ACF_defineGun("AGM-122 ASM", { --id
	name = "AGM-122 Sidearm Missile",
        desc = "A refurbished early-model AIM-9, for attacking ground targets.  Less well-known than the bigger Shrike, it provides easy-to-use blind-fire anti-SAM performance for helicopters and light aircraft, with far heavier a punch than its ancestor.",
	model = "models/missiles/aim9.mdl",
	gunclass = "ASM",
    rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 205,
	caliber = 12.7, -- Aim-9 is listed as 9 as of 6/30/2017, why?  Wiki lists it as a 5" rocket!
	weight = 177,    -- Don't scale down the weight though!
	rofmod = 0.3,
	year = 1986,
	round = {
		model		= "models/missiles/aim9.mdl",
		rackmdl		= "models/missiles/aim9.mdl",
		maxlength	= 140,
		casing		= 0.1,	        -- thickness of missile casing, cm
		armour		= 7,			-- effective armour thickness of casing, in mm
		propweight	= 4,	        -- motor mass - motor casing
		thrust		= 4000,	    -- average thrust - kg*in/s^2		--was 100000
		burnrate	= 1400,	        -- cm^3/s at average chamber pressure	--was 350
		starterpct	= 0.4,          -- percentage of the propellant consumed in the starter motor.	--was 0.2
		minspeed	= 5000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
                dragcoefflight  = 0.001,                 -- drag coefficient during flight
		finmul		= 0.03,			-- fin multiplier (mostly used for unpropelled guidance)
        penmul      = math.sqrt(0.1)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

    ent         = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
    guidance    = {"Dumb", "Radar", "Infrared"},
    fuses       = {"Contact", "Optical"},

	racks       = {["1xRK"] = true,  ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["1xRK_small"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 10,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
    viewcone    = 20,   -- getting outside this cone will break the lock.  Divided by 2.

    agility     = 0.3,  -- multiplier for missile turn-rate.
    armdelay    = 0.00     -- minimum fuse arming delay		--was 0.4
} )

ACF_defineGun("AGM-65 ASM", { --id
	name = "AGM-65 Maverick Missile",
	desc = "You see that tank over there a mile away? I want you to lock onto it and forget about it.",
	model = "models/missiles/aim54.mdl",
	gunclass = "ASM",
    rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 1000,
	caliber = 22,
	weight = 300,    -- Don't scale down the weight though!
	year = 1974,
	modeldiameter = 9.0 * 2.54, -- in cm
	rofmod          = 0.3,
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
	guidance    = {"Dumb" , "Infrared"},
    fuses       = {"Contact", "Optical"},

	racks       = {["1xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

    seekcone    = 10,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
    viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2.

    agility     = 0.15,    -- multiplier for missile turn-rate.
	armdelay    = 0.00,     -- minimum fuse arming delay --was 0.3
	penmul      = math.sqrt(0.53)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
} )