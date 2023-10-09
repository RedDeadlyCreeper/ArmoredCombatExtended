
--define the class
ACF_defineGunClass("ARTY", {
	type           = "missile",
	spread         = 1,
	name           = "[ARTY] - Artillery Rockets",
	desc           = ACFTranslation.MissileClasses[2],
	muzzleflash    = "40mm_muzzleflash_noscale",
	rofmod         = 1,
	sound          = "acf_extra/airfx/rocket_fire2.wav",
	year           = 1944,
	soundDistance  = " ",
	soundNormal    = " ",
	effect         = "Rocket Motor Arty"
} )


ACF_defineGun("Type 63 RA", {							-- id

	name             = "Type 63 Rocket",
	desc             = "A common artillery rocket in the third world, able to be launched from a variety of platforms with a painful whallop and a very arced trajectory.\nContrary to appearances and assumptions, does not in fact werf nebel.",
	model            = "models/missiles/glatgm/mgm51.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 10.7,
	gunclass         = "ARTY",
	rack             = "1xRK_small",							-- Which rack to spawn this missile on?
	weight           = 80,
	length           = 126,
	year             = 1960,
	rofmod           = 0.3,
	roundclass       = "Rocket",
	modeldiameter    = 7.96,
	bodydiameter     = 8.8, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rotmult          = 60,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	maxrottq         = 2000, -- Max torque applied to the missile when its rotating during a unguided flight. Use this if you see your missile doing crazy movements when its out.

	round	=	{
		model             = "models/missiles/glatgm/mgm51.mdl",
		rackmdl           = "models/missiles/glatgm/mgm51.mdl",
		maxlength         = 200,
		casing            = 0.1,							-- thickness of missile casing, cm
		armour            = 5,								-- effective armour thickness of casing, in mm
		propweight        = 0.7,							-- motor mass - motor casing
		thrust            = 2700,							-- average thrust - kg * in/s ^ 2
		burnrate          = 450,							-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.1,
		minspeed          = 200,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.005,							-- drag coefficient while falling
		dragcoefflight    = 0.001,							-- drag coefficient during flight
		finmul            = 0.5,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.15)				-- 139 HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser", "GPS"},
	fuses      = {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {										-- a whitelist for racks that this missile can load into.
					["1xRK_small"] = true,
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["6xUARRK"] = true
				},

	viewcone   = 180,									-- cone radius, 180 = full 360 tracking
	agility    = 0.08,
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.00									-- minimum fuse arming delay
} )



ACF_defineGun("SAKR-10 RA", {							-- id

	name             = "SAKR-10 Rocket",
	desc             = "A short-range but formidable artillery rocket, based upon the Grad.  Well suited to the backs of trucks.",
	model            = "models/missiles/9m31.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 12.2,
	gunclass         = "ARTY",
	rack             = "1xRK",								-- Which rack to spawn this missile on?
	weight           = 160,
	length           = 219, --320
	year             = 1980,
	rofmod           = 0.25,
	roundclass       = "Rocket",
	modeldiameter    = 10,
	bodydiameter     = 7.3, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rotmult          = 20,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	maxrottq         = 2000, -- Max torque applied to the missile when its rotating during a unguided flight. Use this if you see your missile doing crazy movements when its out.

	round	=	{
		model             = "models/missiles/9m31.mdl",
		rackmdl           = "models/missiles/9m31.mdl",
		maxlength         = 140,
		casing            = 0.1,							-- thickness of missile casing, cm
		armour            = 10,							-- effective armour thickness of casing, in mm
		propweight        = 1.2,							-- motor mass - motor casing
		thrust            = 1300,							-- average thrust - kg * in/s ^ 2
		burnrate          = 150,							-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.1,
		minspeed          = 300,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.006,							-- drag coefficient while falling
		dragcoefflight    = 0.009,							-- drag coefficient during flight
		finmul            = 0.5,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.2)					--  139 HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser", "GPS"},
	fuses      = {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {										-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["6xUARRK"] = true
				},

	agility    = 0.07,
	viewcone   = 180,
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00									-- minimum fuse arming delay
} )



ACF_defineGun("SS-40 RA", {								-- id

	name             = "SS-40 Rocket",
	desc             = "A large, heavy, guided artillery rocket for taking out stationary or dug-in targets.  Slow to load, slow to fire, slow to guide, and slow to arrive.",
	model            = "models/missiles/aim120.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 18.0,
	gunclass         = "ARTY",
	rack             = "1xRK",								-- Which rack to spawn this missile on?
	weight           = 320,
	length           = 383,
	year             = 1983,
	rofmod           = 0.2,
	roundclass       = "Rocket",
	modeldiameter    = 4 * 2.54,
	bodydiameter     = 9.2, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rotmult          = 25,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	maxrottq         = 3000, -- Max torque applied to the missile when its rotating during a unguided flight. Use this if you see your missile doing crazy movements when its out.

	round	=	{
		model             = "models/missiles/aim120.mdl",
		rackmdl           = "models/missiles/aim120.mdl",
		maxlength         = 180,
		casing            = 0.1,							-- thickness of missile casing, cm
		armour            = 10,							-- effective armour thickness of casing, in mm
		propweight        = 4.0,							-- motor mass - motor casing
		thrust            = 850,							-- average thrust - kg * in/s ^ 2
		burnrate          = 200,							-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.075,
		minspeed          = 300,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.002,							-- drag coefficient while falling
		dragcoefflight    = 0.009,							-- drag coefficient during flight
		finmul            = 0.5,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.2)					-- 139 HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser", "GPS"},
	fuses      = {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {										-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["6xUARRK"] = true
				},

	agility    = 0.03,
	viewcone   = 180,
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00									-- minimum fuse arming delay
} )


ACF_defineGun("RW61 RA", {								-- id

	name             = "Raketwerfer-61",
	desc             = "A heavy, demolition-oriented rocket-assisted mortar, devastating against field works but takes a very, VERY long time to load.\n\n\nDon't miss.",
	model            = "models/missiles/RW61M.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 38,
	gunclass         = "ARTY",
	rack             = "380mmRW61",							-- Which rack to spawn this missile on?
	weight           = 1800,
	length           = 161,
	year             = 1944,
	rofmod           = 0.25,
	roundclass       = "Rocket",
	modeldiameter    = 16,
	rotmult          = 100,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling

	round	=
	{
		model             = "models/missiles/RW61M.mdl",
		rackmdl           = "models/missiles/RW61M.mdl",
		maxlength         = 160,
		casing            = 1.0,								-- thickness of missile casing, cm
		armour            = 10,								-- effective armour thickness of casing, in mm
		propweight        = 5,									-- motor mass - motor casing
		thrust            = 5000,								-- average thrust - kg * in/s ^ 2
		burnrate          = 5000,								-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.01,								-- percentage of the propellant consumed in the starter motor.
		minspeed          = 1,									-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.002,									-- drag coefficient of the missile
		dragcoefflight    = 0.009,							-- drag coefficient during flight
		finmul            = 0.001,								-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.4)						-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},		-- Because who doesn't love cluster RW61s

	racks	= {										-- a whitelist for racks that this missile can load into.
					["380mmRW61"] = true
				},

	seekcone   = 35,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone   = 55,									-- getting outside this cone will break the lock.  Divided by 2.

	agility    = 1,										-- multiplier for missile turn-rate.
	ghosttime  = 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00									-- minimum fuse arming delay
} )
