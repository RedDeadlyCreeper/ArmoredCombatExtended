
AddCSLuaFile()

ACF.AmmoBlacklist.Batt = { "AC", "AL", "C", "HMG", "HW", "MG", "MO", "RAC", "SA", "SC", "SAM", "AAM", "ASM", "BOMB", "FFAR", "UAR", "GBU", "FGL" , "GL", "RM", "AR", "SBC", "ATR", "SL", "ATGM", "ARTY"}

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "ECM Battery (Batt)" --Human readable name
Round.model = "" --Shell flight model
Round.desc = "Battery Charged used in an ECM pod."
Round.netid = 14 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )
	
	ACF_CreateBullet( BulletData )
	
	local bdata = ACF.Bullet[BulletData.Index]
	
	bdata.CreateTime = SysTime()
	
	ACFM_RegisterECM(bdata)
	
end

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
	
	local Data = {}
	local ServerData = {}
	local GUIData = {}
	
	if not PlayerData.PropLength then PlayerData.PropLength = 0 end
	if not PlayerData.ProjLength then PlayerData.ProjLength = 0 end
	if not PlayerData.Data5 then PlayerData.Data5 = 0 end
	if not PlayerData.Data10 then PlayerData.Data10 = 0 end
	
	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )
	
	--Shell sturdiness calcs
	Data.ProjMass = 1
	local Energy = -1
		
	GUIData.FillerVol = 1
	Data.FillerMass = 1
	
	Data.ProjMass = 1
	Data.MuzzleVel = -1
	
	--Random bullshit left
	Data.ShovePower = 0
	Data.PenAera = 1000
	Data.DragCoef = 0
	Data.LimitVel = 700										--Most efficient penetration speed in m/s
	Data.KETransfert = 0.1									--Kinetic energy transfert to the target for movement purposes
	Data.Ricochet = 90										--Base ricochet angle
	
	Data.BurnRate = 1
	Data.DistractChance = 0.35
	Data.BurnTime = 1

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
	
	GUIData.MaxPen = 0
	
	GUIData.BurnRate = 0.1
	GUIData.DistractChance = Data.DistractChance
	GUIData.BurnTime = 1
	
	return GUIData
end


function Round.network( Crate, BulletData )

	Crate:SetNWString( "AmmoType", "Batt" )
	Crate:SetNWString( "AmmoID", BulletData.Id )
	Crate:SetNWFloat( "Caliber", 1 )
	Crate:SetNWFloat( "ProjMass", 0.1 )
	Crate:SetNWFloat( "FillerMass", 1 )
	Crate:SetNWFloat( "PropMass", 1 )
	Crate:SetNWFloat( "DragCoef", 0 )
	Crate:SetNWFloat( "MuzzleVel", -1 )
	Crate:SetNWFloat( "Tracer", 0 )

end

function Round.cratetxt( BulletData )
	
	local DData = Round.getDisplayData(BulletData)
	
	local str = 
	{
		"Burn Duration: ", math.Round(DData.BurnTime, 1), " s\n",
		"Distract Chance: ", math.floor(DData.DistractChance * 100), " %"
	}
	
	return table.concat(str)
	
end

function Round.propimpact( Index, Bullet, Target, HitNormal, HitPos, Bone )
	
	return false
	
end

function Round.worldimpact( Index, Bullet, HitPos, HitNormal )

	return false

end

function Round.endflight( Index, Bullet, HitPos, HitNormal )
	
	ACF_RemoveBullet( Index )
	
end

function Round.endeffect( Effect, Bullet )
	
	-- local Radius = (Bullet.FillerMass)^0.33*8*39.37
	-- local Flash = EffectData()
		-- Flash:SetOrigin( Bullet.SimPos )
		-- Flash:SetNormal( Bullet.SimFlight:GetNormalized() )
		-- Flash:SetRadius( math.max( Radius, 1 ) )
	-- util.Effect( "ACF_Scaled_Explosion", Flash )
	
end

function Round.pierceeffect( Effect, Bullet )
	
	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( 0 )
		Spall:SetMagnitude( 0 )
	util.Effect( "ACF_AP_Penetration", Spall )
	
end

function Round.ricocheteffect( Effect, Bullet )
	
	local Spall = EffectData()
		Spall:SetEntity( Bullet.Crate )
		Spall:SetOrigin( Bullet.SimPos )
		Spall:SetNormal( (Bullet.SimFlight):GetNormalized() )
		Spall:SetScale( 0 )
		Spall:SetMagnitude( 0 )
	util.Effect( "ACF_AP_Ricochet", Spall )
	
end

function Round.guicreate( Panel, Table )
	
	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.Batt )
	
	acfmenupanel:CPanelText("BonusDisplay", "")

	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "")	--Total round length (Name, Desc)
	
	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("BurnRateDisplay", "")	--Proj muzzle penetration (Name, Desc)
	acfmenupanel:CPanelText("BurnDurationDisplay", "")	--HE Blast data (Name, Desc)
	acfmenupanel:CPanelText("DistractChanceDisplay", "")	--HE Fragmentation data (Name, Desc)
	
	Round.guiupdate( Panel, Table )
	
end

function Round.guiupdate( Panel, Table )
	
	local PlayerData = {}
		PlayerData.Id = acfmenupanel.AmmoData.Data.id			--AmmoSelect GUI
		PlayerData.Type = "Batt"										--Hardcoded, match ACFRoundTypes table index
		PlayerData.PropLength = acfmenupanel.AmmoData.PropLength	--PropLength slider
		PlayerData.ProjLength = acfmenupanel.AmmoData.ProjLength	--ProjLength slider
		PlayerData.Data5 = acfmenupanel.AmmoData.FillerVol
		local Tracer = 0
		if acfmenupanel.AmmoData.Tracer then Tracer = 1 end
		PlayerData.Data10 = Tracer				--Tracer
	
	local Data = Round.convert( Panel, PlayerData )
	
	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
	RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )		--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data5", Data.FillerVol )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	
	local vol = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].volume

	acfmenupanel:CPanelText("DistractChanceDisplay", "Distraction Chance : " .. math.floor(Data.DistractChance * 100) .. " %")
	
end

list.Set( "ACFRoundTypes", "Batt", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid, "Batt" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above
