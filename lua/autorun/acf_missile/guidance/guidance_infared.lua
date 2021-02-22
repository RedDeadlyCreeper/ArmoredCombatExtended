
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

-- Minimum distance for a target to be considered
this.MinimumDistance = 200	-- ~5m


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

		if(IsValid(scanEnt))then
		    model = scanEnt:GetModel()
			print(model)
			local entpos = scanEnt:GetPos()
			local difpos = entpos - missilePos
			local dist = difpos:Length()

			if dist > self.MinimumDistance then -- Target is outside min seek cone
--					print("InDist")		

					local LOStr = util.TraceLine( {start = missilePos ,endpos = entpos,collisiongroup  = COLLISION_GROUP_WORLD,filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end}) --Hits anything world related.			

					if not LOStr.Hit then --Trace did not hit world	

							table.insert(foundAnim, scanEnt)





			
					end

			
			end



		end

	end
    
    return foundAnim
    
end

-- Return the first entity found within the seek-tolerance, or the entity within the seek-cone closest to the seek-tolerance.
function this:AcquireLock(missile)

	local curTime = CurTime()
    
	if self.LastSeek + self.SeekDelay > curTime then 
        --print("tried seeking within timeout period")
        return nil 
    end
	self.LastSeek = curTime

	-- Part 1: get all whitelisted entities in seek-cone.
	local found = self:GetWhitelistedEntsInCone(missile)
    	
	-- Part 2: get a good seek target
	
    local missilePos = missile:GetPos()
	local missileForward = missile:GetForward()




	local bestAng = 0
	local bestent = nil

	for k, classifyent in pairs(found) do
	    if classifyent:GetParent():IsValid() or classifyent:IsConstrained() or classifyent:GetClass() == 'ace_flare' then    ---only flares, constrained props are allowed as targets.
		local entpos = classifyent:GetPos()
		local difpos = entpos - missilePos
		local dist = difpos:Length()
		local entvel = classifyent:GetVelocity()
		local ang = missile:WorldToLocalAngles((entpos - missilePos):Angle())	--Used for testing if inrange
		local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much

		local testHeat = self.SeekSensitivity*(((classifyent.THeat or 0) + 8*entvel:Length()/17.6)*math.min(4000/math.max(dist,1),1)) --Heat mechanic is dependant on target´s speed, so faster = hotter
--dist
--		print(testHeat)
		if testHeat > 0 then --Hotter than 50 deg C. Due to its easy to avoid by reducing speed that i´ll have this off (0 deg C.)

			if (absang.p < self.SeekCone and absang.y < self.SeekCone) then --Entity is within missile cone
				local testang = testHeat + (360-(absang.p + absang.y)) --Could do pythagorean stuff but meh, works 98% of time
--				print(testHeat)
--				print((360-(absang.p + absang.y)))
				if testang > bestAng then --Sorts targets as closest to being directly in front of radar
					print("Locking")
				bestAng = testang
				bestent = classifyent
				end

			end
		end
		end
	end

	

    
--    print("iterated and found", mostCentralEnt)
	if not bestent then return nil end
	return bestent
end



function this:GetDisplayConfig()
	return 
	{
		["Seeking"] = math.Round(self.SeekCone * 2*1.3, 1) .. " deg",
		["Tracking"] = math.Round(self.ViewCone * 2*1.3, 1) .. " deg"
	}
end
