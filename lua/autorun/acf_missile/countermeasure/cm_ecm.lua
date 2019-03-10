
local ClassName = "ECM"


ACF = ACF or {}
ACF.Countermeasure = ACF.Countermeasure or {}

local this = ACF.Countermeasure[ClassName] or inherit.NewBaseClass()
ACF.Countermeasure[ClassName] = this

---


this.AppliesTo = 
{
	Radar = true
}


-- bulletdata bound to this object
this.ECM = nil


-- chance as a fraction, 0 - 1
this.SuccessChance = 1


-- Can deactivate after time has passed
this.Active = false


-- indicate to ACFM that this should only be applied when guidance is activated or flare is spawned - not per-frame.
this.ApplyContinuous = false




function this:Init()

end




function this:Configure(ecm)

	self.ECM = ecm
	self.SuccessChance = ecm.DistractChance	
	self:UpdateActive()
	
	--print("SuccessChance", self.SuccessChance, "Active", self.Active)

end




function this:UpdateActive()

	local ecm = self.ECM
	
	if not ecm then 
		self.Active = false 
		return 
	end

	self.Active = (ecm.CreateTime + ecm.BurnTime) > SysTime()
	
end




function this:GetGuidanceOverride(missile, guidance)

	if not self.ECM then return end
	
	self:UpdateActive()
	if not self.Active then return end
	
	local activeECM = ACF.Bullet[self.ECM.Index]
	if not (activeECM and activeECM.ECMUID == self.ECM.ECMUID) then return end

	return {TargetPos = self.ECM.Pos + vector(math.random(1,-1)*500,math.random(1,-1)*500,math.random(1,-1)*500), TargetVel = 0}

end




-- TODO: refine formula.
function this:ApplyChance(missile, guidance)
	
	self:UpdateActive()
	
	if not self.Active then return false end
	
	local success = math.random() < self.SuccessChance
	
	--print("Applying chance", math.Round(self.SuccessChance * 100, 1) .. "% : ", success and "success" or "failed")
	
	return success
	
end




-- roll the dice against a missile.  returns true if the flare succeeds in distracting the missile.
-- does not actually apply the effect, just tests the chance of it happening.
-- 'flare' is bulletdata.
function this:TryAgainst(missile, guidance)
	
	if not self.ECM then return end
	
	self:UpdateActive()
	if not self.Active then return end
	
	local cone = guidance.ViewCone
	
	if not cone or cone <= 0 then return end
	
	local pos = missile:GetPos()
	local dir = missile:GetForward()
	
	return ACFM_ConeContainsPos(pos, dir, cone, self.ECM.Pos) and self:ApplyChance(missile, guidance, ecm)
	
end




-- counterpart to ApplyAll.  this takes one flare and applies it to all missiles.
-- returns all missiles which should be affected by this flare.
function this:ApplyToAll()

	if not self.ECM then return {} end

	self:UpdateActive()
	if not self.Active then return {} end
	
	local ret = {}
	
	local targets = ACFM_GetAllMissilesWhichCanSee(self.ECM.Pos)
	
	for k, missile in pairs(targets) do
	
		local guidance = missile.Guidance
		
		if self:ApplyChance(missile, guidance) then
			ret[#ret+1] = missile
		end
	
	end

	return ret
	
end




-- 'static' function to iterate over all flares in flight and return one which affects the guidance.
-- TODO: apply sub-1 chance to distract guidance in ACFM_GetAnyFlareInCone.
function this.ApplyAll(missile, guidance)
	
	local cone = guidance.ViewCone
	
	if not cone or cone <= 0 then return end
	
	local pos = missile:GetPos()
	local dir = missile:GetForward()
	
	local ecms = ACFM_GetECMsInCone(pos, dir, cone)
	
	for k, ecm in pairs(ecms) do
	
		local ret = ecm.ECMObj
	
		if ret:ApplyChance(missile, guidance, ecm) then		
			return ret
		end
		
	end
	
	return nil
	
end



