
local ClassName = "Wire"

ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Dumb)
ACF.Guidance[ClassName] = this

this.Name = ClassName

-- Length of the guidance wire
this.WireLength = 19685^2			-- about 500m

-- Disables guidance when true
this.WireSnapped = false

this.desc = "This guidance package is controlled by the launcher, which reads a target-position and steers the munition towards it. Has a limited guidance distance."

function this:Init()

end

-- Use this to make sure you don't alter the shared default filter unintentionally
function this:GetSeekFilter()
	if self.Filter == self.DefaultFilter then
		self.Filter = table.Copy(self.DefaultFilter)
	end

	return self.Filter
end

function this:Configure()

	self.WireSnapped = false

end

function this:GetGuidance(missile)

	local launcher = missile.Launcher

	if not IsValid(launcher) then
		return {}
	end

	local posVec = launcher.TargPos

	local launcherPos = launcher:GetPos()
	local distMsl = missile:GetPos():DistToSqr(launcherPos)		-- We're using squared distance to optimise

	if distMsl > self.WireLength then
		self.WireSnapped = true
		return {TargetPos = nil}
	end


	if not posVec or posVec == Vector() or self.WireSnapped then
		return {TargetPos = nil}
	--else
	--	local distTrgt = posVec:DistToSqr(launcherPos)
	--	if distMsl > distTrgt then
	--		return {TargetPos = nil}
	--	end
	end


	self.TargetPos = posVec
	return {TargetPos = posVec}

end

function this:GetDisplayConfig()
	return {["Wire Length"] = math.Round(math.sqrt(self.WireLength) / 39.37, 1) .. " m"}
end
