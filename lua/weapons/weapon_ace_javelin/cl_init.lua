include("shared.lua")

function SWEP:DoDrawCrosshair(x, y)
	local Zoom = self:GetZoomState()
	local LaunchAuth = self:GetLaunchAuth()

--	self:DrawScope(Zoom)

	local owner = self:GetOwner()
	local inaccuracy = math.min(owner:GetVelocity():Length() / owner:GetRunSpeed(), 1)
	local VectorPos = Vector(self:GetTarPosX(), self:GetTarPosY(), self:GetTarPosZ())
	inaccuracy = math.max(inaccuracy, self.Heat / self.HeatMax)

	if Zoom then
		--	surface.DrawCircle( x, y, 215, Color( 255, 120, 0 ) )
		local tempcolor = Color(255, 200, 200, 255)
		local tempcolor2 = Color(255, 0, 0, 0)
		local thickness = 2

		if LaunchAuth then
			tempcolor = Color(150, 0, 0)
			tempcolor2 = Color(255, 0, 0, 255)
			thickness = 3
		end

		local rectSize = 85
		surface.SetDrawColor(tempcolor)
		surface.DrawOutlinedRect(x - rectSize, y - rectSize, rectSize * 2, rectSize * 2, thickness)

		--Draw basic crosshair that increases in size with Inaccuracy Accumulation
		local tarpos2d = VectorPos:ToScreen()
		tarpos2d = Vector(math.floor(tarpos2d.x + 0.5), math.floor(tarpos2d.y + 0.5), 0)
		rectSize = 15
		thickness = 2

		if self:GetLockProgress() > 0 then
			surface.DrawOutlinedRect(x + math.Clamp(tarpos2d.x - x, -215, 215) - rectSize, y + math.Clamp(tarpos2d.y - y, -215, 215) - rectSize, rectSize * 2, rectSize * 2, thickness)
		end

		surface.SetDrawColor(tempcolor2)
		surface.DrawLine(tarpos2d.x - 50000, tarpos2d.y, tarpos2d.x + 50000, tarpos2d.y)
		surface.DrawLine(tarpos2d.x, tarpos2d.y - 50000, tarpos2d.x, tarpos2d.y + 50000)
		surface.SetFont("DermaLarge")

		rectSize = 1000
		surface.SetDrawColor(50, 50, 50, 255)
		surface.DrawOutlinedRect(x - rectSize * 1.1, y - rectSize, rectSize * 2 * 1.1, rectSize * 2, 600, Color(255, 120, 0))


		rectSize = 1500
		surface.DrawOutlinedRect(x - rectSize, y - rectSize, rectSize * 2, rectSize * 2, 600, Color(255, 120, 0))
		surface.SetDrawColor(30, 30, 30, 255)

		rectSize = 700
		surface.DrawOutlinedRect(x - rectSize * 1.15, y - rectSize, rectSize * 2 * 1.15, rectSize * 2, 280, Color(255, 120, 0))
		surface.DrawOutlinedRect(x - rectSize * 1.15, y - rectSize * 1, rectSize * 2 * 1.15, rectSize * 2, 250, Color(255, 120, 0))


		rectSize = 50
		--Active Lights
		surface.SetDrawColor(0, 255, 0, 255)
		surface.DrawOutlinedRect(x - rectSize - 400, y - rectSize - 480, rectSize * 2, rectSize * 2, 7)
		surface.DrawOutlinedRect(x - rectSize + 135, y - rectSize - 480, rectSize * 2, rectSize * 2, 7)
		surface.DrawOutlinedRect(x - rectSize - 630, y - rectSize + 270, rectSize * 2, rectSize * 2, 7)
		surface.DrawOutlinedRect(x - rectSize + 400, y - rectSize - 480, rectSize * 2, rectSize * 2, 7)
		surface.DrawOutlinedRect(x - rectSize - 400, y - rectSize + 480, rectSize * 2, rectSize * 2, 7)

		--Inactive Lights
		surface.SetDrawColor(0, 60, 0, 255)
		surface.DrawOutlinedRect(x - rectSize - 135, y - rectSize - 480, rectSize * 2, rectSize * 2, 7)
		surface.DrawOutlinedRect(x - rectSize - 630, y - rectSize - 270, rectSize * 2, rectSize * 2, 7)
		surface.DrawOutlinedRect(x - rectSize + 630, y - rectSize + 270, rectSize * 2, rectSize * 2, 7)

		--Red Light
		--Inactive Red
		surface.SetDrawColor(75, 0, 0, 255)
		surface.DrawOutlinedRect(x - rectSize - 135, y - rectSize + 480, rectSize * 2, rectSize * 2, 7)

		if LaunchAuth then
			surface.DrawOutlinedRect(x - rectSize + 400, y - rectSize + 480, rectSize * 2, rectSize * 2, 7)
			surface.DrawOutlinedRect(x - rectSize - 630, y - rectSize - 0, rectSize * 2, rectSize * 2, 7)
			surface.SetDrawColor(0, 255, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 135, y - rectSize + 480, rectSize * 2, rectSize * 2, 7)
		else
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 400, y - rectSize + 480, rectSize * 2, rectSize * 2, 7)
			surface.DrawOutlinedRect(x - rectSize - 630, y - rectSize - 0, rectSize * 2, rectSize * 2, 7)
			surface.SetDrawColor(0, 60, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 135, y - rectSize + 480, rectSize * 2, rectSize * 2, 7)
		end

		surface.SetDrawColor(100, 0, 0, 255)
		surface.DrawOutlinedRect(x - 30 + 400, y - 7 + 480, 30 * 2, 7 * 2, 4)
		surface.SetDrawColor(0, 150, 0, 255)
		surface.DrawOutlinedRect(x - 30 + 135, y - 7 + 480, 30 * 2, 7 * 2, 4)

		--local difpos = owner
		--local rangecalc = 1
		local d = VectorPos - owner:GetPos()
		local range = d:Length()

		if range < self.DirectFireDist then
			surface.SetDrawColor(0, 60, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 630, y - rectSize - 270, rectSize * 2, rectSize * 2, 7)
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 630, y - rectSize - 0, rectSize * 2, rectSize * 2, 7)
		else
			surface.SetDrawColor(0, 255, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 630, y - rectSize - 270, rectSize * 2, rectSize * 2, 7)
			surface.SetDrawColor(75, 0, 0, 255)
			surface.DrawOutlinedRect(x - rectSize + 630, y - rectSize - 0, rectSize * 2, rectSize * 2, 7)
		end

		--Green Text
		surface.SetTextColor(0, 150, 0)
		surface.SetTextPos(x - 427, y - 494)
		surface.DrawText("DAY")

		surface.SetTextPos(x + 100, y - 494)
		surface.DrawText("NFOV")

		surface.SetTextPos(x - 662, y + 255)
		surface.DrawText("CLU+")

		surface.SetTextPos(x + 368, y - 494)
		surface.DrawText("SEEK")

		surface.SetTextPos(x - 427, y + 466)
		surface.DrawText("BCU")

		surface.SetTextPos(x - 170, y - 494)
		surface.DrawText("WFOV")

		surface.SetTextPos(x - 670, y - 285)
		surface.DrawText("NIGHT")

		surface.SetTextPos(x + 599, y + 255)
		surface.DrawText("FLTR")

		surface.SetTextPos(x + 605, y - 285)
		surface.DrawText("TOP")

		--Red Text
		surface.SetTextColor(150, 0, 0)
		surface.SetTextPos(x - 657, y - 15)
		surface.DrawText("CLU")

		surface.SetTextPos(x - 170, y + 450)
		surface.DrawText("HANG")

		surface.SetTextPos(x - 164, y + 475)
		surface.DrawText("FIRE")

		surface.SetTextPos(x + 608, y - 15)
		surface.DrawText("DIR")
	end

	return true
end
