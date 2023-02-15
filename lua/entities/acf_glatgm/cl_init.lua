include("shared.lua")


function ENT:Initialize()

	self.LightUpdate = CurTime() + 0.05

end

function ENT:Draw()

	self:DrawModel()

	render.SetMaterial(Material("sprites/orangeflare1"))


	local size = 2000 * 0.025
	render.DrawSprite( self:GetAttachment(1).Pos , size, size, Color( 255, 255, 255, 255 ) )

	if CurTime() > self.LightUpdate then
		self.LightUpdate = CurTime() + 0.05
		ACF_RenderLight( self:EntIndex(), 750, Color(255, 128, 48), self:GetAttachment(1).Pos)
	end

end



