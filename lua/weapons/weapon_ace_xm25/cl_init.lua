include("shared.lua")

function SWEP:DrawScope(Zoomed)
	if not (Zoomed and self.HasScope) then return end

	local scrw = ScrW()
	local scrh = ScrH()

	surface.SetDrawColor(0, 0, 0, 255)

	local rectsides = ((scrw - scrh) / 2) * 0.7

	surface.SetMaterial(Material("gmod/scope"))
	surface.DrawTexturedRect(rectsides, 0, scrw - rectsides * 2, scrh)
	surface.DrawRect(0, 0, rectsides + 2, scrh)
	surface.DrawRect(scrw - rectsides - 2, 0, rectsides + 2, scrh)
end


function SWEP:DoDrawCrosshair(x, y)
	local Zoom = self:GetZoomState()
	self:DrawScope(Zoom)

	local owner = self:GetOwner()
	local inaccuracy = math.min(owner:GetVelocity():Length() / owner:GetRunSpeed(), 1)
	inaccuracy = math.max(inaccuracy, self.Heat / self.HeatMax)
	local fusedelay = self:GetFuseDelay()
	local fusedist = self:GetDistance()
	local Tx = self:GetPx()
	local Ty = 0
	local Tg = self:GetPg() / 39.37

		if Zoom then
			surface.SetDrawColor(Color(255, 0, 0, 255 - inaccuracy * 150))

			surface.SetDrawColor(Color(255, 0, 0, 255))

			surface.DrawRect(x, y, 4,4)

			surface.SetFont( "HudDefault" )
			surface.SetTextColor( 150, 0, 0 )
			surface.SetTextPos( x - 280, y )
			surface.DrawText( "ABRST: " .. math.Round(fusedelay,2) .. "s" )

			surface.SetTextPos( x - 280, y - 35 )
			surface.DrawText( "OFST: 2.5m")

			surface.SetTextPos( x + 250, y )
			surface.DrawText( "RNG: " .. math.Round(fusedist,0) .. "m")

			surface.SetTextPos( x + 180, y + 125 )
			surface.SetTextColor( 230, 0, 0 )
			surface.DrawText(self:Clip1())

			local ARC = -1 -- +1 for high, -1 for direct fire
			local GVel = 184.871

			local calculatedAngle = (math.atan( (GVel^2 + ARC * math.sqrt(GVel^4 - Tg * ( Tg * Tx^2 + 2 * Ty * GVel^2))) / (Tg * Tx) )) * 180 / math.pi

			local eEye = owner:EyeAngles()
			local VectorPos = Vector()

			if calculatedAngle > 0 then
			VectorPos = owner:EyePos() + ( Angle(eEye.x,eEye.y,0) + Angle(calculatedAngle,0,0)):Forward() * 2000
			else
			VectorPos = owner:EyePos() + ( Angle(eEye.x,eEye.y,0) + Angle(-calculatedAngle,0,0)):Forward() * 2000
			end
			local tarpos2d = VectorPos:ToScreen()
			tarpos2d = Vector(math.floor(tarpos2d.x + 0.5), math.floor(tarpos2d.y + 0.5), 0)

			surface.DrawRect(x - 35 + (tarpos2d.x - x), y-1 + (tarpos2d.y - y), 30, 3)
			surface.DrawRect(x + 6 + (tarpos2d.x - x), y-1 + (tarpos2d.y - y), 30, 3)
			surface.DrawRect(x-1 + (tarpos2d.x - x), y + 6 + (tarpos2d.y - y), 3, 30)

			surface.SetTextColor( 150, 0, 0 )

			surface.SetTextPos( x + 250, y + 50 )
			surface.DrawText( "ANG: " .. math.Round(calculatedAngle,3) .. "")



			return true
		end

	local ReticleSize = (self.Heat + inaccuracy * 15) / (3 / (owner:Crouching() and self.CrouchRecoilBonus or 1))

	--Draw basic crosshair that increases in size with Inaccuracy Accumulation
	surface.SetDrawColor(255, 0, 0, 255)
	surface.DrawLine(x + ReticleSize + 3, y, x + ReticleSize + 10, y)
	surface.DrawLine(x - ReticleSize - 3, y, x - ReticleSize - 10, y)
	surface.DrawLine(x, y + ReticleSize + 3, x, y + ReticleSize + 10)
	surface.DrawLine(x, y - ReticleSize - 3, x, y - ReticleSize - 10)

	return true
end