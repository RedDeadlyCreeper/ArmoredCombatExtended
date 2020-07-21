
-- Electric motors

ACF_DefineEngine( "Electric-Small", {
	name = "Electric motor, Small",
	desc = "A small electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy",
	model = "models/engines/emotorsmall.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	weight = 250,
	torque = 384,
	flywheelmass = 0.3,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 10000,
	iselec = true,
	flywheeloverride = 5000
} )

ACF_DefineEngine( "Electric-Medium", {
	name = "Electric motor, Medium",
	desc = "A medium electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy",
	model = "models/engines/emotormed.mdl",
	sound = "acf_engines/electric_medium.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	weight = 850,
	torque = 1152,
	flywheelmass = 1.5,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 7000,
	iselec = true,
	flywheeloverride = 8000
} )

ACF_DefineEngine( "Electric-Large", {
	name = "Electric motor, Large",
	desc = "A huge electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy",
	model = "models/engines/emotorlarge.mdl",
	sound = "acf_engines/electric_large.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	weight = 1900,
	torque = 3360,
	flywheelmass = 11.2,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 4500,
	iselec = true,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Electric-Tiny-NoBatt", {
	name = "Electric motor, Tiny, Standalone",
	desc = "A pint-size electric motor, for the lightest of light utility work.  Can power electric razors, desk fans, or your hopes and dreams\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotor-standalone-tiny.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 50, --250
	torque = 40,
	flywheelmass = 0.025,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 10000,
	iselec = true,
	flywheeloverride = 500
} )

ACF_DefineEngine( "Electric-Small-NoBatt", {
	name = "Electric motor, Small, Standalone",
	desc = "A small electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotor-standalone-sml.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 125, --250
	torque = 384,
	flywheelmass = 0.3,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 10000,
	iselec = true,
	flywheeloverride = 5000
} )

ACF_DefineEngine( "Electric-Medium-NoBatt", {
	name = "Electric motor, Medium, Standalone",
	desc = "A medium electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotor-standalone-mid.mdl",
	sound = "acf_engines/electric_medium.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 575, --800
	torque = 1152,
	flywheelmass = 1.5,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 7000,
	iselec = true,
	flywheeloverride = 8000
} )

ACF_DefineEngine( "Electric-Large-NoBatt", {
	name = "Electric motor, Large, Standalone",
	desc = "A huge electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotor-standalone-big.mdl",
	sound = "acf_engines/electric_large.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 1500, --1900
	torque = 3360,
	flywheelmass = 11.2,
	idlerpm = 10,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 4500,
	iselec = true,
	flywheeloverride = 6000
} )

ACF_DefineEngine( "Induction motor, Small, Standalone", {
	name = "Induction motor, Small,Standalone",
	desc = "A small electric motor, loads of torque, but low power\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotor-standalone-sml.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 250, --250
	torque = 500,
	flywheelmass = 0.3,
	idlerpm = 40,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 6500,
	iselec = true,
	flywheeloverride = 4750
} )
ACF_DefineEngine( "Induction motor, Tiny", {
	name = "Induction motor, Tiny,Standalone",
	desc = "A pint-size electric motor, for the lightest of light utility work.  Can power electric razors, desk fans, or your hopes and dreams\n\nElectric motors provide huge amounts of torque, but are very heavy.\n\nStandalone electric motors don't have integrated batteries, saving on weight and volume, but require you to supply your own batteries.",
	model = "models/engines/emotor-standalone-tiny.mdl",
	sound = "acf_engines/electric_small.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 35, --35
	torque = 30,
	flywheelmass = 0.3,
	idlerpm = 40,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 8000,
	iselec = true,
	flywheeloverride = 4750
} )
ACF_DefineEngine( "Induction motor, Medium, Standalone", {
	name = "Induction motor, Medium, Standalone",
	desc = "Very nice engine for small cars.You need to have your own batteries.",
	model = "models/engines/emotor-standalone-mid.mdl",
	sound = "acf_engines/electric_medium.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 520, --520
	torque = 810,
	flywheelmass = 0.3,
	idlerpm = 40,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 9500,
	iselec = true,
	flywheeloverride = 7500
} )
ACF_DefineEngine( "Induction motor, Large, Standalone", {
	name = "Induction motor, Large, Standalone",
	desc = "Super power wooooooof.Where is your fuel he-he",
	model = "models/engines/emotor-standalone-big.mdl",
	sound = "acf_engines/electric_medium.wav",
	category = "Electric",
	fuel = "Electric",
	enginetype = "Electric",
	requiresfuel = true,
	weight = 2000, --2000
	torque = 2400,
	flywheelmass = 0.35,
	idlerpm = 40,
	peakminrpm = 1,
	peakmaxrpm = 1,
	limitrpm = 12000,
	iselec = true,
	flywheeloverride = 8000
} )