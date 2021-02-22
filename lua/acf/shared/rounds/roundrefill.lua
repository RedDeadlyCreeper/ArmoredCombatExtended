
AddCSLuaFile()

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = '[Supply] - '..ACFTranslation.ShellRef[1] --Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl" --Shell flight model
Round.desc = ACFTranslation.ShellRef[2]

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
	
	local BulletData = {}
		BulletData.Id = "7.62mmMG"
		BulletData.Type = "Refill"
		
		BulletData.Caliber = 1
		BulletData.ProjMass = 1 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		BulletData.PropMass = 1 --Volume of the case as a cylinder * Powder density converted from g to kg
		BulletData.FillerMass = 0
		BulletData.DragCoef = 0
		BulletData.Tracer = 0
		BulletData.MuzzleVel = 0
		BulletData.RoundVolume = 1
			
	return BulletData
	
end


function Round.getDisplayData(Data)
	return {}
end


function Round.network( Crate, BulletData )
	
	Crate:SetNWString( "AmmoType", "Refill" )
	Crate:SetNWString( "AmmoID", BulletData.Id )
	Crate:SetNWFloat( "Caliber", BulletData.Caliber )
	Crate:SetNWFloat( "ProjMass", BulletData.ProjMass )
	Crate:SetNWFloat( "FillerMass", BulletData.FillerMass )
	Crate:SetNWFloat( "PropMass", BulletData.PropMass )
	Crate:SetNWFloat( "DragCoef", BulletData.DragCoef )
	Crate:SetNWFloat( "MuzzleVel", BulletData.MuzzleVel )
	Crate:SetNWFloat( "Tracer", BulletData.Tracer )
	
end

function Round.cratetxt( BulletData )
	
	return ""
	
end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect()
	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)		
	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel, Table )
		
	RunConsoleCommand( "acfmenu_data1", acfmenupanel.CData.AmmoId )
	RunConsoleCommand( "acfmenu_data2", "Refill")
		
	acfmenupanel.CustomDisplay:PerformLayout()
	
end

list.Set( "SPECSRoundTypes", "Refill", Round ) 
list.Set( "ACFRoundTypes", "Refill", Round )  --Set the round properties
