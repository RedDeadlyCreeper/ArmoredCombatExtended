
--define the class
ACF_defineGunClass("NAV", {
	type           = "missile",
	spread         = 1,
	name           = "[NAV] - Naval Missiles",
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



ACF_defineGun("BGM-109 Tomahawk", {						-- id
	name             = "BGM-109 Tomahawk",
	desc             = "The gold standard of cruise missiles. Subsonic and long range. Though slow this ordinance has extreme range and good maneuverability. Good for removing distant targets. Cannot be updated after it has launched.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No\nTop Speed: 81 m/s",
	model            = "models/macc/tomahawk.mdl",
	effect           = "ACE_RocketBlackSmoke", --Rocket_Smoke_Trail
	effectbooster	 = "ACE_MissileLarge",
	gunclass         = "NAV",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 250 * 2.53, --Convert to ammocrate units
	caliber          = 35.56,
	weight           = 1600,							-- Don't scale down the weight though!
	year             = 1983,
	modeldiameter    = 30, --Already in ammocrate units
	bodydiameter     = 24.25, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rofmod           = 0.3,
	round = {
		rocketmdl			= "models/macc/tomahawk.mdl",
		rackmdl				= "models/macc/tomahawk_folded.mdl",
		firedelay			= 1.0,
		reloadspeed			= 5.0,
		reloaddelay			= 1.0,


		maxlength			= 220,							-- Length of missile. Used for ammo properties.
		propweight			= 0.001,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 40,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.7,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 30,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 15,							-- Acceleration in m/s.

		burntime			= 60,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 5,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 60,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 2,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0025,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= false,
		predictiondelay		= 0.1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(1),			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
		waterthrusttype 	= 1, 	--0-stops underwater, 1-booster only underwater - DEFAULT, 2-works above and below, 3-underwater only, 4-booster all and under thrust only
		pointcost			= 250
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "GPS", "GPS_TerrainAvoidant"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},
	groundclutterfactor = 0,						--Disables radar ground clutter for millimeter wave radar guidance.

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["1xVLS"] = true,
					["1xmVLS"] = true,
					["4xVLS"] = true,
					["4xmVLS"] = true
				},

	seekcone   = 2,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone   = 30,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3

} )


ACF_defineGun("AGM-84 Harpoon", {						-- id
	name             = "AGM-84 Harpoon",
	desc             = "Versatile subsonic anti ship missile. Though somewhat sluggish packs a wallop.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No\nTop Speed: 81 m/s",
	model            = "models/missiles/1xagm84.mdl",
	effect           = "ACE_RocketBlackSmoke", --Rocket_Smoke_Trail
	effectbooster	 = "ACE_MissileMedium",
	gunclass         = "NAV",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 150 * 2.53, --Convert to ammocrate units
	caliber          = 35.56,
	weight           = 1600,							-- Don't scale down the weight though!
	year             = 1983,
	modeldiameter    = 25, --Already in ammocrate units
	bodydiameter     = 15.25, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rofmod           = 0.3,
	round = {
		rocketmdl			= "models/missiles/1xagm84.mdl",
		rackmdl				= "models/missiles/1xagm84.mdl",
		firedelay			= 1.0,
		reloadspeed			= 5.0,
		reloaddelay			= 1.0,


		maxlength			= 100,							-- Length of missile. Used for ammo properties.
		propweight			= 0.001,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.7,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 30,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 14,							-- Acceleration in m/s.

		burntime			= 60,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 15,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 60,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 2,							-- Time in seconds for booster runtime
		boostdelay			= 0.25,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0025,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		datalink			= false,
		predictiondelay		= 0.1,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(1),			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
		waterthrusttype 	= 1, 	--0-stops underwater, 1-booster only underwater - DEFAULT, 2-works above and below, 3-underwater only, 4-booster all and under thrust only
		pointcost			= 1000
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Infrared", "Radar"},
	fuses      = {"Contact", "Overshoot", "Radio", "Optical"},
	groundclutterfactor = 0,						--Disables radar ground clutter for millimeter wave radar guidance.

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["1xVLS"] = true,
					["1xmVLS"] = true,
					["4xVLS"] = true,
					["4xmVLS"] = true
				},

	seekcone   = 2,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone   = 30,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay           = 0.15,								-- minimum fuse arming delay --was 0.3

} )