
ACF_DefineSonarClass("Sonar", {
	name = "Hull Sonar Array",
	type = "Sonar",
	desc = ACFTranslation.Sonar[1],
} )

--
ACF_DefineSonar("Tiny-Sonar", {
	name		= "Tiny Sonar Array",
	ent			= "ace_sonar",
	desc		= ACFTranslation.Sonar[5],
	model		= "models/props_c17/utilityconnecter006c.mdl",
	class		= "Sonar",
	weight		= 250,
	powerscale	= 0.34,--Multiplier for the energy of the sonar. The base range of sonar is (300m,200m,100m) for an omnidirectional ping and (600m,400m,200m) for a directed ping.
	noisemul	= 1.5, --Multiplier for the noise of the sonar.
	washoutfactor = 1.25, --Resistance to being washed out. 0.5 means washes out half as quickly. Full washout at 35 mph base.
	maxangle = 360, --Max sonar angle of the sonar. 360 is a full circle
	acepoints = 300
} )

ACF_DefineSonar("Small-Sonar", {
	name		= "Small Sonar Array",
	ent			= "ace_sonar",
	desc		= ACFTranslation.Sonar[2],
	model		= "models/macc/Cylindrical_Sonar.mdl",
	class		= "Sonar",
	weight		= 2000,
	powerscale	= 0.5,--Multiplier for the energy of the sonar. The base range of sonar is (300m,200m,100m) for an omnidirectional ping and (600m,400m,200m) for a directed ping.
	noisemul	= 1.25, --Multiplier for the noise of the sonar.
	washoutfactor = 1.25, --Resistance to being washed out. 0.5 means washes out half as quickly. Full washout at 35 mph base.
	acepoints = 750
} )


ACF_DefineSonar("Medium-Sonar", {
	name		= "Medium Sonar Array",
	ent			= "ace_sonar",
	desc		= ACFTranslation.Sonar[3],
	model		= "models/macc/SQS53.mdl", -- medium one is for now scalled big one - will be changed
	class		= "Sonar",
	weight		= 7500,
	powerscale	= 0.75,--Multiplier for the energy of the sonar. The base range of sonar is (300m,200m,100m) for an omnidirectional ping and (600m,400m,200m) for a directed ping.
	noisemul	= 0.85, --Multiplier for the noise of the sonar.
	washoutfactor = 1.0, --Resistance to being washed out. 0.5 means washes out half as quickly. Full washout at 35 mph base.
	acepoints = 2700
} )


ACF_DefineSonar("Large-Sonar", {
	name		= "Large Sonar Array",
	ent			= "ace_sonar",
	desc		= ACFTranslation.Sonar[4],
	model		= "models/macc/zaryam.mdl",
	class		= "Sonar",
	weight		= 20000,
	powerscale	= 1.0,--Multiplier for the energy of the sonar. The base range of sonar is (300m,200m,100m) for an omnidirectional ping and (600m,400m,200m) for a directed ping.
	noisemul	= 1.0, --Multiplier for the noise of the sonar. Less accurate than the medium because of the sheer amount of power involved and inferior technology.
	washoutfactor = 0.8, --Resistance to being washed out. 0.5 means washes out half as quickly. Full washout at 35 mph base.
	acepoints = 3000
} )
