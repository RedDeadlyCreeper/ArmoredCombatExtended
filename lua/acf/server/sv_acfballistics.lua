ACF.Bullet = {}	--when ACF is loaded, this table holds bullets
ACF.CurBulletIndex = 0	--used to track where to insert bullets
ACF.BulletIndexLimt = 2000  --The maximum number of bullets in flight at any one time TODO: fix the typo
ACF.TraceFilter = { --entities that cause issue with acf and should be not be processed at all

	prop_vehicle_crane = true,
	prop_dynamic = true
	
	}

	
ACF.SkyboxGraceZone = 100 --grace zone for the high angle fire

-- optimization; reuse tables for ballistics traces
local FlightRes = { }
local FlightTr = { output = FlightRes, 	mins = Vector( 0, 0, 0 ), maxs = Vector( 0, 0, 0 ) }
-- end init

--creates a new bullet being fired
function ACF_CreateBullet( BulletData )
	
	ACF.CurBulletIndex = ACF.CurBulletIndex + 1		--Increment the index
	if ACF.CurBulletIndex > ACF.BulletIndexLimt then
		ACF.CurBulletIndex = 1
	end

	--Those are BulletData settings that are global and shouldn't change round to round	
	local cvarGrav = GetConVar("sv_gravity")
	BulletData["Accel"] =  Vector(0,0,cvarGrav:GetInt()*-1)--Vector(0,0,cvarGrav:GetInt()*-1)
	BulletData["LastThink"] = ACF.SysTime
	BulletData["FlightTime"] = 0
	BulletData["TraceBackComp"] = 0
	--BulletData.FiredPos = BulletData.Pos --when adding back in, update acfdamage roundimpact rico
	--BulletData.FiredTime = ACF.SysTime --same as fuse inittime, can combine when readding
	if type(BulletData["FuseLength"]) ~= "number" then
		BulletData["FuseLength"] = 0
	else
		--print("Has fuse")
		if BulletData["FuseLength"] > 0 then
			BulletData["InitTime"] = ACF.SysTime
		end
	end

	--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
	if BulletData["Gun"]:IsValid() then										--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path

		BulletData["TraceBackComp"] = math.max(ACF_GetPhysicalParent(BulletData["Gun"]):GetPhysicsObject():GetVelocity():Dot(BulletData["Flight"]:GetNormalized()),0)

		--print(BulletData["TraceBackComp"])
		if BulletData["Gun"].sitp_inspace then
			BulletData["Accel"] = Vector(0, 0, 0)
			BulletData["DragCoef"] = 0
		end
	end
	BulletData["Filter"] = { BulletData["Gun"] }
	BulletData["Index"] = ACF.CurBulletIndex
	ACF.Bullet[ACF.CurBulletIndex] = table.Copy(BulletData)		--Place the bullet at the current index pos
	ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
	ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )
	
end

--global update function where acf updates ALL bullets at once--this runs once per tick, handling bullet physics for all bullets in table.
function ACF_ManageBullets()
	for Index,Bullet in pairs(ACF.Bullet) do
		if not Bullet.HandlesOwnIteration then
			ACF_CalcBulletFlight( Index, Bullet )			--This is the bullet entry in the table, the Index var omnipresent refers to this
		end
	end
end

hook.Add("Tick", "ACF_ManageBullets", ACF_ManageBullets)

--removes the bullet from acf
function ACF_RemoveBullet( Index )
	local Bullet = ACF.Bullet[Index]
	ACF.Bullet[Index] = nil
	if Bullet and Bullet.OnRemoved then Bullet:OnRemoved() end
end

--[[------------------------------------------------------------------------------------------------
   checks the visclips of an entity, to determine if round should pass through or not.
   ignores anything that's not a prop (acf components, seats) or with nil volume (makesphere props)
]]--------------------------------------------------------------------------------------------------
function ACF_CheckClips( Ent, HitPos )

	if not IsValid(Ent) or (Ent.ClipData == nil)
		or (not (Ent:GetClass() == "prop_physics"))
		or (Ent:GetPhysicsObject():GetVolume() == nil) -- makesphere
		then return false end
	
	local normal
	local origin
	for i=1, #Ent.ClipData do
		normal = Ent:LocalToWorldAngles(Ent.ClipData[i]["n"]):Forward() 
		origin = Ent:LocalToWorld(Ent:OBBCenter())+normal*Ent.ClipData[i]["d"]
		--debugoverlay.BoxAngles( origin, Vector(0,-24,-24), Vector(1,24,24), Ent:LocalToWorldAngles(Ent.ClipData[i]["n"]), 15, Color(255,0,0,32) )
		if normal:Dot((origin - HitPos):GetNormalized()) > 0 then return true end  --Since tracehull/traceline transition during impacts, this can be 0 with no issues
	end
	
	return false
	
end

--handles non-terminal ballistics and fusing of bullets
function ACF_CalcBulletFlight( Index, Bullet, BackTraceOverride )
	-- perf concern: use direct function call stored on bullet over hook system.
	if Bullet.PreCalcFlight then Bullet:PreCalcFlight() end
	
	if not Bullet.LastThink then ACF_RemoveBullet( Index ) end

	if BackTraceOverride then Bullet.FlightTime = 0 end
	local DeltaTime = ACF.SysTime - Bullet.LastThink
	
	--actual motion of the bullet
	local Drag = Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Bullet.Flight:LengthSqr()) / ACF.DragDiv
	Bullet.NextPos = Bullet.Pos + (Bullet.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	Bullet.Flight = Bullet.Flight + (Bullet.Accel - Drag)*DeltaTime				--Calculates the next shell vector
	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized()*(math.min(ACF.PhysMaxVel*0.025,(Bullet.FlightTime*Bullet.Flight:Length()-Bullet.TraceBackComp*DeltaTime))) --Originally limited to 5m backtrace. Disabled due to reports of it breaking things.

		--	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized()*(math.min(ACF.PhysMaxVel*0.025,(Bullet.FlightTime*Bullet.Flight:Length()-Bullet.TraceBackComp*DeltaTime)))
	
	--0.035 seconds of max backtrace of shell velocity, a bit more than 1 tick at 33 ticks/second

	--ACF.PhysMaxVel*1,     limits max backtrace length at 200 meters.
	--ACF.PhysMaxVel*0.025, limits max backtrace length at 5 meters.
	--ACF.PhysMaxVel*0.1, limits max backtrace length at 20 meters.
	--Distance in meters a vehicle covers each tick in meters


	--print(math.Round((Bullet.Pos-Bullet.StartTrace):Length(),1))
	--debugoverlay.Cross(Bullet.Pos,3,15,Color(255,255,255,32), true) --true start
	--debugoverlay.Box(Bullet.StartTrace,Vector(-2,-2,-2),Vector(2,2,2),15,Color(0,255,0,32), true) --backtrace start
	--debugoverlay.EntityTextAtPosition(Bullet.StartTrace, 0, "Tr", 15)
	--debugoverlay.EntityTextAtPosition(Bullet.Pos, 0, "Pos", 15)
	--debugoverlay.Line( Bullet.Pos+Vector(0,0,1), Bullet.StartTrace+Vector(0,0,1), 15, Color(0, 255, 255), true )
	--debugoverlay.Line( Bullet.NextPos+VectorRand(), Bullet.StartTrace+VectorRand(), 15, ColorRand(), true )
	
	--updating timestep timers
	Bullet.LastThink = ACF.SysTime
	Bullet.FlightTime = Bullet.FlightTime + DeltaTime
	
	ACF_DoBulletsFlight( Index, Bullet )

	-- perf concern: use direct function call stored on bullet over hook system.
	if Bullet.PostCalcFlight then Bullet:PostCalcFlight() end
end

--handles bullet terminal ballistics, fusing, and visclip checking
function ACF_DoBulletsFlight( Index, Bullet )


	local CanDo = hook.Run("ACF_BulletsFlight", Index, Bullet )
	if CanDo == false then return end
	if Bullet.FuseLength and Bullet.FuseLength > 0 then
		local Time = ACF.SysTime - Bullet.InitTime
		if Time > Bullet.FuseLength then
			--print("Explode")
			if not util.IsInWorld(Bullet.Pos) then
				ACF_RemoveBullet( Index )
			else
				if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, nil) end -- nil was flightres, garbage data this early in code
				ACF_BulletClient( Index, Bullet, "Update" , 1 , Bullet.Pos  ) -- defined at bottom
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, Bullet.Pos, Bullet.Flight:GetNormalized() )	
			end
		end
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
			Bullet.SkyLvL = nil
			Bullet.LifeTime = nil
			Bullet.Pos = Bullet.NextPos
			Bullet.SkipNextHit = true
			return
		end
	end
	-- I'm leaving disabled tracehull setup here, from when I was testing it. just need to set the mins/maxs and swap trace methods a few lines below. --ferv
	-- tracehull is causing issues with hit detections on clips (ie slipping through clipped glacis seams; reported hitpos is on clipped side of both?)
	-- ocassional issues with determining hit normal on prop seams, may be related to clip seams
	-- issues with determining if a glancing hit; these settings have a reduced hull size so that only non-glancing hits count
	-- possible fix: do a secondary traceline of flight through tracehull hitpos, as if the bullet was travelling through hitpos
	--    worth the extra trace overhead? only run hulls for large shells? 3" (75mm)? 4" (100mm)? extra complexity for handling different cal traces

	FlightTr.mask = Bullet.Caliber <= 0.3 and MASK_SHOT or MASK_SOLID -- cals 30mm and smaller will pass through things like chain link fences
	FlightTr.filter = Bullet.Filter -- any changes to bullet filter will be reflected in the trace
	TROffset = 0.235*Bullet.Caliber/1.14142 --Square circumscribed by circle. 1.14142 is an aproximation of sqrt 2. Radius and divide by 2 for min/max cancel.
	FlightTr.maxs = Vector( TROffset, TROffset, TROffset )
	FlightTr.mins = -FlightTr.maxs	
	
	--perform the trace for damage	
		
	local RetryTrace = true	

	while RetryTrace do			--if trace hits clipped part of prop, add prop to trace filter and retry
	    
		RetryTrace = false  --disabling....
		FlightTr.start = Bullet.StartTrace
		FlightTr.endpos = Bullet.NextPos + Bullet.Flight:GetNormalized()*(ACF.PhysMaxVel * 0.025) --compensation 		

		
		util.TraceHull(FlightTr)    --Defining tracehull at first instance
		
		if ACF_CheckClips( FlightRes.Entity, FlightRes.HitPos ) then   --if our shell hits visclips, convert the tracehull on traceline.
		   --print('Traceline!')
		   util.TraceLine(FlightTr) -- trace result is stored in supplied output FlightRes (at top of file)	
		  
		    if not FlightRes.HitNonWorld then -- if our traceline doesnt detect anything after conversion, revert it to tracehull again. This should fix the 1 in 1 billon issue.
			
		        --print('back to tracehull!')
			    util.TraceHull(FlightTr)
		   
		    end
		   
		end  
        
		--We hit something that's not world, if it's visclipped, filter it out and retry	
        if FlightRes.HitNonWorld and ACF_CheckClips( FlightRes.Entity, FlightRes.HitPos ) then   --our shells hit the visclip as traceline, no more double bounds.
		    
		    table.insert( Bullet.Filter , FlightRes.Entity )
		    RetryTrace = true   --re-enabled for retry trace. Bullet will start as tracehull again unless other visclip is detected!
			
	    end
	
	end	
	
	--bullet is told to ignore the next hit, so it does and resets flag
	if Bullet.SkipNextHit then
		if not FlightRes.StartSolid and not FlightRes.HitNoDraw then Bullet.SkipNextHit = nil end
		Bullet.Pos = Bullet.NextPos
	
	--bullet hit something that isn't world and is allowed to hit
	elseif FlightRes.HitNonWorld and not ACF.TraceFilter[FlightRes.Entity:GetClass()] then --don't process ACF.TraceFilter ents
	
		--If we hit stuff then send the resolution to the bullets damage function
		
		ACF_BulletPropImpact = ACF.RoundTypes[Bullet.Type]["propimpact"]
		
		--Added to calculate change in shell velocity through air gaps. Required for HEAT jet dissipation since a HEAT jet can move through most tanks in 1 tick.


		--local DTImpact = ((FlightRes.HitPos-Bullet.Pos):Length()/(Bullet.Flight:Length() * ACF.VelScale * DeltaTime) * DeltaTime) or 0.01515
		local DTImpact = ((FlightRes.HitPos-Bullet.Pos):Length()/((Bullet.Flight * ACF.VelScale * engine.TickInterval()):Length())) * engine.TickInterval() --i would rather use tickinterval over deltatime

--		DTImpact = 1

		--Gets the distance the bullet traveled and divides it by the distance the bullet should have traveled during deltatime. Used to calculate drag time.
		local Drag = Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Bullet.Flight:LengthSqr()) / ACF.DragDiv

--		print("GAP")
--		print(DTImpact)
--		print(DeltaTime)
		--Adjusts bullet speed by time it spent flying into target.
		--print("Before")
		--print(Bullet.Flight:Length()/39.37)
		Bullet.Flight = Bullet.Flight - Drag * DTImpact
		--print("After")
		--print(Bullet.Flight:Length()/39.37)



		local Retry = ACF_BulletPropImpact( Index, Bullet, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )
		if Retry == "Penetrated" then		--If we should do the same trace again, then do so
		    
			if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end

					Bullet.ImpactCount = (Bullet.ImpactCount or 0) + 1
				if Bullet.ImpactCount > 50 then --A bullet has impacted more than 50 props. But why though?			
					ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
					ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
					ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
				else

					ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
					--print("After")
					--print(Bullet.Flight)
					ACF_DoBulletsFlight( Index, Bullet )
				end

		elseif Retry == "Ricochet"  then
		
			if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end

			Bullet.ImpactCount = (Bullet.ImpactCount or 0) + 1
			if Bullet.ImpactCount > 50 then --A bullet has impacted more than 50 props. But why though?			
				ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
			else

			ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
			--print("After")
			--print(Bullet.Flight)
			ACF_CalcBulletFlight( Index, Bullet, true )
			end
			
		else						--Else end the flight here
			if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
			ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
			ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
			ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
		end

	--bullet hit the world
	elseif FlightRes.HitWorld then
	
		if not FlightRes.HitSky then									--If we hit the world then try to see if it's thin enough to penetrate
		
			ACF_BulletWorldImpact = ACF.RoundTypes[Bullet.Type]["worldimpact"]
			
			local Retry = ACF_BulletWorldImpact( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )
			
			if Retry == "Penetrated" then 								--if it is, we soldier on	
			    --print('World-Pen')
				if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end
				ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
				ACF_CalcBulletFlight( Index, Bullet, true )				--The world ain't going to move, so we say True for the backtrace override
				
			elseif Retry == "Ricochet"  then
			    --print('World-Rico')
				if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end
				ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
				ACF_CalcBulletFlight( Index, Bullet, true )
				
			else														--If not, end of the line, boyo
			    --print('World-NoPen')
				if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end
				ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
				
			end
		
		else												--hit skybox
			if FlightRes.HitNormal == Vector(0,0,-1) then 	--only if leaving top of skybox
				Bullet.SkyLvL = FlightRes.HitPos.z 						-- Lets save height on which bullet went through skybox. So it will start tracing after falling bellow this level. This will prevent from hitting higher levels of map
				Bullet.LifeTime = ACF.CurTime
				Bullet.Pos = Bullet.NextPos
			else 
				ACF_RemoveBullet( Index )
			end
		end

	--bullet hit nothing, keep flying
	else
		Bullet.Pos = Bullet.NextPos
	end
	
end

function ACF_BulletClient( Index, Bullet, Type, Hit, HitPos )
	
	if Type == "Update" then
		local Effect = EffectData()
		    
			Effect:SetAttachment( Index )		--Bulet Index
			Effect:SetStart( Bullet.Flight/10 )	--Bullet Direction
			
			if Hit > 0 then		-- If there is a hit then set the effect pos to the impact pos instead of the retry pos
				Effect:SetOrigin( HitPos )		--Bullet Pos
			else
				Effect:SetOrigin( Bullet.Pos )
			end
			
			Effect:SetScale( Hit )	--Hit Type 
		util.Effect( "ACF_BulletEffect", Effect, true, true )

	else
		local Effect = EffectData()
			local Filler = 0
			if Bullet["FillerMass"] then Filler = Bullet["FillerMass"]*15 end
			Effect:SetAttachment( Index )		--Bulet Index
			Effect:SetStart( Bullet.Flight/10 )	--Bullet Direction
			Effect:SetOrigin( Bullet.Pos )
			Effect:SetEntity( Entity(Bullet["Crate"]) )
			Effect:SetScale( 0 )
		util.Effect( "ACF_BulletEffect", Effect, true, true )

	end

end

function ACF_BulletWorldImpact( Bullet, Index, HitPos, HitNormal )
	--You overwrite this with your own function, defined in the ammo definition file
end

function ACF_BulletPropImpact( Bullet, Index, Target, HitNormal, HitPos )
	--You overwrite this with your own function, defined in the ammo definition file
end

function ACF_BulletEndFlight( Bullet, Index, HitPos )
	--You overwrite this with your own function, defined in the ammo definition file
end

