--define the class
ACF_defineGunClass("ATR", {
	spread = 0.2,
	name = "Anti-Tank Rifle",
	desc = "Anti Tank rifles fire stupidly fast small bullets to penetrate light armor. Built to fire HVAP out of these. Using placeholder models ATM.",
	muzzleflash = "30mm_muzzleflash_noscale",
	rofmod = 10,
	sound = "acf_extra/tankfx/gnomefather/7mm1.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("7.92mmATR", { --id
	name = "(+)7.92mm Anti Tank Rifle",
	desc = "The 7.92 Anti Tank Rifle is somone's desperate attempt to fend off hordes of tracked beasts in the trenches",
	model = "models/tankgun/atrifle_792mm.mdl",
	gunclass = "ATR",
	caliber = 0.792,
	weight = 90,
	year = 1917,
	rofmod = 1.2,
	magsize = 5,
	magreload = 6,
	round = {
		maxlength = 12,
		propweight = 1.7
	}
} )

ACF_defineGun("14.5mmATR", { --id
	name = "(+)14.5mm Anti Tank Rifle",
	desc = "Commonly used by soviets as a budget way to kill tanks, still worthless.",
	model = "models/tankgun/atrifle_145mm.mdl",
	gunclass = "ATR",
	caliber = 1.45,
	weight = 130,
	year = 1917,
	rofmod = 1.1,
	magsize = 5,
	magreload = 8,
	round = {
		maxlength = 19.5,
		propweight = 3.2
	}
} )

ACF_defineGun("20mmATR", { --id
	name = "(+)20mm Anti Tank Rifle",
	desc = "Collosal anti tank rifle, good for putting a hole through side armor at point blank, that is if you can carry it.",
	model = "models/machinegun/machinegun_20mm.mdl",
	gunclass = "ATR",
	caliber = 2,
	weight = 190,
	year = 1917,
	rofmod = 0.9,
	magsize = 5,
	magreload = 10,
	round = {
		maxlength = 22,
		propweight = 5.1
	}
} )
