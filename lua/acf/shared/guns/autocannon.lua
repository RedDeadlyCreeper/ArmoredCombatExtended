--define the class
ACF_defineGunClass("AC", {
	type = "Gun",
	spread = 0.14,
	name = "Autocannon",
	desc = ACFTranslation.GunClasses[2],
	muzzleflash = "30mm_muzzleflash_noscale",
	rofmod = 0.35,
	year = 1930,
	sound = "ace_weapons/multi_sound/30mm_multi.mp3",
	noloader = true,
} )

--add a gun to the class
ACF_defineGun("20mmAC", { --id
	name = "20mm Autocannon",
	desc = "The 20mm AC is the smallest of the family; having a good rate of fire but a tiny shell.",
	model = "models/autocannon/autocannon_20mm.mdl",
	sound = "ace_weapons/multi_sound/20mm_multi.mp3",
	caliber = 2.0,
	gunclass = "AC",
	nomag = true,
	weight = 170,
	year = 1930,
	rofmod = 1,
	round = {
		maxlength = 32,
		propweight = 0.13
	}
} )

ACF_defineGun("30mmAC", {
	name = "30mm Autocannon",
	desc = "The 30mm AC can fire shells with sufficient space for a small payload, and has modest anti-armor capability",
	model = "models/autocannon/autocannon_30mm.mdl",
	sound = "ace_weapons/multi_sound/30mm_multi.mp3",
	gunclass = "AC",
	nomag = true,
	caliber = 3.01,
	weight = 255,
	year = 1935,
	rofmod = 1,
	round = {
		maxlength = 39,
		propweight = 0.350
	}
} )

ACF_defineGun("40mmAC", {
	name = "40mm Autocannon",
	desc = "The 40mm AC can fire shells with sufficient space for a useful payload, and can get decent penetration with proper rounds.",
	model = "models/autocannon/autocannon_40mm.mdl",
	sound = "ace_weapons/multi_sound/40mm_multi.mp3",
	gunclass = "AC",
	nomag = true,
	caliber = 4.0,
	weight = 425,
	year = 1940,
	rofmod = 0.92,
	round = {
		maxlength = 45,
		propweight = 0.9
	}
} )

ACF_defineGun("50mmAC", {
	name = "50mm Autocannon",
	desc = "The 50mm AC fires shells comparable with the 50mm Cannon, making it capable of destroying light armour quite quickly.",
	model = "models/autocannon/autocannon_50mm.mdl",
	sound = "ace_weapons/multi_sound/50mm_multi.mp3",
	gunclass = "AC",
	nomag = true,
	caliber = 5.0,
	weight = 880,
	year = 1965,
	rofmod = 0.9,
	round = {
		maxlength = 52,
		propweight = 1.2
	}
} )

ACF_defineGun("20mmHAC", { --id
	name = "20mm Heavy Autocannon",
	desc = "The 20mm HAC is the smallest heavy autocannon, special watercooling allows this autocannon to continuously fire its nonexistant payload at extreme rates, great for attacking unarmored planes or cutting down forests.",
	model = "models/autocannon/autocannon_20mm_compact.mdl",
	sound = "ace_weapons/multi_sound/20mm_hmg_multi.mp3",
	gunclass = "AC",
	nomag = true,
	caliber = 2.0,
	weight = 320,
	year = 1960,
	rofmod = 0.8,
	round = {
		maxlength = 24,
		propweight = 0.13
	}
} )

ACF_defineGun("30mmHAC", {
	name = "30mm Heavy Autocannon",
	desc = "The watercooled 30mm HAC fires decently heavy shells at a rapid rate that are great for chewing through light armor",
	model = "models/autocannon/autocannon_30mm_compact.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "AC",
	nomag = true,
	caliber = 3.0,
	weight = 700,
	year = 1935,
	rofmod = 0.55,
	round = {
		maxlength = 28,
		propweight = 0.350
	}
} )

ACF_defineGun("40mmHAC", {
	name = "40mm Heavy Autocannon",
	desc = "The watercooled 40mm HAC is a long range grinder created in secrecy by light vehicles with very little patience",
	model = "models/autocannon/autocannon_40mm_compact.mdl",
	sound = "ace_weapons/multi_sound/30mm_hmg_multi.mp3",
	gunclass = "AC",
	nomag = true,
	caliber = 4.0,
	weight = 1400,
	year = 1000,
	rofmod = 0.55,
	round = {
		maxlength = 34,
		propweight = 0.9
	}
} )

