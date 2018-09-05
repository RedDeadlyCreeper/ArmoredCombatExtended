--define the class
ACF_defineGunClass("HMG", {
	spread = 0.35,
	name = "Heavy Machinegun",
	desc = "Designed as autocannons for aircraft, HMGs are rapid firing, lightweight, and compact but sacrifice accuracy, magazine size, and reload times.  They excel at strafing and dogfighting.\nBecause of their long reload times and high rate of fire, it is best to aim BEFORE pushing the almighty fire switch.",
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.17,
	sound = "weapons/ACF_Gun/mg_fire3.wav",
	soundDistance = " ",
	soundNormal = " ",
	longbarrel = {
		index = 2, 
		submodel = 4, 
		newpos = "muzzle2"
	}
} )

--add a gun to the class
ACF_defineGun("(C)20mmHMG", {
	name = "(C)20mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 20mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	gunclass = "HMG",
	caliber = 2.0,
	weight = 240,
	year = 1935,
	rofmod = 1.7, --at 1.5, 675rpm; at 2.0, 480rpm
	magsize = 60,
	magreload = 13,
	round = {
		maxlength = 28,
		propweight = 0.10
	}
} )

ACF_defineGun("(C)30mmHMG", {
	name = "(C)30mm Heavy Machinegun",
	desc = "30mm shell chucker, light and compact. Your average cold war dogfight go-to.",
	model = "models/machinegun/machinegun_30mm_compact.mdl",
	gunclass = "HMG",
	caliber = 3.0,
	weight = 580,
	year = 1941,
	rofmod = 1.2, --at 1.05, 495rpm; 
	magsize = 40,
	magreload = 14,
	round = {
		maxlength = 34,
		propweight = 0.33
	}
} )

ACF_defineGun("(C)40mmHMG", {
	name = "(C)40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns.  Massively powerful with a killer reload and hefty ammunition requirements, it can pop even relatively heavy targets with ease.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	gunclass = "HMG",
	caliber = 4.0,
	weight = 900,
	year = 1955,
	rofmod = 1, --at 0.75, 455rpm
	magsize = 40,
	magreload = 15,
	round = {
		maxlength = 40,
		propweight = 0.87
	}
} )
	
--add a gun to the class
ACF_defineGun("20mmHMG", {
	name = "20mm Heavy Machinegun",
	desc = "The lightest of the HMGs, the 20mm has a rapid fire rate but suffers from poor payload size.  Often used to strafe ground troops or annoy low-flying aircraft.",
	model = "models/machinegun/machinegun_20mm_compact.mdl",
	gunclass = "HMG",
	caliber = 2.0,
	weight = 160,
	year = 1935,
	rofmod = 1.9, --at 1.5, 675rpm; at 2.0, 480rpm
	magsize = 15,
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
	gunclass = "HMG",
	caliber = 3.0,
	weight = 480,
	year = 1941,
	rofmod = 1.1, --at 1.05, 495rpm; 
	magsize = 12,
	magreload = 9,
	round = {
		maxlength = 37,
		propweight = 0.35
	}
} )

ACF_defineGun("40mmHMG", {
	name = "40mm Heavy Machinegun",
	desc = "The heaviest of the heavy machineguns.  Massively powerful with a killer reload and hefty ammunition requirements, it can pop even relatively heavy targets with ease.",
	model = "models/machinegun/machinegun_40mm_compact.mdl",
	gunclass = "HMG",
	caliber = 4.0,
	weight = 780,
	year = 1955,
	rofmod = 0.95, --at 0.75, 455rpm
	magsize = 10,
	magreload = 10,
	round = {
		maxlength = 42,
		propweight = 0.9
	}
} )