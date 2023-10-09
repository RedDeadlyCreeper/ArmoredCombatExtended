include("shared.lua")

local ACF_GunInfoWhileSeated = CreateClientConVar("ACF_GunInfoWhileSeated", 0, true, false)

function ENT:Initialize()
	self.BaseClass.Initialize(self)
end

function ENT:Draw()
	local lply = LocalPlayer()
	local hideBubble = not ACF_GunInfoWhileSeated:GetBool() and IsValid(lply) and lply:InVehicle()

	self.BaseClass.DoNormalDraw(self, false, hideBubble)
	Wire_Render(self)
end
