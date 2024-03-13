include("shared.lua")




function ENT:Initialize()

	self.LightUpdate = CurTime() + 0.05

end

function ENT:Draw()

	self:DrawModel()

	if CurTime() > self.LightUpdate then
		self.LightUpdate = CurTime() + 0.05
		self:RenderMotorLight()
	end
end

function ENT:RenderMotorLight()

	local idx = self:EntIndex()
	local lightSize = self:GetNWFloat("LightSize") * 175
	local colour = Color(255, 128, 48)
	local pos = self:GetPos() - self:GetForward() * 64

	ACF_RenderLight(idx, lightSize, colour, pos, 1)

end
