--define the class
ACF_defineGunClass("MG", {
	type = "Gun",
	spread = 0.16,
	name = "Machinegun",
	desc = ACFTranslation.GunClasses[9],
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.9,
	year = 1910,
	sound = "ace_weapons/multi_sound/7_62mm_multi.mp3",
	noloader = true,

} )

--add a gun to the class
ACF_defineGun("7.62mmMG", { --id
	name = "7.62mm Machinegun",
	desc = "The 7.62mm is effective against infantry, but its usefulness against armor is laughable at best.",
	model = "models/machinegun/machinegun_762mm.mdl",
	sound = "ace_weapons/multi_sound/7_62mm_multi.mp3",
	gunclass = "MG",
	caliber = 0.762,
	weight = 10,
	year = 1930,
	rofmod = 1.2,
	round = {
		maxlength = 13,
		propweight = 0.04
	}
} )

ACF_defineGun("12.7mmMG", {
	name = "12.7mm Machinegun",
	desc = "The 12.7mm MG is still light, finding its way into a lot of mountings, including on top of tanks.",
	model = "models/machinegun/machinegun_127mm.mdl",
	sound = "ace_weapons/multi_sound/12_7mm_multi.mp3",
	gunclass = "MG",
	caliber = 1.27,
	weight = 20,
	year = 1910,
	rofmod = 0.74,
	round = {
		maxlength = 24,
		propweight = 0.1
	}
} )

ACF_defineGun("14.5mmMG", {
	name = "14.5mm Machinegun",
	desc = "The 14.5mm MG trades its smaller stablemates' rate of fire for more armor penetration and damage.",
	model = "models/machinegun/machinegun_145mm.mdl",
	sound = "ace_weapons/multi_sound/12_7mm_multi.mp3",
	gunclass = "MG",
	caliber = 1.45,
	weight = 25,
	year = 1932,
	rofmod = 0.75,
	round = {
		maxlength = 27,
		propweight = 0.04
	}
} )


ACF_defineGun("20mmMG", {
	name = "20mm Machinegun",
	desc = "The 20mm MG is practically a cannon in its own right; the weight and recoil made it difficult to mount on light land vehicles, though it was adapted for use on both aircraft and ships.",
	model = "models/machinegun/machinegun_20mm.mdl",
	sound = "ace_weapons/multi_sound/12_7mm_multi.mp3",
	gunclass = "MG",
	caliber = 2.0,
	weight = 35,
	year = 1935,
	rofmod = 0.55,
	round = {
		maxlength = 32,
		propweight = 0.09
	}
} )


