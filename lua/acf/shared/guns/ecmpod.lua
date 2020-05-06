--define the class
ACF_defineGunClass("ECM", {
	spread = 0,
	name = "ECM Pod",
	desc = "ECM Pods utilize battery charge to jam missiles and will have to cool down between charges.",
	muzzleflash = "",
	rofmod = 1,
	sound = "acf_extra/airfx/mobile_radar.wav",
	soundDistance = " ",
	soundNormal = " ",
	year = 9999999,	--Go away broken stuff
	ammoBlacklist   = {"AP", "APHE", "FL", "HE", "HEAT", "HP", "SM"} -- ok fun's over
} )

--add a gun to the class
ACF_defineGun("STDECM", { --id
	name = "Standard ECM Pod",
	desc = "Jam those incoming missiles!!! MUHAHAHAHAHAHA. Just hope you dont have to suffer through the 30 second recharge time.",
	model = "models/missiles/minipod.mdl",
	gunclass = "ECM",
	canparent = true,
	caliber = 8,
	rofmod = 0.15,
	weight = 108,
	magsize = 30,
	magreload = 30,
	year = 1980,
	round = {
		maxlength = 100,
		propweight = 100
	}
} )

/*
--add a gun to the class 
ACF_defineGun("LRGECM", { --id
	name = "Large ECM Pod",
	desc = "Jam ALL of those incoming missiles!!! MUAHAHAHAHAHAHA. Jams as long as charged however has an absurd 60 second reload. Jams missiles better than its smaller counterpart.",
	model = "models/missiles/ecm.mdl",
	gunclass = "ECM",
	canparent = true,
	caliber = 8,
	rofmod = 0.1,
	weight = 108,
	magsize = 80,
	magreload = 60,
	year = 1980,
	round = {
		maxlength = 100,
		propweight = 100
	}
} )
*/