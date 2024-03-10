--define the class
ACF_defineGunClass("FGL", {
	type = "Gun",
	spread = 3,
	name = "Flare Launcher",
	desc = ACFTranslation.GunClasses[5],
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 0.6,
	year = 1970,
	sound = "acf_extra/tankfx/flare_launch.wav",

	ammoBlacklist	= {"AP", "APHE", "FL", "HE", "HEAT", "HP", "SM"} -- ok fun's over
} )

--add a gun to the class
ACF_defineGun("40mmFGL", { --id
	name = "40mm Flare Launcher",
	desc = "Put on an all-American fireworks show with this flare launcher: high fire rate, low distraction rate.  Fill the air with flare.  Careful of your reload time.",
	model = "models/missiles/blackjellypod.mdl",
	sound = "acf_extra/tankfx/flare_launch.wav",
	gunclass = "FGL",
	caliber = 4.0,
	weight = 75,
	magsize = 30,
	magreload = 40,
	year = 1970,
	round = {
		maxlength = 9,
		propweight = 0.007
	}
} )
