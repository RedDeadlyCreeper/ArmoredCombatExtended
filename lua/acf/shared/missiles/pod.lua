--define the class
ACF_DefineRackClass("POD", {
	spread		= 0.5,
	name			= "Rocket Pod",
	desc			= "An accurate, lightweight rocket launcher which can explode if its armour is pierced.",
	muzzleflash	= "40mm_muzzleflash_noscale",
	rofmod		= 2,
	sound		= "acf_extra/airfx/rocket_fire2.wav",
	soundDistance	= " ",
	soundNormal	= " ",

	hidemissile	= true,
	protectmissile  = true,

	reloadmul	= 8,
} )





-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("40mm7xPOD", {
	name		= "7x 40mm FFAR Pod",
	desc		= "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	model	= "models/missiles/launcher7_40mm.mdl",
	gunclass	= "POD",
	weight	= 20,
	year		= 1940,
	magsize	= 7,
	caliber	= 4,

	reloadmul	= 150,

	hidemissile	= false,
	protectmissile  = true,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(0,-2,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(0,-1,-1.733), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(0,1,-1.733), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = { ["pos"] = Vector(0,2,0),  ["pos"] = Vector(0,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = { ["pos"] = Vector(0,1,1.736), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile7"] = { ["pos"] = Vector(0,-1,1.736), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )



-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("70mm7xPOD", {
	name		= "7x 70mm FFAR Pod",
	desc		= "A lightweight pod for rockets which is vulnerable to shots and explosions.",
	model	= "models/missiles/launcher7_70mm.mdl",
	gunclass	= "POD",
	weight	= 40,
	year		= 1940,
	magsize	= 7,
	caliber	= 7,

	reloadmul	= 150,

	hidemissile	= false,
	protectmissile  = true,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(0,-3.5,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(0,-1.75,-3.033), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(0,1.75,-3.033), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = { ["pos"] = Vector(0,3.5,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = { ["pos"] = Vector(0,1.75,3.038), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile7"] = { ["pos"] = Vector(0,-1.75,3.038), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )



-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("1x BGM-71E", {
	name = "BGM-71E Single Tube",
	desc = "A single BGM-71E round.",
	model = "models/missiles/bgm_71e_round.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1970,
	magsize = 1,
	caliber = 13,

	whitelistonly	= true,
	protectmissile  = true,
	hidemissile	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(15.759,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )



-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("2x BGM-71E", {
	name = "BGM-71E 2x Rack",
	desc = "A BGM-71E rack designed to carry 2 rounds.",
	model = "models/missiles/bgm_71e_2xrk.mdl",
	gunclass = "POD",
	weight = 60,
	year = 1970,
	magsize = 2,
	caliber = 13,

	whitelistonly	= true,
	protectmissile  = true,
	hidemissile	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(23.639,4.728,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(23.639,-4.728,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )



-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("4x BGM-71E", {
	name = "BGM-71E 4x Rack",
	desc = "A BGM-71E rack designed to carry 4 rounds.",
	model = "models/missiles/bgm_71e_4xrk.mdl",
	gunclass = "POD",
	weight = 100,
	year = 1970,
	magsize = 4,
	caliber = 13,

	whitelistonly	= true,
	protectmissile  = true,
	hidemissile	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(23.639,4.728,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(23.639,-4.728,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(23.639,4.728,-11.426), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(23.639,-4.728,-11.426), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

-- MAKE SURE THE CALIBER MATCHES THE yeah yeah I know I can read the code mate whitelist only mmkay?
ACF_DefineRack("380mmRW61", {
	name		= "380mm rocket asisted mortar",
	desc		= "A lightweight pod for rocket-asisted mortars which is vulnerable to shots and explosions.",
	model	= "models/launcher/RW61.mdl",
	gunclass	= "POD",
	weight	= 600,
	year		= 1945,
	magsize	= 1,
	caliber	= 38,

	hidemissile	= false,
	whitelistonly	= true,
	protectmissile  = true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(8.387,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
	}
} )



-- New-old racks became pods:


ACF_DefineRack("3xUARRK", {
	name = "A-20 3x HVAR Rocket pod",
	desc = "A lightweight rack for bombs which is vulnerable to shots and explosions.",
	model	= "models/missiles/rk3uar.mdl",
	gunclass = "POD",
	weight = 150,
	year = 1941,
	magsize = 3,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(-6.759,0,9.09), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(-6.759,3.188,3.475), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(-6.759,-3.209,3.475), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
	}
} )

ACF_DefineRack("6xUARRK", {
	name = "M27 6x Artillery Launcher",
	desc = "6-pack of death, used to efficiently carry artillery rockets",
	model	= "models/missiles/6pod_rk.mdl",
	rackmdl	= "models/missiles/6pod_cover.mdl",
	gunclass = "POD",
	weight = 600,
	year = 1980,
	magsize = 6,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	inverted = true,

	mountpoints =
	{

		["missile1"] = { ["pos"] = Vector(0,-11.158,5.581), ["offset"] = Vector(0,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(0,0.129,5.581), ["offset"] = Vector(0,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(0,11.279,5.581), ["offset"] = Vector(0,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(0,-11.159,-5.512), ["offset"] = Vector(0,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = { ["pos"] = Vector(0,0.129,-5.512), ["offset"] = Vector(0,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = { ["pos"] = Vector(0,11.279,-5.512), ["offset"] = Vector(0,0.1,0), ["scaledir"] = Vector(0,0,0)},

	}
} )

ACF_DefineRack("1x FIM-92", {
	name = "Single Munition FIM-92 Rack",
	desc = "A FIM-92 rack designed to carry 1 missile.",
	model	= "models/missiles/fim_92_1xrk.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1984,
	magsize = 1,
	caliber = 11,
	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

ACF_DefineRack("2x FIM-92", {
	name = "Double Munition FIM-92 Rack",
	desc = "A FIM-92 rack designed to carry 2 missiles.",
	model	= "models/missiles/fim_92_2xrk.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1984,
	magsize = 2,
	caliber = 11,
	rofmod = 3,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,3.35,0.45), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(0,-3.35,0.45), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

ACF_DefineRack("4x FIM-92", {
	name = "Quad Munition FIM-92 Rack",
	desc = "A FIM-92 rack designed to carry 4 missile.",
	model	= "models/missiles/fim_92_4xrk.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1984,
	magsize = 4,
	caliber = 11,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,2.6,2.65), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(0,-2.6,2.65), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(0,2.6,-3.6), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(0,-2.6,-3.6), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )


ACF_DefineRack("1x Strela-1", {
	name = "Single Munition 9M31 Rack",
	desc = "An 9M31 rack designed to carry 1 missile.",
	model	= "models/missiles/9m31_rk1.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1968,
	magsize = 1,
	caliber = 12,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(44.124,2.646,0.132), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

ACF_DefineRack("2x Strela-1", {
	name = "Double Munition 9M31 Rack",
	desc = "An 9M31 rack designed to carry 2 missiles.",
	model	= "models/missiles/9m31_rk2.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1968,
	magsize = 2,
	caliber = 12,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(44.119,-5.592,0.132), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(44.119,10.967,0.132), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--strela-1
ACF_DefineRack("4x Strela-1", {
	name = "Quad Munition 9M31 Rack",
	desc = "An 9m31 rack designed to carry until 4 missiles.",
	model	= "models/missiles/9m31_rk4.mdl",
	gunclass = "POD",
	weight = 50,
	year = 1968,
	magsize = 4,
	caliber = 12,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(43.668,-42.664,3.738), ["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(43.668,-26.105,3.738), ["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(43.668,25.983,3.738), ["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(43.668,42.541,3.738), ["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--ataka tube
ACF_DefineRack("1x Ataka", {
	name = "Single Munition 9M120 Rack",
	desc = "An 9M120 rack designed to carry 1 missile.",
	model	= "models/missiles/9m120_rk1.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1968,
	magsize = 1,
	caliber = 13,

	protectmissile  = true,
	hidemissile	= true,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,3), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--spg9 tube
ACF_DefineRack("1x SPG9", {
	name = "SPG-9 Launch Tube",
	desc = "Launch tube for SPG-9 recoilless rocket.",
	model	= "models/spg9/spg9.mdl",
	gunclass = "POD",
	weight = 90,
	year = 1968,
	magsize = 1,
	caliber = 7.3,
	spread = 0.1,

	protectmissile  = true,
	hidemissile	= true,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

-- 1 Kornet tube
ACF_DefineRack("1x Kornet", {
	name       = "Kornet Launch Tube",
	desc       = "Launch tube for Kornet antitank missile.",
	model      = "models/kali/weapons/kornet/parts/9m133 kornet tube.mdl",
	gunclass   = "POD",
	weight     = 30,
	year       = 1994,
	magsize    = 1,
	caliber    = 15.2,

	protectmissile   = true,
	hidemissile      = true,
	whitelistonly    = true,

	mountpoints =
	{
		missile1 = { pos = Vector(0,0,0), scaledir = Vector(0,0,0) }
	}
} )

-- 2 Kornet tube
ACF_DefineRack("2x Kornet", {
	name       = "Kornet Launch Tube",
	desc       = "A double Launch tube for 2 Kornet missiles.",
	model      = "models/missiles/kornetrack2.mdl",
	gunclass   = "POD",
	weight     = 60,
	year       = 1994,
	magsize    = 2,
	caliber    = 15.2,

	protectmissile   = true,
	hidemissile      = true,
	whitelistonly    = true,

	mountpoints =
	{
		missile1 = { pos = Vector(2,-7.3,-1), scaledir = Vector(0,0,0) },
		missile2 = { pos = Vector(2,7.3,-1), scaledir = Vector(0,0,0) },
	}
} )

-- 4 Kornet tube
ACF_DefineRack("4x Kornet", {
	name       = "Kornet Launch Tube",
	desc       = "A Quad Launch tube for 4 Kornet missiles.",
	model      = "models/missiles/kornetrack4.mdl",
	gunclass   = "POD",
	weight     = 120,
	year       = 1994,
	magsize    = 4,
	caliber    = 15.2,

	protectmissile   = true,
	hidemissile      = true,
	whitelistonly    = true,

	mountpoints =
	{
		missile1 = { pos = Vector(-1,-7.3,4.5), scaledir = Vector(0,0,0) },
		missile2 = { pos = Vector(-1,7.3,4.5), scaledir = Vector(0,0,0) },
		missile3 = { pos = Vector(-1,-7.3,-6.5), scaledir = Vector(0,0,0) },
		missile4 = { pos = Vector(-1,7.3,-6.5), scaledir = Vector(0,0,0) },
	}
} )


--Zuni pod
ACF_DefineRack("127mm4xPOD", {
	name = "5.0 Inch Zuni Pod",
	desc = "LAU-10/A Pod for the Zuni rocket.",
	model	= "models/ghosteh/lau10.mdl",
	gunclass = "POD",
	weight = 100,
	year = 1957,
	magsize = 4,
	caliber = 12.7,

	protectmissile  = true,
	hidemissile	= false,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(5.2,2.75,2.65), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(5.2,-2.75,2.65), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(5.2,2.75,-2.83), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(5.2,-2.75,-2.83), ["scaledir"] = Vector(0,0,0)}
	}
} )

--9m311 pod
ACF_DefineRack("1x 9m311", {
	name = "9m311 Round",
	desc = "A single 9m311 round.",
	model = "models/missiles/bgm_71e_round.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1970,
	magsize = 1,
	caliber = 12,

	whitelistonly	= true,
	protectmissile  = true,
	hidemissile	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(15.759,0,0), ["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--Javelin pod. Using the unfixed model since in the new one, missile is created at 90° degrees from original direction. I wonder why.
ACF_DefineRack("1x Javelin", {
	name = "FGM-148 Javelin Launch Tube",
	desc = "A launch tube designed for the javelin.",
	model = "models/mac/Javelin_straight.mdl",
	gunclass = "POD",
	weight = 6.4,
	year = 1989,
	magsize = 1,
	caliber = 12.7,

	protectmissile  = true,
	hidemissile	= true,
	whitelistonly	= true,

	mountpoints =
	{
		["missile1"] = { ["pos"] = Vector(0,0,0), ["offset"] = Vector(0,-1.38,2.4), ["scaledir"] = Vector(0,0,0)}
	}
} )
