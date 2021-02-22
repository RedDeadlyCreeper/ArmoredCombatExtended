--define the class
ACF_defineGunClass("GL", {
    type = "Gun",
	spread = 0.4,
	name = "Grenade Launcher",
	desc = ACFTranslation.GunClasses[6],
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 1,
	year = 1970,
	sound = "weapons/acf_gun/grenadelauncher.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("40mmGL", { --id
	name = "40mm Grenade Launcher",
	desc = "The 40mm chews up infantry but is about as useful as tits on a nun for fighting armor.  Often found on 4x4s rolling through the third world.",
	model = "models/launcher/40mmgl.mdl",
	gunclass = "GL",
	canparent = true,
	caliber = 4.0,
	weight = 55,
	magsize = 6,
	magreload = 7.5,
	year = 1970,
	round = {
		maxlength = 7.5,
		propweight = 0.01
	}
} )
if ACF.EnableNewContent then
ACF_defineGun("20mmGL", { --id
	name = "20mm Grenade Launcher",
	desc = "The 20mm is the embodyment of wimpy weapons, although it has a large clip and can fire HE it is bloody weak                            using 40mm GL as placeholder bc the 20mm mini is borked",
	model = "models/launcher/20mmgl.mdl",
	gunclass = "GL",
	canparent = true,
	caliber = 3.01,
	weight = 10,
	magsize = 24,
	magreload = 8,
	year = 1970,
	round = {
		maxlength = 5,
		propweight = 0.007
	}
} )

ACF_defineGun("40mmGLSingle", { --id
	name = "40mm Single Grenade Launcher",
	desc = "The 40mm grenade projecter excels at launching a small 40mm charge at nearby infantry or defending a tank from an incoming rocket.",
	model = "models/launcher/40mmsl.mdl",
	gunclass = "GL",
	caliber = 4.0,
	canparent = true,
	weight = 5,
	rofmod = 12,
	year = 1940,
	round = {
		maxlength = 35,
		propweight = 0.02
	}
} )
end