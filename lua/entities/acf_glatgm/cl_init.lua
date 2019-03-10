include("shared.lua")







function ENT:Draw()

	self:DrawModel() 
	
	render.SetMaterial(Material("sprites/orangeflare1"))


	local size = 2000*0.025
	render.DrawSprite( self:GetAttachment(1).Pos , size, size, Color( 255, 255, 255, 255 ) )

	
end



