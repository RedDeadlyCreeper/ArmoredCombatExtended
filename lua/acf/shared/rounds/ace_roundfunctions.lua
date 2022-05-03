AddCSLuaFile( "acf/shared/rounds/ace_roundfunctions.lua" )


function ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )


	local BulletMax = ACF.Weapons["Guns"][PlayerData["Id"]]["round"]
		
	GUIData["MaxTotalLength"] 	= BulletMax["maxlength"] * (Data["LengthAdj"] or 1)
		
	Data["Caliber"] 			= ACF.Weapons["Guns"][PlayerData["Id"]]["caliber"]
	Data["FrAera"] 				= 3.1416 * (Data["Caliber"]/2)^2
	
	Data["Tracer"] 				= 0
	if PlayerData["Data10"]*1 > 0 then	--Check for tracer
		Data["Tracer"] 			= math.min(Data["Caliber"]/5,3) --Tracer space calcs
	end

	--print('Prop Before: '..PlayerData["PropLength"])
	--print('Proj Before: '..PlayerData["ProjLength"])

	local Type = PlayerData.Type or ''

	--created to adapt old ammos to the new heatfs speed
	if Type == 'HEATFS' or Type == 'THEATFS' then
		PlayerData["PropLength"] = math.max(0.01 + Data["Caliber"]*3.9, PlayerData["PropLength"] )

		--check if current lenght exceeds the max lenght available
		if PlayerData["PropLength"] + PlayerData["ProjLength"] > GUIData["MaxTotalLength"] then

			PlayerData["ProjLength"] = GUIData["MaxTotalLength"] - PlayerData["PropLength"]

		end

	--same as above, but for hefs
	elseif Type == 'HEFS' then
		PlayerData["PropLength"] = math.max(0.01 + Data["Caliber"]*4.5, PlayerData["PropLength"] )

		--check if current lenght exceeds the max lenght available
		if PlayerData["PropLength"] + PlayerData["ProjLength"] + 1 > GUIData["MaxTotalLength"] then

			PlayerData["ProjLength"] = GUIData["MaxTotalLength"] - PlayerData["PropLength"]

		end
	end

	--print('MaxLenght: '..GUIData["MaxTotalLength"])
	--print('Remain for Proj: '..GUIData["MaxTotalLength"] - PlayerData["PropLength"])
	--print('Prop After: '..PlayerData["PropLength"])
	--print('Proj After: '..PlayerData["ProjLength"])

	local PropMax = (BulletMax["propweight"]*1000/ACF.PDensity) / Data["FrAera"]	--Current casing absolute max propellant capacity
	local CurLength = (PlayerData["ProjLength"] + math.min(PlayerData["PropLength"],PropMax) + Data["Tracer"])


	GUIData["MinPropLength"] = 0.01
	GUIData["MaxPropLength"] = math.max(math.min(GUIData["MaxTotalLength"]-CurLength+PlayerData["PropLength"], PropMax),GUIData["MinPropLength"]) --Check if the desired prop lenght fits in the case and doesn't exceed the gun max
	
	GUIData["MinProjLength"] = Data["Caliber"]*1.5
	GUIData["MaxProjLength"] = math.max(GUIData["MaxTotalLength"]-CurLength+PlayerData["ProjLength"],GUIData["MinProjLength"]) --Check if the desired proj lenght fits in the case
	
	--This is to check the current ratio between elements if i need to clamp it
	local Ratio 			= math.min( (GUIData["MaxTotalLength"] - Data["Tracer"])/(PlayerData["ProjLength"] + math.min(PlayerData["PropLength"],PropMax)) , 1 ) 
	
	Data["ProjLength"] 		= math.Clamp(PlayerData["ProjLength"]*Ratio,GUIData["MinProjLength"],GUIData["MaxProjLength"])
	Data["PropLength"] 		= math.Clamp(PlayerData["PropLength"]*Ratio,GUIData["MinPropLength"],GUIData["MaxPropLength"])
	
	Data["PropMass"] 		= Data["FrAera"] * (Data["PropLength"]*ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
	GUIData["ProjVolume"] 	= Data["FrAera"] * Data["ProjLength"]
	Data["RoundVolume"] 	= Data["FrAera"] * (Data["ProjLength"] + Data["PropLength"])
	
	return PlayerData, Data, ServerData, GUIData
end

function ACF_RoundShellCapacity( Momentum, FrAera, Caliber, ProjLength )
	local MinWall = 0.2+((Momentum/FrAera)^0.7)/50 --The minimal shell wall thickness required to survive firing at the current energy level	
	local Length = math.max(ProjLength-MinWall,0)
	local Radius = math.max((Caliber/2)-MinWall,0)
	local Volume = 3.1416*Radius^2 * Length
	return  Volume, Length, Radius --Returning the cavity volume and the minimum wall thickness
end

function ACF_RicoProbability( Rico, Speed )
	
	local RicoAngle = math.Round(math.min(Rico -  (( (Speed-800) / 39.37 ) /5),89))
		
    local None = math.max(RicoAngle-10,1) --0% chance to ricochet
	local Mean = math.max(RicoAngle,1)   --50% chance to ricochet
	local Max = math.max(RicoAngle+10,1)  --100% chance to ricochet
	
	return None, Mean, Max

end

--Formula from https://mathscinotes.wordpress.com/2013/10/03/parameter-determination-for-pejsa-velocity-model/
--not terribly accurate for acf, particularly small caliber (7.62mm off by 120 m/s at 800m), but is good enough for quick indicator
function ACF_PenRanging( MuzzleVel, DragCoef, ProjMass, PenAera, LimitVel, Range ) --range in m, vel is m/s
	local V0 = (MuzzleVel * 39.37 * ACF.VelScale) 	-- initial velocity
	local D0 = (DragCoef * V0^2 / ACF.DragDiv)		-- initial drag
	local K1 = ( D0 / (V0^(3/2)) )^-1  				-- estimated drag coefficient
	
	local Vel = (math.sqrt(V0) - ((Range*39.37) / (2 * K1)) )^2
	local Pen = (ACF_Kinetic( Vel, ProjMass, LimitVel ).Penetration/PenAera)*ACF.KEtoRHA
	
	return (Vel*0.0254), Pen
end

--This function is not used by ACE anymore, but i´ll keep it just for those acf2 custom ammos dont break	
function ACF_CalcCrateStats( CrateVol, RoundVol )

	local CapMul = (CrateVol > 40250) and ((math.log(CrateVol*0.00066)/math.log(2)-4)*0.15+1) or 1
	local RoFMul = (CrateVol > 40250) and (1-(math.log(CrateVol*0.00066)/math.log(2)-4)*0.05) or 1
	
	--local Cap = math.floor(CapMul * CrateVol * ACF.AmmoMod * ACF.CrateVolEff * 16.38 / RoundVol)
	local Cap = 0
	
	return Cap, CapMul, RoFMul
end

--This function is a direct copy from acf_ammo code. So its expected that the result matches with the ammo count
function ACE_AmmoCapacity( ProjLenght, PropLenght, Caliber )

    local Cal = (Caliber)/ACF.AmmoWidthMul/1.6
	local shellLength = ((PropLenght or 0) + (ProjLenght or 0))/ACF.AmmoLengthMul/3

	local Lenght = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].Lenght
	local Width = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].Width
	local Height = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].Height
	
    local CrateVol = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].volume

	local CapMul = (CrateVol > 40250) and ((math.log(CrateVol*0.00066)/math.log(2)-4)*0.15+1) or 1
	local RoFMul = (CrateVol > 40250) and (1-(math.log(CrateVol*0.00066)/math.log(2)-4)*0.05) or 1
	
	local cap1 = (math.floor(Height/shellLength) * math.floor(Lenght/Cal) * math.floor(Width/Cal)) or 1
		--Horizontal Placement 1
	local cap2 = (math.floor(Lenght/shellLength) * math.floor(Height/Cal) * math.floor(Width/Cal)) or 1
		--Horizontal placement 2
	local cap3 = (math.floor(Width/shellLength) * math.floor(Height/Cal) * math.floor(Lenght/Cal)) or 1
		--Vertical 2 piece placement
	local cap4 = math.floor(math.floor(Height/shellLength*2)/2 * math.floor(Lenght/Cal) * math.floor(Width/Cal)) or 1
		--Horizontal 2 piece  Placement 1
	local cap5 = math.floor(math.floor(Lenght/shellLength*2)/2 * math.floor(Height/Cal) * math.floor(Width/Cal)) or 1
		--Horizontal 2 piece  placement 2
	local cap6 = math.floor(math.floor(Width/shellLength*2)/2 * math.floor(Height/Cal) * math.floor(Lenght/Cal)) or 1
	
    local Cap
	local TwoPiece
	local tval1 = math.max(cap1,cap2,cap3)
	local tval2 = math.max(cap4,cap5,cap6)

	if (tval2-tval1)/(tval1+tval2) > 0.3 then --2 piece ammo time, uses 2 piece if 2 piece leads to more than 30% shells
		Cap = tval2
		TwoPiece = true
	else
		Cap = tval1
		TwoPiece = false
	end
    
    return Cap, CapMul, RoFMul, TwoPiece
end

--General Ammo Capacity diplay shown on ammo config
function ACE_AmmoCapacityDisplay( Data )

	local Cap, CapMul, RoFMul, TwoPiece = ACE_AmmoCapacity( Data.ProjLength, Data.PropLength, Data.Caliber )
	
	local plur = 'Contains '..Cap..' round'
	
	if Cap > 1 then
	    plur = 'Contains '..Cap..' rounds'
	end
	
	local bonustxt = "Crate info: +"..(math.Round((CapMul-1)*100,1)).."% capacity, +"..(math.Round((RoFMul-1)*-100,1)).."% RoF\n"..plur
	
	if TwoPiece then	
		bonustxt = bonustxt..'. Uses 2 piece ammo.'	
	end
	
	acfmenupanel:CPanelText("BonusDisplay", bonustxt )

end

function ACE_AmmoRangeStats( MuzzleVel, DragCoef, ProjMass, PenAera, LimitVel )

    local Range 	= {}
    Range.Vel 		= {}
    Range.Pen 		= {}
    Range.Distance 	= {}
    final_text		= {}

    for i = 1, 4 do

    	Range.Distance[i] = (2^(i-1))*100
    	Range.Vel[i], Range.Pen[i] = ACF_PenRanging( MuzzleVel, DragCoef, ProjMass, PenAera, LimitVel, Range.Distance[i] ) 

    	final_text[i] = "At "..Range.Distance[i].."m pen: "..math.floor(Range.Pen[i]).."mm @ "..math.floor(Range.Vel[i]).."m\\s\n"

    end

    local ftext = table.concat(final_text)

    acfmenupanel:CPanelText("PenetrationDisplay", ftext.."\nThe range data is an approximation and may not be entirely accurate.\n") 

end