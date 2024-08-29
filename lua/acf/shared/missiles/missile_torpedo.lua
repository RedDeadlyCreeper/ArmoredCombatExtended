
--define the class
ACF_defineGunClass("Torpedo", {
	type           = "missile",
	spread         = 1,
	name           = "[Torp] - Underwater Torpedo",
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

ACF_defineGun("Black Shark Torp", {						-- id
	name             = "533mm Black Shark Torpedo",
	desc             = "Advanced heavyweight torpedo meant to strike fear into capital ships of all sizes.\n\nInertial Guidance: Yes\nECCM: Yes\nDatalink: No\nTop Speed: N/A m/s",
	model            = "models/missiles/aim9m.mdl",
	effect           = "ACE_TorpedoMedium",
	effectbooster    = "",
	gunclass         = "Torpedo",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 250 * 2.53, --Convert to ammocrate units,
	caliber          = 15, --Unfortunately caliber determines the minimum length even above the max length var. For now has to be set lower than 1:1
	weight           = 1200,								-- Don't scale down the weight though!
	rofmod           = 0.3,
	year             = 2015,
	modeldiameter    = 30,
	bodydiameter     = 32, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/missiles/blacksharkwass.mdl",
		rackmdl				= "models/missiles/blacksharkwass.mdl",
		firedelay			= 0.5,
		reloadspeed			= 6.0,
		reloaddelay			= 25.0,

		maxlength			= 175,							-- Length of missile. Used for ammo properties.
		propweight			= 0.001,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
		turnrate			= 6,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.5,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 0,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 100,							-- Acceleration in m/s.
		burntime			= 120,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 20,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		waterthrusttype 	= 4, 	--0-stops underwater, 1-booster only underwater - DEFAULT, 2-works above and below, 3-underwater only, 4-booster all and under thrust only
		pointcost			= 1500,
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb","Straight_Running","Acoustic_Straight","Wire"},
	fuses	= {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true
				},

	seekcone   = 45,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone   = 45,								-- getting outside this cone will break the lock.  Divided by 2.

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay           = 0.15								-- minimum fuse arming delay		--was 0.4
} )

ACF_defineGun("G7a Torp", {						-- id
	name             = "533mm G7a Torpedo",
	desc             = "Classic German U-boat torpedo. Fast, heavy hitting, but not particularly advanced.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No\nTop Speed: N/A m/s",
	model            = "models/missiles/aim9m.mdl",
	effect           = "ACE_TorpedoMedium",
	effectbooster    = "",
	gunclass         = "Torpedo",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 250 * 2.53, --Convert to ammocrate units,
	caliber          = 15, --Unfortunately caliber determines the minimum length even above the max length var. For now has to be set lower than 1:1
	weight           = 1538,								-- Don't scale down the weight though!
	rofmod           = 0.3,
	year             = 1934,
	modeldiameter    = 30,
	bodydiameter     = 32, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/macc/Torpedo_G7A.mdl",
		rackmdl				= "models/macc/Torpedo_G7A.mdl",
		firedelay			= 0.5,
		reloadspeed			= 6.0,
		reloaddelay			= 25.0,

		maxlength			= 250,							-- Length of missile. Used for ammo properties.
		propweight			= 0.001,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
		turnrate			= 2,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.5,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 0,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 150,							-- Acceleration in m/s.
		burntime			= 120,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 20,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		waterthrusttype 	= 4, 	--0-stops underwater, 1-booster only underwater - DEFAULT, 2-works above and below, 3-underwater only, 4-booster all and under thrust only
		pointcost			= 1000,
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb","Straight_Running"},
	fuses	= {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true
				},

	seekcone   = 25,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone   = 50,								-- getting outside this cone will break the lock.  Divided by 2.

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay           = 0.15								-- minimum fuse arming delay		--was 0.4
} )

ACF_defineGun("Mk13 Torp", {						-- id
	name             = "570mm Mk 13 Torpedo",
	desc             = "One of the most common aerial torpedoes of WW2. Used by the US. Has claimed many capital ships.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No\nTop Speed: N/A m/s",
	model            = "models/missiles/aim9m.mdl",
	effect           = "ACE_TorpedoMedium",
	effectbooster    = "",
	gunclass         = "Torpedo",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 125 * 2.53, --Convert to ammocrate units,
	caliber          = 15, --Unfortunately caliber determines the minimum length even above the max length var. For now has to be set lower than 1:1
	weight           = 1942,								-- Don't scale down the weight though!
	rofmod           = 0.3,
	year             = 2015,
	modeldiameter    = 30,
	bodydiameter     = 36, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/macc/Torpedo_MK13.mdl",
		rackmdl				= "models/macc/Torpedo_MK13.mdl",
		firedelay			= 0.5,
		reloadspeed			= 6.0,
		reloaddelay			= 25.0,

		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 0.001,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
		turnrate			= 16,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.5,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 0,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 60,							-- Acceleration in m/s.
		burntime			= 120,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 20,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		waterthrusttype 	= 4, 	--0-stops underwater, 1-booster only underwater - DEFAULT, 2-works above and below, 3-underwater only, 4-booster all and under thrust only
		pointcost			= 750,
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb","Straight_Running"},
	fuses	= {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true
				},

	seekcone   = 45,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone   = 45,								-- getting outside this cone will break the lock.  Divided by 2.

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay           = 0.15								-- minimum fuse arming delay		--was 0.4
} )