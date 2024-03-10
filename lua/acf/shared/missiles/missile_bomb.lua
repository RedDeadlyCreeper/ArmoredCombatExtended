--define the class
ACF_defineGunClass("BOMB", {
	type           = "missile",  -- i know i know
	spread         = 1,
	name           = "[Bomb] - General Purpose Bomb",
	desc           = ACFTranslation.MissileClasses[5],
	muzzleflash    = "40mm_muzzleflash_noscale",
	rofmod         = 0.1,
	year           = 1915,
	sound          = "acf_extra/tankfx/clunk.wav",
	soundDistance  = " ",
	soundNormal    = " ",
	nothrust       = true,

	reloadmul      = 8
} )


-- Balance the round in line with the 40mm pod rocket.
ACF_defineGun("50kgBOMB", {						-- id
	name             = "50kg Free Falling Bomb",
	desc             = "Old 100lb bomb, most effective vs exposed infantry and light trucks.",
	model            = "models/bombs/fab50.mdl",
	gunclass         = "BOMB",
	rack             = "3xRK",					-- Which rack to spawn this missile on?
	length           = 90,
	caliber          = 5.0,
	weight           = 50,						-- Don't scale down the weight though!
	year             = 1915,
	modeldiameter    = 11.15,					-- in cm

	round = {
		model       = "models/bombs/fab50.mdl",
		rackmdl     = "models/bombs/fab50.mdl",
		maxlength   = 62,
		casing      = 0.05,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.003,						-- drag coefficient of the missile
		finmul      = 0.004,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.05)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
				["1xRK_small"] = true,
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["4xRK"] = true
			},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
} )


ACF_defineGun("100kgBOMB", {						-- id
	name             = "100kg Free Falling Bomb",
	desc             = "An old 250lb WW2 bomb, as used by Soviet bombers to destroy enemies of the Motherland.",
	model            = "models/bombs/fab100.mdl",
	gunclass         = "BOMB",
	rack             = "1xRK",					-- Which rack to spawn this missile on?
	length           = 106,
	caliber          = 10.0,
	weight           = 100,						-- Don't scale down the weight though!
	year             = 1939,
	modeldiameter    = 13,				-- in cm

	round = {
		model       = "models/bombs/fab100.mdl",
		rackmdl     = "models/bombs/fab100.mdl",
		maxlength   = 125,
		casing      = 0.1,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.003,						-- drag coefficient of the missile
		finmul      = 0.004,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.05)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
					["1xRK_small"] = true,
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true
				},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
} )

ACF_defineGun("250kgBOMB", {						-- id
	name             = "250kg Free Falling Bomb",
	desc             = "A heavy 500lb bomb, widely used as a tank buster on various WW2 aircraft.",
	model            = "models/bombs/fab250.mdl",
	gunclass         = "BOMB",
	rack             = "1xRK",					-- Which rack to spawn this missile on?
	length           = 207,
	caliber          = 12.5,
	weight           = 250,						-- Don't scale down the weight though!
	year             = 1941,
	modeldiameter    = 15, -- in cm

	round = {
		model       = "models/bombs/fab250.mdl",
		rackmdl     = "models/bombs/fab250.mdl",
		maxlength   = 150,						-- was 115, wtf!
		casing      = 0.15,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.003,						-- drag coefficient of the missile
		finmul      = 0.004,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.05)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
				["1xRK_small"] = true,
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["4xRK"] = true
			},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
} )

ACF_defineGun("500kgBOMB", {						-- id
	name             = "500kg Free Falling Bomb",
	desc             = "A 1000lb bomb, as found in the heavy bombers of late WW2. Best used against fortifications or immobile targets.",
	model            = "models/bombs/fab500.mdl",
	gunclass         = "BOMB",
	rack             = "1xRK",					-- Which rack to spawn this missile on?
	length           = 210, --i know. Real one is too big for the largest of the ammocrates
	caliber          = 30,
	weight           = 500,						-- Don't scale down the weight though!
	year             = 1943,
	modeldiameter    = 18,				-- in cm

	round = {
		model       = "models/bombs/fab500.mdl",
		rackmdl     = "models/bombs/fab500.mdl",
		maxlength   = 300,
		casing      = 0.2,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.003,						-- drag coefficient of the missile
		finmul      = 0.004,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.05)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
				["1xRK"] = true,
				["2xRK"] = true
			},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
} )

ACF_defineGun("1000kgBOMB", {					-- id
	name             = "1000kg Free Falling Bomb",
	desc             = "A 2000lb bomb. As close to a nuke as you can get in ACF, this munition will turn everything it touches to ashes. Handle with care.",
	model            = "models/bombs/an_m66.mdl",
	gunclass         = "BOMB",
	rack             = "1xRK",					-- Which rack to spawn this missile on?
	length           = 227, --i know. Real one is too big for the largest of the ammocrates
	caliber          = 30,
	weight           = 1000,						-- Don't scale down the weight though!
	year             = 1945,
	modeldiameter    = 26,				-- in cm

	round = {
		model       = "models/bombs/an_m66.mdl",
		rackmdl     = "models/bombs/an_m66.mdl",
		maxlength   = 600,
		casing      = 0.1,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.003,						-- drag coefficient of the missile
		finmul      = 0.004,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.08)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
				["1xRK"] = true
			},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
} )


ACF_defineGun("100kgGBOMB", {					-- id
	name             = "100kg Glide Bomb",
	desc             = "A 250-pound bomb, fitted with fins for a longer reach.  Well suited to dive bombing, but bulkier and heavier from its fins.",
	model            = "models/missiles/micro.mdl",
	gunclass         = "BOMB",
	rack             = "1xRK",					-- Which rack to spawn this missile on?
	length           = 121,
	caliber          = 10.0,
	weight           = 150,						-- Don't scale down the weight though!
	year             = 1939,
	modeldiameter    = 13,				-- in cm

	round = {
		model       = "models/missiles/micro.mdl",
		rackmdl     = "models/missiles/micro.mdl",
		maxlength   = 125,
		casing      = 0.1,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 500,						-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.002,						-- drag coefficient of the missile
		finmul      = 0.05,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.05)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
				["1xRK_small"] = true,
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["4xRK"] = true
			},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
})


ACF_defineGun("250kgGBOMB", {					-- id
	name             = "250kg Glide Bomb",
	desc             = "A heavy 500lb bomb, fitted with fins for a gliding trajectory better suited to striking point targets.",
	model            = "models/missiles/fab250.mdl",
	gunclass         = "BOMB",
	rack             = "1xRK",					-- Which rack to spawn this missile on?
	length           = 165,
	caliber          = 12.5,
	weight           = 375,						-- Don't scale down the weight though!
	year             = 1941,
	modeldiameter    = 15.29,				-- in cm
	bodydiameter     = 16.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		model       = "models/missiles/fab250.mdl",
		rackmdl     = "models/missiles/fab250.mdl",
		maxlength   = 150,
		casing      = 0.2,						-- thickness of missile casing, cm
		armour      = 25,						-- effective armour thickness of casing, in mm
		propweight  = 0,							-- motor mass - motor casing
		thrust      = 1,							-- average thrust - kg * in/s ^ 2
		burnrate    = 1,							-- cm ^ 3/s at average chamber pressure
		starterpct  = 1,							-- percentage of the propellant consumed in the starter motor.
		minspeed    = 500,						-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef    = 0.002,						-- drag coefficient of the missile
		finmul      = 0.05,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.05)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb"},
	fuses      = {"Contact", "Optical", "Cluster"},

	racks	= {								-- a whitelist for racks that this missile can load into.
					["1xRK_small"] = true,
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true
				},

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00							-- minimum fuse arming delay
} )
