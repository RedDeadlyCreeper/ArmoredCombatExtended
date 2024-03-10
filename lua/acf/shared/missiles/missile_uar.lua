
--define the class
ACF_defineGunClass("UAR", {
	type			= "missile",
	spread		= 0.2,
	name			= "[ASR] - Unguided Aerial Rockets",
	desc			= ACFTranslation.MissileClasses[9],
	muzzleflash	= "40mm_muzzleflash_noscale",
	rofmod		= 0.5,
	year = 1933,
	sound		= "acf_extra/airfx/rocket_fire2.wav",
	soundDistance	= " ",
	soundNormal	= " ",
	effect		= "Rocket Motor Arty"
} )


ACF_defineGun("SPG-9 ASR", { --id

	name             = "SPG-9 Rocket",
	desc             = "A recoilless rocket launcher similar to an RPG or Grom.  The main charge ignites in the tube, while a rocket accelerates a small antitank grenade to the target, giving it a high initial velocity, smaller launch signature, and flatter trajectory than a conventional round but less accuracy.  A useful alternative to guided missiles, it is also quite capable as lightweight HE-slinging artillery for air-drop and expeditionary forces.",
	model            = "models/munitions/round_100mm_mortar_shot.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 7.3,
	gunclass         = "UAR",
	rack             = "1x SPG9",  -- Which rack to spawn this missile on?
	weight           = 47,
	length           = 63,
	year             = 1962,
	rofmod           = 0.4,
	roundclass       = "Rocket",
	rotmult          = 1,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	modeldiameter    = 5,

	round	= {
		model             = "models/missiles/glatgm/9m112f.mdl",
		rackmdl           = "models/munitions/round_100mm_mortar_shot.mdl",
		maxlength         = 100,
		casing            = 0.08,		-- thickness of missile casing, cm
		armour            = 4,			-- effective armour thickness of casing, in mm
		propweight        = 0.5,		-- motor mass - motor casing
		thrust            = 120000,	-- average thrust - kg * in/s ^ 2 very high but only burns a brief moment, most of which is in the tube
		burnrate          = 1200,		-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.72,
		minspeed          = 900,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoefflight    = 0.05,				-- drag coefficient during flight
		dragcoef          = 0.001,		-- drag coefficient while falling
		finmul            = 0.02,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.3)	-- 215.9 HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)

	},

	ent        = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical"},

	racks      = {["1x SPG9"] = true},	-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	ghosttime  = 0.1,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.0	-- minimum fuse arming delay, very short since we have a high muzzle velocity
} )

ACF_defineGun("RS82 ASR", { --id

	name             = "RS-82 Rocket",
	desc             = "A small, unguided rocket, often used in multiple-launch artillery as well as for attacking pinpoint ground targets.  It has a small amount of propellant, limiting its range, but is compact and light.",
	model            = "models/missiles/rs82.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 8.2,
	gunclass         = "UAR",
	rack             = "1xRK_small",  -- Which rack to spawn this missile on?
	weight           = 6.8,
	length           = 62,
	year             = 1933,
	rofmod           = 0.07,
	roundclass       = "Rocket",
	rotmult          = 1,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	modeldiameter    = 4,
	bodydiameter     = 4.8, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round	= {
		model             = "models/missiles/rs82.mdl",
		rackmdl           = "models/missiles/rs82.mdl",
		maxlength         = 50,
		casing            = 0.2,		-- thickness of missile casing, cm
		armour            = 5,			-- effective armour thickness of casing, in mm
		propweight        = 0.7,		-- motor mass - motor casing
		thrust            = 15000,		-- average thrust - kg * in/s ^ 2
		burnrate          = 800,		-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.15,
		minspeed          = 6000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.002,		-- drag coefficient while falling
		dragcoefflight    = 0.025,				-- drag coefficient during flight
		finmul            = 0.008,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.115)	--  139 HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Timed"},

	racks      = {["1xRK"] = true, ["1xRK_small"] = true, ["3xUARRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true},	-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	ghosttime  = 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.0	-- minimum fuse arming delay
} )

ACF_defineGun("Zuni ASR", { --id
	name             = "Zuni Rocket",
	desc             = "A heavy 5in air to surface unguided rocket, able to provide heavy suppressive fire in a single pass.",
	model            = "models/ghosteh/zuni.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 12.7,
	gunclass         = "UAR",
	rack             = "127mm4xPOD",
	weight           = 36.1,
	length           = 298,
	year             = 1957,
	rofmod           = 0.5,
	roundclass       = "Rocket",
	rotmult          = 1,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	modeldiameter    = 5.26,
	bodydiameter     = 6.7, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)


	round	=
	{
		model             = "models/ghosteh/zuni.mdl",
		rackmdl           = "models/ghosteh/zuni_folded.mdl",
		maxlength         = 200,
		casing            = 0.2,
		armor             = 10,
		propweight        = 0.7,
		thrust            = 24000,
		burnrate          = 1000,
		starterpct        = 0.2,
		minspeed          = 8000,
		dragcoef          = 0.0001,
		dragcoefflight    = 0.001,
		finmul            = 0.0001,
		penmul            = math.sqrt(0.115)
	},
	ent        = "acf_missile_to_rack",
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Timed", "Optical", "Radio"},
	racks      = {["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["127mm4xPOD"] = true},

	ghosttime  = 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.0

})

ACF_defineGun("HVAR ASR", { --id

	name             = "HVAR Rocket",
	desc             = "A medium, unguided rocket. More bang than the RS82, at the cost of size and weight.",
	model            = "models/missiles/hvar.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 12.7,
	gunclass         = "UAR",
	rack             = "1xRK",  -- Which rack to spawn this missile on?
	weight           = 63,
	length           = 174,
	year             = 1933,
	rofmod           = 0.5,
	roundclass       = "Rocket",
	rotmult          = 1,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	modeldiameter    = 12,
	bodydiameter     = 7, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round	= {
		model             = "models/missiles/hvar.mdl",
		rackmdl           = "models/missiles/hvar.mdl",
		maxlength         = 155,
		casing            = 0.2,		-- thickness of missile casing, cm
		armour            = 8,			-- effective armour thickness of casing, in mm
		propweight        = 0.7,		-- motor mass - motor casing
		thrust            = 25000,		-- average thrust - kg * in/s ^ 2
		burnrate          = 600,		-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.15,
		minspeed          = 5000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.002,		-- drag coefficient while falling
		dragcoefflight    = 0.02,				-- drag coefficient during flight
		finmul            = 0.01,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.115)	-- 215.9 HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Timed"},

	racks      = {["1xRK"] = true, ["1xRK_small"] = true, ["3xUARRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true},	-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	ghosttime  = 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.0	-- minimum fuse arming delay
} )

ACF_defineGun("S-24 ASR", { --id

	name             = "S-24 Rocket",
	desc             = "A big, unguided rocket. Mostly used by late cold war era attack planes and helicopters.",
	model            = "models/missiles/s24.mdl",
	effect           = "Rocket Motor Arty",
	caliber          = 24,
	gunclass         = "UAR",
	rack             = "1xRK",  -- Which rack to spawn this missile on?
	weight           = 235,
	length           = 223 , -- Note: intentional. When scalable system becomes true. I could fix this.
	year             = 1960,
	rofmod           = 0.4,
	roundclass       = "Rocket",
	rotmult          = 360,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling
	modeldiameter    = 18,
	bodydiameter     = 11, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round	= {
		model             = "models/missiles/s24.mdl",
		rackmdl           = "models/missiles/s24.mdl",
		maxlength         = 100,
		casing            = 0.3,					-- thickness of missile casing, cm
		armour            = 10,					-- effective armour thickness of casing, in mm
		propweight        = 20,					-- motor mass - motor casing
		thrust            = 9000,					-- average thrust - kg * in/s ^ 2
		burnrate          = 2000,					-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.15,
		minspeed          = 10000,					-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.001,					-- drag coefficient while falling
		dragcoefflight    = 0.01,				-- drag coefficient during flight
		finmul            = 0.5,					-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.115)		-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Timed"},

	racks      = {["1xRK"] = true, ["3xRK"] = true, ["2xRK"] = true, ["6xUARRK"] = true},	-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	skinindex  = {HEAT = 0, HE = 1},

	ghosttime  = 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.0	-- minimum fuse arming delay
} )

