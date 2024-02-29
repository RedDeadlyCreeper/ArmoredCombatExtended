
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
	name 			= "AGM-114 Hellfire Missile",
	desc 			= "The AGM-114 Hellfire is an air-to-surface missile first developed for anti-armor use, but later models were developed for precision strikes against other target types. Bringer of Hell.",
	model 			= "models/missiles/agm_114.mdl",
	effect			= "Rocket Motor ATGM",
	effectbooster	= "Rocket Motor Missile1",
	gunclass 		= "ASM",
	rack 			= "2x AGM-114",					-- Which rack to spawn this missile on?
	length 			= 163,
	caliber 		= 16,
	weight 			= 45,							-- Don't scale down the weight though!
	modeldiameter	= 3 * 2.54,					-- in cm
	bodydiameter	= 8.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	year			= 1984,

	round = {
		model				= "models/missiles/agm_114.mdl",
		rackmdl				= "models/missiles/agm_114.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 60.0,

		maxlength			= 150,							-- Length of missile. Used for ammo properties.
		propweight			= 1,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 21,							-- Armour effectiveness of casing, in mm

		turnrate			= 30,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.5,							--Fraction of speed redirected every second at max deflection

		thrust				= 0,							-- Acceleration in m/s.
		burntime			= 25,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 30,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 60,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 2.5,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.2,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul				= math.sqrt(0.518)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Laser", "Radar"},
	fuses      = {"Contact", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2x AGM-114"] = true,
					["4x AGM-114"] = true,

				},

	seekcone   = 2,
	viewcone   = 30,								-- getting outside this cone will break the lock.  Divided by 2.
	groundclutterfactor = 0,						--Disables radar ground clutter for millimeter wave radar guidance.
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay
} )

-- The 9M120 Ataka, a laser guided missile with high anti-tank effectiveness.
ACF_defineGun("Ataka ASM", { --id
	name			= "9M120 Ataka Missile",
	desc			= "The 9M120 Ataka is a high-speed anti tank missile used by soviet helicopters and ground vehicles.  It has very limited maneuverability but excellent range and speed, and can be armed with HE and HEAT warheads",
	model			= "models/missiles/9m120.mdl",
	effect			= "Rocket Motor ATGM",
	gunclass		= "ASM",
	rack			= "1x Ataka",							-- Which rack to spawn this missile on?
	length			= 174,
	caliber			= 13,
	weight			= 198,									-- Don't scale down the weight though!
	year			= 1984,
	modeldiameter	= 3 * 2.54,

	round = {
		model				= "models/missiles/9m120.mdl",
		rackmdl				= "models/missiles/9m120.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 40.0,

		maxlength			= 105,							-- Length of missile. Used for ammo properties.
		propweight			= 1.7,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 21,							-- Armour effectiveness of casing, in mm

		turnrate			= 2,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.35,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 14,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 70,							-- Acceleration in m/s.
		burntime			= 5,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 70,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.2,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		penmul			= math.sqrt(1.148)					-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)	--was 0.797
	},

	ent			= "acf_missile_to_rack",						-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser"},
	fuses		= {"Contact", "Optical"},

	racks	= {											-- a whitelist for racks that this missile can load into.
					["1x Ataka"] = true,
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true
				},

	seekcone		= 20,										-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone		= 40,										-- getting outside this cone will break the lock.  Divided by 2.

	guidanceInac	= 1, --50								-- How much inaccuracy this missile will have when its being guided. In units
	ghosttime		= 0.3,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay		= 0.00										-- minimum fuse arming delay
} )

--Sidearm, a lightweight anti-radar missile used by helicopters in the 80s
ACF_defineGun("AGM-122 ASM", {						-- id
	name             = "AGM-122 Sidearm Missile",
	desc             = "A refurbished early-model AIM-9, for attacking ground targets.  Less well-known than the bigger Shrike, it provides easy-to-use blind-fire anti-SAM performance for helicopters and light aircraft, with far heavier a punch than its ancestor.",
	model            = "models/missiles/aim9m.mdl",
	effect           = "Rocket Motor",
	effectbooster    = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",							-- Which rack to spawn this missile on?
	length           = 215,
	caliber          = 12.7,								-- Aim-9 is listed as 9 as of 6/30/2017, why?  Wiki lists it as a 5" rocket!
	weight           = 88,								-- Don't scale down the weight though!
	rofmod           = 0.3,
	year             = 1986,
	modeldiameter    = 3 * 2.25,
	bodydiameter     = 6, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rotmult          = 0.25,	-- Adjust this if you see that your missile falls too quickly. 0 to deny falling

	round = {
		rocketmdl			= "models/missiles/aim9m.mdl",
		rackmdl				= "models/missiles/aim9m.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 40.0,

		maxlength			= 140,							-- Length of missile. Used for ammo properties.
		propweight			= 4,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm
		turnrate			= 320,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.75,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 20,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		thrust				= 40,							-- Acceleration in m/s.
		burntime			= 1.5,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 300,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.45,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0005,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(0.4)				-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "AntiRadiation"},
	fuses	= {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true,
					["4xRK"] = true,
					["1xRK_small"] = true
				},

	seekcone   = 25,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone   = 50,								-- getting outside this cone will break the lock.  Divided by 2.

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay		--was 0.4
} )

-- The AGM-45 shrike, a vietnam war-era antiradiation missile built off the AIM-7 airframe.
ACF_defineGun("AGM-45 ASM", {						-- id
	name             = "AGM-45 Shrike Missile",
	desc             = "The body of an AIM-7 sparrow, an air-to-ground seeker kit, and a far larger warhead than its ancestor.\nWith its homing radar seeker option, thicker skin, and long range, it is a great weapon for long-range, precision standoff attack versus squishy things, like those pesky sam sites.",
	model            = "models/missiles/arend/aim7f.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 383,
	caliber          = 20.3,
	weight           = 177,							-- Don't scale down the weight though!
	modeldiameter    = 4 * 2.54,					-- in cm
	bodydiameter     = 9.7, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	year             = 1969,
	rofmod           = 0.6,

	round = {
		rocketmdl			= "models/missiles/arend/aim7f.mdl",
		rackmdl				= "models/missiles/arend/aim7f.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 60.0,

		maxlength			= 150,							-- Length of missile. Used for ammo properties.
		propweight			= 3,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm

		turnrate			= 30,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.4,							--Fraction of speed redirected every second at max deflection

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

		dragcoef			= 0.005,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(0.4)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "AntiRadiation"},
	fuses	= {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true
				},

	seekcone   = 15,									-- why do you need a big seeker cone if yuo're firing vs a SAM site?
	viewcone   = 40,								-- I don't think a fucking SAM site should have to dodge much >_>

	agility    = 0.03,								-- multiplier for missile turn-rate.  --was 0.08
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay
} )

-- The AGM-45 shrike, a vietnam war-era antiradiation missile built off the AIM-7 airframe.
ACF_defineGun("AGM-88 ASM", {						-- id
	name             = "AGM-88 HARM",
	desc             = "Advanced long range anti-radiation missile with improved guidance. Significantly heavier but makes up for it in range and tracking.",
	model            = "models/missiles/arend/agm-88.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 383,
	caliber          = 25.4,
	weight           = 360,							-- Don't scale down the weight though!
	modeldiameter    = 5 * 2.54,					-- in cm
	bodydiameter     = 11.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	year             = 1969,
	rofmod           = 0.6,

	round = {
		rocketmdl			= "models/missiles/arend/agm-88.mdl",
		rackmdl				= "models/missiles/arend/agm-88.mdl",
		firedelay			= 0.5,
		reloadspeed			= 1.0,
		reloaddelay			= 60.0,

		maxlength			= 150,							-- Length of missile. Used for ammo properties.
		propweight			= 3,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 25,							-- Armour effectiveness of casing, in mm

		turnrate			= 60,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.5,							--Fraction of speed redirected every second at max deflection

		thrust				= 100,							-- Acceleration in m/s.
		--120 seconds? Does it really have a 120 second burntime??? Not setting higher so people can't minimize proppelant
		burntime			= 20,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.0025,						-- percent speed loss per second
		inertialcapable		= false,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(0.6)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "AntiRadiation"},
	fuses	= {"Contact", "Overshoot", "Radio", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true
				},

	seekcone   = 15,									-- why do you need a big seeker cone if yuo're firing vs a SAM site?
	viewcone   = 60,								-- I don't think a fucking SAM site should have to dodge much >_>

	agility    = 0.03,								-- multiplier for missile turn-rate.  --was 0.08
	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00								-- minimum fuse arming delay
} )

ACF_defineGun("KH-31 ASM", {						-- id
	name             = "KH-31A",
	desc             = "Massive turbojet Antiradiation missile also used as antiship missile. It may be slower to get there but it HURTS. Mini Moskit.",
	model            = "models/missiles/arend/kh31.mdl",
	effect           = "Rocket_Smoke_Trail",
	effectbooster	 = "Rocket Motor",
	gunclass         = "ASM",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 469,
	caliber          = 35.56,
	weight           = 610,							-- Don't scale down the weight though!
	year             = 1974,
	modeldiameter    = 29.35,					-- in cm
	bodydiameter     = 15.4, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rofmod           = 0.3,
	round = {
		rocketmdl			= "models/missiles/arend/kh31.mdl",
		rackmdl				= "models/missiles/arend/kh31.mdl",
		firedelay			= 0.5,
		reloadspeed			= 2.0,
		reloaddelay			= 80.0,


		maxlength			= 220,							-- Length of missile. Used for ammo properties.
		propweight			= 5,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 60,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.7,							--Fraction of speed redirected every second at max deflection

		thrust				= 60,							-- Acceleration in m/s.

		burntime			= 15,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 200,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0.5,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.005,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(1)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb", "Radar", "AntiRadiation"},
	fuses      = {"Contact", "Optical"},
	groundclutterfactor = 0,						--Disables radar ground clutter for millimeter wave radar guidance.

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true
				},

	seekcone   = 2,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone   = 30,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00,								-- minimum fuse arming delay --was 0.3

} )

-- Maverick. A heavy missile which excels at destroying armoured ground targets. Used by ground attack aircrafts like the A-10
ACF_defineGun("AGM-65 ASM", {						-- id
	name             = "AGM-65 Maverick Missile",
	desc             = "You see that tank over there a mile away? I want you to lock onto it and forget about it.",
	model            = "models/missiles/arend/agm65d.mdl",
	effect           = "Rocket Motor Missile1",
	gunclass         = "ASM",
	rack             = "1xRK",						-- Which rack to spawn this missile on?
	length           = 253,
	caliber          = 30.5,
	weight           = 300,							-- Don't scale down the weight though!
	year             = 1974,
	modeldiameter    = 15.29,					-- in cm
	bodydiameter     = 14.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	rofmod           = 0.3,
	round = {
		rocketmdl			= "models/missiles/arend/agm65d.mdl",
		rackmdl				= "models/missiles/arend/agm65d.mdl",
		firedelay			= 0.5,
		reloadspeed			= 2.0,
		reloaddelay			= 80.0,


		maxlength			= 220,							-- Length of missile. Used for ammo properties.
		propweight			= 5,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 60,							-- Armour effectiveness of casing, in mm
								--320
		turnrate			= 120,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection

		thrust				= 50,							-- Acceleration in m/s.
		burntime			= 15,							-- time in seconds for rocket motor to burn at max proppelant.
		startdelay			= 0,

		launchkick			= 0,							-- Speed missile starts with on launch in m/s

		--Technically if you were crazy you could use boost instead of your rocket motor to get thrust independent of burn. Maybe on torpedoes.

		boostacceleration	= 0,							-- Acceleration in m/s of boost motor. Main Engine is not burning at this time.
		boostertime			= 0,							-- Time in seconds for booster runtime
		boostdelay			= 0,							-- Delay in seconds before booster activates.

		fusetime			= 19,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.005,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.25,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.
		penmul            = math.sqrt(1)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent        = "acf_missile_to_rack",				-- A workaround ent which spawns an appropriate rack for the missile.
	guidance   = {"Dumb" , "Infrared"},
	fuses      = {"Contact", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true
				},

	seekcone   = 4,								-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone   = 60,								-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime  = 0.2,									-- Time where this missile will be unable to hit surfaces, in seconds

	armdelay   = 0.00,								-- minimum fuse arming delay --was 0.3

} )