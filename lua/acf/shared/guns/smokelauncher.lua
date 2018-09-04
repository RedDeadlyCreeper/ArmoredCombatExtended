--define the class
ACF_defineGunClass("SL", {
	spread = 0.32,
	name = "Smoke Launcher",
	desc = "Smoke launcher to block an attacker's line of sight.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 45,
	sound = "weapons/acf_gun/smoke_launch.wav",
	soundDistance = "Mortar.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("40mmSL", { --id
	name = "40mm Smoke Launcher",
	desc = "",
	model = "models/launcher/40mmsl.mdl",
	gunclass = "SL",
	canparent = true,
	caliber = 4.0,
	rofmod = 0.6,
	weight = 5,
	year = 1941,
	round = {
		maxlength = 15,
		propweight = 0.00005 
	}
} )

ACF_defineGun("40mmSLMulti", { --id
	name = "40mm MultiBarrel Smoke Launcher",
	desc = "Parentable Multibarrel Smoke Launcher",
	model = "models/launcher/40mmgl.mdl",
	gunclass = "SL",
	canparent = true,
	caliber = 4.0,
	weight = 35,
	rofmod = 0.03,
	magsize = 6,
	magreload = 20,
	year = 1975,
	round = {
		maxlength = 15,
		propweight = 0.00005
	}
} )