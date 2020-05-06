
ACF_DefineRadarClass("DIR-AM", {
	name = "Directional Anti-missile Radar",
	desc = ACFTranslation.Radar[1],
} )




ACF_DefineRadar("SmallDIR-AM", {
	name 		= "Small Directional Radar",
	ent			= "acf_missileradar",
	desc 		= ACFTranslation.Radar[2],
	model		= "models/radar/radar_sml.mdl",
	class 		= "DIR-AM",
	weight 		= 200,
	viewcone 	= 25 -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
} )


ACF_DefineRadar("MediumDIR-AM", {
	name 		= "Medium Directional Radar",
	ent			= "acf_missileradar",
	desc 		= ACFTranslation.Radar[3],
	model		= "models/radar/radar_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 		= "DIR-AM",
	weight 		= 400,
	viewcone 	= 40 -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
} )


ACF_DefineRadar("LargeDIR-AM", {
	name 		= "Large Directional Radar",
	ent			= "acf_missileradar",
	desc 		= ACFTranslation.Radar[4],
	model		= "models/radar/radar_big.mdl",
	class 		= "DIR-AM",
	weight 		= 600,
	viewcone 	= 50 -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
} )