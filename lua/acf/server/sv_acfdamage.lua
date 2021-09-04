-- This file is meant for the advanced damage functions used by the Armored Combat Framework

-- optimization; reuse tables for ballistics traces
local TraceRes = { }
local TraceInit = { output = TraceRes }

ACF.HEFilter = {
	gmod_wire_hologram = true,
	prop_vehicle_crane, true,
	prop_dynamic = true,
	ace_debris = true,
	gmod_ent_ttc = true,
	gmod_ent_ttc_auto = true,
	ace_flares = true
}

--I don't want HE processing every ent that it has in range
function ACF_HEFind( Hitpos, Radius )

	local Table = {}
	for i, ent in pairs( ents.FindInSphere( Hitpos, Radius ) ) do
		--skip any undesired ent
		if ACF.HEFilter[ent:GetClass()] then goto cont end
		if not ent:IsSolid() then goto cont end

		table.insert( Table, ent )
		::cont::
	end

	return Table
end
--[[----------------------------------------------------------------------------
	Function:
		ACF_HE
	Arguments:
		HitPos 		- detonation center,
		FillerMass 	- mass of TNT being detonated in KG
		FragMass 	- mass of the round casing for fragmentation purposes
		Inflictor	- owner of said TNT
		NoOcc		- table with entities to ignore
		Gun			- gun entity from which round is fired
	Purpose:
		Handles ACF explosions
------------------------------------------------------------------------------]]

function ACF_HE( Hitpos , HitNormal , FillerMass, FragMass, Inflictor, NoOcc, Gun )
	local Power = FillerMass * ACF.HEPower					--Power in KiloJoules of the filler mass of  TNT
	local Radius = (FillerMass)^0.33*8*39.37				--Scalling law found on the net, based on 1PSI overpressure from 1 kg of TNT at 15m.
	local MaxSphere = (4 * 3.1415 * (Radius*2.54 )^2) 		--Surface Aera of the sphere at maximum radius
	local Amp = math.min(Power/2000,50)
	util.ScreenShake( Hitpos, Amp, Amp, Amp/15, Radius*10 )

	--debugoverlay.Sphere(Hitpos, Radius, 15, Color(255,0,0,32), 1) --developer 1   in console to see
	
	--Will give tiny HE just a pinch of radius to help it hit the player
	local Targets = ACF_HEFind( Hitpos, Radius )
	
	local Fragments = math.max(math.floor((FillerMass/FragMass)*ACF.HEFrag),2)
	local FragWeight = FragMass/Fragments
	local FragVel = (Power*50000/FragWeight/Fragments)^0.5
	local FragAera = (FragWeight/7.8)^0.33
	
	local OccFilter = istable(NoOcc) and NoOcc or { NoOcc }
	local LoopKill = true
	
	while LoopKill and Power > 0 do

		LoopKill = false

		local PowerSpent = 0
		local Damage = {}
		local TotalAera = 0

		for i,Tar in pairs(Targets) do

			if not Tar:IsValid() then goto cont end

			if Power > 0 and not Tar.Exploding then

				local Type = ACF_Check(Tar)

				if ( Type ) then

					local Hitat = nil

					if Type == "Squishy" then 	--A little hack so it doesn't check occlusion at the feet of players

						--Modified to attack the feet, center, or eyes, whichever is closest to the explosion
						Hitat = Tar:NearestPoint( Hitpos )					
						local cldist = Hitpos:Distance( Hitat ) or 99999999999
						local Tpos
						local Tdis = 99999999999
						
						local Eyes = Tar:LookupAttachment("eyes")

						if Eyes then

							local Eyeat = Tar:GetAttachment( Eyes )
							if Eyeat then
								--Msg("Hitting Eyes\n")
								Tpos = Eyeat.Pos
								Tdis = Hitpos:Distance( Tpos ) or 99999999999
								if Tdis < cldist then
									Hitat = Tpos
									cldist = cldist
								end
							end
						end

						Tpos = Tar:WorldSpaceCenter()
						Tdis = Hitpos:Distance( Tpos ) or 99999999999
						if Tdis < cldist then
							Hitat = Tpos
							cldist = cldist
						end

					else
						Hitat = Tar:NearestPoint( Hitpos )
					end
					
					--if hitpos inside hitbox of victim prop, nearest point doesn't work as intended
					if Hitat == Hitpos then Hitat = Tar:GetPos() end
					
					--[[see if we have a clean view to victim prop
					local Occlusion = {}
						Occlusion.start = Hitpos
						Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
						Occlusion.filter = OccFilter
						Occlusion.mask = MASK_SOLID
					local Occ = util.TraceLine( Occlusion )	
					]]--


					TraceInit.start = Hitpos
					TraceInit.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
					TraceInit.filter = OccFilter
					TraceInit.mask = MASK_SOLID
					TraceInit.mins = Vector( 0, 0, 0 )
					TraceInit.maxs = Vector( 0, 0, 0 ) 

					--util.TraceLine( TraceInit ) -- automatically stored in output table: TraceRes
					util.TraceHull( TraceInit )

					--[[
					--retry for prop center if no hits at all, might have whiffed through bounding box and missed phys hull
					--nearestpoint uses intersect of bbox from source point to origin (getpos), this is effectively just redoing the same thing
					if ( !Occ.Hit and Hitpos != Hitat ) then
						local Hitat = Tar:GetPos()
						local Occlusion = {}
							Occlusion.start = Hitpos
							Occlusion.endpos = Hitat + (Hitat-Hitpos):GetNormalized()*100
							Occlusion.filter = OccFilter
							Occlusion.mask = MASK_SOLID
						Occ = util.TraceLine( Occlusion )	
					end
					--]]
					
					if ( !TraceRes.Hit ) then
						--no hit
					elseif ( TraceRes.Hit and TraceRes.Entity:EntIndex() != Tar:EntIndex() ) then
						--occluded, no hit
					else
						Targets[i] = nil	--Remove the thing we just hit from the table so we don't hit it again in the next round
						local Table = {}
							
						Table.Ent = Tar

						if Tar:GetClass() == "acf_engine" or Tar:GetClass() == "acf_ammo" or Tar:GetClass() == "acf_fueltank" then
							Table.LocalHitpos = WorldToLocal(Hitpos, Angle(0,0,0), Tar:GetPos(), Tar:GetAngles())
						end

						Table.Dist = Hitpos:Distance(Tar:GetPos())
						Table.Vec = (Tar:GetPos() - Hitpos):GetNormalized()

						local Sphere = math.max(4 * 3.1415 * (Table.Dist*2.54 )^2,1) --Surface Aera of the sphere at the range of that prop
						local AreaAdjusted = Tar.ACF.Aera

						--Project the aera of the prop to the aera of the shadow it projects at the explosion max radius
						Table.Aera = math.min(AreaAdjusted/Sphere,0.5)*MaxSphere 
						table.insert(Damage, Table)	--Add it to the Damage table so we know to damage it once we tallied everything

						-- is it adding it too late?
						TotalAera = TotalAera + Table.Aera
					end

				else

					Targets[i] = nil	--Target was invalid, so let's ignore it
					table.insert( OccFilter , Tar ) -- updates the filter in TraceInit too
				end	
			end
			::cont::
		end
		
		for i,Table in pairs(Damage) do
			
			local Tar = Table.Ent
			local Feathering = (1-math.min(1,Table.Dist/Radius)) ^ ACF.HEFeatherExp
			local AeraFraction = Table.Aera/TotalAera
			local PowerFraction = Power * AeraFraction	--How much of the total power goes to that prop
			local AreaAdjusted = (Tar.ACF.Aera / ACF.Threshold) * Feathering
			
			local BlastRes
			local Blast = {
				--Momentum = PowerFraction/(math.max(1,Table.Dist/200)^0.05), --not used for anything
				Penetration = PowerFraction^ACF.HEBlastPen*AreaAdjusted
			}
			
			local FragRes
			local FragHit = Fragments * AeraFraction
			local FragVel = math.max(FragVel - ( (Table.Dist/FragVel) * FragVel^2 * FragWeight^0.33/10000 )/ACF.DragDiv,0)
			local FragKE = ACF_Kinetic( FragVel , FragWeight*FragHit, 1500 )
			if FragHit < 0 then 
				if math.Rand(0,1) > FragHit then FragHit = 1 else FragHit = 0 end
			end
			
			-- erroneous HE penetration bug workaround; retries trace on crit ents after a short delay to ensure a hit.
			-- we only care about hits on critical ents, saves on processing power
			-- not going to re-use tables in the timer, shouldn't make too much difference
			if Tar:GetClass() == "acf_engine" or Tar:GetClass() == "acf_ammo" or Tar:GetClass() == "acf_fueltank" then
				timer.Simple(0.015*2, function() 
					if not IsValid(Tar) then return end
					
					--recreate the hitpos and hitat, add slight jitter to hitpos and move it away some
					local NewHitpos = LocalToWorld(Table.LocalHitpos + Table.LocalHitpos:GetNormalized()*3, Angle(math.random(),math.random(),math.random()), Tar:GetPos(), Tar:GetAngles())
					local NewHitat = Tar:NearestPoint( NewHitpos )
					
					local Occlusion = {
						start = NewHitpos,
						endpos = NewHitat + (NewHitat-NewHitpos):GetNormalized()*100,
						filter = NoOcc,
						mask = MASK_SOLID,
						mins = Vector( 0, 0, 0 ), 
						maxs = Vector( 0, 0, 0 ) 
					}
					local Occ = util.TraceHull( Occlusion )	
					
					if ( !Occ.Hit and NewHitpos != NewHitat ) then
						local NewHitat = Tar:GetPos()
						local Occlusion = {
							start = NewHitpos,
							endpos = NewHitat + (NewHitat-NewHitpos):GetNormalized()*100,
							filter = NoOcc,
							mask = MASK_SOLID,
							mins = Vector( 0, 0, 0 ), 
							maxs = Vector( 0, 0, 0 ) 
						}
						Occ = util.TraceHull( Occlusion )	
					end
					
					if ( Occ.Hit and Occ.Entity:EntIndex() != Tar:EntIndex() ) then
						--occluded, confirmed HE bug
						--print("HE bug on "..Tar:GetClass()..", occluded by "..(Occ.Entity:GetModel()))
						--debugoverlay.Sphere(Hitpos, 4, 20, Color(16,16,16,32), 1)
						--debugoverlay.Sphere(NewHitpos,3,20,Color(0,255,0,32), true)
						--debugoverlay.Sphere(NewHitat,3,20,Color(0,0,255,32), true)
					elseif ( !Occ.Hit and NewHitpos != NewHitat ) then
						--no hit, confirmed HE bug
						--print("HE bug on "..Tar:GetClass())
					else
						--confirmed proper hit, apply damage
						--print("No HE bug on "..Tar:GetClass())
						
						BlastRes = ACF_Damage ( Tar    , Blast  , AreaAdjusted , 0     , Inflictor , 0    , Gun , "HE" )
						FragRes = ACF_Damage ( Tar , FragKE , FragAera*FragHit , 0 , Inflictor , 0, Gun, "Frag" )
						if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then					
							local Debris = ACF_HEKill( Tar, (Tar:GetPos() - NewHitpos):GetNormalized(), PowerFraction , Hitpos)
						else
							ACF_KEShove(Tar, NewHitpos, (Tar:GetPos() - NewHitpos):GetNormalized(), PowerFraction * 0.333 * (GetConVarNumber("acf_hepush") or 1) ) --0.333
						end
					end
				end)
				
				--calculate damage that would be applied (without applying it), so HE deals correct damage to other props
				BlastRes = ACF_CalcDamage( Tar, Blast, AreaAdjusted, 0 )

			else

				--reduced damage to era if detonation is from another era by 85%. So we avoid a chain reaction
				if IsValid(Gun) then
					if Gun:GetClass() == 'prop_physics' then
						local mat = Gun.ACF and Gun.ACF.Material
						if mat == 4 then
							Blast.Penetration = Blast.Penetration*0.15
						end
					end
				end

				BlastRes = ACF_Damage ( Tar  , Blast , AreaAdjusted , 0 , Inflictor ,0 , Gun, "HE" )
				FragRes = ACF_Damage ( Tar , FragKE , FragAera*FragHit , 0 , Inflictor , 0, Gun, "Frag" )
				
				
				if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then

				    --print('RIP') 
					--Add the debris created to the ignore so we don't hit it in other rounds
					local Debris = ACF_HEKill( Tar , Table.Vec , PowerFraction , Hitpos )
					table.insert( OccFilter , Debris )						
					LoopKill = true --look for fresh targets since we blew a hole somewhere

				else
				    --print('NO RIP')
				    --Assuming about 1/30th of the explosive energy goes to propelling the target prop (Power in KJ * 1000 to get J then divided by 33)
					ACF_KEShove(Tar, Hitpos, Table.Vec, PowerFraction * 15 * (GetConVarNumber("acf_hepush") or 1) ) 

				end
			end

			PowerSpent = PowerSpent + PowerFraction*BlastRes.Loss/2--Removing the energy spent killing props
		end

		Power = math.max(Power - PowerSpent,0)	
	end
		
end

--Handles normal spalling
function ACF_Spall( HitPos , HitVec , HitMask , KE , Caliber , Armour , Inflictor , Material)
	
	--Don't use it if it's not allowed to
	if not ACF.Spalling then return end
	
	local Mat = Material or 0

	-- Spall damage
	local SpallMul = ACE.ArmorTypes[ Mat ].spallmult or 1

	-- Spall armor factor bias
	local ArmorMul = ACE.ArmorTypes[ Mat ].ArmorMul or 1
	local UsedArmor = Armour*ArmorMul

	if SpallMul > 0 and Caliber*10 > UsedArmor and Caliber > 3 then

		-- Normal spalling core
		local TotalWeight = 3.1416*(Caliber/2)^2 * math.max(UsedArmor,30) * 150
		local Spall = math.min(math.floor((Caliber-3)*ACF.KEtoSpall*SpallMul*1.33),24)
		local SpallWeight = TotalWeight/Spall*SpallMul
		local SpallVel = (KE*16/SpallWeight)^0.5/Spall*SpallMul
		local SpallAera = (SpallWeight/7.8)^0.33 
		local SpallEnergy = ACF_Kinetic( SpallVel , SpallWeight, 800 )

		for i = 1,Spall do

			-- Normal Trace creation
			local SpallTr = {}
			SpallTr.start = HitPos
			SpallTr.endpos = HitPos + (HitVec:GetNormalized()+VectorRand()/3):GetNormalized()*math.max( SpallVel*10, math.random(450,600) ) --I got bored of spall not going across the tank
			SpallTr.filter = HitMask

			ACF_SpallTrace(HitVec, SpallTr , SpallEnergy , SpallAera , Inflictor)

			--little sound optimization
			if i < math.max(math.Round(Spall/2), 1) then
				sound.Play('/acf_other/penetratingshots/pen'..math.Round(math.random(1, 6))..'.wav', HitPos, 75, 100, 0.5)
			end

		end
	end
end

--ents that should recieve the spall instead of being used as shockwave transfer
ACF.VulnerableEnts = {

	acf_gun = true,
	acf_engine = true,
	acf_fueltank = true,
	acf_gearbox = true,
	acf_ammo = true,
	acf_rack = true,
	prop_vehicle_prisoner_pod = true

}

--Dedicated function for HESH spalling
function ACF_PropShockwave( HitPos, HitVec, HitMask, Caliber )

	--Don't even bother at calculating something that doesn't exist
	if #HitMask == 0 then return end

	--General
	local FindEnd = true --marked for initial loop
	local TraceBugged = false --Sometimes trace tends to bug itself and renders the loop useless, so we need to tag it
	local iteration = 0 	--since while has not index

	local EntsToHit = { HitMask[1] } --Used for the second tracer, where it tells what ents must hit

	--HitPos
	local HitFronts = {}	--Any tracefronts hitpos will be stored here
	local HitBacks = {}		--Any traceback hitpos will be stored here

	--Distances. Store any distance
	local FrontDists = {}
	local BackDists = {}

	local Normals = {}

	--Results
	local fNormal = Vector(0,0,0)
	local finalpos
	local TotalArmor = {}

	--Tracefront general data--
	local TrFront = {}
	TrFront.start = HitPos
	TrFront.endpos = HitPos + HitVec:GetNormalized()*Caliber*1.5
	TrFront.ignoreworld = true
	TrFront.filter = {}

	--Traceback general data--
	local TrBack = {}
	TrBack.start = HitPos + HitVec:GetNormalized()*Caliber*1.5
	TrBack.endpos = HitPos
	TrBack.ignoreworld = true
	TrBack.filter = function( ent ) if ( ent:EntIndex() == EntsToHit[#EntsToHit]:EntIndex()) then print(ent:GetClass()) return true end end


	while FindEnd do

		iteration = iteration + 1
		--print('iteration #'..iteration)

		--In case of total failure, this loop is limited to 1000 iterations, don't make me increase it even more.
		if iteration >= 1000 then FindEnd = false end

		--================-TRACEFRONT-==================-
		local tracefront = util.TraceLine( TrFront )

		--insert the hitpos here
		local HitFront = tracefront.HitPos
		table.insert( HitFronts, HitFront )

		--distance between the initial hit and hitpos of front plate
		local distToFront = math.abs( (HitPos - HitFront):Length() )
		table.insert( FrontDists, distToFront)

		--TraceFront's armor entity
		local Armour = tracefront.Entity.ACF and tracefront.Entity.ACF.Armour or 0

		--Code executed once its scanning the 2nd prop
		if iteration > 1 then

			--check if they are totally overlapped
			if math.Round(FrontDists[iteration-1]) ~= math.Round(FrontDists[iteration] ) then

				--distance between the start of ent1 and end of ent2
				local space = math.abs( (HitFronts[iteration] - HitBacks[iteration - 1]):Length() )

				--prop's material
				local mat = tracefront.Entity.ACF and tracefront.Entity.ACF.Material or 0


				local Hasvoid = false
				local NotOverlap = false

				--print('DATA TABLE - DONT FUCKING DELETE')
				--print('distToFront: '..distToFront)
				--print('BackDists[iteration - 1]: '..BackDists[iteration - 1])
				--print('DISTS DIFF: '..distToFront - BackDists[iteration - 1])
				--print('ESTA OVERLAPEADO SI ES +, NO LO ESTA SI ES NEGATIVO')

				--check if we have void
				if space > 1 then
					Hasvoid = true
				end

				--check if we dont have props semi-overlapped
				if distToFront > BackDists[iteration - 1] then
					NotOverlap = true
				end

				--check if we have spaced armor, spall liners ahead, if so, end here
				if (Hasvoid and NotOverlap) or (tracefront.Entity:IsValid() and ACF.VulnerableEnts[ tracefront.Entity:GetClass() ]) or mat == 3 or mat == 4 or mat == 6 then
					--print('stopping')
					FindEnd = false
					finalpos = HitBacks[iteration - 1] + HitVec:GetNormalized()*0.1
					fNormal = Normals[iteration - 1]
					--print('iteration #'..iteration..' / FINISHED!') 

					break 
				end
			end
	
			--start inserting new ents to the table when iteration pass 1, so we don't insert the already inserted prop (first one)
			table.insert( EntsToHit, tracefront.Entity)

		end

		--Filter this ent from being processed again in the next checks
		table.insert( TrFront.filter, tracefront.Entity )

		--Add the armor value to table
		table.insert( TotalArmor, Armour )

		--================-TRACEBACK-==================
		local traceback = util.TraceLine( TrBack )

		--insert the hitpos here
		local HitBack = traceback.HitPos
		table.insert( HitBacks, HitBack )

		--store the dist between the backhit and the hitvec
		local distToBack = math.abs( (HitPos - HitBack):Length() )
		table.insert( BackDists, distToBack)

		table.insert( Normals, traceback.HitNormal )

		--flag this iteration as lost
		if not tracefront.Hit then
			--print('[ACE|WARN]- TRACE HAS BROKEN!')
			TraceBugged = true
		end
		--break if the trace has bugged.
		if TraceBugged  then
			FindEnd = false 
			finalpos = HitBack + HitVec:GetNormalized()*0.1
			fNormal = Normals[iteration]
			--print('iteration #'..iteration..' / FINISHED')

			break
		end

		--for red traceback
		debugoverlay.Line( traceback.StartPos+Vector(0,0,#EntsToHit*0.1), traceback.HitPos+Vector(0,0,#EntsToHit*0.1), 20 , Color(math.random(100,255),0,0) )
		--for green tracefront
		debugoverlay.Line( tracefront.StartPos+Vector(0,0,#EntsToHit*0.1), tracefront.HitPos+Vector(0,0,#EntsToHit*0.1), 20 , Color(0,math.random(100,255),0) )
	end

	local ArmorSum = 0
	for i=1, #TotalArmor do
		--print('Armor prop count: '..i..', Armor value: '..TotalArmor[i])
		ArmorSum = ArmorSum + TotalArmor[i]
	end

	--print(ArmorSum)
	return finalpos, ArmorSum, TrFront.filter, fNormal
end

--Handles HESH spalling
function ACF_Spall_HESH( HitPos , HitVec , HitMask , HEFiller , Caliber , Armour , Inflictor , Material)
    
    local Mat = Material or 0

	spallPos, Armour, PEnts, fNormal = ACF_PropShockwave( HitPos, HitVec, HitMask, Caliber )

	--if not spallPos then return end
    -- Spall damage
	local SpallMul = ACE.ArmorTypes[ Mat ].spallmult or 1

	-- Spall armor factor bias
	local ArmorMul = ACE.ArmorTypes[ Mat ].ArmorMul or 1
	local UsedArmor = Armour*ArmorMul

	if SpallMul > 0 and HEFiller/1501*4 > UsedArmor then

		--print('[ACE|INFO]- Spall created')

		--era stops the spalling at the cost of being detonated
		if Mat == 4 then HitMask[1].ACF.ERAexploding = true return end

		-- HESH spalling core
		local TotalWeight = 3.1416*(Caliber/2)^2 * math.max(UsedArmor,30) * 2500
		local Spall = math.min(math.floor((Caliber-3)/3*ACF.KEtoSpall*SpallMul),48) --24
		local SpallWeight = TotalWeight/Spall*SpallMul
		local SpallVel = (HEFiller*16/SpallWeight)^0.5/Spall*SpallMul
		local SpallAera = (SpallWeight/7.8)^0.33 
		local SpallEnergy = ACF_Kinetic( SpallVel , SpallWeight, 800 )



		for i = 1,Spall do

			-- HESH trace creation
			local SpallTr = { }
			SpallTr.start = spallPos
			SpallTr.endpos = spallPos + ((fNormal*2500+HitVec):GetNormalized()+VectorRand()/3):GetNormalized()*math.max(SpallVel*10,math.random(450,600)) --I got bored of spall not going across the tank
			SpallTr.filter = PEnts

			ACF_SpallTrace(HitVec, SpallTr , SpallEnergy , SpallAera , Inflictor, i)

			--little sound optimization
			if i < math.max(math.Round(Spall/4), 1) then
				sound.Play('/acf_other/penetratingshots/pen'..math.Round(math.random(1, 6))..'.wav', spallPos, 75, 100, 0.5)
			end
		end
	end
end

--Spall trace core. For HESH and normal spalling
function ACF_SpallTrace(HitVec,  SpallTr, SpallEnergy, SpallAera, Inflictor, Spallid )

	-- Spalling trace data
	local SpallRes = util.TraceLine(SpallTr)

	debugoverlay.Line( SpallRes.StartPos, SpallRes.HitPos, 10 , Color(255,150,0) )

	-- Check if spalling hit something
	if SpallRes.Hit and ACF_Check( SpallRes.Entity ) then

		-- Get the spalling hitAngle
		local Angle = ACF_GetHitAngle( SpallRes.HitNormal , HitVec )

		local Mat = SpallRes.Entity.ACF and SpallRes.Entity.ACF.Material or 0

		local spallarmor = ACE.ArmorTypes[ Mat ].spallarmor
		local spallresist = ACE.ArmorTypes[ Mat ].spallresist

		SpallEnergy.Penetration = SpallEnergy.Penetration / spallarmor
		--SpallEnergy.Momentum = SpallEnergy.Momentum / spallresist

		--extra damage for ents like ammo, engines, etc
		if ACF.VulnerableEnts[ SpallRes.Entity:GetClass() ] then
			SpallEnergy.Penetration = SpallEnergy.Penetration * 1.25
		end

		-- Applies the damage to the impacted entity
		local HitRes = ACF_Damage( SpallRes.Entity , SpallEnergy , SpallAera , Angle , Inflictor, 0, nil, "Spall")  --DAMAGE !!

		-- If it's able to destroy it, kill it
		if HitRes.Kill then
			ACF_APKill( SpallRes.Entity , HitVec:GetNormalized() , SpallEnergy.Kinetic )
		end		

		-- Applies a decal
		util.Decal("GunShot1", SpallRes.StartPos, SpallRes.HitPos, SpallTr.filter )

		-- The entity was penetrated
		if HitRes.Overkill > 0 then

			-- filter the penetrated prop for the retry
			table.insert( SpallTr.filter , SpallRes.Entity )

			-- Reduces the current SpallEnergy data for the next entity to hit
			SpallEnergy.Penetration = SpallEnergy.Penetration*(1-HitRes.Loss)
			SpallEnergy.Momentum = SpallEnergy.Momentum*(1-HitRes.Loss)

			-- Retry
			ACF_SpallTrace( SpallRes.HitPos , SpallTr , SpallEnergy , SpallAera , Inflictor, Material )

			return
		end
	end
end

--Calculates the vector of the ricochet of a round upon impact at a set angle
function ACF_RicochetVector(Flight, HitNormal)
	local Vec = Flight:GetNormalized() 

	return Vec - ( 2 * Vec:Dot(HitNormal) ) * HitNormal
end

-- Handles the impact of a round on a target
function ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone  )

	Bullet.Ricochets = Bullet.Ricochets or 0

	local Angle = ACF_GetHitAngle( HitNormal , Bullet["Flight"] )
	local HitRes = ACF_Damage ( --DAMAGE !!
		Target,
		Energy,
		Bullet["PenAera"],
		Angle,
		Bullet["Owner"],
		Bone,
		Bullet["Gun"],
		Bullet["Type"]
	)

	local Ricochet = 0
	local sigmoidCenter = Bullet.DetonatorAngle or ( (Bullet.Ricochet or 55) - math.max(Speed / 39.37 - (Bullet.LimitVel or 800),0) / 100 ) --Changed the abs to a min. Now having a bullet slower than normal won't increase chance to richochet.
	local ricoProb = 1

	--print(Angle)

	if Angle > 85 then
		ricoProb = 0 --Guarenteed Richochet
	elseif Bullet.Caliber*3.33 > Target.ACF.Armour/math.max(math.sin(90-Angle),0.0001)  then
		ricoProb = 1 --Guarenteed to not richochet
	else
		ricoProb = math.min(1-(math.max(Angle - sigmoidCenter,0)/sigmoidCenter*4),1)
	end


	-- Checking for ricochet
	if ricoProb < math.random() and Angle < 90 then --The angle value is clamped but can cause game crashes if this overflow check doesnt exist. Why?
		Ricochet       = math.Clamp(Angle / 90, 0.1, 1) -- atleast 10% of energy is kept
		HitRes.Loss    = 1 - Ricochet
		Energy.Kinetic = Energy.Kinetic * HitRes.Loss
	end	

	
	ACF_KEShove(
		Target,
		HitPos,
		Bullet["Flight"]:GetNormalized(),
		Energy.Kinetic * HitRes.Loss * 1000 * Bullet["ShovePower"] * (GetConVarNumber("acf_recoilpush") or 1)
	)
	
	if HitRes.Kill then
		local Debris = ACF_APKill( Target , (Bullet["Flight"]):GetNormalized() , Energy.Kinetic )
		table.insert( Bullet["Filter"] , Debris )
	end	
	
	HitRes.Ricochet = false
	if Ricochet > 0 and Bullet.Ricochets < 3 and IsValid(Target) then
		Bullet.Ricochets = Bullet.Ricochets + 1
		Bullet["Pos"] = HitPos + HitNormal * 0.75
		Bullet.FlightTime = 0
		Bullet.Flight = (ACF_RicochetVector(Bullet.Flight, HitNormal) + VectorRand()*0.025):GetNormalized() * Speed * Ricochet
		
		if IsValid( ACF_GetPhysicalParent(Target):GetPhysicsObject() ) then
		    Bullet.TraceBackComp = math.max(ACF_GetPhysicalParent(Target):GetPhysicsObject():GetVelocity():Dot(Bullet["Flight"]:GetNormalized()),0)
		else 
		    --print('holy crap, how this is possible??!?!')
		end
		
		HitRes.Ricochet = true
	end
	
	return HitRes
end

--Handles Ground penetrations
function ACF_PenetrateGround( Bullet, Energy, HitPos, HitNormal )   --tracehull show again

	Bullet.GroundRicos = Bullet.GroundRicos or 0
	
	local MaxDig = (( Energy.Penetration * 1.5 / Bullet.PenAera ) * ACF.KEtoRHA / ACF.GroundtoRHA )/25.4  --adding 0.5x more energy pen cuz some low caliber guns like racs with 60mm pen are supposed to break though thin walls.
	
	--print('Max Dig: '..MaxDig..'\nEnergy Pen: '..Energy.Penetration..'\n')
	
	local HitRes = {Penetrated = false, Ricochet = false}
			
	local DigRes = util.TraceHull( { 

	
		start = HitPos + Bullet.Flight:GetNormalized()*0.1,
		endpos = HitPos + Bullet.Flight:GetNormalized()*(MaxDig+0.1),
		filter = Bullet.Filter,
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ), 
		mask = MASK_SOLID_BRUSHONLY
		
		} )
	--print(util.GetSurfacePropName(DigRes.SurfaceProps))
	
	local loss = DigRes.FractionLeftSolid
	
	if loss == 1 or loss == 0 then --couldn't penetrate
	    --print('Non Penetration! PenValid: '..loss)
		--print(start)
		local Ricochet = 0
		local Speed = Bullet.Flight:Length() / ACF.VelScale
		local Angle = ACF_GetHitAngle( HitNormal, Bullet.Flight )
		local MinAngle = math.min(Bullet.Ricochet - Speed/39.37/30 + 20,89.9)	--Making the chance of a ricochet get higher as the speeds increase
		if Angle > math.random(MinAngle,90) and Angle < 89.9 then	--Checking for ricochet
			Ricochet = Angle/90*0.75
		end
		
		if Ricochet > 0 and Bullet.GroundRicos < 2 then
			Bullet.GroundRicos = Bullet.GroundRicos + 1
			Bullet.Pos = HitPos + HitNormal * 1
			Bullet.Flight = (ACF_RicochetVector(Bullet.Flight, HitNormal) + VectorRand()*0.05):GetNormalized() * Speed * Ricochet
			HitRes.Ricochet = true
		end
	else --penetrated
	    --print('Penetrated! PenValid: '..loss)
		Bullet.Flight = Bullet.Flight * (1 - loss)
		Bullet.Pos = DigRes.StartPos + Bullet.Flight:GetNormalized() * 0.25 --this is actually where trace left brush
		HitRes.Penetrated = true
	end
	
	return HitRes
end

--Handles HE push forces
function ACF_KEShove(Target, Pos, Vec, KE )

	local CanDo = hook.Run("ACF_KEShove", Target, Pos, Vec, KE )
	if CanDo == false then return end

	local parent = ACF_GetPhysicalParent(Target)
	local phys = parent:GetPhysicsObject()
	
	if not phys:IsValid() then return end
	
	if not Target.acflastupdatemass or ((Target.acflastupdatemass + 10) < CurTime()) then
		ACF_CalcMassRatio(Target)
	end
		
	if not Target.acfphystotal then return end --corner case error check
		
	local physratio = Target.acfphystotal / Target.acftotal
	
	--todo: https://github.com/MartyX5555/ACE-Dev/pull/1 --> see this
	phys:ApplyForceOffset( Vec:GetNormalized() * KE * physratio, Pos )

end


-- whitelist for things that can be turned into debris
ACF.Debris = {
	acf_gun = true,
	acf_rack = true,
	acf_gearbox = true,
	acf_engine = true,
	prop_physics = true,
	prop_vehicle_prisoner_pod = true
}

-- things that should have scaledexplosion called on them instead of being turned into debris
ACF.Splosive = {
	acf_ammo = true,
	acf_fueltank = true	
}

-- helper function to process children of an acf-destroyed prop
-- AP will HE-kill children props like a detonation; looks better than a directional spray of unrelated debris from the AP kill
local function ACF_KillChildProps( Entity, BlastPos, Energy )  

	local children = ACF_GetAllChildren(Entity)
	
	--why should we make use of this for ONE prop?
	if table.Count(children) > 1 then  

		local count = 0
		local boom = {}

	    -- do an initial processing pass on children, separating out explodey things to handle last
	    for k, ent in pairs( children ) do

		    --Removes the first impacted entity. This should avoid debris being duplicated there.
		    if Entity:EntIndex() == ent:EntIndex() then children[ent] = nil goto cont end	    	

		    -- mark that it's already processed
		    ent.ACF_Killed = true

		    local class = ent:GetClass()

		    -- exclude any entity that is not part of debris ents whitelist
		    if not ACF.Debris[class] then

		    	children[ent] = nil goto cont
		    else

			    -- remove this ent from children table and move it to the explosive table
			    if ACF.Splosive[class] and not ent.Exploding then

				    table.insert( boom , ent ) 
				    children[ent] = nil

				    goto cont
			    else
			    	-- can't use #table or :count() because of ent indexing...
				    count = count + 1  
			    end

		    end

		    ::cont::
	    end


	    -- HE kill the children of this ent, instead of disappearing them by removing parent
	    if count > 0 then

	    	--Some props will not be processed into debris to save performance
		    local DebrisChance = math.Clamp(ACF.ChildDebris/count, 0, 1)
		    local power = Energy/math.min(count,3)

		    for k, child in pairs( children ) do

		    	--Skip any invalid entity
			    if not IsValid(child) then goto cont end

			    -- ignore some of the debris props to save lag
				if math.random() < DebrisChance then 

					ACF_HEKill( child, (child:GetPos() - BlastPos):GetNormalized(), power )
				else

					constraint.RemoveAll( child )
					child:Remove()
				end

				::cont::
		    end
	    end


	    -- explode stuff last, so we don't re-process all that junk again in a new explosion
	    if table.Count( boom ) > 0 then

		    for _, child in pairs( boom ) do

		    	if not IsValid(child) or child.Exploding then goto cont end

		    	child.Exploding = true
		    	ACF_ScaledExplosion( child ) -- explode any crates that are getting removed

		    	::cont::
		    end
	    end

	    --sound.Play( "weapons/strider_buster/Strider_Buster_detonate.wav", Entity:GetPos() , 100, 75, math.Clamp(300 - count*25,15,255))
	end	
end


function ACF_HEKill( Entity , HitVector , Energy , BlastPos )

	-- if it hasn't been processed yet, check for children
	if not Entity.ACF_Killed then ACF_KillChildProps( Entity, BlastPos or Entity:GetPos(), Energy ) end

	--ERA props should not create debris
	if not Entity.ACF then return end
	local Mat = Entity.ACF.Material or 0
	if Mat == 4 then return end
	
	constraint.RemoveAll( Entity )
	Entity:Remove()

	if(Entity:BoundingRadius() < ACF.DebrisScale) then return nil end
	
	local Debris = ents.Create( "ace_debris" )
		Debris:SetModel( Entity:GetModel() )
		Debris:SetAngles( Entity:GetAngles() )
		Debris:SetPos( Entity:GetPos() )
		Debris:SetMaterial("models/props_wasteland/metal_tram001a")
		Debris:Spawn()
		
	if math.random() < ACF.DebrisIgniteChance then
		Debris:Ignite(math.Rand(5,45),0)
	end
	
	Debris:Activate()

	--Applies force to this debris
	local phys = Debris:GetPhysicsObject() 
	local physent = Entity:GetPhysicsObject()

	if phys:IsValid() and physent:IsValid() then	
		phys:SetMass(physent:GetMass())
		phys:ApplyForceOffset( HitVector:GetNormalized() * Energy * 25, Debris:GetPos()+VectorRand()*600 ) 		   
	end

	return Debris
	
end


function ACF_APKill( Entity , HitVector , Power )

	-- kill the children of this ent, instead of disappearing them from removing parent
	ACF_KillChildProps( Entity, Entity:GetPos(), Power )

	--ERA props should not create debris
	if not Entity.ACF then return end
	local Mat = Entity.ACF.Material or 0
	if Mat == 4 then return end
      
	constraint.RemoveAll( Entity )
	Entity:Remove()
	
	if(Entity:BoundingRadius() < ACF.DebrisScale) then return nil end

	local Debris = ents.Create( "ace_debris" )
		Debris:SetModel( Entity:GetModel() )
		Debris:SetAngles( Entity:GetAngles() )
		Debris:SetPos( Entity:GetPos() )
		Debris:SetMaterial(Entity:GetMaterial())
		Debris:SetColor(Color(120,120,120,255))
		Debris:Spawn()
		Debris:Activate()
		
	local BreakEffect = EffectData()				
		BreakEffect:SetOrigin( Entity:GetPos() )
		BreakEffect:SetScale( 20 )
	util.Effect( "WheelDust", BreakEffect )	

	--Applies force to this debris	
	local phys = Debris:GetPhysicsObject() 
	local physent = Entity:GetPhysicsObject()

	if phys:IsValid() and physent:IsValid() then	
		phys:SetMass(physent:GetMass())
		phys:ApplyForceOffset( HitVector:GetNormalized() * Power * 100 ,  Debris:GetPos()+VectorRand()*20 )		
	end

	return Debris
	
end

--converts what would be multiple simultaneous cache detonations into one large explosion
function ACF_ScaledExplosion( ent )
  
	local Inflictor = nil
	local Owner = CPPI and ent:CPPIGetOwner() or NULL

	if ent.Inflictor then
		Inflictor = ent.Inflictor
	end
	
	local HEWeight
	if ent:GetClass() == "acf_fueltank" then
		HEWeight = (math.max(ent.Fuel, ent.Capacity * 0.0025) / ACF.FuelDensity[ent.FuelType]) * 0.25
	else
		local HE, Propel
		if ent.RoundType == "Refill" then
			HE = 0.00025
			Propel = 0.00025
		else 
			HE = ent.BulletData["FillerMass"] or 0
			Propel = ent.BulletData["PropMass"] or 0
		end
		HEWeight = (HE+Propel*(ACF.PBase/ACF.HEPower))*ent.Ammo
	end
	local Radius = HEWeight^0.33*8*39.37
	local ExplodePos = {}
	local Pos = ent:LocalToWorld(ent:OBBCenter())
	table.insert(ExplodePos, Pos)
	local LastHE = 0
	
	local Search = true
	local Filter = {ent}

	while Search do
	
		for key,Found in pairs( ACF_HEFind( Pos, Radius ) ) do

			local EOwner = CPPI and Found:CPPIGetOwner() or NULL
		    
			if Found.IsExplosive and not Found.Exploding and Owner == EOwner then	--So people cant bypass damage perms  --> possibly breaking when CPPI is not installed!
				local Hitat = Found:NearestPoint( Pos )
				
				local Occlusion = {}
					Occlusion.start = Pos
					Occlusion.endpos = Hitat
					Occlusion.filter = FilterTraceHull
					Occlusion.mins = Vector( 0, 0, 0 )
					Occlusion.maxs = Vector( 0, 0, 0 ) 
				local Occ = util.TraceHull( Occlusion )
				
				if ( Occ.Fraction == 0 ) then
					table.insert(Filter,Occ.Entity)
					local Occlusion = {}
						Occlusion.start = Pos
						Occlusion.endpos = Hitat
						Occlusion.filter = Filter
						Occlusion.mins = Vector( 0, 0, 0 )
						Occlusion.maxs = Vector( 0, 0, 0 ) 
					Occ = util.TraceHull( Occlusion )
					--print("Ignoring nested prop")
				end
					
				if ( Occ.Hit and Occ.Entity:EntIndex() != Found.Entity:EntIndex() ) then 
						--Msg("Target Occluded\n")
				else
					local FoundHEWeight
					if Found:GetClass() == "acf_fueltank" then
						FoundHEWeight = (math.max(Found.Fuel, Found.Capacity * 0.0025) / ACF.FuelDensity[Found.FuelType]) * 0.25
					else
						local HE, Propel
						if Found.RoundType == "Refill" then
							HE = 0.00001
							Propel = 0.00001
						else 
							HE = Found.BulletData["FillerMass"] or 0
							Propel = Found.BulletData["PropMass"] or 0
						end
						FoundHEWeight = (HE+Propel*(ACF.PBase/ACF.HEPower))*Found.Ammo
					end
					
					table.insert(ExplodePos, Found:LocalToWorld(Found:OBBCenter()))
					HEWeight = HEWeight + FoundHEWeight
					Found.IsExplosive = false
					Found.DamageAction = false
					Found.KillAction = false
					Found.Exploding = true
					table.insert(Filter,Found)
					Found:Remove()
				end			
			end
		end	
		
		if HEWeight > LastHE then
			Search = true
			LastHE = HEWeight
			Radius = (HEWeight)^0.33*8*39.37
		else
			Search = false
		end
		
	end	

	local totalpos = Vector()
	for _, cratepos in pairs(ExplodePos) do totalpos = totalpos + cratepos end
	local AvgPos = totalpos / #ExplodePos

	ent:Remove()
	
	HEWeight = HEWeight*ACF.BoomMult
	Radius = (HEWeight)^0.33*8*39.37
			
	ACF_HE( AvgPos , Vector(0,0,1) , HEWeight*0.1 , HEWeight*0.25 , Inflictor , ent, ent )
	
	local Flash = EffectData()
		Flash:SetEntity( ent )
		Flash:SetOrigin( AvgPos )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( math.max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )
end

function ACF_GetHitAngle( HitNormal , HitVector )
	
	HitVector = HitVector*-1
	local Angle = math.min(math.deg(math.acos(HitNormal:Dot( HitVector:GetNormalized() ) ) ),89.999 )
	--Msg("Angle : " ..Angle.. "\n")
	return Angle
	
end
