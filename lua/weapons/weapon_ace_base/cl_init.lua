include("shared.lua")

-- ICON BACKGROUND: sprops/textures/sprops_metal5

SWEP.CSMuzzleFlashes = true
SWEP.ViewModelFlip = true

function SWEP:Initialize()
	self.m_bInitialized = true

	self:SetHoldType(self.HoldType)
	self:InitBulletData()
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
		self.AmmoDisplay.PrimaryAmmo = self:Ammo1()
	end

	return self.AmmoDisplay
end

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

	if self.HasScope then
		if Zoom then
			surface.SetDrawColor(Color(0, 0, 0, 255 - inaccuracy * 150))

			local width = 1 + inaccuracy * 7
			surface.DrawRect(x - 1000, y - width / 2 + 1, 2000, width)
			surface.DrawRect(x - width / 2 + 1, y - 1000, width, 2000)

			surface.SetDrawColor(Color(0, 0, 0, 255))

			surface.DrawRect(x - 1000, y, 2000, 2)
			surface.DrawRect(x, y - 1000, 2, 2000)

			return true
		end

		if self:GetClass() == "weapon_ace_awp" or self:GetClass() == "weapon_ace_scout" then return true end
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
