
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
	effect           = "Rocket_Smoke_Trail",
	effectbooster	= "Rocket Motor Arty",
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
		rocketmdl			= "models/missiles/glatgm/mgm51.mdl",
		rackmdl				= "models/missiles/glatgm/mgm51.mdl",
		firedelay			= 0.25,
		reloadspeed			= 0.5,
		reloaddelay			= 30.0,
		inaccuracy			= 2.0,

		maxlength			= 200,							-- Length of missile. Used for ammo properties.
		propweight			= 0.7,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm

		turnrate			= 0,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.35,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 15,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 25,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 20,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 120,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 1.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.003,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.




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

	viewcone   = 30,									-- cone radius, 180 = full 360 tracking
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.15									-- minimum fuse arming delay
} )



ACF_defineGun("SAKR-10 RA", {							-- id

	name             = "SAKR-10 Rocket",
	desc             = "A short-range but formidable artillery rocket, based upon the Grad.  Well suited to the backs of trucks.",
	model            = "models/missiles/9m31.mdl",
	effect           = "Rocket_Smoke_Trail",
	effectbooster	= "Rocket Motor Arty",
	caliber          = 12.2,
	gunclass         = "ARTY",
	rack             = "1xRK",								-- Which rack to spawn this missile on?
	weight           = 160,
	length           = 219, --320
	year             = 1980,
	roundclass       = "Rocket",
	modeldiameter    = 10,
	bodydiameter     = 7.3, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round	=	{
		rocketmdl			= "models/missiles/9m31.mdl",
		rackmdl				= "models/missiles/9m31.mdl",
		firedelay			= 0.35,
		reloadspeed			= 1.0,
		reloaddelay			= 40.0,
		inaccuracy			= 2.0,

		maxlength			= 210,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm

		turnrate			= 0,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.35,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 10,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 25,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 20,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 150,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 1.25,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.003,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

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

	viewcone   = 20,
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay	= 0.15									-- minimum fuse arming delay
} )



ACF_defineGun("SS-40 RA", {								-- id

	name             = "SS-40 Rocket",
	desc             = "A large, heavy, guided artillery rocket for taking out stationary or dug-in targets.  Slow to load, slow to fire, slow to guide, and slow to arrive.",
	model            = "models/missiles/aim120.mdl",
	effect           = "Rocket_Smoke_Trail",
	effectbooster	= "Rocket Motor Arty",
	caliber          = 18.0,
	gunclass         = "ARTY",
	rack             = "1xRK",								-- Which rack to spawn this missile on?
	weight           = 320,
	length           = 383,
	year             = 1983,
	roundclass       = "Rocket",
	modeldiameter    = 4 * 2.54,
	bodydiameter     = 9.2, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round	=	{
		rocketmdl			= "models/missiles/aim120.mdl",
		rackmdl				= "models/missiles/aim120.mdl",
		firedelay			= 0.25,
		reloadspeed			= 0.5,
		reloaddelay			= 50.0,
		inaccuracy			= 0.5,

		maxlength			= 180,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm

		turnrate			= 0,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.1,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 15,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 25,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 20,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 120,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 3,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.003,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

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

	viewcone   = 180,
	ghosttime  = 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay	= 0.15									-- minimum fuse arming delay
} )


ACF_defineGun("RW61 RA", {								-- id

	name             = "Raketwerfer-61",
	desc             = "A heavy, demolition-oriented rocket-assisted mortar, devastating against field works but takes a very, VERY long time to load.\n\n\nDon't miss.",
	model            = "models/missiles/RW61M.mdl",
	effect           = "Rocket_Smoke_Trail",
	effectbooster	= "Rocket Motor Arty",
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
		rocketmdl			= "models/missiles/RW61M.mdl",
		rackmdl				= "models/missiles/RW61M.mdl",
		firedelay			= 0.25,
		reloadspeed			= 0.2,
		reloaddelay			= 60.0,
		inaccuracy			= 0.1,

		maxlength			= 200,							-- Length of missile. Used for ammo properties.
		propweight			= 7,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 60,							-- Armour effectiveness of casing, in mm

		turnrate			= 0,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 0,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 25,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 75,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 120,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 1.5,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.004,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

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

	armdelay	= 0.15									-- minimum fuse arming delay
} )
