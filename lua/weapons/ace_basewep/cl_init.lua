include('shared.lua')
 

SWEP.DrawAmmo           = true
SWEP.DrawCrosshair      = true
SWEP.DrawWeaponInfoBox	= true


function SWEP:Initialize()

	if not IsValid(self.Owner) then return end
	self:SetWeaponHoldType( self.HoldType )
	self.defaultFOV = self.Owner:GetFOV()
	
	self.fromPos = Vector(0,0,0)
	self.toPos = Vector(0,0,0)
	
	self.fromAng = Angle(0,0,0)
	self.toAng = Angle(0,0,0)
	
	self.zoomProgress = 1
	
	self:InitBulletData()
    
end


local function GetCurrentACFSWEP()

    if not (LocalPlayer():Alive() or LocalPlayer():InVehicle()) then return end
	local self = LocalPlayer():GetActiveWeapon()

	if not (self.Owner:Alive() or self.Owner:InVehicle()) then return end
    
    return self

end




