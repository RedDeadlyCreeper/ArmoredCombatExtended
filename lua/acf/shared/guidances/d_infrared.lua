
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
this.MinimumDistance = 200  -- ~5m

-- Maximum distance for a target to be considered.
this.MaximumDistance = 20000

this.desc = "This guidance package detects hot targets infront of itself, and guides the munition towards it."


function this:Init()
	self.LastSeek = CurTime() - self.SeekDelay - 0.000001
	self.LastTargetPos = Vector()
end

function this:Configure(missile)

	self:super().Configure(self, missile)

	self.ViewCone		= (ACF_GetGunValue(missile.BulletData, "viewcone") or this.ViewCone) * 1.2
	self.ViewConeCos		= (math.cos(math.rad(self.ViewCone))) * 1.2
	self.SeekCone		= (ACF_GetGunValue(missile.BulletData, "seekcone") or this.SeekCone) * 1.2
	self.SeekSensitivity	= ACF_GetGunValue(missile.BulletData, "seeksensitivity") or this.SeekSensitivity

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
	--local missileForward = missile:GetForward()
	--local targetPhysObj = self.Target:GetPhysicsObject()
	local targetPos = self.Target:GetPos() + Vector(0,0,25)

	local mfo	= missile:GetForward()
	local mdir	= (targetPos - missilePos):GetNormalized()
	local dot	= mfo:Dot(mdir)

	if dot < self.ViewConeCos then
		self.Target = nil
		return {}
	else
		self.TargetPos = targetPos
		return {TargetPos = targetPos, ViewCone = self.ViewCone * 1.3}
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

	local target = self:AcquireLock(missile)

	if IsValid(target) then
		self.Target = target
	end
end

function this:GetWhitelistedEntsInCone(missile)

	local ScanArray = ACE.contraptionEnts
	if table.IsEmpty(ScanArray) then return {} end

	local missilePos	= missile:GetPos()
	local WhitelistEnts = {}
	local LOSdata	= {}
	local LOStr		= {}

	local entpos		= Vector()
	local difpos		= Vector()
	local dist		= 0

	for _, scanEnt in ipairs(ScanArray) do

		-- skip any invalid entity
		if not IsValid(scanEnt) then continue end

		entpos  = scanEnt:GetPos()
		difpos  = entpos - missilePos
		dist	= difpos:Length()

		-- skip any ent outside of minimun distance
		if dist < self.MinimumDistance then continue end

		-- skip any ent far than maximum distance
		if dist > self.MaximumDistance then continue end

		LOSdata.start		= missilePos
		LOSdata.endpos		= entpos
		LOSdata.collisiongroup  = COLLISION_GROUP_WORLD
		LOSdata.filter		= function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end
		LOSdata.mins			= Vector(0,0,0)
		LOSdata.maxs			= Vector(0,0,0)

		LOStr = util.TraceHull( LOSdata )

		--Trace did not hit world
		if not LOStr.Hit then
			table.insert(WhitelistEnts, scanEnt)
		end


	end

	return WhitelistEnts

end

-- Return the first entity found within the seek-tolerance, or the entity within the seek-cone closest to the seek-tolerance.
function this:AcquireLock(missile)

	local curTime = CurTime()

	if self.LastSeek + self.SeekDelay > curTime then return nil end
	self.LastSeek = curTime

	--Part 1: get all ents in cone
	local found = self:GetWhitelistedEntsInCone(missile)

	--Part 2: get a good seek target
	if table.IsEmpty(found) then return NULL end

	local missilePos	= missile:GetPos()

	local bestAng	= math.huge
	local bestent	= NULL

	local Heat		= 0

	local entpos		= Vector()
	local difpos		= Vector()
	--local entvel		= Vector()
	local dist		= 0

	local physEnt	= NULL

	local ang		= Angle()
	local absang		= Angle()
	local testang	= Angle()

	for _, classifyent in ipairs(found) do

		entpos  = classifyent:WorldSpaceCenter()
		difpos  = entpos - missilePos
		dist	= difpos:Length()
		entvel  = classifyent:GetVelocity()

		--if the target is a Heat Emitter, track its heat
		if classifyent.Heat then

			Heat = self.SeekSensitivity * classifyent.Heat

		--if is not a Heat Emitter, track the friction's heat
		else

			physEnt = classifyent:GetPhysicsObject()

			--skip if it has not a valid physic object. It's amazing how gmod can break this. . .
			--check if it's not frozen. If so, skip it, unmoveable stuff should not be even considered
			if IsValid(physEnt) and not physEnt:IsMoveable() then continue end

			Heat = ACE_InfraredHeatFromProp( self, classifyent , dist )

		end

		--Skip if not Hotter than AmbientTemp in deg C.
		if Heat <= ACE.AmbientTemp + self.HeatAboveAmbient then continue end

		ang	= missile:WorldToLocalAngles((entpos - missilePos):Angle())	--Used for testing if inrange
		absang	= Angle(math.abs(ang.p),math.abs(ang.y),0) --Since I like ABS so much

		if absang.p < self.SeekCone and absang.y < self.SeekCone then --Entity is within missile cone

			testang = absang.p + absang.y --Could do pythagorean stuff but meh, works 98% of time

			if self.Target == scanEnt then
				testang = testang / self.SeekSensitivity
			end

			testang = testang - Heat



			--Sorts targets as closest to being directly in front of radar
			if testang < bestAng then

				bestAng = testang
				bestent = classifyent

			end

		end


	end

	return bestent
end

--Another Stupid Workaround. Since guidance degrees are not loaded when ammo is created
function this:GetDisplayConfig(Type)

	local seekCone =  (ACF.Weapons.Guns[Type].seekcone or 0 ) * 2
	local ViewCone = (ACF.Weapons.Guns[Type].viewcone or 0 ) * 2

	return
	{
		["Seeking"] = math.Round(seekCone, 1) .. " deg",
		["Tracking"] = math.Round(ViewCone, 1) .. " deg"
	}
end
