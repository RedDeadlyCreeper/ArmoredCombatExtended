AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()

	self.SpecialDamage = true
	self.Owner = self:GetOwner()
	
	print("hi from fakecrate")
	
end




local nullhit = {Damage = 0, Overkill = 0, Loss = 0, Kill = false}
function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	return table.Copy(nullhit)
end




function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS
	
end




function ENT:RegisterTo(bullet)

		if bullet.BulletData then
			self:SetNetworkedString( "Sound", bullet.Primary and bullet.Primary.Sound or nil)
			self.Owner = bullet:GetOwner()
			self:SetOwner(bullet:GetOwner())
		end
	
	
	self:SetNetworkedInt( "Caliber", bullet.Caliber or 10)
	self:SetNetworkedInt( "ProjMass", bullet.ProjMass or 10)
	self:SetNetworkedInt( "FillerMass", bullet.FillerMass or 0)
	self:SetNetworkedInt( "DragCoef", bullet.DragCoef or 1)
	self:SetNetworkedString( "AmmoType", bullet.Type or "AP")
	self:SetNetworkedInt( "Tracer" , bullet.Tracer or 0)
    
	local col = bullet.Colour or self:GetColor()
	self:SetNWVector( "Color" , Vector(col.r, col.g, col.b))
	self:SetNWVector( "TracerColour" , Vector(col.r, col.g, col.b))
	self:SetColor(col)
	
end


