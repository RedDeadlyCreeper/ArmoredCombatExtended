--define the class
ACF_defineGunClass("SAM", {
	type           = "missile",  -- i know i know
	spread         = 1,
	name           = "[SAM] - Surface-To-Air Missile",
	desc           = ACFTranslation.MissileClasses[8],
	muzzleflash    = "40mm_muzzleflash_noscale",
	rofmod         = 1,
	year           = 1960,
	sound          = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance  = " ",
	soundNormal    = " ",
	effect         = "Rocket Motor",
	reloadmul      = 8
} )

-- The FIM-92, a lightweight, medium-speed short-range anti-air missile.
ACF_defineGun("FIM-92 SAM", {								-- id
	name             = "FIM-92 Missile",
	desc             = "The FIM-92 Stinger is a lightweight and versatile close-range air defense missile.\nWith a seek cone of 15 degrees and a sharply limited range that makes it useless versus high-flying targets, it is best to aim before firing and choose shots carefully.",
	model            = "models/missiles/fim_92.mdl",
	effect           = "Rocket Motor FFAR",					--Tiny motor for tiny rocket
	gunclass         = "SAM",
	rack             = "1x FIM-92",							-- Which rack to spawn this missile on?
	length           = 150,
	caliber          = 11,
	weight           = 20,									-- 15.1,	-- Don't scale down the weight though!
	modeldiameter    = 3,									-- in cm
	year             = 1978,
	rofmod           = 0.15,
	rotmult          = 0.1,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling

	round = {
		model             = "models/missiles/fim_92.mdl",
		rackmdl           = "models/missiles/fim_92_folded.mdl",
		maxlength         = 125,
		casing            = 0.5,								-- thickness of missile casing, cm
		armour            = 5,									-- effective armour thickness of casing, in mm
		propweight        = 1.5,								-- motor mass - motor casing
		thrust            = 7000,								-- average thrust - kg * in/s ^ 2		--was 120000
		burnrate          = 1000,		--1000					-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.1,								-- percentage of the propellant consumed in the starter motor.  --was 0.2
		minspeed          = 10000,								-- minimum speed beyond which the fins work at 100% efficiency  --was 15000
		dragcoef          = 0.005,								-- drag coefficient while falling						--was 0.001
		dragcoefflight    = 0.006,							-- drag coefficient during flight
		finmul            = 0.05								-- fin multiplier (mostly used for unpropelled guidance)	--was 0.02
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared" ,"Antimissile"},
	fuses      = {"Contact", "Radio"},

	racks	= {										-- a whitelist for racks that this missile can load into.
				["1x FIM-92"] = true,
				["2x FIM-92"] = true,
				["4x FIM-92"] = true
			},

	seekcone           = 15,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 35
	viewcone           = 60,									-- getting outside this cone will break the lock.  Divided by 2.	--was 55

	agility            = 3,										-- multiplier for missile turn-rate.		--was 1
	armdelay           = 0.00,									-- minimum fuse arming delay		-was 0.3
	guidelay           = 0,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	SeekSensitivity    = 2
} )

-- The Mistral missile is a faster short range missile with greater range than fim92 but less agility
ACF_defineGun("Mistral SAM", {								-- id
	name             = "Mistral Missile",
	desc             = "A very fast short range missile, faster and less agile than FIM-92. Mostly for Anti-Aircraft and Anti-Missile operations.",
	model            = "models/missiles/fim_92_folded.mdl",
	effect           = "Rocket Motor FFAR",					-- Tiny motor for tiny rocket
	gunclass         = "SAM",
	rack             = "2x FIM-92",							-- Which rack to spawn this missile on?
	length           = 150,
	caliber          = 11,
	weight           = 19.7,									-- 15.1,	-- Don't scale down the weight though!
	modeldiameter    = 3,									-- in cm
	year             = 1974,
	rofmod           = 0.15,
	rotmult          = 0.25,

	round = {
		model             = "models/missiles/fim_92_folded.mdl",
		rackmdl           = "models/missiles/fim_92_folded.mdl",
		maxlength         = 130,
		casing            = 0.01,								-- thickness of missile casing, cm
		armour            = 5,									-- effective armour thickness of casing, in mm
		propweight        = 1.5,								-- motor mass - motor casing
		thrust            = 9000,								-- average thrust - kg * in/s ^ 2		--was 120000
		burnrate          = 850,	-- 850							-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.1,								-- percentage of the propellant consumed in the starter motor.  --was 0.2
		minspeed          = 17000,								-- minimum speed beyond which the fins work at 100% efficiency  --was 15000
		dragcoef          = 0.0035,								-- drag coefficient while falling
		dragcoefflight    = 0.005,								-- drag coefficient during flight
		finmul            = 0.05								-- fin multiplier (mostly used for unpropelled guidance)
	},

	ent        = "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Antimissile"},
	fuses      = {"Contact", "Radio"},

	racks	= {											-- a whitelist for racks that this missile can load into.
					["2x FIM-92"] = true
				},

	seekcone   = 15,										-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 35
	viewcone   = 60,										-- getting outside this cone will break the lock.  Divided by 2.	--was 55

	agility    = 2,											-- multiplier for missile turn-rate.		--was 1
	guidelay   = 0,										-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.00										-- minimum fuse arming delay		-was 0.3
} )

-- The 9M31 Strela-1, a bulky, slow medium-range anti-air missile.
ACF_defineGun("Strela-1 SAM", {								-- id
	name             = "9M31 Strela-1",
	desc             = "The 9M31 Strela-1 is a medium-range homing SAM with a much bigger payload than the FIM-92. Bulk, it is best suited to ground vehicles or stationary units.\nWith its 30 degree seek cone, the strela is fast-reacting, while its missiles are surprisingly deadly and able to defend an acceptable area.",
	model            = "models/missiles/9m31.mdl",
	effect           = "Rocket Motor",
	gunclass         = "SAM",
	rack             = "1x Strela-1",							-- Which rack to spawn this missile on?
	length           = 219,
	caliber          = 12,
	weight           = 72,									-- 15.1,	-- Don't scale down the weight though!
	year             = 1960,
	rofmod           = 0.3,
	modeldiameter    = 10,
	bodydiameter     = 7.3, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rotmult          = 1,

	round = {
		model             = "models/missiles/9m31.mdl",
		rackmdl           = "models/missiles/9m31f.mdl",
		maxlength         = 190,
		casing            = 0.05,								-- thickness of missile casing, cm
		armour            = 10,								-- effective armour thickness of casing, in mm
		propweight        = 1,									-- motor mass - motor casing
		thrust            = 4900,								-- average thrust - kg * in/s ^ 2									--was 3800
		burnrate          = 250,								-- cm ^ 3/s at average chamber pressure						--was 400
		starterpct        = 0.05,								-- percentage of the propellant consumed in the starter motor.
		minspeed          = 10000,								-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.01,								-- drag coefficient while falling
		dragcoefflight    = 0.01,								-- drag coefficient during flight			--was 0
		finmul            = 0.15								-- fin multiplier (mostly used for unpropelled guidance)		--was 0.03
	},

	ent			= "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance		= {"Dumb", "Infrared","Antimissile"},
	fuses		= {"Contact", "Radio"},

	racks		= {										-- a whitelist for racks that this missile can load into.
						["1x Strela-1"] = true,
						["2x Strela-1"] = true,
						["4x Strela-1"] = true
					},

	seekcone           = 15,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone           = 60,									-- getting outside this cone will break the lock.  Divided by 2.

	agility            = 1,										-- multiplier for missile turn-rate.	--was 1.5
	armdelay           = 0.00,									-- minimum fuse arming delay
	guidelay           = 0.75,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	SeekSensitivity    = 2
} )

--Tunguska Missile
ACF_defineGun("9M311 SAM", {										-- id
	name             = "9M311 Missile",
	desc             = "The 9M311 missile is a supersonic Anti Air missile that while is not agile enough to hit maneuvering planes, excels against helicopters.",
	model            = "models/missiles/aim9.mdl",
	effect           = "Rocket Motor",
	gunclass         = "SAM",
	rack             = "1x 9m311",								-- Which rack to spawn this missile on?
	length           = 215,										-- Used for the physics calculations
	caliber          = 12,
	weight           = 71,										-- Don't scale down the weight though!
	year             = 1982,
	rofmod           = 0.3,
	modeldiameter    = 3 * 2.54,
	rotmult          = 1,

	round = {
		model             = "models/missiles/aim9.mdl",
		rackmdl           = "models/missiles/aim9.mdl",
		maxlength         = 250,
		casing            = 0.1,								-- thickness of missile casing, cm
		armour            = 5,									-- effective armour thickness of casing, in mm
		propweight        = 0.8,								-- motor mass - motor casing
		thrust            = 17000,								-- average thrust - kg * in/s ^ 2
		burnrate          = 400,								-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.2,								-- percentage of the propellant consumed in the starter motor.
		minspeed          = 17000,								-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.011,								-- drag coefficient while falling
		dragcoefflight    = 0.01,								-- drag coefficient during flight
		finmul            = 0.01,								-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(8.8)						-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser"},
	fuses      = {"Contact", "Radio", "Optical"},

	racks = {										-- a whitelist for racks that this missile can load into.
				["1x 9m311"] = true
			},

	seekcone           = 15,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone           = 60,									-- getting outside this cone will break the lock.  Divided by 2.

	agility            = 0.8,										-- multiplier for missile turn-rate.
	armdelay           = 0.00,									-- minimum fuse arming delay
	guidelay           = 0,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	SeekSensitivity    = 2
} )
