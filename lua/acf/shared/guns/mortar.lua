--define the class
ACF_defineGunClass("MO", {
    type = "Gun",
	spread = 0.7,
	name = "Mortar",
	desc = ACFTranslation.GunClasses[10],
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 2,
	year = 1915,
	sound = "weapons/ACF_Gun/mortar_new.wav",
	soundDistance = "Mortar.Fire",
	soundNormal = " "
} )

ACF_defineGun("60mmM", { --id
	name = "60mm Mortar",
	desc = "The 60mm is a common light infantry support weapon, with a high rate of fire but a puny payload.",
	model = "models/mortar/mortar_60mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 6.0,
	weight = 80,
	rofmod = 1.25,
	year = 1930,
	round = {
		maxlength = 30,
		propweight = 0.037
	}
} )

ACF_defineGun("80mmM", {
	name = "80mm Mortar",
	desc = "The 80mm is a common infantry support weapon, with a good bit more boom than its little cousin.",
	model = "models/mortar/mortar_80mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 8.0,
	weight = 210,
	year = 1915,
	round = {
		maxlength = 38,
		propweight = 0.055 
	}
} )
	
ACF_defineGun("120mmM", {
	name = "120mm Mortar",
	desc = "The versatile 120 is sometimes vehicle-mounted to provide quick boomsplat to support the infantry.  Carries more boom in its boomsplat, has good HEAT performance, and is more accurate in high-angle firing.",
	model = "models/mortar/mortar_120mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 12.0,
	weight = 440,
	year = 1935,
	round = {
		maxlength = 45,
		propweight = 0.175 
	}
} )
	
ACF_defineGun("150mmM", {
	name = "150mm Mortar",
	desc = "The perfect balance between the 120mm and the 200mm. Can prove a worthy main gun weapon, as well as a mighty good mortar emplacement",
	model = "models/mortar/mortar_150mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 15.0,
	weight = 680,
	year = 1945,
	round = {
		maxlength = 60,
		propweight = 0.235 
	}
} )

ACF_defineGun("200mmM", {
	name = "200mm Mortar",
	desc = "The 200mm is a beast, often used against fortifications.  Though enormously powerful, feel free to take a nap while it reloads",
	model = "models/mortar/mortar_200mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 20.0,
	weight = 980,
	year = 1940,
	round = {
		maxlength = 90,
		propweight = 0.330 
	}
} )

if ACF.EnableNewContent then


	ACF_defineGun("50mmM", { --id
	name = "50mm Mortar",
	desc = "The 50mm is an uncommon light mortar often seen at or before the begening of ww2, it fires a light 50mm rounds that is good for splatting infantry.",
	model = "models/mortar/mortar_50mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 5.0,
	weight = 40,
	rofmod = 1.25,
	year = 1930,
	round = {
		maxlength = 25,
		propweight = 0.03
	}
} )

ACF_defineGun("280mmM", {
	name = "280mm Mortar",
	desc = "Massive payload, with a reload time to match. Found in rare WW2 siege artillery pieces. It's the perfect size for a jeep.",
	model = "models/mortar/mortar_280mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 28.0,
	weight = 2000,
	year = 1945,
	round = {
		maxlength = 150,
		propweight = 0.462 
	}
} )

ACF_defineGun("380mmM", {
	name = "380mm Mortar",
	desc = "Massive payload, with a reload time to match. Found in rare WW2 siege artillery pieces.",
	model = "models/mortar/mortar_300mm.mdl",
	gunclass = "MO",
	canparent = true,
	caliber = 38.0,
	weight = 5000,
	year = 1941,
	round = {
		maxlength = 180,
		propweight = 0.562 
	}
} )
end