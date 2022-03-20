--define the class
ACF_defineGunClass("SBC", {
    type = "Gun",
	spread = 0.095,
	name = "Smooth-Bore Cannon",
	desc = ACFTranslation.GunClasses[15],
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.7,
	sound = "acf_extra/ace/weapons/cannon/125mm_1.wav",
	year = 1960,

} )

--add a gun to the class

ACF_defineGun("50mmSBC", {
	name = "50mm Smoothbore Cannon",
	desc = "A small, 50mm Smoothbore cannon, being able to be fitted into a very light tank, it's a decent weapon if you want to create a hole on those ww2 tonks.",
	model = "models/tankgun_new/tankgun_50mm.mdl",
	sound = "ace_weapons/multi_sound/50mm_multi.mp3",
	gunclass = "SBC",
	caliber = 5.0,
	weight = 650,
	year = 1965,
	round = {
		maxlength = 63,
		propweight = 2.1
	}
} )

ACF_defineGun("75mmSBC", {
	name = "75mm Smoothbore Cannon",
	desc = "75mm Smoothbore cannon. The nightmare for those who think they are well armored.",
	model = "models/tankgun_new/tankgun_75mm.mdl",
	sound = "ace_weapons/multi_sound/75mm_multi.mp3",
	gunclass = "SBC",
	caliber = 7.5,
	weight = 900,
	year = 1960,
	round = {
		maxlength = 78,
		propweight = 3.8
	}
} )
	
ACF_defineGun("100mmSBC", {
	name = "100mm Smoothbore Cannon",
	desc = "100mm Smoothbore cannon, with good penetration performance, can perform a deadly strike in one single pass. Seen on those modern tank destroyers.",
	model = "models/tankgun_new/tankgun_100mm.mdl",
	sound = "ace_weapons/multi_sound/100mm_multi.mp3",
	gunclass = "SBC",
	caliber = 10.0,
	weight = 1700,
	year = 1960,
	round = {
		maxlength = 93,
		propweight = 20
	}
} )
	
ACF_defineGun("120mmSBC", {
	name = "120mm Smoothbore Cannon",
	desc = "120mm Smoothbore cannon, powerful general purpose main battle tank cannon",
	model = "models/tankgun_new/tankgun_120mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	gunclass = "SBC",
	caliber = 12.0,
	weight = 3200,
	year = 1970,
	round = {
		maxlength = 115,
		propweight = 30
	}
} )
	
ACF_defineGun("140mmSBC", {
	name = "140mm Smoothbore Cannon",
	desc = "140mm Smoothbore cannon, heavy railgun like cannon spawned out of a hatred of 60 tons. 'Your litterly removing the armor tool' -Anon",
	model = "models/tankgun_new/tankgun_140mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	gunclass = "SBC",
	caliber = 14.0,
	weight = 4300,
	year = 1995,
	round = {
		maxlength = 140,
		propweight = 60
	}
} )


ACF_defineGun("170mmSBC", {
	name = "170mm Smoothbore Cannon",
	desc = "Some might laugh at those who choose to forego armor. The 170mm laughs at anyone as it casually tears all tanks alike to shreds.",
	model = "models/tankgun_new/tankgun_170mm.mdl",
	sound = "ace_weapons/multi_sound/120mm_multi.mp3",
	gunclass = "SBC",
	caliber = 17.0,
	weight = 12350,
	year = 1990,
	round = {
		maxlength = 180,
		propweight = 34
	}
} )