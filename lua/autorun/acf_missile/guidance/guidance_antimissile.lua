
local ClassName = "Antimissile"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Wire)
ACF.Guidance[ClassName] = this

---


this.Name = ClassName

--Currently acquired target.
this.Target = nil

-- Cone to acquire targets within.
this.SeekCone = 20

-- Cone to retain targets within.
this.ViewCone = 25

-- Targets this close to the front are good enough.
this.SeekTolerance = math.cos( math.rad( 2 ) )

-- This instance must wait this long between target seeks.
this.SeekDelay = 100000 -- The re-seek cycle is expensive, let's disable it until we figure out some optimization.
--note that we halved this, making anti-missiles expensive relatively

-- Delay between re-seeks if an entity is provided via wiremod.
this.WireSeekDelay = 0.1

-- Minimum distance for a target to be considered
this.MinimumDistance = 196.85	--a scant 5m

-- Entity class whitelist
-- thanks to Sestze for the listing.
this.DefaultFilter = 
{
	acf_missile					= true
}


this.desc = "This guidance package detects a missile in front of itself, and guides the munition towards it."



function this:Init()
	self.LastSeek = CurTime() - self.SeekDelay - 0.000001
    --self.Filter = self.DefaultFilter
	self.Filter = table.Copy(self.DefaultFilter)
	self.LastTargetPos = Vector()
end




function this:Configure(missile)
    
    self:super().Configure(self, missile)
    
    self.ViewCone = ACF_GetGunValue(missile.BulletData, "viewcone") or this.ViewCone
	self.ViewConeCos = math.cos(math.rad(self.ViewCone))
    self.SeekCone = ACF_GetGunValue(missile.BulletData, "seekcone") or this.SeekCone
    
end



-- Use this to make sure you don't alter the shared default filter unintentionally
function this:GetSeekFilter(class)
    if self.Filter == self.DefaultFilter then
        self.Filter = table.Copy(self.DefaultFilter)
    end
    
    return self.Filter
end




function this:GetNamedWireInputs(missile)

    local launcher = missile.Launcher
    local outputs = launcher.Outputs

    local names = {}
    
    if outputs.Target and outputs.Target.Type == "ENTITY" then
        names[#names+1] = "Target"
    end
    
    return names

end




function this:GetFallbackWireInputs()

    -- Can't scan for entity outputs: a lot of ents have self-outputs.
    return {}

end




--TODO: still a bit messy, refactor this so we can check if a flare exits the viewcone too.
function this:GetGuidance(missile)

	self:PreGuidance(missile)
	
	local override = self:ApplyOverride(missile)
	if override then return override end

	self:CheckTarget(missile)
	
	if not IsValid(self.Target) then 
		return {} 
	end

	local missilePos = missile:GetPos()
	local missileForward = missile:GetForward()
	local targetPhysObj = self.Target:GetPhysicsObject()
	local targetPos = self.Target:GetPos()
	
	-- this was causing radar to break in certain conditions, usually on parented props.
	--if IsValid(targetPhysObj) then
		--targetPos = util.LocalToWorld( self.Target, targetPhysObj:GetMassCenter(), nil )
	--end

	local mfo       = missile:GetForward()
	local mdir      = (targetPos - missilePos):GetNormalized()
	local dot       = mfo:Dot(mdir)
	
	if dot < self.ViewConeCos then
		self.Target = nil
		return {}
	else
        self.TargetPos = targetPos
		return {TargetPos = targetPos, ViewCone = self.ViewCone}
	end
	
end




function this:ApplyOverride(missile)
	
	if self.Override then
	
		local ret = self.Override:GetGuidanceOverride(missile, self)
		
		if ret then		
			ret.ViewCone = self.ViewCone
			ret.ViewConeRad = math.rad(self.ViewCone)
			return ret
		end
		
	end

end




function this:CheckTarget(missile)

	if not (self.Target or self.Override) then	
		local target = self:AcquireLock(missile)

		if IsValid(target) then 
			self.Target = target
		end
	end
	
end




function this:GetWireTarget(missile)
	
    local launcher = missile.Launcher
    local outputs = launcher.Outputs
    
    if not IsValid(self.InputSource) then 
		return nil
	end
    
    local outputs = self.InputSource.Outputs
    
    if not outputs then
        return nil
	end
    
    
    for k, name in pairs(self.InputNames) do
        
        local outTbl = outputs[name]
        
        if not (outTbl and outTbl.Value) then continue end
        
        local val = outTbl.Value
        
        if IsValid(val) and IsEntity(val) then 
            return val
        end
        
    end
    
end



--ents.findincone not working? weird.
--TODO: add a check on the allents table to ignore if parent is valid
function JankCone (init, forward, range, cone)
	local allents = ents.GetAll()
	local tblout = {}
	
	for k, v in pairs (allents) do
		if not IsValid(v) then continue end
		local dist = (v:GetPos() - init):Length()
		local ang = math.deg(math.acos(math.Clamp(((v:GetPos() - init):GetNormalized()):Dot(forward), -1, 1)))
		if (dist > range) then continue end
		if (ang > cone) then continue end
		
		table.insert(tblout, v)
	end
	return tblout
end




function this:GetWhitelistedEntsInCone(missile)

    local missilePos = missile:GetPos()
	local missileForward = missile:GetForward()
	local minDot = math.cos(math.rad(self.SeekCone))
	
	--local found = ents.FindInCone(missilePos, missileForward, 50000, self.SeekCone)
	local found = JankCone(missilePos, missileForward, 50000, self.SeekCone)
	
	local foundAnim = {}
	local foundEnt
	local minDistSqr = ( self.MinimumDistance * self.MinimumDistance )
	
    local filter = self.Filter
	for i, foundEnt in pairs(found) do
	
		--if not (IsValid(foundEnt) and self.Filter[foundEnt:GetClass()]) then continue end
		if (not IsValid(foundEnt)) or (not self.Filter[foundEnt:GetClass()]) then	continue end
		local foundLocalPos = foundEnt:GetPos() - missilePos
		
		local foundDistSqr = foundLocalPos:LengthSqr()
		if foundDistSqr < minDistSqr then continue end
		
		local foundDot = foundLocalPos:GetNormalized():Dot(missileForward)
		if foundDot < minDot then continue end
		
		table.insert(foundAnim, foundEnt)
		
	end
    
    return foundAnim
    
end




function this:HasLOSVisibility(ent, missile)

	local traceArgs = 
	{
		start = missile:GetPos(),
		endpos = ent:GetPos(),
		mask = MASK_SOLID_BRUSHONLY,
		filter = {missile, ent}
	}
	
	local res = util.TraceLine(traceArgs)
	
	--debugoverlay.Line( missile:GetPos(), ent:GetPos(), 15, Color(res.Hit and 255 or 0, res.Hit and 0 or 255, 0), true )
	
	return not res.Hit

end




-- Return the first entity found within the seek-tolerance, or the entity within the seek-cone closest to the seek-tolerance.
function this:AcquireLock(missile)

	local curTime = CurTime()
    
    if self.LastSeek + self.WireSeekDelay <= curTime then 
    
        local wireEnt = self:GetWireTarget(missile)
        
        if wireEnt then
            --print("wiremod provided", wireEnt)
            return wireEnt
        end
        
    end
    
	if self.LastSeek + self.SeekDelay > curTime then 
        --print("tried seeking within timeout period")
        return nil 
    end
	self.LastSeek = curTime

	-- Part 1: get all whitelisted entities in seek-cone.
	local found = self:GetWhitelistedEntsInCone(missile)
    	
	-- Part 2: get a good seek target
	local foundCt = table.Count(found)
	if foundCt < 2 then 
        --print("shortcircuited and found", found[1])
        return found[1] 
    end
	
    local missilePos = missile:GetPos()
	local missileForward = missile:GetForward()
    
	local mostCentralEnt 
	local lastKey
	
	while not mostCentralEnt do
	
		local ent
		lastKey, ent = next(found, lastKey)
		
		if not ent then break end
		
		if self:HasLOSVisibility(ent, missile) then
			mostCentralEnt = ent
		end
		
	end
	
	if not mostCentralEnt then return nil end
	
	local mostCentralPos = mostCentralEnt:GetPos()
	local highestDot = (mostCentralEnt:GetPos() - missilePos):GetNormalized():Dot(missileForward)
	local currentEnt
	local currentDot
	
	for k, ent in next, found, lastKey do
		
		currentEnt = ent
		currentDot = (currentEnt:GetPos() - missilePos):GetNormalized():Dot(missileForward)
		
		if currentDot > highestDot and self:HasLOSVisibility(currentEnt, missile) then
			mostCentralEnt = currentEnt
			highestDot = currentDot
			
			if currentDot >= self.SeekTolerance then 
                --print("found", mostCentralEnt, "in tolerance")
                return currentEnt 
            end
		end
	end
    
    --print("iterated and found", mostCentralEnt)
    
	return mostCentralEnt
end



function this:GetDisplayConfig()
	return 
	{
		["Seeking"] = math.Round(self.SeekCone * 2, 1) .. " deg",
		["Tracking"] = math.Round(self.ViewCone * 2, 1) .. " deg"
	}
end
