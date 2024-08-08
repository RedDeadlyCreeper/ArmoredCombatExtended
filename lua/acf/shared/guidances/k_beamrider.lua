
local ClassName = "Beam_Riding"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Wire)
ACF.Guidance[ClassName] = this

this.Name = ClassName

-- Cone to retain targets within.
this.ViewCone = 30

this.desc = "This guidance package directs the missile to keep it in line with the sight as if it were riding a beam. Results in a fast traveltime."

this.GuidanceEntity = nil


function this:Init()

end




function this:Configure(missile)

	self:super().Configure(self, missile)

	self.ViewCone = ACF_GetGunValue(missile.BulletData, "viewcone") or this.ViewCone
	self.ViewConeCos = math.cos(math.rad(self.ViewCone))
	self.GuidanceEntity = missile.Launcher

end




function this:GetGuidance(missile)

	--local posVec = missile.Launcher.TargPos

	--if not posVec or type(posVec) ~= "Vector" or posVec == Vector() then
	--	return {TargetPos = nil}
	--end

	if not IsValid(self.GuidanceEntity) then return {TargetPos = nil} end

	local GEntPos = self.GuidanceEntity:GetPos()
	local GEntDir = self.GuidanceEntity:GetForward()

	local Dist = GEntPos:Distance(missile:GetPos())


	self.TargetPos = GEntPos + GEntDir * (Dist + 39.37 * 15)
	return {TargetPos = self.TargetPos, ViewCone = self.ViewCone}

end

--Another Stupid Workaround. Since guidance degrees are not loaded when ammo is created
function this:GetDisplayConfig(Type)

	local Guns = ACF.Weapons.Guns
	local GunTable = Guns[Type]
	local ViewCone = GunTable.viewcone and (GunTable.viewcone * 2) or 0

	return
	{
		["Tracking"] = math.Round(ViewCone, 1) .. " deg"
	}
end
