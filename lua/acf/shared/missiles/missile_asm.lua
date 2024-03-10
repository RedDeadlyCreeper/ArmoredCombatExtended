
--define the class
ACF_defineGunClass("ASM", {
	type           = "missile",
	spread         = 1,
	name           = "[ASM] - Air-To-Surface Missile",
	desc           = ACFTranslation.MissileClasses[3],
	muzzleflash    = "40mm_muzzleflash_noscale",
	year           = 1969,
	rofmod         = 1,
	sound          = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance  = " ",
	soundNormal    = " ",
	effect         = "Rocket Motor Missile1",		-- Small/Medium size missile

	reloadmul      = 8
} )


-- The AGM-114, a laser guided missile with high anti-tank effectiveness.
ACF_defineGun("AGM-114 ASM", {						--id
	name             = "AGM-114 Hellfire Missile",
	desc             = "The AGM-114 Hellfire is an air-to-surface missile first developed for anti-armor use, but later models were developed for precision strikes against other target types. Bringer of Hell.",
	model            = "models/missiles/agm_114.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "2x AGM-114",					-- Which rack to spawn this missile on?
	length           = 163,
	caliber          = 16,
	weight           = 45,							-- Don't scale down the weight though!
	modeldiameter    = 3 * 2.54,					-- in cm
	bodydiameter     = 8.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	year             = 1984,

	round = {
		model             = "models/missiles/agm_114.mdl",
		rackmdl           = "models/missiles/agm_114.mdl",
		maxlength         = 150,
		casing            = 0.2,						-- thickness of missile casing, cm
		armour            = 10,						-- effective armour thickness of casing, in mm
		propweight        = 1,							-- motor mass - motor casing
		thrust            = 15000,						-- average thrust - kg * in/s ^ 2	--was 12000
		burnrate          = 100,						-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.25,						-- percentage of the propellant consumed in the starter motor.	--was 0.25
		minspeed          = 4000,						-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.001,						-- drag coefficient while falling
		dragcoefflight    = 0.05,						-- drag coefficient during flight
		finmul            = 0.1,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.518)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser"},
	fuses      = {"Contact", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2x AGM-114"] = true,
					["4x AGM-114"] = true,

				},

	seekcone   = 10,
	viewcone   = 40,								-- getting outside this cone will break the lock.  Divided by 2.
	agility    = 0.07,								-- multiplier for missile turn-rate.
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay
} )

-- The AGM-45 shrike, a vietnam war-era antiradiation missile built off the AIM-7 airframe.
ACF_defineGun("AGM-45 ASM", {						-- id
	name             = "AGM-45 Shrike Missile",
	desc             = "The body of an AIM-7 sparrow, an air-to-ground seeker kit, and a far larger warhead than its ancestor.\nWith its homing radar seeker option, thicker skin, and long range, it is a great weapon for long-range, precision standoff attack versus squishy things, like those pesky sam sites.",
	model            = "models/missiles/aim120.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 383,
	caliber          = 20.3,
	weight           = 177,							-- Don't scale down the weight though!
	modeldiameter    = 4 * 2.54,					-- in cm
	bodydiameter     = 9.2, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	year             = 1969,
	rofmod           = 0.6,

	round = {
		model             = "models/missiles/aim120.mdl",
		rackmdl           = "models/missiles/aim120.mdl",
		maxlength         = 150,
		casing            = 0.15,						-- thickness of missile casing, cm
		armour            = 15,						-- effective armour thickness of casing, in mm
		propweight        = 3,							-- motor mass - motor casing
		thrust            = 2000,						-- average thrust - kg * in/s ^ 2		--was 600
		burnrate          = 300,						-- cm ^ 3/s at average chamber pressure
		starterpct        = 0.05,						-- percentage of the propellant consumed in the starter motor.
		minspeed          = 4000,						-- minimum speed beyond which the fins work at 100% efficiency	--was 4000
		dragcoef          = 0.004,						-- drag coefficient while falling								--was 0.001
		dragcoefflight    = 0.004,						-- drag coefficient during flight
		finmul            = 0.2,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.1)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Radar", "Laser", "Infrared"},
	fuses	= {"Contact", "Timed"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["6xUARRK"] = true
				},

	seekcone   = 5,									-- why do you need a big seeker cone if yuo're firing vs a SAM site?
	viewcone   = 10,								-- I don't think a fucking SAM site should have to dodge much >_>

	agility    = 0.03,								-- multiplier for missile turn-rate.  --was 0.08
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay
} )

--Sidearm, a lightweight anti-radar missile used by helicopters in the 80s
ACF_defineGun("AGM-122 ASM", {						-- id
	name             = "AGM-122 Sidearm Missile",
	desc             = "A refurbished early-model AIM-9, for attacking ground targets.  Less well-known than the bigger Shrike, it provides easy-to-use blind-fire anti-SAM performance for helicopters and light aircraft, with far heavier a punch than its ancestor.",
	model            = "models/missiles/aim9.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 215,
	caliber          = 12.7,								-- Aim-9 is listed as 9 as of 6/30/2017, why?  Wiki lists it as a 5" rocket!
	weight           = 88,								-- Don't scale down the weight though!
	rofmod           = 0.3,
	year             = 1986,
	modeldiameter    = 3 * 2.54,
	bodydiameter     = 6, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rotmult          = 0.25,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling

	round = {
		model             = "models/missiles/aim9.mdl",
		rackmdl           = "models/missiles/aim9.mdl",
		maxlength         = 140,
		casing            = 0.1,						-- thickness of missile casing, cm
		armour            = 15,							-- effective armour thickness of casing, in mm
		propweight        = 4,							-- motor mass - motor casing
		thrust            = 8500,						-- average thrust - kg * in/s ^ 2	--was 4000
		burnrate          = 1600,						-- cm ^ 3/s at average chamber pressure	--was 1400
		starterpct        = 0.4,						-- percentage of the propellant consumed in the starter motor.  --was 0.2
		minspeed          = 12000,						-- minimum speed beyond which the fins work at 100% efficiency	--was 5000
		dragcoef          = 0.005,						-- drag coefficient while falling								--0.001
		dragcoefflight    = 0.001,						-- drag coefficient during flight
		finmul            = 0.02,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.075)				-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Radar", "Infrared"},
	fuses	= {"Contact", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["1xRK_small"] = true
				},

	seekcone   = 7.5,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone   = 14,								-- getting outside this cone will break the lock.  Divided by 2.

	agility    = 0.3,								-- multiplier for missile turn-rate.  --was 0.3
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay		--was 0.4
} )

-- Maverick. A heavy missile which excels at destroying armoured ground targets. Used by ground attack aircrafts like the A-10
ACF_defineGun("AGM-65 ASM", {						-- id
	name             = "AGM-65 Maverick Missile",
	desc             = "You see that tank over there a mile away? I want you to lock onto it and forget about it.",
	model            = "models/missiles/aim54.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 352,
	caliber          = 30.5,
	weight           = 300,							-- Don't scale down the weight though!
	year             = 1974,
	modeldiameter    = 9.0 * 2.54,					-- in cm
	bodydiameter     = 15.4, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rofmod           = 0.3,
	round = {
		model             = "models/missiles/aim54.mdl",
		rackmdl           = "models/missiles/aim54.mdl",
		maxlength         = 220,
		casing            = 0.2,						-- thickness of missile casing, cm
		armour            = 25,						-- effective armour thickness of casing, in mm
		propweight        = 5,							-- motor mass - motor casing
		thrust            = 18000,						-- average thrust - kg * in/s ^ 2	--was 10000
		burnrate          = 200,						-- cm ^ 3/s at average chamber pressure	--was 800
		starterpct        = 0.1,						-- percentage of the propellant consumed in the starter motor.
		minspeed          = 1000,						-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef          = 0.01,						-- drag coefficient while falling
		dragcoefflight    = 0.1,						-- drag coefficient during flight
		finmul            = 0.05,						-- fin multiplier (mostly used for unpropelled guidance)
		penmul            = math.sqrt(0.53)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb" , "Infrared"},
	fuses      = {"Contact", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true
				},

	seekcone   = 10,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone   = 60,								-- getting outside this cone will break the lock.  Divided by 2.

	agility    = 0.15,								-- multiplier for missile turn-rate.
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00,								-- minimum fuse arming delay --was 0.3

} )
