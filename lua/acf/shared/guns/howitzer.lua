--define the class
ACF_defineGunClass("HW", {
    type = "Gun",
	spread = 0.3,
	name = "Howitzer",
	desc = ACFTranslation.GunClasses[8],
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.5,
	year = 1900,
	sound = "weapons/ACF_Gun/howitzer_new2.wav",
	soundDistance = "Howitzer.Fire",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("75mmHW", { --id
	name = "75mm Howitzer",
	desc = "Often found being towed by large smelly animals, the 75mm has a high rate of fire, and is surprisingly lethal against light armor.  Great for a sustained barrage against someone you really don't like.",
	model = "models/howitzer/howitzer_75mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 7.5,
	weight = 550,
	year = 1900,
	round = {
		maxlength = 60,
		propweight = 1.8
	}
} )
	
ACF_defineGun("105mmHW", {
	name = "105mm Howitzer",
	desc = "The 105 lobs a big shell far, and its HEAT rounds can be extremely effective against even heavier armor.",
	model = "models/howitzer/howitzer_105mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 10.5,
	weight = 980,
	year = 1900,
	round = {
		maxlength = 86,
		propweight = 3.75
	}
} )

ACF_defineGun("122mmHW", {
	name = "122mm Howitzer",
	desc = "The 122mm bridges the gap between the 105 and the 155, providing a lethal round with a big splash radius.",
	model = "models/howitzer/howitzer_122mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 12.2,
	weight = 1450,
	year = 1900,
	round = {
		maxlength = 106,
		propweight = 7
	}
} )
	
ACF_defineGun("155mmHW", {
	name = "155mm Howitzer",
	desc = "The 155 is a classic heavy artillery round, with good reason.  A versatile weapon, it's found on most modern SPGs.",
	model = "models/howitzer/howitzer_155mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 15.5,
	weight = 2100,
	year = 1900,
	round = {
		maxlength = 124,
		propweight = 13.5
	}
} )
	
ACF_defineGun("203mmHW", {
	name = "203mm Howitzer",
	desc = "An 8-inch deck gun, found on siege artillery and cruisers.",
	model = "models/howitzer/howitzer_203mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 20.3,
	weight = 3900,
	year = 1900,
	round = {
		maxlength = 162.4,
		propweight = 28.5
	}
} )


ACF_defineGun("240mmHW", {
	name = "240mm Howitzer",
	desc = "A 9.4-inch deck gun, found on heavy siege artillery and cruisers.",
	model = "models/howitzer/howitzer_240mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 24.0,
	weight = 8000,
	year = 1900,
	round = {
		maxlength = 192.0,
		propweight = 33.7
	}
} )

ACF_defineGun("290mmHW", {
	name = "290mm Howitzer",
	desc = " Mother of all howitzers. This 12in beast was used to shell absurd underground compound. Using it is truly a warcrime.",
	model = "models/howitzer/howitzer_290mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 29,
	weight = 26800,
	year = 1900,
	round = {
		maxlength = 360,
		propweight = 57.0
	}
} )

ACF_defineGun("406mmHW", {
	name = "406mm Howitzer",
	desc = "The ultimate anti everything weapon, this absurd 16 inch gun can commonly be found on American Battleships and emplacements and its mere existence is a warcrime. HOW COULD YOU YOU MONSTER!",
	model = "models/howitzer/howitzer_406mm.mdl",
	gunclass = "HW",
	canparent = true,
	caliber = 40.6,
	weight = 50000,
	year = 1920,
	round = {
		maxlength = 540,
		propweight = 40000
	}
} )

