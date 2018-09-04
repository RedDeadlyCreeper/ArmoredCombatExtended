--define the class
ACF_defineGunClass("RM", {
	spread = 0.4,
	name = "Rifled Mortar",
	desc = "Rifled Mortars are like their smooth counterparts but fire slower, are heavier, and are more accurate.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 2,
	sound = "weapons/ACF_Gun/mortar_new.wav",
	soundDistance = "Mortar.Fire",
	soundNormal = " "
} )

ACF_defineGun("50mmRM", { --id
	name = "50mm Rifled Mortar",
	desc = "The 50mm, why does this even exist?",
	model = "models/mortar/mini/mortar_80mm.mdl",
	gunclass = "RM",
	caliber = 5.0,
	weight = 48,
	rofmod = 1.4,
	year = 1930,
	round = {
		maxlength = 20,
		propweight = 0.037
	}
} )

--add a gun to the class
ACF_defineGun("60mmRM", { --id
	name = "60mm Rifled Mortar",
	desc = "The 60mm rifled mortar is for those that despise infantry but hate missing.",
	model = "models/mortar/mortar_60mm.mdl",
	gunclass = "RM",
	caliber = 6.0,
	weight = 70,
	rofmod = 1.4,
	year = 1930,
	round = {
		maxlength = 26,
		propweight = 0.050
	}
} )

ACF_defineGun("80mmRM", {
	name = "80mm Rifled Mortar",
	desc = "The 80mm is a good but hefty support weapon that makes infantry and stationary light emplacements cry.",
	model = "models/mortar/mortar_80mm.mdl",
	gunclass = "RM",
	caliber = 8.0,
	weight = 140,
	year = 1930,
	rofmod = 1.2,
	round = {
		maxlength = 35,
		propweight = 0.15 
	}
} )
	
ACF_defineGun("120mmRM", {
	name = "120mm Rifled Mortar",
	desc = "120mm Support mortar, good for precisely shelling the roofs of emplacements.",
	model = "models/mortar/mortar_120mm.mdl",
	gunclass = "RM",
	caliber = 12.0,
	weight = 690,
	year = 1935,
	rofmod = 1.2,
	round = {
		maxlength = 50,
		propweight = 0.20 
	}
} )
	
ACF_defineGun("150mmRM", {
	name = "150mm Rifled Mortar",
	desc = "For those who want to place an accurate round inside a pillbox.",
	model = "models/mortar/mortar_150mm.mdl",
	gunclass = "RM",
	caliber = 15.0,
	weight = 1350,
	year = 1945,
	rofmod = 1.2,
	round = {
		maxlength = 65,
		propweight = 0.28 
	}
} )

ACF_defineGun("200mmRM", {
	name = "200mm Rifled Mortar",
	desc = "For those who want to place an accurate heat round onto the roof of a heavily armored bunker.",
	model = "models/mortar/mortar_200mm.mdl",
	gunclass = "RM",
	caliber = 20.0,
	weight = 3000,
	year = 1940,
	rofmod = 1.2,
	round = {
		maxlength = 85,
		propweight = 0.39 
	}
} )


ACF_defineGun("280mmRM", {
	name = "280mm Rifled Mortar",
	desc = "For those that want to accurately remove the bunker entirely. Kind of pointless given its range.",
	model = "models/mortar/mortar_280mm.mdl",
	gunclass = "RM",
	caliber = 28.0,
	weight = 9500,
	year = 1945,
	rofmod = 1.2,
	round = {
		maxlength = 138,
		propweight = 0.462 
	}
} )

