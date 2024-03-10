include("shared.lua")

local FlareSound = "ambient/gas/steam2.wav"

function ENT:Initialize()

	self.LightUpdate = CurTime() + 0.05
	ACE_EmitSound( FlareSound, self, 70, 100, 1 )

	ParticleEffectAttach("ACFM_Flare",4, self,1) --TODO: Create a way to identify chaff/flare.  And make effects scale with flare filler.

end

function ENT:Draw()

	self:DrawModel()

	if self:WaterLevel() == 3 then
		self:StopSound( FlareSound )
		self.StopLight = true
	end

	if CurTime() > self.LightUpdate then
		self.LightUpdate = CurTime() + 0.05
		ACF_RenderLight(self:EntIndex(), 20000, Color(255, 196, 0), self:GetPos(), 0.1)
	end
end

function ENT:OnRemove()
	self:StopSound( FlareSound )
end


