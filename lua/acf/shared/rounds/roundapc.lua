
AddCSLuaFile()

local Round = {}

Round.type  = "Ammo"									-- Tells the spawn menu what entity to spawn
Round.name  = "[APC] - " .. ACFTranslation.ShellAPC[1]	-- Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl"	-- Shell flight model
Round.desc  = ACFTranslation.ShellAPC[2]
Round.netid = 17										-- Unique ammotype ID for network transmission

Round.Type  = "APC"

function Round.create( _, BulletData )

	ACF_CreateBullet( BulletData )

end

-- Function to convert the player's slider data into the complete round data
function Round.convert( _, PlayerData )

	local Data		= {}
	local ServerData	= {}
	local GUIData	= {}

	PlayerData.PropLength	=  PlayerData.PropLength	or 0
	PlayerData.ProjLength	=  PlayerData.ProjLength	or 0
	PlayerData.Tracer	=  PlayerData.Tracer		or 0
	PlayerData.TwoPiece	=  PlayerData.TwoPiece	or 0

	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )

	Data.ProjMass	= Data.FrArea * (Data.ProjLength * 7.9 / 1000) --Volume of the projectile as a cylinder * density of steel
	Data.ShovePower	= 0.2
	Data.PenArea		= Data.FrArea ^ ACF.PenAreaMod
	Data.DragCoef	= ((Data.FrArea / 10000) / Data.ProjMass) * 1.2
	Data.LimitVel	= 750									--Most efficient penetration speed in m/s
	Data.KETransfert	= 0.3								--Kinetic energy transfert to the target for movement purposes
	Data.Ricochet	= 56										--Base ricochet angle
	Data.MuzzleVel	= ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )

	Data.BoomPower	= Data.PropMass
	Data.Normalize	= true


	if SERVER then --Only the crates need this part
		ServerData.Id	= PlayerData.Id
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
	local Energy = ACF_Kinetic( Data.MuzzleVel * 39.37 , Data.ProjMass, Data.LimitVel )
	GUIData.MaxPen = (Energy.Penetration / Data.PenArea) * ACF.KEtoRHA
	return GUIData
end



function Round.network( Crate, BulletData )

	Crate:SetNWString( "AmmoType", "APC" )
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

	local DData = Round.getDisplayData(BulletData)
	local str =
	{
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Max Penetration: ", math.floor(DData.MaxPen), " mm"
	}

	return table.concat(str)

end

function Round.normalize( _, Bullet, HitPos, HitNormal, Target)

	local Mat = Target.ACF.Material or "RHA"
	local NormieMult = ACE.ArmorTypes[ Mat ].NormMult or 1

	Bullet.Normalize = true
	Bullet.Pos = HitPos

	local FlightNormal = (Bullet.Flight:GetNormalized() - HitNormal * ACF.NormalizationFactor * NormieMult * 2):GetNormalized() --Guess it doesnt need localization
	local Speed = Bullet.Flight:Length()

	Bullet.Flight = FlightNormal * Speed

	local DeltaTime = SysTime() - Bullet.LastThink
	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized() * math.min(ACF.PhysMaxVel * DeltaTime,Bullet.FlightTime * Bullet.Flight:Length())
	Bullet.NextPos = Bullet.Pos + (Bullet.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position

end

function Round.propimpact( Index, Bullet, Target, HitNormal, HitPos, Bone )

	if ACF_Check( Target ) then

		if Bullet.Normalize then
--	print("PropHit")
			local Speed = Bullet.Flight:Length() / ACF.VelScale
			local Energy = ACF_Kinetic( Speed , Bullet.ProjMass, Bullet.LimitVel )
			local HitRes = ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )

			if HitRes.Overkill > 0 then
				table.insert( Bullet.Filter , Target )				--"Penetrate" (Ingoring the prop for the retry trace)
				ACF_Spall( HitPos , Bullet.Flight , Bullet.Filter , Energy.Kinetic * HitRes.Loss , Bullet.Caliber , Target.ACF.Armour , Bullet.Owner , Target.ACF.Material) --Do some spalling
				Bullet.Flight = Bullet.Flight:GetNormalized() * (Energy.Kinetic * (1-HitRes.Loss) * 2000 / Bullet.ProjMass) ^ 0.5 * 39.37
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
--	print("Normalize")
		return "Penetrated"
		end
	else
		table.insert( Bullet.Filter , Target )
	return "Penetrated" end

end

function Round.worldimpact( _, Bullet, HitPos, HitNormal )

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

function Round.endflight( Index )

	ACF_RemoveBullet( Index )

end

-- Bullet stops here
function Round.endeffect( _, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Impact", Spall )

end

-- Bullet penetrated something
function Round.pierceeffect( _, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Penetration", Spall )

end

-- Bullet ricocheted off something
function Round.ricocheteffect( _, Bullet )

	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( Bullet.SimFlight:Length() )
		Spall:SetMagnitude( Bullet.RoundMass )
	util.Effect( "ACF_AP_Ricochet", Spall )

end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.AP )

	ACE_UpperCommonDataDisplay()

	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)

	acfmenupanel:AmmoCheckbox("Tracer", "Tracer", "")		--Tracer checkbox (Name, Title, Desc)
	acfmenupanel:AmmoCheckbox("TwoPiece", "Enable Two Piece Storage", "", "" )

	acfmenupanel:CPanelText("RicoDisplay", "")  --estimated rico chance
	acfmenupanel:CPanelText("PenetrationDisplay", "")	--Proj muzzle penetration (Name, Desc)

	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel, _ )

	local PlayerData = {}
		PlayerData.Id = acfmenupanel.AmmoData.Data.id		--AmmoSelect GUI
		PlayerData.Type = "APC"									--Hardcoded, match as Round.Type instead
		PlayerData.PropLength = acfmenupanel.AmmoData.PropLength	--PropLength slider
		PlayerData.ProjLength = acfmenupanel.AmmoData.ProjLength	--ProjLength slider
		PlayerData.Tracer	= acfmenupanel.AmmoData.Tracer
		PlayerData.TwoPiece	= acfmenupanel.AmmoData.TwoPiece

	local Data = Round.convert( Panel, PlayerData )

	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
	RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )	--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )	--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	RunConsoleCommand( "acfmenu_data11", Data.TwoPiece )

	acfmenupanel:AmmoSlider("PropLength", Data.PropLength, Data.MinPropLength, Data.MaxTotalLength, 3, "Propellant Length", "Propellant Mass : " .. (math.floor(Data.PropMass * 1000)) .. " g" .. "/ " .. (math.Round(Data.PropMass, 1)) .. " kg" )  --Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength", Data.ProjLength, Data.MinProjLength, Data.MaxTotalLength, 3, "Projectile Length", "Projectile Mass : " .. (math.floor(Data.ProjMass * 1000)) .. " g" .. "/ " .. (math.Round(Data.ProjMass, 1)) .. " kg")  --Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)

	ACE_UpperCommonDataDisplay( Data, PlayerData )
	ACE_CommonDataDisplay( Data )

end

list.Set( "APRoundTypes", "APC", Round )
ACF.RoundTypes[Round.Type] = Round     --Set the round properties
ACF.IdRounds[Round.netid] = Round.Type --Index must equal the ID entry in the table above, Data must equal the index of the table above