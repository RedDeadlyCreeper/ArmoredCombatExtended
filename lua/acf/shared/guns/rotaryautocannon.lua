--define the class
ACF_defineGunClass("RAC", {
	spread = 0.4,
	name = "Rotary Autocannon",
	desc = "Rotary Autocannons sacrifice weight, bulk and accuracy over classic Autocannons to get the highest rate of fire possible.",
	muzzleflash = "50cal_muzzleflash_noscale",
	rofmod = 0.07,
	sound = "weapons/acf_gun/mg_fire3.wav",
	soundDistance = " ",
	soundNormal = " ",
	color = {135, 135, 135}
} )

ACF_defineGun("14.5mmRAC", { --id
	name = "14.5mm Rotary Autocannon",
	desc = "A lightweight rotary autocannon, used primarily against infantry and light vehicles.  It has a lower firerate than its larger brethren, but a significantly quicker cooldown period as well.",
	model = "models/rotarycannon/kw/14_5mmrac.mdl",
	gunclass = "RAC",
	caliber = 1.45,
	weight = 240,
	year = 1962,
	magsize = 60,
	magreload = 6,
	rofmod = 5.4,
	round = {
		maxlength = 25,
		propweight = 0.06
	}
} )

ACF_defineGun("20mmRAC", {
	name = "20mm Rotary Autocannon",
	desc = "The 20mm is able to chew up light armor with decent penetration or put up a big flak screen. Typically mounted on ground attack aircraft, SPAAGs and the ocassional APC. Suffers from a moderate cooldown period between bursts to avoid overheating the barrels.",
	model = "models/rotarycannon/kw/20mmrac.mdl",
	gunclass = "RAC",
	caliber = 2.0,
	weight = 760,
	year = 1965,
	magsize = 40,
	magreload = 7,
	rofmod = 2.1,
	round = {
		maxlength = 30,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmRAC", {
	name = "30mm Rotary Autocannon",
	desc = "The 30mm is the bane of ground-attack aircraft, able to tear up light armor without giving one single fuck.  Also seen in the skies above dead T-72s.  Has a moderate cooldown period between bursts to avoid overheating the barrels.",
	model = "models/rotarycannon/kw/30mmrac.mdl",
	gunclass = "RAC",
	caliber = 3.0,
	weight = 1500,
	year = 1975,
	magsize = 40,
	magreload = 8,
	rofmod = 1,
	round = {
		maxlength = 40,
		propweight = 0.350
	}
} )


ACF_defineGun("20mmHRAC", {
	name = "20mm Heavy Rotary Autocannon",
	desc = "A reinforced, heavy-duty 20mm rotary autocannon, able to fire heavier rounds with a larger magazine.  Phalanx.",
	model = "models/rotarycannon/kw/20mmrac.mdl",
	gunclass = "RAC",
	caliber = 2.0,
	weight = 1200,
	year = 1981,
	magsize = 60,
	magreload = 4,
	rofmod = 2.5,
	round = {
		maxlength = 36,
		propweight = 0.12
	}
} )

ACF_defineGun("30mmHRAC", {
	name = "30mm Heavy Rotary Autocannon",
	desc = "A reinforced, heavy duty 30mm rotary autocannon, able to fire heavier rounds with a larger magazine.  Keeper of goals.",
	model = "models/rotarycannon/kw/30mmrac.mdl",
	gunclass = "RAC",
	caliber = 3.0,
	weight = 2850,
	year = 1985,
	magsize = 50,
	magreload = 6,
	rofmod = 1.2,
	round = {
		maxlength = 45,
		propweight = 0.350
	}
} )

ACF_defineGun("(C)14.5mmRAC", { --id
	name = "(C)14.5mm Rotary Autocannon",
	desc = "A lightweight rotary autocannon, a great support weapon for effortlessly shredding infantry and technicals alike.",
	model = "models/rotarycannon/kw/14_5mmrac.mdl",
	gunclass = "RAC",
	canparent = true,
	caliber = 1.45,
	weight = 340,
	year = 1962,
	magsize = 150,
	magreload = 6,
	rofmod = 4.3,
	round = {
		maxlength = 20.5,
		propweight = 0.05
	}
} )

ACF_defineGun("(C)20mmRAC", {
	name = "(C)20mm Rotary Autocannon",
	desc = "The 20mm is able to chew up light armor with decent penetration or put up a big flak screen. Typically mounted on ground attack aircraft, SPAAGs and the ocassional APC. Suffers from a moderate cooldown period between bursts to avoid overheating the barrels.",
	model = "models/rotarycannon/kw/20mmrac.mdl",
	gunclass = "RAC",
	caliber = 2.0,
	weight = 920,
	year = 1965,
	magsize = 70,
	magreload = 10,
	rofmod = 1.65,
	round = {
		maxlength = 30,
		propweight = 0.12
	}
} )

ACF_defineGun("(C)30mmRAC", {
	name = "(C)30mm Rotary Autocannon",
	desc = "The 30mm is the bane of ground-attack aircraft, able to tear up light armor without giving one single fuck.  Also seen in the skies above dead T-72s.  Has a moderate cooldown period between bursts to avoid overheating the barrels.",
	model = "models/rotarycannon/kw/30mmrac.mdl",
	gunclass = "RAC",
	caliber = 3.0,
	weight = 1680,
	year = 1975,
	magsize = 50,
	magreload = 8,
	rofmod = 0.93,
	round = {
		maxlength = 40,
		propweight = 0.350
	}
} )

ACF_defineGun("14.5mmHRAC", { --id
	name = "(+)14.5mm Heavy Rotary Autocannon",
	desc = "For those that want an even heavier machinegun capable of firing faster 14.5 rounds for all of eternity, great for scout helis",
	model = "models/rotarycannon/kw/14_5mmrac.mdl",
	gunclass = "RAC",
	caliber = 1.45,
	weight = 500,
	year = 1962,
	rofmod = 4.6,
	round = {
		maxlength = 21,
		propweight = 0.06
	}
} )

ACF_defineGun("(C)20mmHRAC", {
	name = "(C)20mm Heavy Rotary Autocannon",
	desc = "A reinforced, heavy-duty 20mm rotary autocannon, free of barrel heat issues and with an optimized ammo feed.  Keep the bullets flowing!",
	model = "models/rotarycannon/kw/20mmrac.mdl",
	gunclass = "RAC",
	caliber = 2.0,
	weight = 1280,
	year = 1965,
	rofmod = 2.2,
	round = {
		maxlength = 33,
		propweight = 0.12
	}
} )

ACF_defineGun("(C)30mmHRAC", {
	name = "(C)30mm Heavy Rotary Autocannon",
	desc = "A reinforced, heavy duty 30mm rotary autocannon, free of barrel heat issues and with an optimized ammo feed.  Let the bullets fly!",
	model = "models/rotarycannon/kw/30mmrac.mdl",
	gunclass = "RAC",
	caliber = 3.0,
	weight = 3850,
	year = 1975,
	rofmod = 1.3,
	round = {
		maxlength = 44,
		propweight = 0.350
	}
} )


