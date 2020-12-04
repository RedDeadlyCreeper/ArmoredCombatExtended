
local ClassName = "Radar"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Wire)
ACF.Guidance[ClassName] = this

---
--GetGuidanceOverride
--models/props_c17/light_cagelight02_on.mdl --IR Jammer
--models/props_wasteland/prison_lamp001c.mdl --RWR

this.Name = ClassName

--Currently acquired target.
this.Target = nil

-- Cone to acquire targets within.
this.SeekCone = 20

-- Cone to retain targets within.
this.ViewCone = 25

-- This instance must wait this long between target seeks.
this.SeekDelay = 0.5 -- Re-seek drastically reduced cost so we can re-seek

-- Minimum distance for a target to be considered
this.MinimumDistance = 393.7	--10m



this.desc = "This guidance package detects a target-position infront of itself, and guides the munition towards it."



function this:Init()
	self.LastSeek = CurTime() - self.SeekDelay - 0.000001
	self.LastTargetPos = Vector()
end




function this:Configure(missile)
    
    self:super().Configure(self, missile)
    
    self.ViewCone = ACF_GetGunValue(missile.BulletData, "viewcone") or this.ViewCone
	self.ViewConeCos = math.cos(math.rad(self.ViewCone))
    self.SeekCone = ACF_GetGunValue(missile.BulletData, "seekcone") or this.SeekCone
    
end


--TODO: still a bit messy, refactor this so we can check if a flare exits the viewcone too.
function this:GetGuidance(missile)

	self:PreGuidance(missile)
	
	local override = self:ApplyOverride(missile)
	if override then self.Target = nil return override end

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

function this:GetWhitelistedEntsInCone(missile) --Gets all valid targets, does not check angle

	local missilePos = missile:GetPos()
	local missileForward = missile:GetForward()
	local DPLRFAC = 65-((self.SeekCone)/2)
	local foundAnim = {}
	local foundEnt
	

	local ScanArray = ACE.contraptionEnts


	for k, scanEnt in pairs(ScanArray) do

		if(IsValid(scanEnt))then
			local entpos = scanEnt:GetPos()
			local difpos = entpos - missilePos
			local dist = difpos:Length()
			local entvel = scanEnt:GetVelocity()

			if dist > self.MinimumDistance then -- Target is outside min seek cone
--					print("InDist")		

					local LOStr = util.TraceLine( {start = missilePos ,endpos = entpos,collisiongroup  = COLLISION_GROUP_WORLD,filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end}) --Hits anything world related.			

					if not LOStr.Hit then --Trace did not hit world
--					if true then
--						print("HasLOS")		 
						local ConeInducedGCTRSize = dist/100 --2 meter wide tracehull for every 100m distance
						local GCtr = util.TraceHull( {
							 start = entpos,
							 endpos = entpos + difpos:GetNormalized() * 1000 ,
							 collisiongroup  = COLLISION_GROUP_WORLD,
							 mins = Vector( -ConeInducedGCTRSize, -ConeInducedGCTRSize, -ConeInducedGCTRSize ),
							 maxs = Vector( ConeInducedGCTRSize, ConeInducedGCTRSize, ConeInducedGCTRSize ),
							 filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end
							}) --Hits anything in the world.

							--Doppler testing fun
							local DPLR = missile:WorldToLocal(missilePos+entvel*2)
							local Dopplertest = math.min(math.abs( entvel:Length()/math.max(math.abs(DPLR.Y),0.01))*100,10000)
							local Dopplertest2 = math.min(math.abs(entvel:Length()/math.max(math.abs(DPLR.Z),0.01))*100,10000)

						if (Dopplertest < DPLRFAC or Dopplertest2 < DPLRFAC or (math.abs(DPLR.X) > 880) ) and ( (math.abs(DPLR.X/entvel:Length()) > 0.3) or (not GCtr.Hit) ) then --Qualifies as radar target, if a target is moving towards the radar at 30 mph the radar will also classify the target.
--							print("PassesDoppler")		
							--Valid target
--							print(scanEnt)
							table.insert(foundAnim, scanEnt)

						end



			
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

	local bestAng = math.huge
	local bestent = nil

	for k, classifyent in pairs(found) do
		local entpos = classifyent:GetPos()
		local ang = missile:WorldToLocalAngles((entpos - missilePos):Angle())	--Used for testing if inrange
		local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much

		if (absang.p < self.SeekCone and absang.y < self.SeekCone) then --Entity is within missile cone

			local testang = absang.p + absang.y --Could do pythagorean stuff but meh, works 98% of time

			if testang < bestAng then --Sorts targets as closest to being directly in front of radar
				bestAng = testang
				bestent = classifyent
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
		["Seeking"] = math.Round(self.SeekCone * 2, 1) .. " deg",
		["Tracking"] = math.Round(self.ViewCone * 2, 1) .. " deg"
	}
end
