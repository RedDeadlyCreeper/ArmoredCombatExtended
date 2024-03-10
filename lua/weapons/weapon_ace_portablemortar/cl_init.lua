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
--	local fusedelay = self:GetFuseDelay()
	local Tx = self:GetPx()
	local ST = self:GetPy()
	local Tg = self:GetPg()

	if Zoom then

		local RT = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * 50000, {owner})

		local RDist = 9999

		if RT.Hit then
			local difpos = RT.HitPos - owner:GetShootPos()
			RDist = ( difpos * Vector(1,1,0) ):Length() / 39.37
		end


--			surface.SetDrawColor(Color(255, 0, 0, 255 - inaccuracy * 150))

		if ST == 2 then
			surface.SetDrawColor(Color(150, 150, 150, 255))
		else
			surface.SetDrawColor(Color(150, 30, 30, 255))
		end

		surface.DrawCircle(x + 2, y + 2, 20)

--			surface.SetDrawColor(Color(150, 0, 0, 255))

		surface.DrawRect(x + 1, y + 1, 3,3)

		surface.SetDrawColor(Color(150, 30, 30, 255))
		surface.SetTextColor( 85, 30, 30 )

		surface.SetTextPos( x + 250, y )
		surface.DrawText( "RNG: " .. math.Round(RDist,0) .. "m")

		surface.SetTextPos( x - 20, y + 120 )
		surface.DrawText( "" .. math.Round(Tx,0) .. "m")

		local GVel = 84

		if Tx < 100 then --If chain. Deal with it.
			GVel = 47.15

			surface.SetDrawColor(Color(255, 0, 0, 255))
			surface.DrawRect(x - 330, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 320, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 310, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 300, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 290, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 280, y + 180, 8,20)

		elseif  Tx < 200  then
			GVel = 56.25

			surface.SetDrawColor(Color(255, 0, 0, 255))
			surface.DrawRect(x - 330, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 94, 0))
			surface.DrawRect(x - 320, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 310, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 300, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 290, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x-280, y + 180, 8,20)

		elseif  Tx < 300  then
			GVel = 67

			surface.SetDrawColor(Color(255, 0, 0, 255))
			surface.DrawRect(x - 330, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 94, 0))
			surface.DrawRect(x - 320, y + 180, 8,20)

			surface.SetDrawColor(Color(215, 185, 0))
			surface.DrawRect(x - 310, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 300, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 290, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 280, y + 180, 8,20)

		elseif  Tx < 400  then
			GVel = 79

			surface.SetDrawColor(Color(255, 0, 0, 255))
			surface.DrawRect(x - 330, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 94, 0))
			surface.DrawRect(x - 320, y + 180, 8,20)

			surface.SetDrawColor(Color(215, 185, 0))
			surface.DrawRect(x - 310, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 200, 0))
			surface.DrawRect(x - 300, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x - 290, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x-280, y + 180, 8,20)

		elseif  Tx < 500  then
			GVel = 89

			surface.SetDrawColor(Color(255, 0, 0, 255))
			surface.DrawRect(x-330, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 94, 0))
			surface.DrawRect(x-320, y + 180, 8,20)

			surface.SetDrawColor(Color(215, 185, 0))
			surface.DrawRect(x-310, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 200, 0))
			surface.DrawRect(x-300, y + 180, 8,20)

			surface.SetDrawColor(Color(81, 255, 0))
			surface.DrawRect(x-290, y + 180, 8,20)

			surface.SetDrawColor(Color(60, 0, 0, 255))
			surface.DrawRect(x-280, y + 180, 8,20)

		elseif  Tx < 700  then
			GVel = 106.7

			surface.SetDrawColor(Color(255, 0, 0, 255))
			surface.DrawRect(x-330, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 94, 0))
			surface.DrawRect(x-320, y + 180, 8,20)

			surface.SetDrawColor(Color(215, 185, 0))
			surface.DrawRect(x-310, y + 180, 8,20)

			surface.SetDrawColor(Color(255, 200, 0))
			surface.DrawRect(x-300, y + 180, 8,20)

			surface.SetDrawColor(Color(81, 255, 0))
			surface.DrawRect(x-290, y + 180, 8,20)

			surface.SetDrawColor(Color(0, 191, 255))
			surface.DrawRect(x-280, y + 180, 8,20)

		else
			GVel = 126.7

			surface.SetDrawColor(Color(255, 0, 255))
			surface.DrawRect(x-331, y + 180, 60,20)

		end

		surface.SetTextPos( x - 350, y + 160 )
		surface.DrawText( "Vel: " .. math.Round(GVel,0) .. "m/s")

		Tx = Tx - 7 --Because of the incline of the shells near the end of their flight, this helps bring back the distribution a smidge. It just feels right

		local calculatedAngle = (math.atan( (GVel^2 + math.sqrt(GVel^4 - Tg * ( Tg * Tx^2))) / (Tg * Tx) ))
		local ShellTime = 2 * ( GVel / Tg) * math.sin(calculatedAngle)

		surface.SetTextPos( x - 350, y-10 )
		surface.DrawText( "Ang: " .. math.Round(-calculatedAngle * 180 / math.pi,0) .. " deg")

		surface.SetTextPos( x - 350, y + 20 )
		surface.DrawText( "Travel: " .. math.Round(ShellTime,2) .. "s")


		local eEye = owner:EyeAngles()
		local eyeYaw = 180 - eEye.y

		surface.SetTextPos( x - 45, y-250 )
		surface.DrawText( "-  " .. math.Round(eyeYaw) .. "  +")


		surface.SetTextPos( x + 260 , y + 170 )
		surface.DrawText( "" .. owner:GetAmmoCount( "CombineCannon" ) .. " Shells")

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