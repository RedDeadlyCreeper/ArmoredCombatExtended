-- This file is meant for the advanced damage functions used by the Armored Combat Framework

-- optimization; reuse tables for ballistics traces
local TraceRes = { }
local TraceInit = { output = TraceRes }

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
	
	local Targets = ents.FindInSphere( Hitpos, Radius )--Will give tiny HE just a pinch of radius to help it hit the player
	
	local Fragments = math.max(math.floor((FillerMass/FragMass)*ACF.HEFrag),2)
	local FragWeight = FragMass/Fragments
	local FragVel = (Power*50000/FragWeight/Fragments)^0.5
	local FragAera = (FragWeight/7.8)^0.33
	
	local OccFilter = { NoOcc }
	TraceInit.filter = OccFilter
	local LoopKill = true
	
	while LoopKill and Power > 0 do
		LoopKill = false
		local PowerSpent = 0
		local Iterations = 0
		local Damage = {}
		local TotalAera = 0
		for i,Tar in pairs(Targets) do
			Iterations = i
			if ( Tar != nil and Power > 0 and not Tar.Exploding ) then
				local Type = ACF_Check(Tar)
				if ( Type ) then
					local Hitat = nil
					if Type == "Squishy" then 	--A little hack so it doesn't check occlusion at the feet of players
						--Modified to attack the feet, center, or eyes, whichever is closest to the explosion

						Hitat = Tar:NearestPoint( Hitpos )					
						local cldist = Hitpos:Distance( Hitat ) or 999999999
						local Tpos
						local Tdis = 999999999
						
						local Eyes = Tar:LookupAttachment("eyes")

						if Eyes then


							local Eyeat = Tar:GetAttachment( Eyes )
							if Eyeat then
								--Msg("Hitting Eyes\n")
								Tpos = Eyeat.Pos
								Tdis = Hitpos:Distance( Tpos ) or 999999999
								if Tdis < cldist then
									Hitat = Tpos
									cldist = cldist
								end

							end


						end

						Tpos = Tar:WorldSpaceCenter()
						Tdis = Hitpos:Distance( Tpos ) or 999999999
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
							Table.Aera = math.min(AreaAdjusted/Sphere,0.5)*MaxSphere --Project the aera of the prop to the aera of the shadow it projects at the explosion max radius
						table.insert(Damage, Table)	--Add it to the Damage table so we know to damage it once we tallied everything
						-- is it adding it too late?
						TotalAera = TotalAera + Table.Aera
					end
				else
					Targets[i] = nil	--Target was invalid, so let's ignore it
					table.insert( OccFilter , Tar ) -- updates the filter in TraceInit too
				end	
			end
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
							ACF_KEShove(Tar, NewHitpos, (Tar:GetPos() - NewHitpos):GetNormalized(), PowerFraction * 0.333 * (GetConVarNumber("acf_hepush") or 1) )
						end
					end
				end)
				
				--calculate damage that would be applied (without applying it), so HE deals correct damage to other props
				BlastRes = ACF_CalcDamage( Tar, Blast, AreaAdjusted, 0 )
				--FragRes = ACF_CalcDamage( Tar , FragKE , FragAera*FragHit , 0 ) --not used for anything in this case
			else
				BlastRes = ACF_Damage ( Tar , Blast , AreaAdjusted , 0 , Inflictor ,0 , Gun, "HE" )
				FragRes = ACF_Damage ( Tar , FragKE , FragAera*FragHit , 0 , Inflictor , 0, Gun, "Frag" )
				if (BlastRes and BlastRes.Kill) or (FragRes and FragRes.Kill) then
					local Debris = ACF_HEKill( Tar , Table.Vec , PowerFraction , Hitpos )
					table.insert( OccFilter , Debris )						--Add the debris created to the ignore so we don't hit it in other rounds
					LoopKill = true --look for fresh targets since we blew a hole somewhere
				else
					ACF_KEShove(Tar, Hitpos, Table.Vec, PowerFraction * 0.1 * (GetConVarNumber("acf_hepush") or 1) ) --Assuming about 1/30th of the explosive energy goes to propelling the target prop (Power in KJ * 1000 to get J then divided by 33)
				end
			end
			PowerSpent = PowerSpent + PowerFraction*BlastRes.Loss/2--Removing the energy spent killing props
			
		end
		Power = math.max(Power - PowerSpent,0)	
	end
		
end


function ACF_Spall( HitPos , HitVec , HitMask , KE , Caliber , Armour , Inflictor , Material)
	
	if(!ACF.Spalling) then
		return
	end
	
	local SpallMul = 1 --If all else fails treat it like RHA
	local ArmorMul = 1

	if Material == 2 then 
		SpallMul = 1.2 --Cast
		ArmorMul = 1.8
	elseif Material == 3 then 
		SpallMul = 0 --Rubber does not spall
	elseif Material == 5 then
		SpallMul = ACF.AluminumSpallMult
		ArmorMul = 0.334
	elseif Material == 6 then
		SpallMul = ACF.TextoliteSpallMult
		ArmorMul = 0.23
	end
	
		--	print("CMod: "..Caliber*4) 
		--	print(Caliber) 
	local UsedArmor = Armour*ArmorMul
	if (SpallMul > 0) and (Caliber*10 > UsedArmor) and (Caliber > 3) then
		--print("SpallPass")
		local TotalWeight = 3.1416*(Caliber/2)^2 * math.max(UsedArmor,30) * 0.0004
		local Spall = math.min(math.floor((Caliber-3)*ACF.KEtoSpall*SpallMul*1.33),20)
		local SpallWeight = TotalWeight/Spall*SpallMul*400
		local SpallVel = (KE*1600000/SpallWeight)^0.5/Spall*SpallMul
		local SpallAera = (SpallWeight/7.8)^0.33 
		local SpallEnergy = ACF_Kinetic( SpallVel , SpallWeight, 8000 )

--	print("Weight: "..SpallWeight)
--	print("Vel: "..SpallVel)
--	print("Count: "..Spall)
	
	for i = 1,Spall do
		local SpallTr = { }
			SpallTr.start = HitPos
			SpallTr.endpos = HitPos + (HitVec:GetNormalized()+VectorRand()):GetNormalized()*math.max(SpallVel*100,300) --I got bored of spall not going across the tank
			SpallTr.filter = HitMask

			ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
	end
	end
	
end

function ACF_Spall_HESH( HitPos , HitVec , HitMask , HEFiller , Caliber , Armour , Inflictor , Material)

	local SpallMul = 1
	local ArmorMul = 1

	if Material == 2 then 
	SpallMul = 1.5
	ArmorMul = 1.8
	elseif Material == 3 then 
	SpallMul = 0.1
	ArmorMul = 0.01
	elseif Material == 5 then
	SpallMul = ACF.AluminumSpallMult
	ArmorMul = 0.334
	elseif Material == 6 then
	SpallMul = ACF.TextoliteSpallMult
	ArmorMul = 0.23
	end
--	print("CMod: "..Caliber*4) 

--	print(HEFiller)

local UsedArmor = Armour*ArmorMul

	if SpallMul > 0 and HEFiller/1501*4 > UsedArmor then

	local TotalWeight = 3.1416*(Caliber/2)^2 * math.max(UsedArmor,30) * 0.00079
	local Spall = math.min(math.floor((Caliber-3)/3*ACF.KEtoSpall*SpallMul),24)
	local SpallWeight = TotalWeight/Spall*SpallMul
	local SpallVel = (HEFiller*10/SpallWeight)^0.5/Spall*SpallMul
	local SpallAera = (SpallWeight/7.8)^0.33 
	local SpallEnergy = ACF_Kinetic( SpallVel*1000 , SpallWeight, 800 )

--	print("Weight: "..SpallWeight)
--	print("Vel: "..SpallVel)
--	print("Count: "..Spall)
	
	for i = 1,Spall do
		local SpallTr = { }
			SpallTr.start = HitPos
			SpallTr.endpos = HitPos + (HitVec:GetNormalized()+VectorRand()/2):GetNormalized()*math.max(SpallVel*100,300) --I got bored of spall not going across the tank
			SpallTr.filter = HitMask
			SpallTr.mins = Vector( 0, 0, 0 )
			SpallTr.maxs = Vector( 0, 0, 0 )

			ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
	end
	end
end

function ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )

	local SpallRes = util.TraceHull(SpallTr)
	
	if SpallRes.Hit and ACF_Check( SpallRes.Entity ) then
--		print("SpallHit")
--		SpallRes.Entity:SetColor( Color(255,0,0))
		local Angle = ACF_GetHitAngle( SpallRes.HitNormal , HitVec )
		local HitRes = ACF_Damage( SpallRes.Entity , SpallEnergy , SpallAera , Angle , Inflictor, 0 )  --DAMAGE !!
		if HitRes.Kill then
			ACF_APKill( SpallRes.Entity , HitVec:GetNormalized() , SpallEnergy.Kinetic )
		end	
		if HitRes.Overkill > 0 then
			table.insert( SpallTr.filter , Target )					--"Penetrate" (Ingoring the prop for the retry trace)
			SpallEnergy.Penetration = SpallEnergy.Penetration*(1-HitRes.Loss)
			SpallEnergy.Momentum = SpallEnergy.Momentum*(1-HitRes.Loss)
			ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
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

		--	if HitRes.Loss == 1 then --Why did we need to fail to pen to get a richochet anyway?

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
		--	end
	
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
	if Ricochet > 0 and Bullet.Ricochets < 3 then
		Bullet.Ricochets = Bullet.Ricochets + 1
		Bullet["Pos"] = HitPos + HitNormal * 0.75
		Bullet.FlightTime = 0
		Bullet.Flight = (ACF_RicochetVector(Bullet.Flight, HitNormal) + VectorRand()*0.025):GetNormalized() * Speed * Ricochet
		Bullet.TraceBackComp = math.max(ACF_GetPhysicalParent(Target):GetPhysicsObject():GetVelocity():Dot(Bullet["Flight"]:GetNormalized()),0)
		HitRes.Ricochet = true
	end
	
	return HitRes
end

function ACF_PenetrateGround( Bullet, Energy, HitPos, HitNormal )
	Bullet.GroundRicos = Bullet.GroundRicos or 0
	local MaxDig = ((Energy.Penetration/Bullet.PenAera)*ACF.KEtoRHA/ACF.GroundtoRHA)/25.4
	local HitRes = {Penetrated = false, Ricochet = false}
	
	local DigTr = { }
		DigTr.start = HitPos + Bullet.Flight:GetNormalized()*0.1
		DigTr.endpos = HitPos + Bullet.Flight:GetNormalized()*(MaxDig+0.1)
		DigTr.filter = Bullet.Filter
		DigTr.mask = MASK_SOLID_BRUSHONLY
		DigTr.mins = Vector( 0, 0, 0 )
		DigTr.maxs = Vector( 0, 0, 0 ) 
	local DigRes = util.TraceHull(DigTr)
	--print(util.GetSurfacePropName(DigRes.SurfaceProps))
	
	local loss = DigRes.FractionLeftSolid
	
	if loss == 1 or loss == 0 then --couldn't penetrate
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
		Bullet.Flight = Bullet.Flight * (1 - loss)
		Bullet.Pos = DigRes.StartPos + Bullet.Flight:GetNormalized() * 0.25 --this is actually where trace left brush
		HitRes.Penetrated = true
	end
	
	return HitRes
end

function ACF_KEShove(Target, Pos, Vec, KE )
	local CanDo = hook.Run("ACF_KEShove", Target, Pos, Vec, KE )
	if CanDo == false then return end

	local parent = ACF_GetPhysicalParent(Target)
	local phys = parent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		if(!Target.acflastupdatemass) or ((Target.acflastupdatemass + 10) < CurTime()) then
			ACF_CalcMassRatio(Target)
		end
		if not Target.acfphystotal then return end --corner case error check
		local physratio = Target.acfphystotal / Target.acftotal
		phys:ApplyForceOffset( Vec:GetNormalized() * KE * physratio, Pos )
	end
end


-- whitelist for things that can be turned into debris
ACF.Debris = {
	acf_ammo = true,
	acf_gun = true,
	acf_rack = true,
	acf_gearbox = true,
	acf_fueltank = true,
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

--[[
local function ACF_KillChildProps( Entity, BlastPos, Energy )  

	local count = 0
	local boom = {}
	local children = ACF_GetAllChildren(Entity)

	-- do an initial processing pass on children, separating out explodey things to handle last
	for _, ent in pairs( children ) do
		ent.ACF_Killed = true  -- mark that it's already processed
		local class = ent:GetClass()
		if not ACF.Debris[class] then
			children[ent] = nil -- ignoring stuff like holos
		else
			ent:SetParent(nil)
			if ACF.Splosive[class] then
				table.insert(boom, ent) -- keep track of explosives to make them boom last
				children[ent] = nil
			else
				count = count+1  -- can't use #table or :count() because of ent indexing...
			end
		end
	end
	
	-- HE kill the children of this ent, instead of disappearing them by removing parent
	if count > 0 then
		local DebrisChance = math.Clamp(ACF.ChildDebris/count, 0, 1)
		local power = Energy/math.min(count,3)

		for _, child in pairs( children ) do
			if IsValid(child) then
				if math.random() < DebrisChance then -- ignore some of the debris props to save lag
					ACF_HEKill( child, (child:GetPos() - BlastPos):GetNormalized(), power )
				else
					constraint.RemoveAll( child )
					child:Remove()
				end
			end
		end
	end
	
	-- explode stuff last, so we don't re-process all that junk again in a new explosion
	if #boom > 0 then
		for _, child in pairs( boom ) do
			if not IsValid(child) or child.Exploding then continue end
			child.Exploding = true
			ACF_ScaledExplosion( child ) -- explode any crates that are getting removed
		end
	end
	
end
]]--
function ACF_HEKill( Entity , HitVector , Energy , BlastPos )

	-- if it hasn't been processed yet, check for children
	--if not Entity.ACF_Killed then
		--ACF_KillChildProps( Entity, BlastPos or Entity:GetPos(), Energy )
	--end

	-- process this prop into debris
	local entClass = Entity:GetClass()
	local obj = Entity:GetPhysicsObject()
	local grav = true
	local mass = 50000 --Reduce odds of crazy physics
	if obj:IsValid() then
		mass = math.max(obj:GetMass(), mass)
		if ISSITP then
			grav = obj:IsGravityEnabled()
		end
	end
	
	constraint.RemoveAll( Entity )
	Entity:Remove()

	if(Entity:BoundingRadius() < ACF.DebrisScale) then
		return nil
	end
	
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

	local phys = Debris:GetPhysicsObject() 
	if phys:IsValid() then
	
		phys:SetMass(mass)
		
	    phys:ApplyForceOffset( HitVector:GetNormalized() * Energy * 10 , Debris:GetPos()+VectorRand()*20 ) 	-- previously energy*350
		
	    phys:EnableGravity( grav )
	   
	end

	return Debris
	
end


function ACF_APKill( Entity , HitVector , Power )

	-- kill the children of this ent, instead of disappearing them from removing parent
	--ACF_KillChildProps( Entity, Entity:GetPos(), Power )
    
	

	constraint.RemoveAll( Entity )
	Entity:Remove()
	
	if(Entity:BoundingRadius() < ACF.DebrisScale) then
		return nil
	end

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
		
	local phys = Debris:GetPhysicsObject() 
	if (phys:IsValid()) then	
		phys:ApplyForceOffset( HitVector:GetNormalized() * Power * 350 ,  Debris:GetPos()+VectorRand()*20 )	
	end

	return Debris
	
end

--converts what would be multiple simultaneous cache detonations into one large explosion
function ACF_ScaledExplosion( ent )
	local Inflictor = nil
	local Owner = ent:CPPIGetOwner()
	if( ent.Inflictor ) then
		Inflictor = ent.Inflictor
	end
	
	local HEWeight
	if ent:GetClass() == "acf_fueltank" then
		HEWeight = (math.max(ent.Fuel, ent.Capacity * 0.0025) / ACF.FuelDensity[ent.FuelType]) * 1
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
		for key,Found in pairs(ents.FindInSphere(Pos, Radius)) do
			if Found.IsExplosive and not Found.Exploding and not (Owner != Found:CPPIGetOwner()) then	--So people cant bypass damage perms
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
						FoundHEWeight = (math.max(Found.Fuel, Found.Capacity * 0.0025) / ACF.FuelDensity[Found.FuelType]) * 10
					else
						local HE, Propel
						if Found.RoundType == "Refill" then
							HE = 0.001
							Propel = 0.001
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
	
	
	HEWeight=HEWeight*ACF.BoomMult
	Radius = (HEWeight)^0.33*8*39.37
			
	ACF_HE( AvgPos , Vector(0,0,1) , HEWeight , HEWeight*0.5 , Inflictor , ent, ent )
	
	local Flash = EffectData()
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
