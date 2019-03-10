
ACF_DefineRadarClass("OMNI-AM", {
	name = "Spherical Anti-missile Radar",
	desc = "A missile radar with full 360-degree detection but a limited range.  Only detects launched missiles.\nThese may be parented to what they are welded to.",
} )




ACF_DefineRadar("SmallOMNI-AM", {
	name 		= "Small Spherical Radar",
	ent			= "acf_missileradar",
	desc 		= "A lightweight omni-directional radar with a smaller range.",
	model		= "models/radar/radar_sp_sml.mdl",
	class 		= "OMNI-AM",
	weight 		= 300,
	range 		= 7874 -- range in inches.
} )


ACF_DefineRadar("MediumOMNI-AM", {
	name 		= "Medium Spherical Radar",
	ent			= "acf_missileradar",
	desc 		= "A omni-directional radar with a regular range.",
	model		= "models/radar/radar_sp_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 		= "OMNI-AM",
	weight 		= 600,
	range 		= 15748 -- range in inches.
} )


ACF_DefineRadar("LargeOMNI-AM", {
	name 		= "Large Spherical Radar",
	ent			= "acf_missileradar",
	desc 		= "A heavy omni-directional radar with a large range.",
	model		= "models/radar/radar_sp_big.mdl",
	class 		= "OMNI-AM",
	weight 		= 1200,
	range 		= 31496 -- range in inches.
} )