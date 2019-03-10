
local ClassName = "Dumb"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewBaseClass()
ACF.Guidance[ClassName] = this

---



this.Name = ClassName


this.desc = "This guidance package is empty and provides no control."


-- an object containing an obj:GetGuidanceOverride(missile, guidance) function
this.Override = nil



this.AppliedSpawnCountermeasures = false


function this:Init()
	
end


function this:Configure(missile)

end


function this:GetGuidance(missile)

	self:PreGuidance(missile)

	return self:ApplyOverride(missile) or {}
	
end


function this:PreGuidance(missile)

	if not self.AppliedSpawnCountermeasures then
	
		ACFM_ApplySpawnCountermeasures(missile, self)
		self.AppliedSpawnCountermeasures = true
		
	end

	ACFM_ApplyCountermeasures(missile, self)

end


function this:ApplyOverride(missile)


end


function this:GetDisplayConfig()
	return {}
end