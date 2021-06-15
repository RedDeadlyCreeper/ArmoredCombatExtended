
local ClassName = "Infrared"


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

-- This instance must wait this long between target seeks.
this.SeekDelay = 0.5 -- Re-seek drastically reduced cost so we can re-seek

--Sensitivity of the IR Seeker, higher sensitivity is for aircraft
this.SeekSensitivity = 1

--Defines how many degrees are required above the ambient one to consider a target
this.HeatAboveAmbient = 5

-- Minimum distance for a target to be considered
this.MinimumDistance = 200	-- ~5m

-- Maximum distance for a target to be considered.
this.MaximumDistance = 20000

this.desc = "This guidance package detects a target-position infront of itself, and guides the munition towards it. It has a larger seek cone than a radar seeker but a smaller range."


function this:Init()
	self.LastSeek = CurTime() - self.SeekDelay - 0.000001
	self.LastTargetPos = Vector()
end




function this:Configure(missile)
    
    self:super().Configure(self, missile)
	
    self.ViewCone = (ACF_GetGunValue(missile.BulletData, "viewcone") or this.ViewCone)*1.2
	self.ViewConeCos = (math.cos(math.rad(self.ViewCone)))*1.2
    self.SeekCone = (ACF_GetGunValue(missile.BulletData, "seekcone") or this.SeekCone)*1.2
    self.SeekSensitivity = ACF_GetGunValue(missile.BulletData, "seeksensitivity") or this.SeekSensitivity
	
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
	local targetPos = self.Target:GetPos() + Vector(0,0,25)

	local mfo       = missile:GetForward()
	local mdir      = (targetPos - missilePos):GetNormalized()
	local dot       = mfo:Dot(mdir)
	
	if dot < self.ViewConeCos then
		self.Target = nil
		return {}
	else
        self.TargetPos = targetPos
		--print(self.TargetPos)
		return {TargetPos = targetPos, ViewCone = self.ViewCone*1.3}
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

--	if not (self.Target or self.Override) then	
		local target = self:AcquireLock(missile)

		if IsValid(target) then 
			self.Target = target
		end
--	end
	
end

function this:GetWhitelistedEntsInCone(missile)

	local missilePos = missile:GetPos()
	local foundAnim = {}
	  
	local ScanArray = ACE.contraptionEnts

	for k, scanEnt in pairs(ScanArray) do

		if not IsValid(scanEnt) then goto cont end -- skip any invalid entity
		    
		local entpos = scanEnt:GetPos()
		local difpos = entpos - missilePos
		local dist = difpos:Length()
            
		if dist < self.MinimumDistance then goto cont end -- skip any ent outside of minimun distance
					
        if dist > self.MaximumDistance then goto cont end -- skip any ent far than maximum distance
        --print("InDist")
		local LOStr = util.TraceLine( {start = missilePos ,endpos = entpos,collisiongroup  = COLLISION_GROUP_WORLD,filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end}) --Hits anything world related.			

		if not LOStr.Hit then --Trace did not hit world	

			table.insert(foundAnim, scanEnt)

		end		
		
		::cont::
	end
    
    return foundAnim
    
end

-- Return the first entity found within the seek-tolerance, or the entity within the seek-cone closest to the seek-tolerance.
function this:AcquireLock(missile)

	local curTime = CurTime()
    
	if self.LastSeek + self.SeekDelay > curTime then return nil end
        --print("tried seeking within timeout period")
  
	self.LastSeek = curTime

----Part 1: get all ents in cone

	local found = self:GetWhitelistedEntsInCone(missile) or {}
    	
----Part 2: get a good seek target
	if table.Count( found ) > 0 then
	
        local missilePos = missile:GetPos()

	    local bestAng = 0
	    local bestent = nil
    
	    for k, classifyent in pairs(found) do
				
		    local entpos = classifyent:GetPos()
		    local difpos = entpos - missilePos
		    local dist = difpos:Length()
		    local entvel = classifyent:GetVelocity()

		    local Heat
		
		
----------------if the target is a Heat Emitter, track its heat		
	    
		    if classifyent.Heat then 
			    
			    Heat = self.SeekSensitivity * classifyent.Heat 
			
----------------if not is a Heat Emitter, track the friction's heat			
		    else
			
			    local physEnt = classifyent:GetPhysicsObject()
		
----------------check if it's not frozen		
	            if not physEnt:IsMoveable() then goto cont end
				
				Heat = ACE_InfraredHeatFromProp( self, classifyent , dist )
			
		    end
		
		    if Heat <= ACE.AmbientTemp + self.HeatAboveAmbient then goto cont end --Hotter than AmbientTemp in deg C. 
               
		    local ang = missile:WorldToLocalAngles((entpos - missilePos):Angle())	--Used for testing if inrange
		    local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much
            	
			if (absang.p < self.SeekCone and absang.y < self.SeekCone) then --Entity is within missile cone
					
				local testang = Heat + (360-(absang.p + absang.y)) --Could do pythagorean stuff but meh, works 98% of time
									
				if testang > bestAng then --Sorts targets as closest to being directly in front of radar
					--print('locking')
									
				    bestAng = testang
				    bestent = classifyent
									    
				end

			end
				
			::cont::
	    end
        
	    if not bestent then return nil end
	    return bestent
		
	end
end

function this:GetDisplayConfig()
	return 
	{
		["Seeking"] = math.Round(self.SeekCone * 2*1.3, 1) .. " deg",
		["Tracking"] = math.Round(self.ViewCone * 2*1.3, 1) .. " deg"
	}
end