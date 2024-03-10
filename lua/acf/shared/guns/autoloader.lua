--define the class
ACF_defineGunClass("AL", {
	type = "Gun",
	spread = 0.1,
	name = "Autoloader",
	desc = ACFTranslation.GunClasses[3],
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 0.64,
	year = 1946,
	sound = "ace_weapons/multi_sound/100mm_multi.mp3",
	autosound = "acf_extra/tankfx/reload.wav",
	noloader = true,
} )

--add a gun to the class
ACF_defineGun("75mmAL", { --id
	name = "75mm Autoloading Cannon",
	desc = "A quick-firing 75mm gun, pops off a number of rounds in relatively short order.",
	model = "models/tankgun/tankgun_al_75mm.mdl",
	sound = "ace_weapons/multi_sound/75mm_multi.mp3",
	autosound = "acf_extra/tankfx/reload.wav",
	gunclass = "AL",
	caliber = 7.5,
	weight = 980,
	year = 1946,
	rofmod = 1,
	magsize = 12,
	magreload = 20,
	round = {
		maxlength = 78,
		propweight = 3.8
	}
} )

ACF_defineGun("100mmAL", {
	name = "100mm Autoloading Cannon",
	desc = "The 100mm is good for rapidly hitting medium armor, then running like your ass is on fire to reload.",
	model = "models/tankgun/tankgun_al_100mm.mdl",
	sound = "ace_weapons/multi_sound/100mm_multi.mp3",
	autosound = "acf_extra/tankfx/reload.wav",
	gunclass = "AL",
	caliber = 10.0,
	weight = 1800,
	year = 1956,
	rofmod = 0.8,
	magsize = 12,
	magreload = 25,
	round = {
		maxlength = 93,
		propweight = 9.5
	}
} )

ACF_defineGun("120mmAL", {
	name = "120mm Autoloading Cannon",
	desc = "The 120mm autoloader can do serious damage before reloading, but the reload time is killer.",
	model = "models/tankgun/tankgun_al_120mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	autosound = "acf_extra/tankfx/reload.wav",
	gunclass = "AL",
	caliber = 12.0,
	weight = 2700,
	year = 1956,
	rofmod = 0.8,
	magsize = 12,
	magreload = 30,
	round = {
		maxlength = 110,
		propweight = 18
	}
} )

ACF_defineGun("140mmAL", {
	name = "140mm Autoloading Cannon",
	desc = "The 140mm can shred a medium tank's armor with one magazine, and even function as shoot & scoot artillery, with its useful HE payload.",
	model = "models/tankgun/tankgun_al_140mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	autosound = "acf_extra/tankfx/reload.wav",
	gunclass = "AL",
	caliber = 14.0,
	weight = 4800,
	year = 1970,
	rofmod = 0.9,
	magsize = 12,
	magreload = 40,
	round = {
		maxlength = 127,
		propweight = 28
	}
} )


ACF_defineGun("170mmAL", {
	name = "170mm Autoloading Cannon",
	desc = "The 170mm can shred an average 40ton tank's armor with one magazine.",
	model = "models/tankgun/tankgun_al_170mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	autosound = "acf_extra/tankfx/reload.wav",
	gunclass = "AL",
	caliber = 17.0,
	weight = 12460,
	year = 1970,
	rofmod = 1,
	magsize = 12,
	magreload = 40,
	round = {
		maxlength = 154,
		propweight = 34
	}
} )

