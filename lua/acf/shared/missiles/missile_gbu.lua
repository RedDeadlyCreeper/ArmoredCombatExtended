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

ACF_defineGun("227kgGBU", {						-- id
	name			= "227kg GBU-12 Paveway II",
	desc			= "Based on the Mk 82 500-pound general-purpose bomb, but with the addition of a nose-mounted laser seeker and fins for guidance.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No",
	model			= "models/bombs/gbu/gbu12.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 225,
	caliber		= 10.5,
	weight			= 227,							-- Don't scale down the weight though!
	year			= 1976,
	modeldiameter	= 12,					-- in cm
	bodydiameter     = 12.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/bombs/gbu/gbu12_fold.mdl",
		rackmdl				= "models/bombs/gbu/gbu12.mdl",
		firedelay			= 0.1,
		reloadspeed			= 0.3,
		reloaddelay			= 60.0,
		inaccuracy			= 2.0,

		maxlength			= 850,							-- Length of missile. Used for ammo properties.
		propweight			= 0,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 25,							-- Armour effectiveness of casing, in mm

		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 10,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.00075,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		pointcost			= 333,



		penmul      = math.sqrt(0.1)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true
				},

	seekcone	= 2,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 60,							-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime	= 0.5,									-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )

ACF_defineGun("454kgGBU", {						-- id
	name			= "454kg GBU-16 Paveway II",
	desc			= "Based on the Mk 83 general-purpose bomb, but with laser seeker and wings for guidance.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No",
	model			= "models/bombs/gbu/gbu16.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 264,
	caliber		= 17.0,
	weight			= 454,							-- Don't scale down the weight though!
	year			= 1976,
	modeldiameter	= 13,					-- in cm
	bodydiameter     = 13.8, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)

	round = {
		rocketmdl			= "models/bombs/gbu/gbu16_fold.mdl",
		rackmdl				= "models/bombs/gbu/gbu16.mdl",
		firedelay			= 0.1,
		reloadspeed			= 0.3,
		reloaddelay			= 80.0,
		inaccuracy			= 2.0,

		maxlength			= 830,							-- Length of missile. Used for ammo properties.
		propweight			= 0,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 10,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.00075,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		pointcost			= 833,

		penmul      = math.sqrt(0.15)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true
				},

	seekcone	= 2,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 60,							-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime	= 0.5,							-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )

ACF_defineGun("909kgGBU", {						-- id
	name			= "909kg GBU-10 Paveway II",
	desc			= "Based on the Mk 84 general-purpose bomb, but with laser seeker and wings for guidance.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No",
	model			= "models/bombs/gbu/gbu10.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 320,
	caliber		= 20.0,
	weight			= 909,							-- Don't scale down the weight though!
	year			= 1976,
	modeldiameter	= 20,					-- in cm
	round = {
		rocketmdl			= "models/bombs/gbu/gbu10_fold.mdl",
		rackmdl				= "models/bombs/gbu/gbu10.mdl",
		firedelay			= 0.1,
		reloadspeed			= 0.3,
		reloaddelay			= 100.0,
		inaccuracy			= 2.0,

		maxlength			= 1400,							-- Length of missile. Used for ammo properties.
		propweight			= 0,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 40,							-- Armour effectiveness of casing, in mm

		turnrate			= 50,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.65,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 10,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.00075,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		pointcost			= 1667,

		penmul      = math.sqrt(0.2)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.'
					["1xRK"] = true
				},

	seekcone	= 2,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 60,							-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime	= 0.5,							-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )

-- walleye: for fucking missile sites up
ACF_defineGun("WalleyeGBU", {						-- id
	name			= "Guided Weapon AGM-62 Walleye",
	desc			= "An early guided bomb of yield roughly between the 454kg and 1000kg, used over Vietnam by American strike aircraft and by other countries.  Unlike other GBUs, the larger fins let it glide more like an unpowered missile, allowing drops at far greater distances in a more stand-off role.  For this reason, it performs best when released at higher speeds.\nBecause of its large fins, obsolete guidance equipment, and thicker casing, it has greater size and weight than comparable guided bombs.\n\nInertial Guidance: Yes\nECCM: No\nDatalink: No",
	model			= "models/bombs/gbu/agm62.mdl",
	gunclass		= "GBU",
	rack			= "1xRK",						-- Which rack to spawn this missile on?
	length			= 346,
	caliber		= 31.8,						-- fat fucker, real diameter is 0.318m
	weight			= 1000,							-- 510kg
	year			= 1967,
	modeldiameter	= 30,					-- in cm
	bodydiameter     = 18.5, -- If this ordnance has fixed fins. Add this to count the body without finds, to ensure the missile will fit properly on the rack (doesnt affect the ammo dimension)
	round = {
		rocketmdl			= "models/bombs/gbu/agm62.mdl",
		rackmdl				= "models/bombs/gbu/agm62.mdl",
		firedelay			= 0.1,
		reloadspeed			= 0.3,
		reloaddelay			= 120.0,
		inaccuracy			= 2.0,

		maxlength			= 600,							-- Length of missile. Used for ammo properties.
		propweight			= 0,							-- Motor mass - motor casing. Used for ammo properties.

		armour				= 30,							-- Armour effectiveness of casing, in mm

		turnrate			= 40,							--Turn rate of missile at max deflection per 100 m/s
		finefficiency		= 0.5,							--Fraction of speed redirected every second at max deflection
		thrusterturnrate	= 10,							--Max turnrate from thrusters regardless of speed. Active only if the missile motor is active.

		fusetime			= 20,							--Time in seconds after launch/booster stop before missile scuttles

		dragcoef			= 0.001,						-- percent speed loss per second
		inertialcapable		= true,							-- Whether missile is capable of inertial guidance. Inertially guided missiles will follow their last track after losing the target. And can be fired offbore outside their seeker's viewcone.
		predictiondelay		= 0.5,							-- Delay before enabling missile steering guidance. Missile will run straight at the aimpoint until this time. Done to cause missile to not self delete because it tries to steer its velocity at launch.

		pointcost			= 1250,

		penmul      = math.sqrt(0.5)			-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack",			-- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS", "Infrared"},
	fuses	= {"Contact", "Timed", "Optical"},

	racks	= {									-- a whitelist for racks that this missile can load into.
					["1xRK"] = true,
					["2xRK"] = true,
					["3xRK"] = true
				},

	seekcone	= 6,							-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone	= 120,							-- getting outside this cone will break the lock.  Divided by 2.
	SeekSensitivity    = 5,

	ghosttime	= 0.5,							-- Time where this missile will be unable to hit surfaces, in seconds
	armdelay	= 0.00								-- minimum fuse arming delay
} )