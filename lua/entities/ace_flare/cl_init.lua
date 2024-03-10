include("shared.lua")

local FlareSound = "weapons/flaregun/burn.wav"

function ENT:Initialize()

	self.LightUpdate = CurTime() + 0.05
	ACE_EmitSound( FlareSound, self, 80, 100, 1 )
	ParticleEffectAttach("ACFM_Flare",4, self,1)

end

function ENT:Draw()

	self:DrawModel()

	if self:WaterLevel() == 3 then
		self:StopSound( FlareSound )
		self.StopLight = true
	end

	if CurTime() > self.LightUpdate and not self.StopLight then
		self.LightUpdate = CurTime() + 0.05
		ACF_RenderLight(self:EntIndex(), 20000, Color(194, 145, 39), self:GetPos(), 0.1)
	end
end

function ENT:OnRemove()
	self:StopSound( FlareSound )
end


