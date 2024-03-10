--[[------------------------------------------------------------------------------------------------
	SV_BALLISTICS.LUA
]]--------------------------------------------------------------------------------------------------
-- optimization; reuse tables for ballistics traces
local FlightRes = { }
local FlightTr = { output = FlightRes }
-- end init

--[[------------------------------------------------------------------------------------------------
	DEBUG CONFIG
]]--------------------------------------------------------------------------------------------------
local DebugTime = 1

--[[------------------------------------------------------------------------------------------------
	creates a new bullet being fired
]]--------------------------------------------------------------------------------------------------
function ACF_CreateBullet( BulletData )

	-- Increment the index
	ACF.CurBulletIndex = ACF.CurBulletIndex + 1

	if ACF.CurBulletIndex > ACF.BulletIndexLimit then
		ACF.CurBulletIndex = 1
	end

	BulletData = table.Copy(BulletData) -- this is required to avoid overwritting the origin table

	--Those are BulletData settings that are global and shouldn't change round to round
	BulletData.Gravity       = GetConVar("sv_gravity"):GetInt() * -1
	BulletData.Accel         = Vector(0,0,BulletData.Gravity)
	BulletData.LastThink     = ACF.SysTime
	BulletData.FlightTime    = 0
	BulletData.TraceBackComp = 0

	BulletData.FuseLength	= type(BulletData.FuseLength) == "number" and BulletData.FuseLength or 0

	--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
	local Parent = ACF_GetPhysicalParent(BulletData.Gun)

	if IsValid(Parent) then
		local physObj = Parent:GetPhysicsObject()
		if IsValid(physObj) then
			BulletData.TraceBackComp = math.max(physObj:GetVelocity():Dot(BulletData.Flight:GetNormalized()),0)
		end
	end

	if BulletData.Filter then
		table.Add( BulletData.Filter, { BulletData.Gun } )
	else
		BulletData.Filter = { BulletData.Gun }
	end

	BulletData.Index		= ACF.CurBulletIndex
	ACF.Bullet[ACF.CurBulletIndex] = table.Copy(BulletData)	--Place the bullet at the current index pos
	ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
	ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )

end

--[[------------------------------------------------------------------------------------------------
	global update function where acf updates ALL bullets at once.
	this runs once per tick, handling bullet physics for all bullets in table.
]]--------------------------------------------------------------------------------------------------
function ACF_ManageBullets()

	if next(ACF.Bullet) then

		for Index,Bullet in pairs(ACF.Bullet) do
			if not Bullet.HandlesOwnIteration then
				ACF_CalcBulletFlight( Index, Bullet )		--This is the bullet entry in the table, the Index var omnipresent refers to this
			end
		end
	end
end
hook.Remove( "Tick", "ACF_ManageBullets" )
hook.Add("Tick", "ACF_ManageBullets", ACF_ManageBullets)

--[[------------------------------------------------------------------------------------------------
	removes the bullet from acf
]]--------------------------------------------------------------------------------------------------
function ACF_RemoveBullet( Index )

	local Bullet = ACF.Bullet[Index]
	ACF.Bullet[Index] = nil
	if Bullet and Bullet.OnRemoved then Bullet:OnRemoved() end

end

--[[------------------------------------------------------------------------------------------------
	checks the visclips of an entity, to determine if round should pass through or not.
	ignores anything that's not a prop (acf components, seats) or with nil volume (makesphere props)
]]--------------------------------------------------------------------------------------------------

local ValidClipEnts = {
	["prop_physics"]             = true,
	["primitive_shape"]          = true,
	["primitive_airfoil"]        = true,
	["primitive_rail_slider"]    = true,
	["primitive_slider"]         = true,
	["primitive_ladder"]         = true
}

function ACF_CheckClips( Ent, HitPos )

	if not IsValid(Ent) or Ent.ClipData == nil then return false end		-- only valid visclipped ents
	if not ValidClipEnts[Ent:GetClass()] then return false end			-- only props
	local phys = Ent:GetPhysicsObject()
	if not IsValid(phys) or phys:GetVolume() == nil then return false end	-- makesphere

	local normal
	local origin

	for i = 1, #Ent.ClipData do

		local ClipData = Ent.ClipData[i]

		normal = Ent:LocalToWorldAngles(ClipData.n):Forward()
		origin = Ent:LocalToWorld(Ent:OBBCenter()) + normal * ClipData.d
		--debugoverlay.BoxAngles( origin, Vector(0,-24,-24), Vector(1,24,24), Ent:LocalToWorldAngles(ClipData["n"]), 15, Color(255,0,0,32) )
		if not ClipData.physics and normal:Dot((origin - HitPos):GetNormalized()) > 0 then return true end  --Since tracehull/traceline transition during impacts, this can be 0 with no issues
	end

	return false
end

do

	local PhysVel = ACF.PhysMaxVel * 0.025

	--[[------------------------------------------------------------------------------------------------
	handles non-terminal ballistics and fusing of bullets
	]]--------------------------------------------------------------------------------------------------
	function ACF_CalcBulletFlight( Index, Bullet, BackTraceOverride )

		-- perf concern: use direct function call stored on bullet over hook system.
		if Bullet.PreCalcFlight then Bullet:PreCalcFlight() end

		if not Bullet.LastThink then ACF_RemoveBullet( Index ) end

		if BackTraceOverride then Bullet.FlightTime = 0 end
		Bullet.DeltaTime = ACF.SysTime - Bullet.LastThink

		--actual motion of the bullet
		local Drag		= Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Bullet.Flight:LengthSqr()) / ACF.DragDiv
		Bullet.NextPos	= Bullet.Pos + (Bullet.Flight * ACF.VelScale * Bullet.DeltaTime)																								-- Calculates the next shell position
		Bullet.Flight	= Bullet.Flight + (Bullet.Accel - Drag) * Bullet.DeltaTime

		-- Used for trace
		local Flightnorm  = Bullet.Flight:GetNormalized()

		Bullet.StartTrace = Bullet.Pos - Flightnorm * math.min( PhysVel, Bullet.FlightTime * Bullet.Flight:Length() - Bullet.TraceBackComp * Bullet.DeltaTime )
		Bullet.EndTrace	= Bullet.NextPos + Flightnorm * PhysVel

		debugoverlay.Cross(Bullet.Pos,5,DebugTime,Color(255,255,255) ) --true start
		debugoverlay.Line(Bullet.Pos, Bullet.NextPos, DebugTime, Color(0,255,0), true ) -- the predicted trayectory.
		debugoverlay.Line(Bullet.StartTrace, Bullet.EndTrace, DebugTime, Color(255, 255, 0)) -- the real trace detection.

		--updating timestep timers
		Bullet.LastThink = ACF.SysTime
		Bullet.FlightTime = Bullet.FlightTime + Bullet.DeltaTime

		ACF_DoBulletsFlight( Index, Bullet )

		-- perf concern: use direct function call stored on bullet over hook system.
		if Bullet.PostCalcFlight then
			Bullet:PostCalcFlight()
		end
	end

end

--[[------------------------------------------------------------------------------------------------
	handles bullet terminal ballistics, fusing, and visclip checking
]]--------------------------------------------------------------------------------------------------
do

	local MaxvisclipPerBullet = 50

	local function ACF_PerformTrace( Bullet )

		-- perform the trace for damage
		local RetryTrace = true

		--compensation
		FlightTr.start	= Bullet.StartTrace
		FlightTr.endpos	= Bullet.EndTrace

		-- Disabled since, for some reason, MASK_SHOT caused issues with bullets bypassing things should not (parented props if the tracehull had mins/maxs at 0,0,0). WHY??
		--FlightTr.mask	= Bullet.Caliber <= 3 and MASK_SHOT or MASK_SOLID -- cals 30mm and smaller will pass through things like chain link fences

		--FlightTr.mask = MASK_SHOT -- Enable this to see the weird side

		local TROffset = 0.235 * Bullet.Caliber / 1.14142 --Square circumscribed by circle. 1.14142 is an aproximation of sqrt 2. Radius and divide by 2 for min/max cancel.
		FlightTr.maxs = Vector(TROffset, TROffset, TROffset)
		FlightTr.mins = -FlightTr.maxs

		debugoverlay.Box( Bullet.Pos, FlightTr.mins, FlightTr.maxs, DebugTime, Color(255,100,0, 100) )
		--debugoverlay.Cross( FlightTr.start, 10, 20, Color(255,0,0), true )
		--debugoverlay.Cross( FlightTr.endpos, 10, 20, Color(0,255,0), true )

		-- Table to hold temporary filter keys that should be removed after the below while loop is completed
		if not Bullet.FilterKeysToRemove then Bullet.FilterKeysToRemove = {} end
		for k, v in ipairs(Bullet.FilterKeysToRemove) do
			table.remove(Bullet.Filter, v)
			Bullet.FilterKeysToRemove[k] = nil
		end

		FlightTr.filter	= Bullet.Filter -- any changes to bullet filter will be reflected in the trace

		local visCount = 0

		--if trace hits clipped part of prop, add prop to trace filter and retry
		while RetryTrace and visCount < MaxvisclipPerBullet do

			-- Disables so we dont overloop it again
			RetryTrace		= false

			-- Defining tracehull at first instance. If you want serious cases, change this to traceline
			util.TraceHull(FlightTr)
			--util.TraceLine(FlightTr)

			--if our shell hits visclips, convert the tracehull on traceline.
			if ACF_CheckClips( FlightRes.Entity, FlightRes.HitPos ) then

				--print("") -- not wanting linter annoys me.
				-- trace result is stored in supplied output FlightRes (at top of file)
				util.TraceLine(FlightTr)

				-- if our traceline doesnt detect anything after conversion, revert it to tracehull again. This should fix the 1 in 1 billon issue.
				if not FlightRes.HitNonWorld then

					-- The traceline function overrides the mins/maxs. So i must redefine them again here.
					FlightTr.maxs = Vector(TROffset, TROffset, TROffset)
					FlightTr.mins = -FlightTr.maxs
					util.TraceHull(FlightTr)
				end
			end

			--We hit something that's not world, if it's visclipped, filter it out and retry
			if FlightRes.HitNonWorld and ACF_CheckClips( FlightRes.Entity, FlightRes.HitPos ) then	--our shells hit the visclip as traceline, no more double bounds.

				table.insert( Bullet.Filter, FlightRes.Entity )
				RetryTrace = true	--re-enabled for retry trace. Bullet will start as tracehull again unless other visclip is detected!

				-- Counts the amount of passed visclips during this tick. The loop will break if the limit is passed
				visCount = visCount + 1
			end

			-- If we hit a player or NPC, we need to retry the trace as a TraceLine
			-- TraceHull hits player's physics collision boxes rather than proper hitboxes, causing near miss shots to hit
			local HitEnt = FlightRes.Entity
			if FlightRes.HitNonWorld and (HitEnt:IsPlayer() or HitEnt:IsNPC()) then

				FlightTr.output = nil
				local PlayerHitCheck = util.LegacyTraceLine(FlightTr).Entity --new hit ent after traceline conversion
				FlightTr.output = FlightRes

				if HitEnt ~= PlayerHitCheck then
					table.insert(Bullet.Filter, HitEnt)
					table.insert(Bullet.FilterKeysToRemove, #Bullet.Filter)

					RetryTrace = true

					-- Counts the amount of passed visclips during this tick. The loop will break if the limit is passed
					visCount = visCount + 1
				end
			end
		end

		--print("Count: " .. visCount)
	end

	do

		local MaxImpacts = 100 --How many impacts (including penetrations and ricochets) can a bullet tolerate before being deleted?
		local Hit_Resolutions = {

------------ Called and performed when the bullet was told to penetrate ------------

			Penetrated = function(Index, Bullet, FlightRes, type)

				if Bullet.OnPenetrated then
					Bullet.OnPenetrated(Index, Bullet, FlightRes)
				end

				local isProp = (type == "propimpact")

				if isProp then

					Bullet.ImpactCount = (Bullet.ImpactCount or 0) + 1

					--Removes the bullet if it could impact more than the specified
					if Bullet.ImpactCount and Bullet.ImpactCount > MaxImpacts then

						ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
						ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
						ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )
					else

						ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
						ACF_DoBulletsFlight( Index, Bullet )
					end
				else

					ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
					ACF_CalcBulletFlight( Index, Bullet, true )		--The world ain't going to move, so we say True for the backtrace override
				end
			end,

------------ Called and performed when the bullet was told to ricochet ------------

			Ricochet = function(Index, Bullet, FlightRes, type)

				if Bullet.OnRicocheted then
					Bullet.OnRicocheted(Index, Bullet, FlightRes)
				end

				local isProp = (type == "propimpact")

				if isProp then
					Bullet.ImpactCount = (Bullet.ImpactCount or 0) + 1
				end

				--Removes the bullet if it could impact more than the specified
				if Bullet.ImpactCount and Bullet.ImpactCount > MaxImpacts then

					ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
					ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
					ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )
				else

					ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
					ACF_CalcBulletFlight( Index, Bullet, true )
				end
			end,

------------ Called and performed when the bullet was told to stop there. Nothing else ------------

			Hit = function(Index, Bullet, FlightRes, _)

				if Bullet.OnEndFlight then
					Bullet.OnEndFlight(Index, Bullet, FlightRes)
				end

				ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )

			end
		}

		function ACE_PerformHitResolution( Index, Bullet, FlightRes, Retry, Type )
			Hit_Resolutions[Retry or "Hit"](Index, Bullet, FlightRes, Type)
		end
	end

	function ACF_DoBulletsFlight( Index, Bullet )

		local CanDo = hook.Run("ACF_BulletsFlight", Index, Bullet )
		if CanDo == false then return end

		ACF_PerformTrace( Bullet )

		--Fuse detonation. Note: Its possible that the bullet prefers to hit the incoming prop instead of detonate. Not a big concern.
		if Bullet.FuseLength and Bullet.FuseLength > 0 and Bullet.FlightTime > Bullet.FuseLength then

			local Diff         = Bullet.FlightTime - Bullet.FuseLength
			local ratio        = 1 - (Diff / Bullet.DeltaTime)
			local ScaledPos    = LerpVector(ratio, Bullet.Pos, Bullet.NextPos)

			if FlightRes.Hit and FlightRes.Fraction < ratio or Bullet.HasPenned then
				ScaledPos = FlightRes.HitPos
			end

			if not util.IsInWorld(ScaledPos) then
				ACF_RemoveBullet( Index )
			else

			if Bullet.OnEndFlight then
				Bullet.OnEndFlight(Index, Bullet, nil)
			end -- nil was flightres, garbage data this early in code

				ACF_BulletClient( Index, Bullet, "Update" , 1 , ScaledPos  ) -- defined at bottom
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, ScaledPos, Bullet.Flight:GetNormalized() )

				debugoverlay.Sphere(ScaledPos, 10, DebugTime, Color(255,100,0,255) )
				debugoverlay.Text(ScaledPos, "Orange Sphere: Bullet Detonated here!", DebugTime )

			end

			return
		end

		--if we're out of skybox, keep calculating position.  If we have too long out of skybox, remove bullet
		if Bullet.SkyLvL then

			--We don't want to calculate bullets that will never come back to map
			if (ACF.CurTime - Bullet.LifeTime) > 100 then
				ACF_RemoveBullet( Index )
				return
			end

			--We don't want rounds to hit the skybox top, but to pass through and come back down
			if Bullet.NextPos.z + ACF.SkyboxGraceZone > Bullet.SkyLvL then --add in a bit of grace zone
				Bullet.Pos = Bullet.NextPos
				return

			--We do want rounds outside of the world but not skybox top to be deleted
			elseif not util.IsInWorld(Bullet.NextPos) then
				ACF_RemoveBullet( Index )
				return
			--We fall back to this default
			else
				Bullet.SkyLvL         = nil
				Bullet.LifeTime       = nil
				Bullet.Pos            = Bullet.NextPos
				Bullet.SkipNextHit    = true
				return
			end
		end

		--bullet is told to ignore the next hit, so it does and resets flag
		if Bullet.SkipNextHit then

			if not FlightRes.StartSolid and not FlightRes.HitNoDraw then Bullet.SkipNextHit = nil end
			Bullet.Pos = Bullet.NextPos

		--bullet hit something that isn't world and is allowed to hit
		elseif FlightRes.HitNonWorld then

			--If we hit stuff then send the resolution to the bullets damage function
			local ACF_BulletPropImpact = ACF.RoundTypes[Bullet.Type]["propimpact"]

			--Added to calculate change in shell velocity through air gaps. Required for HEAT jet dissipation since a HEAT jet can move through most tanks in 1 tick.
			local DTImpact = ((FlightRes.HitPos - Bullet.Pos):Length() / (Bullet.Flight * ACF.VelScale * engine.TickInterval()):Length()) * engine.TickInterval() --i would rather use tickinterval over deltatime

			--Gets the distance the bullet traveled and divides it by the distance the bullet should have traveled during deltatime. Used to calculate drag time.
			local Drag = Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Bullet.Flight:LengthSqr()) / ACF.DragDiv

			Bullet.Flight = Bullet.Flight - Drag * DTImpact

			local Retry = ACF_BulletPropImpact( Index, Bullet, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )

			--don't process ACF.TraceFilter ents
			if ACF.TraceFilter[FlightRes.Entity:GetClass()] and Retry == "Penetrated" then
				Retry = false
			end

			--If we should do the same trace again, then do so
			ACE_PerformHitResolution(Index, Bullet, FlightRes, Retry, "propimpact")

		--bullet hit the world
		elseif FlightRes.HitWorld then

			--If we hit the world then try to see if it's thin enough to penetrate
			if not FlightRes.HitSky then

				local ACF_BulletWorldImpact = ACF.RoundTypes[Bullet.Type]["worldimpact"]

				local Retry = ACF_BulletWorldImpact( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )

				--If we should do the same trace again, then do so
				ACE_PerformHitResolution(Index, Bullet, FlightRes, Retry, "worldimpact")

			--hit skybox
			else
				--We will keep this disabled for infinite maps
				if not InfMap then

					--only if leaving top of skybox
					if Bullet.Caliber >= 5 and FlightRes.HitNormal == Vector(0,0,-1) then
						Bullet.SkyLvL   = FlightRes.HitPos.z				-- Lets save height on which bullet went through skybox. So it will start tracing after falling bellow this level. This will prevent from hitting higher levels of map
						Bullet.LifeTime = ACF.CurTime
						Bullet.Pos      = Bullet.NextPos
					else
						ACF_RemoveBullet( Index )
						return
					end
				end
			end

		--bullet hit nothing, keep flying
		else
			--If its an infinite map. Remove any bullet if it passed 1 source map distance
			if InfMap and Bullet.NextPos.z < (-32760 * 2) then
				ACF_RemoveBullet( Index )
				return
			end

			Bullet.Pos = Bullet.NextPos

		end
	end

end

--[[------------------------------------------------------------------------------------------------
	Provides the data for the bullet effect
]]--------------------------------------------------------------------------------------------------
function ACF_BulletClient( Index, Bullet, Type, Hit, HitPos )

	--Uncheck this to disable effects
	--if Index then return end
	if Type == "Update" then
	local Effect = EffectData()

		Effect:SetMaterialIndex( Index )	--Bulet Index
		Effect:SetStart( Bullet.Flight / 10 ) --Bullet Direction

		if Hit > 0 then	-- If there is a hit then set the effect pos to the impact pos instead of the retry pos
			Effect:SetOrigin( HitPos )	--Bullet Pos
		else
			Effect:SetOrigin( Bullet.Pos )
		end

		Effect:SetScale( Hit )  --Hit Type
	util.Effect( "ACF_BulletEffect", Effect, true, true )

	elseif Type == "Init" then

	local IsMissile

	if not IsValid(Bullet.Gun) or Bullet.Gun:GetClass() == "acf_missile" then
		IsMissile = 1
	end

	local Effect = EffectData()
		Effect:SetMaterialIndex( Index )	--Bullet Index
		Effect:SetStart( Bullet.Flight / 10 )	--Bullet Direction
		Effect:SetOrigin( Bullet.Pos )
		Effect:SetEntity( Entity(Bullet["Crate"]) )
		Effect:SetScale( 0 )
		Effect:SetAttachment( IsMissile or 0 )
	util.Effect( "ACF_BulletEffect", Effect, true, true )

	end
end