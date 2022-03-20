--define the class
ACF_defineGunClass("HMG", {
    type = "Gun",
	spread = 0.4,
	name = "Heavy Machinegun",
	desc = ACFTranslation.GunClasses[7],
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.17,
	year = 1935,
	sound = "weapons/ACF_Gun/mg_fire3.wav",

	longbarrel = {
		index = 2, 
		submodel = 4, 
		newpos = "muzzle2"
	}
} )

ACF_defineGun("30mmHMGShort", {
	name = "Shortened 30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Great for lobbing mid sized HE shells at infantry.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "HMG",
	caliber = 3.01,
	weight = 140,
	year = 1941,
	rofmod = 1.8, --at 1.05, 495rpm; 
	round = {
		maxlength = 25,
		propweight = 0.03
	}
} )

ACF_defineGun("40mmHMGShort", {
	name = "Shortened 40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns. Lobs low velocity shells at a decent rof for its weight.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "HMG",
	caliber = 4.0,
	weight = 205,
	year = 1955,
	rofmod = 1.4, --at 0.75, 455rpm
	round = {
		maxlength = 32,
		propweight = 0.12
	}
} )
	
--add a gun to the class
ACF_defineGun("20mmHMG", {
	name = "20mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 20mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	sound = "ace_weapons/multi_sound/20mm_hmg_multi.mp3",
	gunclass = "HMG",
	caliber = 2.0,
	weight = 100,
	year = 1935,
	rofmod = 1.2, --at 1.5, 675rpm; at 2.0, 480rpm
	magsize = 60,
	magreload = 8,
	round = {
		maxlength = 30,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmHMG", {
	name = "30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Your average cold war dogfight go-to.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "HMG",
	caliber = 3.0,
	weight = 180,
	year = 1941,
	rofmod = 0.8, --at 1.05, 495rpm; 
	magsize = 50,
	magreload = 10,
	round = {
		maxlength = 37,
		propweight = 0.35
	}
} )

ACF_defineGun("40mmHMG", {
	name = "40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns.  Massively powerful with a killer reload and hefty ammunition requirements, it can pop even relatively heavy targets with ease.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "HMG",
	caliber = 4.0,
	weight = 340,
	year = 1955,
	rofmod = 0.95, --at 0.75, 455rpm
	magsize = 35,
	magreload = 10,
	round = {
		maxlength = 42,
		propweight = 0.9
	}
} )
