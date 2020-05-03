include('shared.lua')
 
Aimscale = 1

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

function SWEP:DrawReticule()

	local screenpos = trace.HitPos:ToScreen()
	
	screenpos = Vector(math.floor(screenpos.x + 0.5), math.floor(screenpos.y + 0.5), 0)

	local circlehue = Color(255, 255, 255, 100)
	local radius = 15
	local CrosshairLength = 50
	
	surface.SetDrawColor(Color(0, 0, 0, circlehue.a))
	surface.DrawRect((screenpos.x - radius - CrosshairLength - 1), screenpos.y - 1, CrosshairLength + 3, 3)
	surface.DrawRect((screenpos.x + radius - 1), screenpos.y - 1, CrosshairLength + 2, 3)
	surface.DrawRect(screenpos.x - 1, (screenpos.y - radius - CrosshairLength - 1), 3, CrosshairLength + 3)
	surface.DrawRect(screenpos.x - 1, (screenpos.y + radius - 1), 3, CrosshairLength + 2)
	
	surface.SetDrawColor(circlehue)
	surface.DrawLine((screenpos.x + radius), screenpos.y, (screenpos.x + (radius + CrosshairLength)), screenpos.y)
	surface.DrawLine((screenpos.x - radius), screenpos.y, (screenpos.x - (radius + CrosshairLength) - 1), screenpos.y)
	surface.DrawLine(screenpos.x, (screenpos.y + radius), screenpos.x, (screenpos.y + (radius + CrosshairLength)))
	surface.DrawLine(screenpos.x, (screenpos.y - radius), screenpos.x, (screenpos.y - (radius + CrosshairLength) - 1))
	
	
	--draw.Arc(screenpos.x, screenpos.y, radius, -1.5, (1-progress)*360, 360, 5, circlehue)
	
end

--[[
hook.Add( "HUDPaint", "Circle", function()
	local center = Vector( ScrW() / 2, ScrH() / 2, 0 )
	local scale = Vector( 100, 100, 0 )
	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
	surface.SetDrawColor( 255, 0, 0, 255 )
 
	surface.DrawLine((center.x + 15), center.y, (center.x + (0)), center.y)

--	for a = 0, 360 - segmentdist, segmentdist do
--		surface.DrawLine( center.x + math.cos( math.rad( a ) ) * scale.x, center.y - math.sin( math.rad( a ) ) * scale.y, center.x + math.cos( math.rad( a + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( a + segmentdist ) ) * scale.y )
--	end


end )
--]]





