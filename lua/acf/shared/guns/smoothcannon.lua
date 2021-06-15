if ACF.EnableNewContent then

--define the class
ACF_defineGunClass("SBC", {
    type = "Gun",
	spread = 0.095,
	name = "Smooth-Bore Cannon",
	desc = ACFTranslation.GunClasses[15],
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.7,
	sound = "weapons/ACF_Gun/cannon_new.wav",
	year = 1960,
	soundDistance = "Cannon.Fire",
	soundNormal = " "
} )

--add a gun to the class

ACF_defineGun("50mmSBC", {
	name = "50mm Smoothbore Cannon",
	desc = "50mm Smoothbore, a very smoll gun for a light tank or tank destroyer",
	model = "models/tankgun_old/tankgun_50mm.mdl",
	canparent = true,
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
	desc = "75mm Smoothbore, a great cannon for a light tank or tank destroyer",
	model = "models/tankgun_old/tankgun_75mm.mdl",
	canparent = true,
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
	desc = "100mm Smoothbore, a great cannon for a light tank or tank destroyer",
	model = "models/tankgun_old/tankgun_100mm.mdl",
	canparent = true,
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
	desc = "120mm Smoothbore, powerful general purpose main battle tank cannon",
	model = "models/tankgun_old/tankgun_120mm.mdl",
	canparent = true,
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
	desc = "140mm Smoothbore, heavy railgun like cannon spawned out of a hatred of 60 tons. 'Your litterly removing the armor tool' -Anon",
	model = "models/tankgun_old/tankgun_140mm.mdl",
	canparent = true,
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
	model = "models/tankgun/tankgun_170mmsb.mdl",
	canparent = true,
	gunclass = "SBC",
	caliber = 17.0,
	weight = 12350,
	year = 1990,
	round = {
		maxlength = 180,
		propweight = 34
	}
} )
	

end