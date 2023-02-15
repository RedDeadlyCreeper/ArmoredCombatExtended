AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")


function ENT:Initialize()

	self.SpecialDamage = true

	--print("hi from fakecrate")

end




local nullhit = {Damage = 0, Overkill = 0, Loss = 0, Kill = false}
function ENT:ACF_OnDamage()
	return table.Copy(nullhit)
end




function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end




function ENT:RegisterTo(bullet)

		if bullet.BulletData then
			self:SetNWString( "Sound", bullet.Primary and bullet.Primary.Sound or nil)
			self:CPPISetOwner(bullet:GetOwner())
--			bullet = bullet.BulletData
		end


	self:SetNWInt( "Caliber", bullet.Caliber or 10)
	self:SetNWInt( "ProjMass", bullet.ProjMass or 10)
	self:SetNWInt( "FillerMass", bullet.BoomFillerMass or bullet.FillerMass or 0)
	self:SetNWInt( "DragCoef", bullet.DragCoef or 1)
	self:SetNWString( "AmmoType", bullet.Type or "AP")
	self:SetNWInt( "Tracer" , bullet.Tracer or 1)
--	self:SetNWInt( "Tracer" , 1)

	local col = bullet.Colour or self:GetColor()
	self:SetNWVector( "Color" , Vector(col.r, col.g, col.b))
	self:SetNWVector( "TracerColour" , Vector(col.r, col.g, col.b))
	self:SetColor(col)

end


