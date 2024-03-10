
ACF_DefineTrackRadarClass("DIR-TRACK", {
	name = "Tracking Radar",
	type = "Tracking-Radar",
	desc = "A radar with unlimited range but limited view cone. Unlike the antimissile radar, this can detect vehicles in front of it, but is affected by ground clutter and subject to jamming."
} )

ACF_DefineTrackRadar("Large-TRACK", {
	name		= "Large Tracking Radar",
	ent			= "ace_trackingradar",
	desc		= "A large tracking radar. Commonly mounted in SPAAGs and aircrafts",
	model		= "models/missiles/radar_big.mdl",
	class		= "DIR-TRACK",
	weight		= 600,
	viewcone	= 15				--sets the cone of this radar in degrees. this represents the half of the total cone, so 15 means 30 degrees in total
} )
