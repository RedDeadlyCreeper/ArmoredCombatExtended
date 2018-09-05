--define the class
ACF_defineGunClass("ATR", {
	spread = 0.2,
	name = "Anti Tank Rifle",
	desc = "Anti Tank rifles fire stupidly fast small bullets to penetrate light armor. I dare you to fire HVAP out of these.",
	muzzleflash = "30mm_muzzleflash_noscale",
	rofmod = 10,
	sound = "acf_extra/tankfx/gnomefather/7mm1.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("7.92mmATR", { --id
	name = "(+)7.92mm Anti Tank Rifle",
	desc = "The 7.92 Anti Tank Rifle is the desperate attempt of someone to fend off hordes of tracked beasts in the trenches",
	model = "models/tankgun/atrifle_792mm.mdl",
	gunclass = "ATR",
	caliber = 7.92,
	weight = 90,
	year = 1917,
	rofmod = 1,
	magsize = 5,
	magreload = 6,
	round = {
		maxlength = 14,
		propweight = 1.2
	}
} )

ACF_defineGun("14.5mmATR", { --id
	name = "(+)14.5mm Anti Tank Rifle",
	desc = "Commonly used by soviets as a budget way to kill expensive stuff, still worthless.",
	model = "models/tankgun/atrifle_145mm.mdl",
	gunclass = "ATR",
	caliber = 1.45,
	weight = 130,
	year = 1917,
	rofmod = 1,
	magsize = 5,
	magreload = 8,
	round = {
		maxlength = 23,
		propweight = 2.2
	}
} )

ACF_defineGun("20mmATR", { --id
	name = "(+)20mm Anti Tank Rifle",
	desc = "Collosal anti tank rifle, good for putting a hole through side armor at point blank, that is if you can carry it.",
	model = "models/tankgun/atrifle_20mm.mdl",
	gunclass = "ATR",
	caliber = 2,
	weight = 190,
	year = 1917,
	rofmod = 1,
	magsize = 5,
	magreload = 10,
	round = {
		maxlength = 24,
		propweight = 3.5
	}
} )
