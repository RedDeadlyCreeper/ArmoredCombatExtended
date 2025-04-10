AddCSLuaFile()

ACF.AmmoBlacklist["FL"] = { "MG", "AC", "HMG", "SA", "RAC", "ATR", "SL", "GL", "FFAR", "FGL", "ATR", "SBC", "BOMB", "GBU", "ASM", "AAM", "SAM", "UAR", "POD", "FFAR", "ATGM", "ARTY" }


local Round = {}

Round.type  = "Ammo"								-- Tells the spawn menu what entity to spawn
Round.name  = "[FL] - " .. ACFTranslation.ShellFL[1]  -- Human readable name
Round.model = "models/munitions/dart_100mm.mdl"	-- Shell flight model
Round.desc  = ACFTranslation.ShellFL[2]
Round.netid = 8									-- Unique ammotype ID for network transmission

Round.Type  = "FL"

function Round.create( Gun, BulletData )

	--setup flechettes
	local FlechetteData = {}
	FlechetteData["Caliber"]		= math.Round( BulletData["FlechetteRadius"] * 0.2 ,2)
	FlechetteData["Id"]			= BulletData["Id"]
	FlechetteData["Type"]		= "AP" --BulletData["Type"]
	FlechetteData["Owner"]		= BulletData["Owner"]
	FlechetteData["Crate"]		= BulletData["Crate"]
	FlechetteData["Gun"]			= BulletData["Gun"]
	FlechetteData["Pos"]			= BulletData["Pos"]
	FlechetteData["FrArea"]		= BulletData["FlechetteArea"]
	FlechetteData["ProjMass"]	= BulletData["FlechetteMass"]
	FlechetteData["DragCoef"]	= BulletData["FlechetteDragCoef"]
	FlechetteData["Tracer"]		= BulletData["Tracer"]
	FlechetteData["LimitVel"]	= BulletData["LimitVel"]
	FlechetteData["Ricochet"]	= BulletData["Ricochet"]
	FlechetteData["PenArea"]		= BulletData["FlechettePenArea"]
	FlechetteData["ShovePower"]	= BulletData["ShovePower"]
	FlechetteData["KETransfert"]	= BulletData["KETransfert"]

	--local I=1
	local MuzzleVec

	--if ammo is cooking off, shoot in random direction
	if Gun:GetClass() == "acf_ammo" then
		local Inaccuracy
		MuzzleVec = VectorRand()

		for _ = 1, BulletData["Flechettes"] do
			Inaccuracy			= VectorRand() / 360 * ((Gun.Inaccuracy or 0) + BulletData["FlechetteSpread"])
			FlechetteData["Flight"] = (MuzzleVec + Inaccuracy):GetNormalized() * BulletData["MuzzleVel"] * 39.37 + Gun:GetVelocity()

			ACF_CreateBullet( FlechetteData )
		end
	else
		local BaseInaccuracy	= math.tan(math.rad(Gun:GetInaccuracy()))
		local AddInaccuracy	= math.tan(math.rad(BulletData["FlechetteSpread"]))

		MuzzleVec = Gun:GetForward()

		for _ = 1, BulletData["Flechettes"] do
			BaseSpread			= BaseInaccuracy * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4))) * (Gun:GetUp() * (2 * math.random() - 1) + Gun:GetRight() * (2 * math.random() - 1)):GetNormalized()
			AddSpread			= AddInaccuracy * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4))) * (Gun:GetUp() * (2 * math.random() - 1) + Gun:GetRight() * (2 * math.random() - 1)):GetNormalized()
			FlechetteData["Flight"] = (MuzzleVec + BaseSpread + AddSpread):GetNormalized() * BulletData["MuzzleVel"] * 39.37 + Gun:GetVelocity()
			ACF_CreateBullet( FlechetteData )
		end
	end

end

-- Function to convert the player's slider data into the complete round data
function Round.convert( _, PlayerData )

	local Data		= {}
	local ServerData	= {}
	local GUIData	= {}

	Data["LengthAdj"] = 0.5

	PlayerData.PropLength	=  PlayerData.PropLength	or 0
	PlayerData.ProjLength	=  PlayerData.ProjLength	or 0
	PlayerData.Tracer	=  PlayerData.Tracer		or 0
	PlayerData.TwoPiece	=  PlayerData.TwoPiece	or 0
	PlayerData["Data5"]		= PlayerData["Data5"]	or 0	-- flechette count
	PlayerData["Data6"]		= PlayerData["Data6"]	or 0	-- flechette spread


	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )

	--local GunClass = ACF.Weapons["Guns"][Data["Id"] or PlayerData["Id"]]["gunclass"]


	--if GunClass == "SA" then
		Data["MaxFlechettes"] = math.Clamp(math.floor(Data["Caliber"] * 8), 1, 96)
	--end


	Data["MinFlechettes"]	= 2
	Data["Flechettes"]	= math.Clamp(math.floor(PlayerData["Data5"]),Data["MinFlechettes"], Data["MaxFlechettes"])  --number of flechettes

	Data["MinSpread"]	= 0.25
	Data["MaxSpread"]	= 30
	Data["FlechetteSpread"] = math.Clamp(tonumber(PlayerData["Data6"]), Data["MinSpread"], Data["MaxSpread"])

	local PenAdj				= 0.8							-- higher means lower pen, but more structure (hp) damage (old: 2.35, 2.85)
	local RadiusAdj			= 1.0							-- lower means less structure (hp) damage, but higher pen (old: 1.0, 0.8)
	local PackRatio			= 0.0025 * Data["Flechettes"] + 0.69 -- how efficiently flechettes are packed into shell

	Data["FlechetteRadius"]	= math.sqrt( ( (PackRatio * RadiusAdj * Data["Caliber"] / 2) ^ 2 ) / Data["Flechettes"] ) -- max radius flechette can be, to fit number of flechettes in a shell
	Data["FlechetteArea"]	= 3.1416 * Data["FlechetteRadius"] ^ 2 -- area of a single flechette
	Data["FlechetteMass"]	= Data["FlechetteArea"] * (Data["ProjLength"] * 7.9 / 1000) -- volume of single flechette * density of steel
	Data["FlechettePenArea"]	= (PenAdj * Data["FlechetteArea"]) ^ ACF.PenAreaMod
	Data["FlechetteDragCoef"]	= (Data["FlechetteArea"] / 10000) / Data["FlechetteMass"]

	Data["ProjMass"]			= Data["Flechettes"] * Data["FlechetteMass"] -- total mass of all flechettes
	Data["PropMass"]			= Data["PropMass"]
	Data["ShovePower"]		= 0.2
	Data["PenArea"]			= Data["FrArea"] ^ ACF.PenAreaMod
	Data["DragCoef"]			= ((Data["FrArea"] / 10000) / Data["ProjMass"])
	Data["LimitVel"]			= 500									--Most efficient penetration speed in m/s
	Data["KETransfert"]		= 0.1								--Kinetic energy transfert to the target for movement purposes
	Data["Ricochet"]			= 50										--Base ricochet angle
	Data["MuzzleVel"]		= ACF_MuzzleVelocity( Data["PropMass"], Data["ProjMass"], Data["Caliber"] )

	Data["BoomPower"]		= Data["PropMass"]

	if SERVER then --Only the crates need this part
		ServerData["Id"] = PlayerData["Id"]
		ServerData["Type"] = PlayerData["Type"]
		return table.Merge(Data,ServerData)
	end

	if CLIENT then --Only the GUI needs this part
		GUIData = table.Merge(GUIData, Round.getDisplayData(Data, PlayerData))
		return table.Merge(Data,GUIData)
	end

end

function Round.getDisplayData(Data)
	local GUIData = {}
	local Energy = ACF_Kinetic( Data["MuzzleVel"] * 39.37 , Data["FlechetteMass"], Data["LimitVel"] )
	GUIData["MaxPen"] = (Energy.Penetration / Data["FlechettePenArea"]) * ACF.KEtoRHA
	return GUIData
end


function Round.network( Crate, BulletData )

	Crate:SetNWString("AmmoType","FL")
	Crate:SetNWString("AmmoID",BulletData["Id"])
	Crate:SetNWFloat("PropMass",BulletData["PropMass"])
	Crate:SetNWFloat("MuzzleVel",BulletData["MuzzleVel"])
	Crate:SetNWFloat("Tracer",BulletData["Tracer"])

	-- bullet effects use networked data, so set these to the flechette stats
	Crate:SetNWFloat("Caliber",math.Round( BulletData["FlechetteRadius"] * 0.2 ,2))
	Crate:SetNWFloat("ProjMass",BulletData["FlechetteMass"])
	Crate:SetNWFloat("DragCoef",BulletData["FlechetteDragCoef"])
	Crate:SetNWFloat( "FillerMass", 0 )

	--For propper bullet model
	Crate:SetNWFloat( "BulletModel", Round.model )

end

function Round.cratetxt( BulletData )

	local DData = Round.getDisplayData(BulletData)

	local inaccuracy = 0
	local Gun = ACF.Weapons.Guns[BulletData.Id]

	if Gun then
		local Classes = ACF.Classes
		inaccuracy = (Classes.GunClass[Gun.gunclass] or {spread = 0}).spread
	end

	local coneAng = inaccuracy * ACF.GunInaccuracyScale

	local str =
	{
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Max Penetration: ", math.floor(DData.MaxPen), " mm\n",
		"Max Spread: ", math.ceil((BulletData.FlechetteSpread + coneAng) * 10) / 10, " deg"
	}

	return table.concat(str)

end

function Round.propimpact( _, Bullet, Target, HitNormal, HitPos, Bone )

	if ACF_Check( Target ) then

		local Speed	= Bullet["Flight"]:Length() / ACF.VelScale
		local Energy	= ACF_Kinetic( Speed , Bullet["ProjMass"], Bullet["LimitVel"] )
		local HitRes	= ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )

		if HitRes.Overkill > 0 then

			table.insert( Bullet["Filter"] , Target )				--"Penetrate" (Ingoring the prop for the retry trace)

			Bullet.Flight = Bullet.Flight:GetNormalized() * (Energy.Kinetic * (1-HitRes.Loss) * 2000 / Bullet["ProjMass"]) ^ 0.5 * 39.37

			return "Penetrated"
		elseif HitRes.Ricochet then

			return "Ricochet"
		else
			return false
		end
	else
		table.insert( Bullet["Filter"] , Target )
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

	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist["FL"] )

	ACE_UpperCommonDataDisplay()

	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("Flechettes",2,3,128,0, "Flechettes", "")	--flechette count Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FlechetteSpread",10,5,60,1, "Flechette Spread", "")	--flechette spread Slider (Name, Value, Min, Max, Decimals, Title, Desc)

	ACE_CommonDataDisplay()

	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel )

	local PlayerData = {}
		PlayerData["Id"]			= acfmenupanel.AmmoData["Data"]["id"]		--AmmoSelect GUI
		PlayerData["Type"]		= "FL"									--Hardcoded, match as Round.Type instead
		PlayerData["PropLength"]	= acfmenupanel.AmmoData["PropLength"]  --PropLength slider
		PlayerData["ProjLength"]	= acfmenupanel.AmmoData["ProjLength"]  --ProjLength slider
		PlayerData["Data5"]		= acfmenupanel.AmmoData["Flechettes"]	--Flechette count slider
		PlayerData["Data6"]		= acfmenupanel.AmmoData["FlechetteSpread"]	--flechette spread slider

		PlayerData.Tracer	= acfmenupanel.AmmoData.Tracer
		PlayerData.TwoPiece	= acfmenupanel.AmmoData.TwoPiece

	local Data = Round.convert( Panel, PlayerData )

	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData["Data"]["id"] )
	RunConsoleCommand( "acfmenu_data2", PlayerData["Type"] )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )	--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )	--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data5", Data.Flechettes )
	RunConsoleCommand( "acfmenu_data6", Data.FlechetteSpread )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	RunConsoleCommand( "acfmenu_data11", Data.TwoPiece )

	acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data["MaxTotalLength"],3, "Propellant Length", "Propellant Mass : " .. (math.floor(Data.PropMass * 1000)) .. " g" )	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data["MaxTotalLength"],3, "Projectile Length", "Projectile Mass : " .. (math.floor(Data.ProjMass * 1000)) .. " g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("Flechettes",Data.Flechettes,Data.MinFlechettes,Data.MaxFlechettes,0, "Flechettes", "Flechette Radius: " .. math.Round(Data["FlechetteRadius"] * 10,2) .. " mm")
	acfmenupanel:AmmoSlider("FlechetteSpread",Data.FlechetteSpread,Data.MinSpread,Data.MaxSpread,1, "Flechette Spread", "")

	ACE_UpperCommonDataDisplay( Data, PlayerData )
	ACE_CommonDataDisplay( Data )
end

list.Set( "APRoundTypes", "FL", Round )
ACF.RoundTypes[Round.Type] = Round     --Set the round properties
ACF.IdRounds[Round.netid] = Round.Type --Index must equal the ID entry in the table above, Data must equal the index of the table above