AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
 
include ('shared.lua')

SWEP.DeployDelay = 4 --No more rocket 2 taps or sprinting lawnchairs

function SWEP:Equip()

	self.Owner:GiveAmmo( 24*self.Primary.ClipSize, self.Primary.Ammo	, false )
	self:DoAmmoStatDisplay()
	self:SetNextPrimaryFire( CurTime() + self.DeployDelay )
end