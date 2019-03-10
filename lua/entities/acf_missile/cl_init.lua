include("shared.lua")




function ENT:Initialize()

end




function ENT:Draw()

	self:DrawModel() 
	
	if self:GetNWFloat("LightSize") then	
		self:RenderMotorLight()
	end
	
end




function ENT:RenderMotorLight()

	local idx = self:EntIndex()
	local lightSize = self:GetNWFloat("LightSize") * 175
	local colour = Color(255, 128, 48)
	local pos = self:GetPos() - self:GetForward() * 64
	
	ACFM_RenderLight(idx, lightSize, colour, pos)

end
