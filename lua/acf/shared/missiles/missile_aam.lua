
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
	name             = "AIM-9 Sidewinder",
	desc             = "The gold standard in airborne jousting sticks. Agile and reliable with a rather underwhelming effective range, this homing missile is the weapon of choice for dogfights.\n\nInertial Guidance: Yes\nECCM: Yes\nDatalink: No\nTop Speed: 183 m/s",
	model            = "models/missiles/aim9m.mdl",
	effect           = "ACE_MissileSmall",
	effectbooster    = "ACE_MissileSmall",
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
		reloaddelay			= 30.0,

		--Formerly 302 and 1. Reduced blast from 381Mj to 136Mj. For reference a 100kg bomb has 117Kj.
		maxlength			= 130,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 120,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.75,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 0,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

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
	guidance   = {"Dumb", "Infrared"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["1xRK_small"] = true
			},

	seekcone           = 15,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 48,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.15,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("AIM-7 AAM", {							-- id
	name             = "AIM-7 Sparrow",
	desc             = "While not as advanced as its modern counterparts, the Sparrow makes up for it in thrust and plentiful speed. Do not underestimate it.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: Yes\nTop Speed: 310 m/s",
	model            = "models/missiles/arend/aim7f.mdl",
	effect           = "ACE_MissileMedium",
	effectbooster    = "ACE_MissileMedium",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 146 * 2.53, --Convert to ammocrate units
	caliber          = 20.3,
	weight           = 230,							-- Don't scale down the weight though!
	year             = 1969,
	modeldiameter    = 30,--Already in ammocrate units
	bodydiameter     = 9.7, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/aim7f.mdl",
		rackmdl				= "models/missiles/arend/aim7f.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 45.0,

		--Formerly 370 and 1. Reduced blast from 1059Mj to 215Mj. For reference a 250kg bomb has 224Kj.
		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 9,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 30,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.28,							--Fraction of speed redirected every second at max deflection

		thrust				= 110,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.2,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Semiactive"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {									-- a whitelist for racks that this missile can load into.
						["1xRK"] = true,
						["2xRK"] = true
					},

	seekcone           = 12,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
	viewcone           = 110,								-- getting outside this cone will break the lock.  Divided by 2.	--was 25
	SeekSensitivity    = 1,
	irccm				= false,

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

--AIM-120 Sparrow. A medium-Range AAM missile, perfect for those who really need a decent boom in a single pass. Just remember that this is not an AIM-9 and is better to aim before.
ACF_defineGun("AIM-120 AAM", {							-- id
	name             = "AIM-120 AMRAAM",
	desc             = "Faster than the AIM-9, but also a lot heavier. Burns hot and fast, with a good reach, but harder to lock with.  This long-range missile is sure to deliver one heck of a blast upon impact.Less agile than its smaller stablemate, so choose your shots carefully.\n\nInertial Guidance: Yes\nECCM: Yes\nDatalink: Yes\nTop Speed: 289 m/s",
	model            = "models/missiles/aim120c.mdl",
	effect           = "ACE_MissileMedium",
	effectbooster    = "ACE_MissileMedium",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 383,
	caliber          = 17.8,
	weight           = 152,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
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

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.1,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Radar"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {									-- a whitelist for racks that this missile can load into.
						["1xRK"] = true,
						["2xRK"] = true
					},

	seekcone           = 12,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
	viewcone           = 110,								-- getting outside this cone will break the lock.  Divided by 2.	--was 25
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

--AIM-54 phoenix. Being faster and bigger than AIM-120, can deliver a single big blast against the target, however, this 300kgs piece of aerial destruction has a serious trouble
--with its seek cone and is suggested to AIM before launching.
ACF_defineGun("AIM-54 AAM", {							-- id
	name             = "AIM-54 Phoenix",
	desc             = "Supersonic long-range air to air missile with early radar homing.Though relatively easy to dodge, this 300 kg beast will atomize any aircraft it hits. Getting hit is a traumatic experience. \n\nInertial Guidance: Yes\nECCM: No\nDatalink: Yes\nTop Speed: 191 m/s",
	model            = "models/missiles/arend/aim54c.mdl",
	effect           = "ACE_MissileLarge",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 153 * 2.53, --Convert to ammocrate units
	caliber          = 38.1,
	weight           = 463,								-- Don't scale down the weight though!
	year             = 1974,
	modeldiameter    = 30,--Already in ammocrate units
	bodydiameter     = 17.3, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/aim54c.mdl",
		rackmdl				= "models/missiles/arend/aim54c.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 60.0,


		--Formerly 396 and 5. Reduced blast from 5509Mj to 1303Mj. For reference a 500kg bomb has 2702Kj.
		maxlength			= 120,							-- Length of missile. Used for ammo properties.
		propweight			= 45,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 12,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection

		thrust				= 70,							-- Acceleration in m/s.
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
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent                = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance           = {"Dumb", "Radar"},
	fuses              = {"Contact", "Overshoot", "Radio", "Optical"},

	racks              = {["1xRK"] = true},					-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone           = 12,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)  --was 4
	viewcone           = 110,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 1,

	agility            = 3,									-- multiplier for missile turn-rate.  --was 0.7
	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.5,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.05									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("SRAAM AAM", {								-- id
	name             = "SRAAM",
	desc             = "Thrust vectoring absurdity. Shoots hot straight off the rails like some bat out of hell. Short range in every sense of the word but have fun dodging this one. Antimissile capable.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No\nTop Speed: 302 m/s",
	model            = "models/missiles/arend/sraam_unfolded.mdl",
	effect           = "ACE_MissileSmall",
	effectbooster    = "ACE_MissileSmall",
	gunclass         = "AAM",
	rack             = "2x SRAAM",							-- Which rack to spawn this missile on?
	length           = 115 * 2.53, --Convert to ammocrate units
	caliber          = 16.5,
	weight           = 70,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1984,
	modeldiameter    = 8,--Already in ammocrate units
	bodydiameter     = 8.9, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/sraam_unfolded.mdl",
		rackmdl				= "models/missiles/arend/sraam_folded.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.5,
		reloaddelay			= 45.0,

		maxlength			= 40,							-- Length of missile. Used for ammo properties.
		propweight			= 3,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.25,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 90,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 0.0,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 1.4,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0025,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Antimissile"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["2x SRAAM"] = true
			},


	seekcone           = 15,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 48,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 1,

	armdelay           = 0.15,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

-- The AIM-9 Sidewinder. The perfect choice for dogfights at short range. Although respectable payload, still tiny.
ACF_defineGun("Magic AAM", {								-- id
	name             = "R-550 Magic",
	desc             = "Short range air to air missile comparable to the sidewinder. Much more agile but less range and a smaller warhead.\n\nInertial Guidance: Yes\nECCM: Yes\nDatalink: No\nTop Speed: 151 m/s",
	model            = "models/missiles/arend/r550magic.mdl",
	effect           = "ACE_MissileSmall",
	effectbooster    = "ACE_MissileSmall",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 115 * 2.53, --Convert to ammocrate units
	caliber          = 15.7,
	weight           = 89,								-- Don't scale down the weight though!
	year             = 1968,
	modeldiameter    = 20, --Already in ammocrate units
	bodydiameter     = 8.1, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/r550magic.mdl",
		rackmdl				= "models/missiles/arend/r550magic.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.5,
		reloaddelay			= 45.0,

		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 3,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 320,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.8,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 0,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 50,							-- Acceleration in m/s.
		burntime			= 2,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 200,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.3,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.00075,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["1xRK_small"] = true
			},

	seekcone           = 15,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 48,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.15,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )


ACF_defineGun("MICA AAM", {								-- id
	name             = "MICA Missile",
	desc             = "Thrust vectoring short range air to air missile. Not quite as maneuverable as the R-73 but still remarkably agile. Capable of missile intercept. \n\nInertial Guidance: Yes\nECCM: Yes\nDatalink: Yes\nTop Speed: 189 m/s",
	model            = "models/missiles/arend/mica_em.mdl",
	effect           = "ACE_MissileSmall",
	effectbooster    = "ACE_MissileSmall",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 122 * 2.53, --Convert to ammocrate units
	caliber          = 16.0,
	weight           = 112,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1984,
	modeldiameter    = 15,--Already in ammocrate units
	bodydiameter     = 8.0, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/mica_em.mdl",
		rackmdl				= "models/missiles/arend/mica_em.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.5,
		reloaddelay			= 45.0,

		maxlength			= 80,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.55,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 20,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 55,							-- Acceleration in m/s.
		burntime			= 3.0,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Antimissile", "Radar"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["1xRK_small"] = true
			},


	seekcone           = 14,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 60,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.15,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("Meteor AAM", {							-- id
	name             = "Meteor Missile",
	desc             = "Long range ramjet proppeled missile. Takes a bit longer to get up to speed but much longer range and harder to overshoot. \n\nInertial Guidance: Yes\nECCM: Yes\nDatalink: Yes\nTop Speed: 236 m/s",
	model            = "models/missiles/arend/meteor.mdl",
	effect           = "ACE_MissileTiny",
	effectbooster    = "ACE_MissileTiny",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 143 * 2.53, --Convert to ammocrate units
	caliber          = 17.8,
	weight           = 190,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1991,
	modeldiameter    = 19,--Already in ammocrate units
	bodydiameter     = 9.3, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/meteor.mdl",
		rackmdl				= "models/missiles/arend/meteor.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 60.0,

		--Formerly 370 and 1. Reduced blast from 1059Mj to 215Mj. For reference a 250kg bomb has 224Kj.
		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 9,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 35,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.25,							--Fraction of speed redirected every second at max deflection

		thrust				= 65,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 30,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Radar"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {									-- a whitelist for racks that this missile can load into.
						["1xRK"] = true,
						["2xRK"] = true
					},

	seekcone           = 12,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
	viewcone           = 110,								-- getting outside this cone will break the lock.  Divided by 2.	--was 25
	SeekSensitivity    = 1,
	irccm				= true,

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("R-60 AAM", {								-- id
	name             = "R-60 Aphid",
	desc             = "Small early soviet air to air missile. Slow but has a good range. Don't expect to do much with its relatively puny warhead.\n\nInertial Guidance: No\nECCM: No\nDatalink: No\nTop Speed: 164 m/s",
	model            = "models/missiles/arend/r60m.mdl",
	effect           = "ACE_MissileSmall",
	effectbooster    = "ACE_MissileSmall",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 85 * 2.53, --Convert to ammocrate units,
	caliber          = 12.0,
	weight           = 44,								-- Don't scale down the weight though!
	year             = 1953,
	modeldiameter    = 13,--Already in ammocrate units
	bodydiameter     = 6.8, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/r60m.mdl",
		rackmdl				= "models/missiles/arend/r60m.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.5,
		reloaddelay			= 30.0,

		maxlength			= 50,							-- Length of missile. Used for ammo properties.
		propweight			= 1,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 15,							-- Armour effectiveness of casing, in mm

		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.35,							--Fraction of speed redirected every second at max deflection

		thrust				= 55,							-- Acceleration in m/s.
		burntime			= 8,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 200,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0005,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["4xRK"] = true,
				["1xRK_small"] = true
			},

	seekcone           = 15,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 60,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 1,

	armdelay           = 0.15,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )


ACF_defineGun("R-73 AAM", {								-- id
	name             = "R-73 Archer",
	desc             = "A monster in a dogfight. Compared to the Aim-9 this missile has a longer range and incredible offbore capability. But the IRCCM isn't as effective.\n\nInertial Guidance: Yes\nECCM: Narrow Seeker\nDatalink: No\nTop Speed: 188 m/s",
	model            = "models/missiles/arend/r73.mdl",
	effect           = "ACE_MissileSmall",
	effectbooster    = "ACE_MissileSmall",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 116 * 2.53, --Convert to ammocrate units
	caliber          = 16.5,
	weight           = 105,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1984,
	modeldiameter    = 15,--Already in ammocrate units
	bodydiameter     = 8.9, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/r73.mdl",
		rackmdl				= "models/missiles/arend/r73.mdl",
		firedelay			= 0.75,
		reloadspeed			= 1.5,
		reloaddelay			= 45.0,

		maxlength			= 80,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.55,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 30,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 60,							-- Acceleration in m/s.
		burntime			= 3.0,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 200,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
				["1xRK"] = true,
				["2xRK"] = true,
				["3xRK"] = true,
				["1xRK_small"] = true
			},


	--Doesn't use the IRCCM system. Instead has a narrower seek cone that makes it better able to filter flares.
	seekcone           = 7,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone           = 48,								-- getting outside this cone will break the lock.  Divided by 2.		--was 30
	SeekSensitivity    = 1,

	armdelay           = 0.15,								-- minimum fuse arming delay		--was 0.4
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("R-77 AAM", {							-- id
	name             = "R-77 Adder",
	desc             = "Counterpart to the aim-120. Very similar in performance but heavier but burns hot and fast.  This long-range missile is sure to deliver its payload fast.Less agile than its smaller stablemate, so choose your shots carefully. \n\nInertial Guidance: Yes\nECCM: Narrow Seeker\nDatalink: Yes\nTop Speed: 330 m/s",
	model            = "models/missiles/arend/r77.mdl",
	effect           = "ACE_MissileMedium",
	effectbooster    = "ACE_MissileMedium",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 142 * 2.53, --Convert to ammocrate units
	caliber          = 20,
	weight           = 175,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1994,
	modeldiameter    = 13,--Already in ammocrate units
	bodydiameter     = 10.8, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/r77.mdl",
		rackmdl				= "models/missiles/arend/r77.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 60.0,

		--Formerly 370 and 1. Reduced blast from 1059Mj to 215Mj. For reference a 250kg bomb has 224Kj.
		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 9,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 15,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.25,							--Fraction of speed redirected every second at max deflection

		thrust				= 130,							-- Acceleration in m/s.
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.1,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Radar"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {									-- a whitelist for racks that this missile can load into.
						["1xRK"] = true,
						["2xRK"] = true
					},

	--Doesn't use the IRCCM system. Instead has a narrower seek cone that makes it better able to filter flares.

	seekcone           = 5,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
	viewcone           = 27.5,								-- getting outside this cone will break the lock.  Divided by 2.	--was 25
	SeekSensitivity    = 1,

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("R-27 AAM", {							-- id
	name             = "R-27 Alamo",
	desc             = "Massive medium range AAM with an equally large warhead. Slower to start than the aim-120 but packs a powerful punch. \n\nInertial Guidance: Yes\nECCM: No\nDatalink: Yes\nTop Speed: 274 m/s",
	model            = "models/missiles/arend/r27t.mdl",
	effect           = "ACE_MissileMedium",
	effectbooster    = "ACE_MissileMedium",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 180 * 2.53, --Convert to ammocrate units
	caliber          = 23,
	weight           = 253,								-- Don't scale down the weight though! --was 152, I cut that down to 1/2 an AIM-7s weight
	year             = 1994,
	modeldiameter    = 28,--Already in ammocrate units
	bodydiameter     = 10.9, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/r27t.mdl",
		rackmdl				= "models/missiles/arend/r27t.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 45.0,

		--Formerly 370 and 1. Reduced blast from 1059Mj to 215Mj. For reference a 250kg bomb has 224Kj.
		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 9,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.3,							--Fraction of speed redirected every second at max deflection

		thrust				= 70,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 10,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 200,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.2,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0005,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Infrared", "Radar", "Semiactive"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},

	racks		= {									-- a whitelist for racks that this missile can load into.
						["1xRK"] = true,
						["2xRK"] = true
					},

	seekcone           = 12,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 20
	viewcone           = 110,								-- getting outside this cone will break the lock.  Divided by 2.	--was 25
	SeekSensitivity    = 1,

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.25,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.075									-- Time where this missile will be unable to hit surfaces, in seconds
} )

ACF_defineGun("R-33 AAM", {							-- id
	name             = "R-33 Amos",
	desc             = "A supersonic long-range air to air missile. H E A V Y. Faster than its Aim-54 counterpart but with a weaker warhead. Will vaporize any aircraft it touches.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No\nTop Speed: 216 m/s",
	model            = "models/missiles/arend/r33.mdl",
	effect           = "ACE_MissileLarge",
	gunclass         = "AAM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 163 * 2.53, --Convert to ammocrate units
	caliber          = 38.0,
	weight           = 490,								-- Don't scale down the weight though!
	year             = 1981,
	modeldiameter    = 27,--Already in ammocrate units
	bodydiameter     = 16.6, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/arend/r33.mdl",
		rackmdl				= "models/missiles/arend/r33.mdl",
		firedelay			= 1.0,
		reloadspeed			= 1.5,
		reloaddelay			= 60.0,


		maxlength			= 110,							-- Length of missile. Used for ammo properties.
		propweight			= 40,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 9.5,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection

		thrust				= 90,							-- Acceleration in m/s.
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
		datalink			= true,
		predictiondelay		= 0.35							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
	},

	ent                = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance           = {"Dumb", "Radar"},
	fuses              = {"Contact", "Overshoot", "Radio", "Optical"},

	racks              = {["1xRK"] = true},					-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone           = 12,									-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)  --was 4
	viewcone           = 110,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 1,

	agility            = 3,									-- multiplier for missile turn-rate.  --was 0.7
	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3
	guidelay           = 0.5,								-- Required time (in seconds) for missile to start guiding at target once launched
	ghosttime          = 0.05									-- Time where this missile will be unable to hit surfaces, in seconds
} )