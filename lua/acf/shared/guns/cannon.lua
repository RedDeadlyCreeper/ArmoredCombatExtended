--define the class
ACF_defineGunClass("C", {
	type = "Gun",
	spread = 0.1,
	name = "Cannon",
	desc = ACFTranslation.GunClasses[4],
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.5,
	maxrof = 19, -- maximum rounds per minute
	sound = "ace_weapons/multi_sound/100mm_multi.mp3",

} )

--add a gun to the class
ACF_defineGun("37mmC", { --id
	name = "37mm Cannon",
	desc = "A light and fairly weak cannon with good accuracy.",
	model = "models/tankgun/tankgun_37mm.mdl",
	sound = "ace_weapons/multi_sound/50mm_multi.mp3",
	gunclass = "C",
	caliber = 3.7,
	weight = 95,
	year = 1919,
	rofmod = 1.4,
	maxrof = 42, -- maximum rounds per minute
	round = {
		maxlength = 48,
		propweight = 1.125
	}
} )

ACF_defineGun("50mmC", {
	name = "50mm Cannon",
	desc = "The 50mm is surprisingly fast-firing, with good effectiveness against light armor, but a pea-shooter compared to its bigger cousins",
	model = "models/tankgun/tankgun_50mm.mdl",
	sound = "ace_weapons/multi_sound/50mm_multi.mp3",
	gunclass = "C",
	caliber = 5.0,
	weight = 380,
	year = 1935,
	maxrof = 32, -- maximum rounds per minute
	round = {
		maxlength = 63,
		propweight = 2.1
	}
} )

ACF_defineGun("75mmC", {
	name = "75mm Cannon",
	desc = "The 75mm is still rather respectable in rate of fire, but has only modest payload.  Often found on the Eastern Front, and on cold war light tanks.",
	model = "models/tankgun/tankgun_75mm.mdl",
	sound = "ace_weapons/multi_sound/75mm_multi.mp3",
	gunclass = "C",
	caliber = 7.5,
	weight = 660,
	year = 1942,
	maxrof = 17, -- maximum rounds per minute
	round = {
		maxlength = 78,
		propweight = 3.8
	}
} )

ACF_defineGun("85mmC", {
	name = "85mm Cannon",
	desc = "Slightly better than 75, however may introduce problems to tanks, whose armor could stop 75mm. T-34-85 gun.",
	model = "models/tankgun/tankgun_85mm.mdl",
	sound = "ace_weapons/multi_sound/75mm_multi.mp3",
	gunclass = "C",
	caliber = 8.5,
	weight = 1030,
	year = 1944,
	maxrof = 15.5, -- maximum rounds per minute
	round = {
		maxlength = 85.5,
		propweight = 6.65
	}
} )

ACF_defineGun("100mmC", {
	name = "100mm Cannon",
	desc = "The 100mm was a benchmark for the early cold war period, and has great muzzle velocity and hitting power, while still boasting a respectable, if small, payload.",
	model = "models/tankgun/tankgun_100mm.mdl",
	sound = "ace_weapons/multi_sound/100mm_multi.mp3",
	gunclass = "C",
	caliber = 10.0,
	weight = 1400,
	year = 1944,
	maxrof = 14, -- maximum rounds per minute
	round = {
		maxlength = 93,
		propweight = 9.5
	}
} )

ACF_defineGun("120mmC", {
	name = "120mm Cannon",
	desc = "Often found in MBTs, the 120mm shreds lighter armor with utter impunity, and is formidable against even the big boys.",
	model = "models/tankgun/tankgun_120mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	gunclass = "C",
	caliber = 12.0,
	weight = 2100,
	year = 1955,
	maxrof = 10, -- maximum rounds per minute
	round = {
		maxlength = 110,
		propweight = 18
	}
} )

ACF_defineGun("140mmC", {
	name = "140mm Cannon",
	desc = "The 140mm fires a massive shell with enormous penetrative capability, but has a glacial reload speed and a very hefty weight.",
	model = "models/tankgun/tankgun_140mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	gunclass = "C",
	caliber = 14.0,
	weight = 3900,
	year = 1990,
	maxrof = 8, -- maximum rounds per minute
	round = {
		maxlength = 127,
		propweight = 28
	}
} )

ACF_defineGun("170mmC", {
	name = "170mm Cannon",
	desc = "The 170mm fires a gigantic shell with ginormous penetrative capability, but has a glacial reload speed and an extremely hefty weight.",
	model = "models/tankgun/tankgun_170mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	gunclass = "C",
	caliber = 17.0,
	weight = 7800,
	year = 1990,
	maxrof = 4, -- maximum rounds per minute
	round = {
		maxlength = 154,
		propweight = 34
	}
} )
