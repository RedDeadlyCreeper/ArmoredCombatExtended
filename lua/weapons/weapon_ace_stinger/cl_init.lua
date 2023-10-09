include("shared.lua")

function SWEP:DoDrawCrosshair(x, y)
	local Zoom = self:GetZoomState()
	local LaunchAuth = self:GetLaunchAuth()

	self:DrawScope(Zoom)

	local owner = self:GetOwner()
	local inaccuracy = math.min(owner:GetVelocity():Length() / owner:GetRunSpeed(), 1)
	local VectorPos = Vector(self:GetTarPosX(), self:GetTarPosY(), self:GetTarPosZ())
	inaccuracy = math.max(inaccuracy, self.Heat / self.HeatMax)

	if Zoom then
		--	surface.DrawCircle( x, y, 215, Color( 255, 120, 0 ) )
		local tempcolor = Color(255, 0, 0)
		local thiccness = 2
		surface.SetDrawColor(255, 120, 0, 255)

		if LaunchAuth then
			tempcolor = Color(0, 150, 0)
			surface.SetDrawColor(0, 255, 0, 255)
			thiccness = 5
		end

		surface.DrawOutlinedRect(x - 215, y - 215, 215 * 2, 215 * 2, thiccness, Color(255, 120, 0))
		--Draw basic crosshair that increases in size with Inaccuracy Accumulation
		local tarpos2d = VectorPos:ToScreen()
		tarpos2d = Vector(math.floor(tarpos2d.x + 0.5), math.floor(tarpos2d.y + 0.5), 0)

		if self:GetLockProgress() > 0 then
			surface.DrawCircle(x + math.Clamp(tarpos2d.x - x, -215, 215), y + math.Clamp(tarpos2d.y - y, -215, 215), 50, tempcolor)
		end

	--	surface.DrawLine(x + ReticleSize + 3, y, x + ReticleSize + 20, y)
	--	surface.DrawLine(x - ReticleSize - 3, y, x - ReticleSize - 20, y)
	--	surface.DrawLine(x, y + ReticleSize + 3, x, y + ReticleSize + 20)
	--	surface.DrawLine(x, y - ReticleSize - 3, x, y - ReticleSize - 20)
	end

	return true
end
