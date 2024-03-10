
--define the class
ACF_defineGunClass("FFAR", {
	type			= "missile",
	spread		= 1,
	name			= "[FFAR] - Folding-Fin Aerial Rockets",
	desc			= ACFTranslation.MissileClasses[7],
	muzzleflash	= "40mm_muzzleflash_noscale",
	rofmod		= 1,
	year = 1960,
	sound		= "acf_extra/airfx/rocket_fire2.wav",
	soundDistance	= " ",
	soundNormal	= " ",
	effect		= "Rocket Motor FFAR"
} )




ACF_defineGun("40mmFFAR", { --id

	name		= "40mm Pod Rocket",
	desc		= "A tiny, unguided rocket.  Useful for anti-infantry, smoke and suppression.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model	= "models/missiles/launcher7_40mm.mdl",
	effect	= "Rocket Motor FFAR",
	caliber	= 4,
	gunclass	= "FFAR",
	rack		= "40mm7xPOD",  -- Which rack to spawn this missile on?
	weight	= 6,
	length	= 65, -- Length affects inertia calculations
	rofmod	= 0.1,
	year		= 1960,
	modeldiameter	= 2,
	round	=
	{
		model	= "models/missiles/ffar_40mm.mdl",
		rackmdl	= "models/missiles/ffar_40mm_closed.mdl",
		maxlength	= 60,
		casing	= 0.2,		-- thickness of missile casing, cm
		armour	= 5,			-- effective armour thickness of casing, in mm
		propweight  = 0.2,		-- motor mass - motor casing
		thrust	= 10000,		-- average thrust - kg * in/s ^ 2
		burnrate	= 120,		-- cm ^ 3/s at average chamber pressure
		starterpct  = 0.15,		-- percentage of the propellant consumed in the starter motor.
		minspeed	= 5000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
		dragcoefflight  = 0.02,				-- drag coefficient during flight
		finmul	= 0.003,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul	= math.sqrt(1)
	},

	ent		= "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb"},
	fuses	= {"Contact", "Timed"},

	racks	= {["40mm7xPOD"] = true},	-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	armdelay	= 0.00	-- minimum fuse arming delay
} )




ACF_defineGun("70mmFFAR", { --id

	name		= "70mm Pod Rocket",
	desc		= "A small, optionally guided rocket.  Useful against light vehicles and infantry.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model	= "models/missiles/launcher7_70mm.mdl",
	effect	= "Rocket Motor FFAR",
	caliber	= 7,
	gunclass	= "FFAR",
	rack		= "70mm7xPOD",  -- Which rack to spawn this missile on?
	weight	= 12,
	length	= 115,
	year		= 1960,
	rofmod	= 0.06,
	roundclass  = "Rocket",
	modeldiameter	= 3,
	round	=
	{
		model	= "models/missiles/ffar_70mm.mdl",
		rackmdl	= "models/missiles/ffar_70mm_closed.mdl",
		maxlength	= 90,
		casing	= 0.2,		-- thickness of missile casing, cm
		armour	= 8,			-- effective armour thickness of casing, in mm
		propweight  = 0.7,		-- motor mass - motor casing
		thrust	= 15000,		-- average thrust - kg * in/s ^ 2
		burnrate	= 300,		-- cm ^ 3/s at average chamber pressure
		starterpct  = 0.15,
		minspeed	= 4000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
		dragcoefflight  = 0.02,				-- drag coefficient during flight
		finmul	= 0.004,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul	= math.sqrt(0.8)	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent		= "acf_missile_to_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance	= {"Dumb", "Laser", "GPS"},
	fuses	= {"Contact", "Timed"},

	racks	= {["70mm7xPOD"] = true},	-- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	agility	= 0.08,	-- multiplier for missile turn-rate.

	seekcone	= 30,	-- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone	= 30,	-- getting outside this cone will break the lock.  Divided by 2.
	seeksensitivity = 0.5, --Less sophisticated seeker is better at close range

	armdelay	= 0.00	-- minimum fuse arming delay
} )
