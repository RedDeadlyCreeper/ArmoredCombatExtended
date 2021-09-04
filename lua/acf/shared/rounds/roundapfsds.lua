
AddCSLuaFile()

ACF.AmmoBlacklist.APFSDS = { "AC", "SA","C","MG", "AL","HMG" ,"RAC", "SC","ATR" , "MO" , "RM", "SL", "GL", "HW", "SC", "BOMB" , "GBU", "ASM", "AAM", "SAM", "UAR", "POD", "FFAR", "ATGM", "ARTY", "ECM", "FGL"}



local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "[APFSDS-LRP] - "..ACFTranslation.ShellAPFSDS[1] --Human readable name
Round.model = "models/munitions/dart_100mm.mdl" --Shell flight model
Round.desc = ACFTranslation.ShellAPFSDS[2]
Round.netid = 16 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )

			ACF_CreateBullet( BulletData )
			
end

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
	
	local Data = {}
	local ServerData = {}
	local GUIData = {}
	
	if not PlayerData.PropLength then PlayerData.PropLength = 0 end
	if not PlayerData.ProjLength then PlayerData.ProjLength = 0 end
	if not PlayerData.SCalMult then PlayerData.SCalMult = 0.5 end
	if not PlayerData["Data5"] then PlayerData["Data5"] = 0.23 end --caliber in mm count
	if not PlayerData.Data10 then PlayerData.Data10 = 0 end

	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )
	
	local GunClass = ACF.Weapons["Guns"][(Data["Id"] or PlayerData["Id"])]["gunclass"]
	
	if ACF.Year > 2000 then
	

	if GunClass == "C" then
	Data.MinCalMult = 0.25
	Data.MaxCalMult = 1.0
	Data.PenModifier = 0.8
	Data.VelModifier = 0.9
	Data.Ricochet = 70
	elseif GunClass == "AL" then
	Data.MinCalMult = 0.28
	Data.MaxCalMult = 1.0
	Data.PenModifier = 0.8
	Data.VelModifier = 0.9
	Data.Ricochet = 70
	elseif GunClass == "SBC" then
	Data.MinCalMult = 0.23
	Data.MaxCalMult = 1.0
	Data.PenModifier = 0.8
	Data.VelModifier = 1.1
	Data.Ricochet = 70
	else
	Data.MinCalMult = 0.25
	Data.MaxCalMult = 1.0
	Data.PenModifier = 1.35
	Data.VelModifier = 1
	Data.Ricochet = 70	
	end
	
	else

	if GunClass == "C" then
	Data.MinCalMult = 0.25
	Data.MaxCalMult = 1.0
	Data.PenModifier = 1
	Data.VelModifier = 1
	Data.Ricochet = 62
	elseif GunClass == "SBC" then
	Data.MinCalMult = 0.23
	Data.MaxCalMult = 1.0
	Data.PenModifier = 0.85
	Data.VelModifier = 1.1
	Data.Ricochet = 68
	else
	Data.MinCalMult = 0.25
	Data.MaxCalMult = 1.0
	Data.PenModifier = 1.35
	Data.VelModifier = 1
	Data.Ricochet = 62	
	end
	
	end
	
	--Used for adapting acf2 apds/apfsds to the new format
	PlayerData["Data5"] = math.Clamp(PlayerData["Data5"],Data.MinCalMult,Data.MaxCalMult)
	
	Data.SCalMult = PlayerData["Data5"]
	Data.SubFrAera = Data.FrAera * math.min(PlayerData.Data5,Data.MaxCalMult)^2
	Data.ProjMass = Data.SubFrAera * (Data.ProjLength*7.9/1000) * 2.5 * 0.95 --Volume of the projectile as a cylinder * density of steel
	Data.ShovePower = 0.2
	Data.PenAera = (Data.PenModifier*Data.SubFrAera)^ACF.PenAreaMod	
	
	Data.DragCoef = ((Data.SubFrAera/10000)/Data.ProjMass)
	Data.CaliberMod = Data.Caliber*math.min(PlayerData.Data5,Data.MaxCalMult)
	Data.LimitVel = 1000										--Most efficient penetration speed in m/s
	Data.KETransfert = 0.2									--Kinetic energy transfert to the target for movement purposes										
	Data.MuzzleVel = ACF_MuzzleVelocity( Data.PropMass * 0.5 , Data.ProjMass*2.5, Data.Caliber )* Data.VelModifier
	Data.BoomPower = Data.PropMass

	if SERVER then --Only the crates need this part
		ServerData.Id = PlayerData.Id
		ServerData.Type = PlayerData.Type
		return table.Merge(Data,ServerData)
	end
	
	if CLIENT then --Only tthe GUI needs this part
		GUIData = table.Merge(GUIData, Round.getDisplayData(Data))
		return table.Merge(Data,GUIData)
	end
	
end


function Round.getDisplayData(Data)
	local GUIData = {}
	local Energy = ACF_Kinetic( Data.MuzzleVel*39.37 , Data.ProjMass, Data.LimitVel )
	GUIData.MaxPen = (Energy.Penetration/Data.PenAera)*ACF.KEtoRHA
	return GUIData
end



function Round.network( Crate, BulletData )
	
	Crate:SetNWString( "AmmoType", "APFSDS" )
	Crate:SetNWString( "AmmoID", BulletData.Id )
	Crate:SetNWFloat( "Caliber", BulletData.Caliber )
	Crate:SetNWFloat( "ProjMass", BulletData.ProjMass )
	Crate:SetNWFloat( "PropMass", BulletData.PropMass )
	Crate:SetNWFloat( "DragCoef", BulletData.DragCoef )
	Crate:SetNWFloat( "MuzzleVel", BulletData.MuzzleVel )
	Crate:SetNWFloat( "Tracer", BulletData.Tracer )

	--For propper bullet model
	Crate:SetNWFloat( "BulletModel", Round.model )
	
end

function Round.cratetxt( BulletData )
	
	--local FrAera = BulletData.FrAera
	local DData = Round.getDisplayData(BulletData)
	
	--fakeent.ACF.Armour = DData.MaxPen or 0
	--fakepen.Penetration = (DData.MaxPen * FrAera) / ACF.KEtoRHA	
	--local fakepen = ACF_Kinetic( BulletData.SlugMV*39.37 , BulletData.SlugMass, 9999999 )
	--local MaxHP = ACF_CalcDamage( fakeent , fakepen , FrAera , 0 )
	
	--[[
	local TotalMass = BulletData.ProjMass + BulletData.PropMass
	local MassUnit
	
	if TotalMass < 0.1 then
		TotalMass = TotalMass * 1000
		MassUnit = " g"
	else
		MassUnit = " kg"
	end
	]]--
	
	local str = 
	{
		--"Cartridge Mass: ", math.Round(TotalMass, 2), MassUnit, "\n",
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Max Penetration: ", math.floor(DData.MaxPen), " mm"
		--"Max Pen. Damage: ", math.Round(MaxHP.Damage, 1), " HP\n",
	}
	
	return table.concat(str)
	
end

function Round.normalize( Index, Bullet, HitPos, HitNormal, Target)

	local NormieMult = 1
	local Mat = Target.ACF.Material or 0
	if Mat == 1 then
	NormieMult = 0.8
	elseif Mat == 2 then
	NormieMult = 1.5
	elseif Mat == 3 then
	NormieMult = 0.05
	elseif Mat == 5 then
	NormieMult = 0.7	
	elseif Mat == 6 then
	NormieMult=0.5
	end
	
	Bullet.Normalize = true
	Bullet.Pos = HitPos
	local FlightNormal = (Bullet.Flight:GetNormalized() - HitNormal * ACF.NormalizationFactor * NormieMult * 2):GetNormalized() --Guess it doesnt need localization
	local Speed = Bullet.Flight:Length()


--	local FlightNormal = Bullet.Flight:GetNormalized() + (HitNormal-Bullet.Flight:GetNormalized()) * ACF.NormalizationFactor * NormieMult * 2
--	local FlightNormal = HitNormal

	Bullet.Flight = FlightNormal * Speed
	
	local DeltaTime = SysTime() - Bullet.LastThink
	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized()*math.min(ACF.PhysMaxVel*DeltaTime,Bullet.FlightTime*Bullet.Flight:Length())
	Bullet.NextPos = Bullet.Pos + (Bullet.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	
end

function Round.propimpact( Index, Bullet, Target, HitNormal, HitPos, Bone )

	if ACF_Check( Target ) then
	
		if Bullet.Normalize then
--		print("PropHit")
			local Speed = Bullet.Flight:Length() / ACF.VelScale
			local Energy = ACF_Kinetic( Speed , Bullet.ProjMass, Bullet.LimitVel )
			local HitRes = ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )
		
			if HitRes.Overkill > 0 then
				table.insert( Bullet.Filter , Target )					--"Penetrate" (Ingoring the prop for the retry trace)
				ACF_Spall( HitPos , Bullet.Flight , Bullet.Filter , Energy.Kinetic*HitRes.Loss , Bullet.Caliber , Target.ACF.Armour , Bullet.Owner , Target.ACF.Material) --Do some spalling
				Bullet.Flight = Bullet.Flight:GetNormalized() * (Energy.Kinetic*(1-HitRes.Loss)*2000/Bullet.ProjMass)^0.5 * 39.37
				Bullet.Normalize = false
				return "Penetrated"
			elseif HitRes.Ricochet then
				Bullet.Normalize = false
				return "Ricochet"
			else
				return false
			end
		else
		Round.normalize( Index, Bullet, HitPos, HitNormal, Target)
--		print("Normalize")
		return "Penetrated"
		end
	else 
		table.insert( Bullet.Filter , Target )
	return "Penetrated" end
		
end

function Round.worldimpact( Index, Bullet, HitPos, HitNormal )
	
	local Energy = ACF_Kinetic( Bullet.Flight:Length() / ACF.VelScale, Bullet.ProjMass, Bullet.LimitVel )
	local HitRes = ACF_PenetrateGround( Bullet, Energy, HitPos, HitNormal )
	if HitRes.Penetrated then
		return "Penetrated"
	elseif HitRes.Ricochet then
		return "Ricochet"
	else
		return false
	end

end

function Round.endflight( Index, Bullet, HitPos )
	
	ACF_RemoveBullet( Index )
	
end

-- Bullet stops here
function Round.endeffect( Effect, Bullet )
	
	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Impact", Spall )

end

-- Bullet penetrated something
function Round.pierceeffect( Effect, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Penetration", Spall )

end

-- Bullet ricocheted off something
function Round.ricocheteffect( Effect, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Ricochet", Spall )
	
end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.APFSDS )
	
	acfmenupanel:CPanelText("BonusDisplay", "")
	
	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	
	acfmenupanel:AmmoStats(0,0,0,0)     --AmmoStats -->> RoundLenght, MuzzleVelocity & MaxPen
	
	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("SCalMult",0,0,1000,2, "Subcaliber Size Multiplier", "")--Subcaliber Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	
	acfmenupanel:AmmoCheckbox("Tracer", "Tracer", "")			--Tracer checkbox (Name, Title, Desc)

	acfmenupanel:CPanelText("RicoDisplay", "")	--estimated rico chance
	acfmenupanel:CPanelText("PenetrationDisplay", "")	--Proj muzzle penetration (Name, Desc)
	
	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel, Table )
	
	local PlayerData = {}
		PlayerData.Id = acfmenupanel.AmmoData.Data.id			--AmmoSelect GUI
		PlayerData.Type = "APFSDS"										--Hardcoded, match ACFRoundTypes table index
		PlayerData.PropLength = acfmenupanel.AmmoData.PropLength	--PropLength slider
		PlayerData.ProjLength = acfmenupanel.AmmoData.ProjLength	--ProjLength slider
		PlayerData.Data5 = acfmenupanel.AmmoData.SCalMult
		local Tracer = 0
		if acfmenupanel.AmmoData.Tracer then Tracer = 1 end
		PlayerData.Data10 = Tracer				--Tracer
	local Data = Round.convert( Panel, PlayerData )
	
	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
	RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )		--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data5", Data.SCalMult )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	
	---------------------------Ammo Capacity-------------------------------------
	
	local Cap, CapMul, RoFMul, TwoPiece = AmmoCapacity( Data.ProjLength, Data.PropLength, Data.Caliber )
	
	local plur = 'Contains '..Cap..' round'
	
	if Cap > 1 then
	    plur = 'Contains '..Cap..' rounds'
	end
	
	local bonustxt = "Crate info: +"..(math.Round((CapMul-1)*100,1)).."% capacity, +"..(math.Round((RoFMul-1)*-100,1)).."% RoF\n"..plur
	
	if TwoPiece then	
		bonustxt = bonustxt..'. Uses 2 piece ammo.'	
	end
	
	acfmenupanel:CPanelText("BonusDisplay", bonustxt )
	
	-------------------------------------------------------------------------------	
	
	acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData.Type].desc)	--Description (Name, Desc)
	
	acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data.MaxTotalLength,3, "Propellant Length", "Propellant Mass : "..(math.floor(Data.PropMass*1000)).." g" )	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data.MaxTotalLength,3, "Projectile Length", "Projectile Mass : "..(math.floor(Data.ProjMass*1000)).." g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("SCalMult",Data.SCalMult,Data.MinCalMult,Data.MaxCalMult,2, "Subcaliber Size Multiplier", "Caliber : "..math.floor(Data.Caliber * math.min(PlayerData.Data5,Data.MaxCalMult)*10).." mm")--Subcaliber round slider (Name, Min, Max, Decimals, Title, Desc)	
	
	acfmenupanel:AmmoCheckbox("Tracer", "Tracer : "..(math.floor(Data.Tracer*5)/10).."cm\n", "" )			--Tracer checkbox (Name, Title, Desc)
	
	acfmenupanel:AmmoStats((math.floor((Data.PropLength+Data.ProjLength+(math.floor(Data.Tracer*5)/10))*100)/100), (Data.MaxTotalLength) ,math.floor(Data.MuzzleVel*ACF.VelScale) ,math.floor(Data.MaxPen))
	
    ---------------------------Chance of Ricochet table----------------------------    
 	
	local None, Mean, Max = ACF_RicoProbability( Data.Ricochet, Data.MuzzleVel*ACF.VelScale )
	acfmenupanel:CPanelText("RicoDisplay", '0% chance of ricochet at: '..None..'°\n50% chance of ricochet at: '..Mean..'°\n100% chance of ricochet at: '..Max..'°')
	
	-------------------------------------------------------------------------------
	
	local R1V, R1P = ACF_PenRanging( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenAera, Data.LimitVel, 100 )	
	local R2V, R2P = ACF_PenRanging( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenAera, Data.LimitVel, 200 )
	local R3V, R3P = ACF_PenRanging( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenAera, Data.LimitVel, 400 )
	local R4V, R4P = ACF_PenRanging( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenAera, Data.LimitVel, 800 )

	acfmenupanel:CPanelText("PenetrationDisplay", "100m pen: "..math.floor(R1P,0).."mm @ "..math.floor(R1V,0).." m\\s\n200m pen: "..math.floor(R2P,0).."mm @ "..math.floor(R2V,0).." m\\s\n400m pen: "..math.floor(R3P,0).."mm @ "..math.floor(R3V,0).." m\\s\n800m pen: "..math.floor(R4P,0).."mm @ "..math.floor(R4V,0).." m\\s\n\nThe range data is an approximation and may not be entirely accurate.\n")	--Proj muzzle penetration (Name, Desc)

	
end

list.Set( "APRoundTypes", "APFSDS", Round )
list.Set( "ACFRoundTypes", "APFSDS", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid, "APFSDS" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above