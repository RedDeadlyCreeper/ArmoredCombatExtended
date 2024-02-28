
--define the class
ACF_defineGunClass("AAM", {
	type           = "missile",
	spread         = 1,
	name           = "[AAM] - Air-To-Air Missile",
	desc           = ACFTranslation.MissileClasses[1],
	muzzleflash    = "40mm_muzzleflash_noscale",
	rofmod         = 1,
	sound          = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance  = " ",
	soundNormal    = " ",
	effect         = "Rocket Motor Missile1",
	year           = 1953,
	reloadmul      = 8
} )

-- The AIM-9 Sidewinder. The perfect choice for dogfights at short range. Although respectable payload, still tiny.
ACF_defineGun("AIM-9 AAM", {								-- id
	name             = "AIM-9 Missile",
	desc             = "The gold standard in airborne jousting sticks. Agile and reliable with a rather underwhelming effective range, this homing missile is the weapon of choice for dogfights.",
	model            = "models/missiles/aim9m.mdl",
	effect           = "Rocket Motor",
	effectbooster    = "Rocket Motor Missile1",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 214,
	caliber          = 12.7,
	weight           = 75,								-- Don't scale down the weight though!
	year             = 1953,
	modeldiameter    = 13.66,
	bodydiameter     = 6.1, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/aim9m.mdl",
		rackmdl				= "models/missiles/aim9m.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.5,
		reloaddelay			= 10.0,

		--Formerly 302 and 1. Reduced blast from 381Mj to 136Mj. For reference a 100kg bomb has 117Kj.
		maxlength			= 130,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 240,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.75,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 20,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 60,							-- Acceleration in m/s.
		burntime			= 2,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0005,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Antimissile"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["1xRK_small"] = true
			},

	seekcone           = 5,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 15,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 8,
	irccm				= true,

	armdelay           = 0.00,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

--AIM-120 Sparrow. A medium-Range AAM missile, perfect for those who really need a decent boom in a single pass. Just remember that this is not an AIM-9 and is better to aim before.
ACF_defineGun("AIM-120 AAM", {							-- id
	name             = "AIM-120 Missile",
	desc             = "Faster than the AIM-9, but also a lot heavier. Burns hot and fast, with a good reach, but harder to lock with.  This long-range missile is sure to deliver one heck of a blast upon impact.Less agile than its smaller stablemate, so choose your shots carefully.",
	model            = "models/missiles/aim120c.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 383,
	caliber          = 18,
	weight           = 125,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1991,
	modeldiameter    = 20.41,						-- in cm
	bodydiameter     = 8.9, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/aim120c.mdl",
		rackmdl				= "models/missiles/aim120c.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 60.0,

		--Formerly 370 and 1. Reduced blast from 1059Mj to 215Mj. For reference a 250kg bomb has 224Kj.
		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 9,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 25,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.25,							--Fraction of speed redirected every second at max deflection

		thrust				= 100,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Radar"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {									-- a whitelist for racks that this missile can load into.
						["1xRK"] = true,
						["2xRK"] = true
					},

	seekcone           = 4,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
	viewcone           = 27.5,								-- getting outside this cone will break the lock.  Divided by 2.	--was 25
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.00,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

--AIM-54 phoenix. Being faster and bigger than AIM-120, can deliver a single big blast against the target, however, this 300kgs piece of aerial destruction has a serious trouble
--with its seek cone and is suggested to AIM before launching.
ACF_defineGun("AIM-54 AAM", {							-- id
	name             = "AIM-54 Missile",
	desc             = "A supersonic long-range air to air missile, an early generation to AIM-120. This 300 kgs beast is decided to reduce your first opponent that it faces to ashes, of course, if its tiny seek cone is able to see it.",
	model            = "models/missiles/aim54.mdl",
	effect           = "Rocket Motor Arty",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 352,
	caliber          = 38.1,
	weight           = 463,								-- Don't scale down the weight though!
	year             = 1974,
	modeldiameter    = 22,86,
	bodydiameter     = 15.4, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/aim54.mdl",
		rackmdl				= "models/missiles/aim54.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 60.0,


		--Formerly 396 and 5. Reduced blast from 5509Mj to 1303Mj. For reference a 500kg bomb has 2702Kj.
		maxlength			= 120,							-- Length of missile. Used for ammo properties.
		propweight			= 45,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 11,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection

		thrust				= 60,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 15,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.002,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent                = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance           = {"Dumb", "Radar"},
	fuses              = {"Contact", "Overshoot", "Radio", "Optical"},

	racks              = {["1xRK"] = true},					-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone           = 4,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)  --was 4
	viewcone           = 22.5,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 1,

	agility            = 3,									-- multiplier for missile turn-rate.  --was 0.7
	armdelay           = 0.00,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.5,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.05									-- Time where this missile will be unable to hit surfaces, in seconds
} )
