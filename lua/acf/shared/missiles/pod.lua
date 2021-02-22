--define the class
ACF_DefineRackClass("POD", {
	spread          = 0.5,
	name            = "Rocket Pod",
	desc            = "An accurate, lightweight rocket launcher which can explode if its armour is pierced.",
	muzzleflash     = "40mm_muzzleflash_noscale",
	rofmod          = 2,
	sound           = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance   = " ",
	soundNormal     = " ",
    
    hidemissile     = true,
    protectmissile  = true,
    armour          = 15,
    
    reloadmul       = 8,
} )





-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("40mm7xPOD", {
	name        = "7x FFAR Pod (40mm)",
	desc        = "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	model		= "models/missiles/launcher7_40mm.mdl",
	gunclass    = "POD",
	weight      = 20,
	year        = 1940,
    magsize     = 7,
    armour      = 15,
    caliber     = 4,
    
    hidemissile     = false,
	protectmissile 	= true,
    whitelistonly   = true,

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile7"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )



-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("70mm7xPOD", {
	name        = "7x FFAR Pod (70mm)",
	desc        = "A lightweight pod for rockets which is vulnerable to shots and explosions.",
	model		= "models/missiles/launcher7_70mm.mdl",
	gunclass    = "POD",
	weight      = 40,
	year        = 1940,
    magsize     = 7,
    armour      = 24,
    caliber     = 7,

    hidemissile     = false,
	protectmissile 	= true,
    whitelistonly   = true,
    
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile7"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )



-- MAKE SURE THE CALIBER MATCHES THE ROCKETS YOU WANT TO LOAD!
ACF_DefineRack("1x BGM-71E", {
	name = "BGM-71E Round",
	desc = "A single BGM-71E round.",
	model = "models/missiles/bgm_71e_round.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1970,
    magsize = 1,
	armour  = 18,
    caliber = 13,

    whitelistonly   = true,
	protectmissile 	= true,
	hidemissile     = true,
    
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
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
	armour  = 18,
    caliber = 13,

    whitelistonly   = true,
	protectmissile 	= true,
	hidemissile     = true,
    
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
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
	armour  = 24,
    caliber = 13,

    whitelistonly   = true,
	protectmissile 	= true,
	hidemissile     = true,
    
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

-- MAKE SURE THE CALIBER MATCHES THE yeah yeah I know I can read the code mate whitelist only mmkay?
ACF_DefineRack("380mmRW61", {
	name        = "1x 380mm Pod",
	desc        = "A lightweight pod for rocket-asisted mortars which is vulnerable to shots and explosions.",
	model		= "models/launcher/RW61.mdl",
	gunclass    = "POD",
	weight      = 600,
	year        = 1945,
    magsize     = 1,
    armour      = 24,
    caliber     = 38,

    hidemissile     = false,
    whitelistonly   = true,
	protectmissile 	= true,
    
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
	}
} )



-- New-old racks became pods:


ACF_DefineRack("3xUARRK", {
	name = "A-20 3xHVAR Rack",
	desc = "A lightweight rack for bombs which is vulnerable to shots and explosions.",
	model		= "models/missiles/rk3uar.mdl",
	gunclass = "POD",
	weight = 150,
	year = 1941,
	armour  = 30,
    magsize = 3,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
	}
} )

ACF_DefineRack("6xUARRK", {
	name = "M27 6xS24 Rack",
	desc = "6-pack of death, used to efficiently carry artillery rockets",
	model		= "models/missiles/6pod_rk.mdl",
	rackmdl		= "models/missiles/6pod_cover.mdl",
	gunclass = "POD",
	weight = 600,
	year = 1980,
	armour  = 45,
    magsize = 6,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,

    mountpoints =
	{
		["missile1"] = {["offset"] = Vector(-3.075,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(-3.075,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(-3.075,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(-3.075,-.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(-3.075,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = {["offset"] = Vector(-3.075,0.1,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = {["offset"] = Vector(-3.075,0.1,0), ["scaledir"] = Vector(0,0,0)},
	}
} )

ACF_DefineRack("1x FIM-92", {
	name = "Single Munition FIM-92 Rack",
	desc = "An FIM-92 rack designed to carry 1 missile.",
	model		= "models/missiles/fim_92_1xrk.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1984,
    magsize = 1,
	armour  = 12,
	caliber = 11, 
	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

ACF_DefineRack("2x FIM-92", {
	name = "Double Munition FIM-92 Rack",
	desc = "An FIM-92 rack designed to carry 2 missiles.",
	model		= "models/missiles/fim_92_2xrk.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1984,
    magsize = 2,
	armour  = 16,
	caliber = 11,
	rofmod = 3,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	} 
} )

ACF_DefineRack("4x FIM-92", {
	name = "Double Munition FIM-92 Rack",
	desc = "An FIM-92 rack designed to carry 4 missile.",
	model		= "models/missiles/fim_92_4xrk.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1984,
    magsize = 4,
	armour  = 20,
	caliber = 11,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	} 
} )


ACF_DefineRack("1x Strela-1", {
	name = "Single Munition 9M31 Rack",
	desc = "An 9M31 rack designed to carry 1 missile.",
	model		= "models/missiles/9m31_rk1.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1968,
    magsize = 1,
	armour  = 50,
	caliber = 12,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

ACF_DefineRack("2x Strela-1", {
	name = "Double Munition 9M31 Rack",
	desc = "An 9M31 rack designed to carry 1 missile.",
	model		= "models/missiles/9m31_rk2.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1968,
    magsize = 2,
	armour  = 80,
	caliber = 12,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	} 
} )

--strela-1 
ACF_DefineRack("4x Strela-1", {
	name = "Quad Munition 9M31 Rack",
	desc = "An 9m31 rack designed to carry 4 missile.",
	model		= "models/missiles/9m31_rk4.mdl",
	gunclass = "POD",
	weight = 50,
	year = 1968,
    magsize = 4,
	armour  = 100,
	caliber = 12,
	
	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(0.5,0,0), ["scaledir"] = Vector(0,0,0)}
	} 
} )

--ataka tube
ACF_DefineRack("1x Ataka", {
	name = "Single Munition 9M120 Rack",
	desc = "An 9M120 rack designed to carry 1 missile.",
	model		= "models/missiles/9m120_rk1.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1968,
    magsize = 1,
	armour  = 50,
	caliber = 13,

	protectmissile  = true,
    hidemissile     = true,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--spg9 tube
ACF_DefineRack("1x SPG9", {
	name = "SPG-9 Launch Tube",
	desc = "Launch tube for SPG-9 recoilless rocket.",
	model		= "models/spg9/spg9.mdl",
	gunclass = "POD",
	weight = 90,
	year = 1968,
    magsize = 1,
	armour  = 30,
	caliber = 9.0,

	protectmissile  = true,
    hidemissile     = true,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--Kornet tube
ACF_DefineRack("1x Kornet", {
	name = "Kornet Launch Tube",
	desc = "Launch tube for Kornet antitank missile.",
	model = "models/kali/weapons/kornet/parts/9m133 kornet tube.mdl",
	gunclass = "POD",
	weight = 30,
	year = 1994,
    magsize = 1,
	armour  = 20,
	caliber = 15.2,

	protectmissile  = true,
    hidemissile     = true,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
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
	armour  = 40,
	caliber = 12.7,

	protectmissile  = true,
    hidemissile     = false,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(5.2,2.75,2.65), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(5.2,-2.75,2.65), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(5.2,2.75,-2.83), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(5.2,-2.75,-2.83), ["scaledir"] = Vector(0,0,0)}
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
	armour  = 18,
    caliber = 12,

    whitelistonly   = true,
	protectmissile 	= true,
	hidemissile     = true,
    
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )

--Javelin pod
ACF_DefineRack("1x Javelin", {
	name = "FGM-148 Javelin Launch Tube",
	desc = "A launch tube designed for the javelin.",
	model = "models/mac/Javelin_straight.mdl",
	gunclass = "POD",
	weight = 10,
	year = 1989,
    magsize = 1,
	armour  = 20,
	caliber = 12.7,

	protectmissile  = true,
    hidemissile     = true,
    whitelistonly   = true,
	
    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,-1.38,2.4), ["scaledir"] = Vector(0,0,0)}
	}
} )