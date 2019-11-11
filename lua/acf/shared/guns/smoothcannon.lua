if ACF.EnableNewContent then

--define the class
ACF_defineGunClass("SBC", {
	spread = 0.24,
	name = "Smooth-Bore Cannon",
	desc = "High velocity guns that Fire slower and are heavier due to more reinforced cannon barrels than their counterparts. They fire fin stabilized ammo and as of such are also more accurate than their counterparts.",
	muzzleflash = "120mm_muzzleflash_noscale",
	rofmod = 1.7,
	sound = "weapons/ACF_Gun/cannon_new.wav",
	year = 1960,
	soundDistance = "Cannon.Fire",
	soundNormal = " "
} )

--add a gun to the class
	
ACF_defineGun("100mmSBC", {
	name = "100mm Smoothbore Cannon",
	desc = "100mm Smoothbore, a great cannon for a light tank or tank destroyer",
	model = "models/tankgun_old/tankgun_100mm.mdl",
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
	model = "models/tankgun/tankgun_170mm.mdl",
	gunclass = "C",
	caliber = 17.0,
	weight = 12350,
	year = 1990,
	round = {
		maxlength = 180,
		propweight = 34
	}
} )
	

end