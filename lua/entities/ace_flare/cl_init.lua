include("shared.lua")




function ENT:Initialize()

	self.LightUpdate = CurTime() + 0.05

end

function ENT:Draw()

	self:DrawModel()

	if self:WaterLevel() == 3 then
		self.StopLight = true
	end

	if CurTime() > self.LightUpdate and not self.StopLight then
		self.LightUpdate = CurTime() + 0.05
		ACF_RenderLight(self:EntIndex(), 20000, Color(194, 145, 39), self:GetPos())
	end
end



