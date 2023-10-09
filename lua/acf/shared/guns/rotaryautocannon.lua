--define the class
ACF_defineGunClass("RAC", {
	type = "Gun",
	spread = 0.35,
	name = "Rotary Autocannon",
	desc = ACFTranslation.GunClasses[11],
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.07,
	year = 1962,
	sound = "weapons/acf_gun/mg_fire2.wav",
	noloader = true,

	color = {135, 135, 135}
} )

ACF_defineGun("14.5mmRAC", { --id
	name = "14.5mm Rotary Autocannon",
	desc = "A lightweight rotary autocannon, a great support weapon for effortlessly shredding infantry and technicals alike.",
	model = "models/rotarycannon/kw/14_5mmrac.mdl",
	sound = "ace_weapons/multi_sound/12_7mm_multi.mp3",
	gunclass = "RAC",
	caliber = 1.45,
	weight = 160,
	year = 1962,
	rofmod = 2.6,
	round = {
		maxlength = 25,
		propweight = 0.06
	}
} )

ACF_defineGun("20mmRAC", {
	name = "20mm Rotary Autocannon",
	desc = "The 20mm is able to chew up light armor with decent penetration or put up a big flak screen. Typically mounted on ground attack aircraft, SPAAGs and the ocassional APC.",
	model = "models/rotarycannon/kw/20mmrac.mdl",
	sound = "ace_weapons/multi_sound/20mm_hmg_multi.mp3",
	gunclass = "RAC",
	caliber = 2.0,
	weight = 420,
	year = 1965,
	rofmod = 1.65,
	round = {
		maxlength = 36,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmRAC", {
	name = "30mm Rotary Autocannon",
	desc = "The 30mm is the bane of ground-attack aircraft, able to tear up light armor without giving one single fuck.  Also seen in the skies above dead T-72s.",
	model = "models/rotarycannon/kw/30mmrac.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "RAC",
	caliber = 3.0,
	weight = 610,
	year = 1975,
	rofmod = 0.93,
	round = {
		maxlength = 45,
		propweight = 0.350
	}
} )
