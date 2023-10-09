--define the class
ACF_defineGunClass("GBU", {
	type			= "missile",  -- i know i know
	spread		= 1,
	name			= "[GBU] - Guided Bomb Unit",
	desc			= ACFTranslation.MissileClasses[6],
	muzzleflash	= "40mm_muzzleflash_noscale",
	rofmod		= 0.1,
	year = 1967,
	sound		= "WT/Misc/bomb_drop.wav",
	soundDistance	= " ",
	soundNormal	= " ",
	nothrust		= true,

	reloadmul	= 2
} )



-- Balance the round in line with the 40mm pod rocket.
-- 116kg removed for now - looking for candidate to replace
-- good idea before axing a bomb to check its specs! https://www.onwar.com/weapons/rocket/missiles/USA_AGM62.html http://www.designation-systems.net/dusrm/m-62.html
-- walleye: for fucking missile sites up
ACF_defineGun("WalleyeGBU", {						-- id
	name			= "Guided Weapon AGM-62 Walleye",
	desc			= "An early guided bomb of yield roughly between the 454kg and 1000kg, used over Vietnam by American strike aircraft and by other countries.  Unlike other GBUs, the larger fins let it glide more like an unpowered missile, allowing drops at far greater distances in a more stand-off role.  For this reason, it performs best when released at higher speeds.\nBecause of its large fins, obsolete guidance equipment, and thicker casing, it has greater size and weight than comparable guided bombs.",
	model			= "models/bombs/gbu/agm62.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 346,
	caliber		= 31.8,						-- fat fucker, real diameter is 0.318m
	weight			= 1000,							-- 510kg
	year			= 1967,
	rofmod			= 4.0963,
	modeldiameter	= 30,					-- in cm
	bodydiameter     = 18.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	round = {
		model		= "models/bombs/gbu/agm62.mdl",
		rackmdl		= "models/bombs/gbu/agm62.mdl",
		maxlength	= 600,							-- real length is 3.45m, filler should be about 374kg
		casing		= 0.3,							-- thickness of missile casing, cm
		armour		= 13,							-- effective armour thickness of casing, in mm
		propweight	= 1,							-- motor mass - motor casing
		thrust		= 1,
		burnrate	= 1,							-- cm ^ 3/s at average chamber pressure
		starterpct	= 0.005,						-- percentage of the propellant consumed in the starter motor.
		minspeed	= 500,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,						-- drag coefficient of the missile
		finmul		= 0.02,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul	= math.sqrt(0.2)				-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true
				},

	seekcone	= 90,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 120,							-- getting outside this cone will break the lock.  Divided by 2.

	agility	= 2,								-- multiplier for missile turn-rate.
	ghosttime	= 0.5,							-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )

ACF_defineGun("227kgGBU", {						-- id
	name			= "227kg GBU-12 Paveway II",
	desc			= "Based on the Mk 82 500-pound general-purpose bomb, but with the addition of a nose-mounted laser seeker and fins for guidance.",
	model			= "models/bombs/gbu/gbu12.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 225,
	caliber		= 10.5,
	weight			= 227,							-- Don't scale down the weight though!
	year			= 1976,
	rofmod			= 1.6,
	modeldiameter	= 12,					-- in cm
	bodydiameter     = 12.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		model		= "models/bombs/gbu/gbu12.mdl",
		rackmdl		= "models/bombs/gbu/gbu12.mdl",
		maxlength	= 136,
		casing		= 0.5,							-- thickness of missile casing, cm
		armour		= 12,							-- effective armour thickness of casing, in mm
		propweight	= 0,							-- motor mass - motor casing
		thrust		= 1,							-- average thrust - kg * in/s ^ 2
		burnrate	= 1,							-- cm ^ 3/s at average chamber pressure
		starterpct	= 0.005,						-- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,						-- drag coefficient of the missile
		finmul		= 0.02,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul	= math.sqrt(0.05)				-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true
				},

	seekcone	= 60,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 80,							-- getting outside this cone will break the lock.  Divided by 2.

	agility	= 1,								-- multiplier for missile turn-rate.
	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )

ACF_defineGun("454kgGBU", {						-- id
	name			= "454kg GBU-16 Paveway II",
	desc			= "Based on the Mk 83 general-purpose bomb, but with laser seeker and wings for guidance.",
	model			= "models/bombs/gbu/gbu16.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 264,
	caliber		= 17.0,
	weight			= 454,							-- Don't scale down the weight though!
	year			= 1976,
	rofmod			= 1.5,
	modeldiameter	= 13,					-- in cm
	bodydiameter     = 13.8, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		model		= "models/bombs/gbu/gbu16.mdl",
		rackmdl		= "models/bombs/gbu/gbu16.mdl",
		maxlength	= 272,
		casing		= 0.5,							-- thickness of missile casing, cm
		armour		= 14,							-- effective armour thickness of casing, in mm
		propweight	= 0,							-- motor mass - motor casing
		thrust		= 1,							-- average thrust - kg * in/s ^ 2
		burnrate	= 1,							-- cm ^ 3/s at average chamber pressure
		starterpct	= 0.005,						-- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,						-- drag coefficient of the missile
		finmul		= 0.02,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul	= math.sqrt(0.04)				-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true
				},

	seekcone	= 60,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 80,							-- getting outside this cone will break the lock.  Divided by 2.

	agility	= 1,								-- multiplier for missile turn-rate.
	ghosttime	= 0.5,							-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )

ACF_defineGun("909kgGBU", {						-- id
	name			= "909kg GBU-10 Paveway II",
	desc			= "Based on the Mk 84 general-purpose bomb, but with laser seeker and wings for guidance.",
	model			= "models/bombs/gbu/gbu10.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 320,
	caliber		= 20.0,
	weight			= 909,							-- Don't scale down the weight though!
	year			= 1976,
	rofmod			= 2,
	modeldiameter	= 20,					-- in cm
	round = {
		model		= "models/bombs/gbu/gbu10_fold.mdl",
		rackmdl		= "models/bombs/gbu/gbu10.mdl",
		maxlength	= 545,
		casing		= 0.5,							-- thickness of missile casing, cm
		armour		= 28,							-- effective armour thickness of casing, in mm
		propweight	= 0,							-- motor mass - motor casing
		thrust		= 1,							-- average thrust - kg * in/s ^ 2
		burnrate	= 1,							-- cm ^ 3/s at average chamber pressure
		starterpct	= 0.005,						-- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,							-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,						-- drag coefficient of the missile
		finmul		= 0.01,							-- fin multiplier (mostly used for unpropelled guidance)
		penmul	= math.sqrt(0.09)				-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical", "Cluster"},

	racks	= {									-- a whitelist for racks that this missile can load into.'
					["1xRK"] = true
				},

	seekcone	= 60,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 80,							-- getting outside this cone will break the lock.  Divided by 2.

	agility	= 1,								-- multiplier for missile turn-rate.
	ghosttime	= 0.5,							-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )
