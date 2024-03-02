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

	round = {
		rocketmdl				= "models/missiles/fim_92.mdl",
		rackmdl				= "models/missiles/fim_92_folded.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 25,

		--Former 125 and 1.5. Reduced blast from 107Mj to 60Mj. For reference a 100kg bomb has 117Kj.
		maxlength			= 85,							-- Length of missile. Used for ammo properties.
		propweight			= 3,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 20,							-- Armour effectiveness of casing, in mm

		turnrate			= 240,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.4,							--Fraction of speed redirected every second at max deflection

		thrust				= 120,							-- Acceleration in m/s.
		burntime			= 2.5,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0.3,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.003,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.4							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared" ,"Antimissile"},
	fuses      = {"Contact", "Overshoot", "Radio"},

	racks	= {										-- a whitelist for racks that this missile can load into.
				["1x FIM-92"] = true,
				["2x FIM-92"] = true,
				["4x FIM-92"] = true
			},

	seekcone           = 7.5,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 35
	viewcone           = 62,									-- getting outside this cone will break the lock.  Divided by 2.	--was 55
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.00,									-- minimum fuse arming delay		-was 0.3
	guidelay           = 0,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5									-- Time where this missile will be unable to hit surfaces, in seconds
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

	round = {
		rocketmdl			= "models/missiles/fim_92.mdl",
		rackmdl				= "models/missiles/fim_92_folded.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.0,
		reloaddelay			= 30.0,

		--Formerly 130 and 1.5. Reduced blast from 112Mj to 72Mj. For reference a 100kg bomb has 117Kj.
		maxlength			= 110,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 20,							-- Armour effectiveness of casing, in mm

		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.3,							--Fraction of speed redirected every second at max deflection

		thrust				= 140,							-- Acceleration in m/s.
		burntime			= 5,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0.2,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.005,						-- percent speed loss per second
		inertialcapable		= false,						-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.1							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Antimissile"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {											-- a whitelist for racks that this missile can load into.
					["2x FIM-92"] = true
				},

	seekcone			= 7.5,										-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 35
	viewcone			= 42,										-- getting outside this cone will break the lock.  Divided by 2.	--was 55
	SeekSensitivity		= 1,
	irccm				= true,

	guidelay   = 0,										-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay   = 0.00										-- minimum fuse arming delay		-was 0.3
} )

-- The 9M31 Strela-1, a bulky, slow medium-range anti-air missile.
ACF_defineGun("Strela-1 SAM", {								-- id
	name             = "9M31 Strela-1",
	desc             = "The 9M31 Strela-1 is a medium-range homing SAM with a much bigger payload than the FIM-92. Bulky. It is best suited to ground vehicles or stationary units. The strela is fast-reacting, while its missiles are surprisingly deadly and able to defend an acceptable area.",
	model            = "models/missiles/9m31.mdl",
	effect           = "Rocket Motor",
	gunclass         = "SAM",
	rack             = "1x Strela-1",							-- Which rack to spawn this missile on?
	length           = 219,
	caliber          = 12,
	weight           = 72,									-- 15.1,	-- Don't scale down the weight though!
	year             = 1960,
	modeldiameter    = 10,
	bodydiameter     = 7.3, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/9m31.mdl",
		rackmdl				= "models/missiles/9m31f.mdl",
		firedelay			= 0.75,
		reloadspeed			= 2.0,
		reloaddelay			= 40.0,

		--Formerly 190 and 1. Reduced blast from 213j to 120Mj. For reference a 100kg bomb has 117Kj.
		maxlength			= 145,							-- Length of missile. Used for ammo properties.
		propweight			= 5,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.25,							--Fraction of speed redirected every second at max deflection

		thrust				= 60,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 50,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent			= "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance		= {"Dumb", "Infrared","Antimissile"},
	fuses		= {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {										-- a whitelist for racks that this missile can load into.
						["1x Strela-1"] = true,
						["2x Strela-1"] = true,
						["4x Strela-1"] = true
					},

	seekcone           = 5,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone           = 60,									-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 1,

	armdelay           = 0.00,									-- minimum fuse arming delay
	guidelay           = 0.75,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("VT-1 SAM", {										-- id
	name             = "VT-1 Missile",
	desc             = "Powerful command guided SAM. Great range, good agility, and a powerful warhead. Has datalink.",
	model            = "models/missiles/arend/vt1.mdl",
	effect           = "Rocket Motor",
	effectbooster	= "Rocket Motor Missile1",
	gunclass         = "SAM",
	rack             = "1x VT-1",								-- Which rack to spawn this missile on?
	length           = 92*2.53, --Convert to ammocrate units
	caliber          = 12,
	weight           = 73,										-- Don't scale down the weight though!
	year             = 1960,
	modeldiameter    = 8,--Already in ammocrate units

	round = {
		rocketmdl			= "models/missiles/arend/vt1.mdl",
		rackmdl				= "models/missiles/arend/vt1_folded.mdl",
		firedelay			= 0.75,
		reloadspeed			= 2.0,
		reloaddelay			= 40.0,

		--Formerly 190 and 1. Reduced blast from 213j to 120Mj. For reference a 100kg bomb has 117Kj.
		maxlength			= 145,							-- Length of missile. Used for ammo properties.
		propweight			= 5,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.3,							--Fraction of speed redirected every second at max deflection

		thrust				= 60,							-- Acceleration in m/s.
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 50,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks = {										-- a whitelist for racks that this missile can load into.
				["1x VT-1"] = true
			},

	seekcone           = 5,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone           = 80,									-- getting outside this cone will break the lock.  Divided by 2.

	armdelay           = 0.00,									-- minimum fuse arming delay
	guidelay           = 0,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	SeekSensitivity    = 2
} )

--Tunguska Missile
ACF_defineGun("9M311 SAM", {										-- id
	name             = "9M311 Tunguska",
	desc             = "The 9M311 missile is a supersonic Anti Air missile that while is not agile enough to hit maneuvering planes, excels against helicopters. Has datalink.",
	model            = "models/missiles/arend/9m311_unfolded.mdl",
	effect           = "Rocket Motor",
	effectbooster	= "Rocket Motor Missile1",
	gunclass         = "SAM",
	rack             = "1x 9m311",								-- Which rack to spawn this missile on?
	length           = 100*2.53, --Convert to ammocrate units
	caliber          = 12,
	weight           = 71,										-- Don't scale down the weight though!
	year             = 1982,
	modeldiameter    = 7,--Already in ammocrate units

	round = {
		rocketmdl			= "models/missiles/arend/9m311_unfolded.mdl",
		rackmdl				= "models/missiles/arend/9m311_folded.mdl",
		firedelay			= 0.75,
		reloadspeed			= 2.0,
		reloaddelay			= 40.0,

		--Formerly 190 and 1. Reduced blast from 283j to 116Mj. For reference a 100kg bomb has 117Kj.

		maxlength			= 140,							-- Length of missile. Used for ammo properties.
		propweight			= 5,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 25,							-- Armour effectiveness of casing, in mm
		turnrate			= 15,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.4,							--Fraction of speed redirected every second at max deflection

		thrust				= 100,							-- Acceleration in m/s.
		burntime			= 1,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		--Should be around 1.5s. Set to 1/4th boost time.
		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.35,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.00035,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks = {										-- a whitelist for racks that this missile can load into.
				["1x 9m311"] = true
			},

	seekcone           = 5,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone           = 80,									-- getting outside this cone will break the lock.  Divided by 2.

	armdelay           = 0.00,									-- minimum fuse arming delay
	guidelay           = 0,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	SeekSensitivity    = 2
} )


--TOR Missile. This is going to be fun.
ACF_defineGun("9M331 SAM", {								-- id
	name             = "9M331 TOR",
	desc             = "The TOR Missile. Medium range SAM. This vertically Launched medium range missile is fast reacting making it good for missile intercepts, agile, and deadly. The missile is first kicked out of the tube, spun towards the target, then launched. Has datalink.",
	model            = "models/missiles/arend/9m331_unfolded.mdl",
	effect           = "Rocket Motor Missile1",
	effectbooster	 = "Rocket_Smoke_Trail",
	gunclass         = "SAM",
	rack             = "1x9M331 Pod",							-- Which rack to spawn this missile on?
	length           = 118*2.53, --Convert to ammocrate units
	caliber          = 23.9,
	weight           = 167,									-- 15.1,	-- Don't scale down the weight though!
	year             = 1986,
	modeldiameter    = 10,
	bodydiameter     = 7.62, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/9m331_unfolded.mdl",
		rackmdl				= "models/missiles/arend/9m331_folded.mdl",
		firedelay			= 0.5,
		reloadspeed			= 2.0,
		reloaddelay			= 45,

		maxlength			= 55,							-- Length of missile. Used for ammo properties.
		propweight			= 5,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 35,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 20,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.1,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 90,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 110,							-- Acceleration in m/s.
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 25,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.65,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.65							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent			= "acf_missile_to_rack",					-- A workaround ent which spawns an appropriate rack for the missile.
	guidance		= {"Dumb", "Laser", "Radar","Antimissile"},
	fuses		= {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {										-- a whitelist for racks that this missile can load into.
						["1x9M331 Pod"] = true
				},

	seekcone           = 5,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone           = 65,									-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 1,

	armdelay           = 0.00,									-- minimum fuse arming delay
	guidelay           = 0.75,									-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.5									-- Time where this missile will be unable to hit surfaces, in seconds
} )