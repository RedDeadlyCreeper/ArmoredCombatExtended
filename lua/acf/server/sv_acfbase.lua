local UpdateIndex = 0

local updateContraptionsTick = 0
ACE = ACE or {}

ACE.contraptionEnts = {}
ACE.contraptionHeat = {} --I wish i could assign properties more easily to props
local cpscanproplist = {} --Proplist for all props, emptied on sort termination
local cpscanproplist2 = {} --Actually scanned proplist, emptied on sort termination
local cpscanproplist3 = {} --Used to store the already sorted props, not using contraption ents so the refresh does not overwrite the main with a partially built table
local cpscanproplist4 = {} --Used to store constrained proplists for slow iteration, empty on termination
local cpscanproplist5 = {} --Seperate loop to iterate props and not overwrite the normal prop iteration system.
local cpscanproplist6 = {} --Used to store the currently scanned hot entities in a constrained list iteration
local cpscanproplistadd = {}
local propScanCount = 0
local TestHeat = 0

local CPPScanPro = 0

ACE.radarEntities = {}
ACE.radarIDs = {}
ACE.ECMPods = {}


ACE_CPro_Mass = 0 --Contraption profiler best constrained mass
ACE_CPro_scanEnt = nil --Contraption profiler heavies constrained entity

ScanTime = 0

function updateContraptionList() --Only fails if every prop is parented to a holoentity, this is an almost nonexistent case and even then most people parent holos to the entity that made them.
--print("Test")

if updateContraptionsTick > CurTime() then return end


	if not table.IsEmpty( cpscanproplist ) then
--print("Test")		
		--[[

						if updateContraptionsTick == 1320 then
							ScanTime = CurTime()
							print("[ACE] ContraptionScan")
							--PrintMessage(HUD_PRINTTALK, "Sorting Started.")
							--local ScanArray = ents.FindByClass( "prop_vehicle_prisoner_pod" ) 
							cpscanproplist = ents.FindByClass( "prop_*" ) --Iterate through all props

							ACE.ECMPods = ents.FindByClass( "ace_ecm" )

							cpscanproplistadd = ents.FindByClass( "acf_gun" ) 
							table.Add( cpscanproplist, cpscanproplistadd )
							cpscanproplistadd = ents.FindByClass( "acf_engine" ) 
							table.Add( cpscanproplist, cpscanproplistadd )
							cpscanproplistadd = ents.FindByClass( "prop_vehicle_prisoner_pod" ) 
							table.Add( cpscanproplist, cpscanproplistadd )
							ACE.radarEntities = ents.FindByClass( "ace_trackingradar" )

								for id, ent in pairs(ACE.radarEntities) do
									ACE.radarIDs[ent] = id
								end

							table.Add( cpscanproplist, ACE.radarEntities )
							propScanCount = table.Count(cpscanproplist)

							TestHeat = 0 --Heat addition system

							for id, ent in pairs(ACE.contraptionEnts) do

								if IsValid(ent) then
									ent.SCTHeat = 0
								end

							end
						end

		]]--


		if (not table.IsEmpty( cpscanproplist4 )) or (not table.IsEmpty( cpscanproplist5 ))  then --For iterating chains of constrained entities

								--print("[ACE] Constrained iteration")

						if table.IsEmpty( cpscanproplist5 ) then

								--print( "[ACE] Found ("..table.Count( cpscanproplist4 )..") Contraptions" )	

									MaxIterations = 20 --1 props aka 33 props per second at 33 tick, plenty if you ask me.
								for id, ent in pairs(cpscanproplist4) do

									table.remove(cpscanproplist4,1) --Removes first entity

									if IsValid(ent) then
										MaxIterations = MaxIterations - 1
										
										table.insert(cpscanproplist5, ent)--Adds the entity to the props to be iterated
										
										if (ent.Heat or 0) > 0 then --Add entity to list of hot entities if it has a heat value
											table.insert(cpscanproplist6, ent)
										end										
										

										ACE_CPro_scanEnt = GetParent(ent)
										local ScanPhys = ACE_CPro_scanEnt:GetPhysicsObject()
										ACE_CPro_Mass = ScanPhys:GetMass()

											if MaxIterations == 0 then --If we run over the iteration limit pause

												break

											end

									end
								end

						end
									--print( "[ACE] iterated ("..table.Count( cpscanproplist5 )..") Contraptions" )	

						for id, ent in pairs(cpscanproplist5) do --Iteration of self hatred, F to pay respect for server, This is hellcode.

												tent = GetParent(ent)

									if IsValid(tent) then

										local TestPhys = tent:GetPhysicsObject()

										local TestMass = TestPhys:GetMass()

											if TestMass > ACE_CPro_Mass then
													ACE_CPro_Mass = TestMass
													ACE_CPro_scanEnt = tent
											end
										--print( "[ACE] iterated ("..table.Count( cpscanproplist5 )..") Contraptions" )
									end
									table.remove(cpscanproplist5,1) --Removed the entity since we already sorted it

						end

			if  table.IsEmpty( cpscanproplist4 ) then --Done iterating through constrained entities, return to normal and add entity to table
					--print("Finished")	
					

				if not (table.HasValue(cpscanproplist3,ACE_CPro_scanEnt)) then
					

					table.insert(cpscanproplist3, ACE_CPro_scanEnt)
					ACE_CPro_scanEnt.HotEnts = ACE_CPro_scanEnt.HotEnts or {}

					for id, ent in pairs(cpscanproplist6) do

						table.remove(cpscanproplist6,1) --Removes first entity

						if IsValid(ent) then

							if not (table.HasValue(ACE_CPro_scanEnt.HotEnts,ent)) then
								--print("HotEnt")
								table.insert( ACE_CPro_scanEnt.HotEnts, ent )
							end

						end

					end

					--print("Added Entity")
				end
					--print( "[ACE] iterated ("..table.Count( cpscanproplist4 )..") Contraptions" )
			end


			

		else --For iterating over regular parented or unparented props

			if table.IsEmpty( cpscanproplist2 ) then
				MaxIterations = 20 --1 props aka 33 props per second at 33 tick, plenty if you ask me.
				for id, ent in pairs(cpscanproplist) do
					MaxIterations = MaxIterations - 1
					table.remove(cpscanproplist,1) --Removes first entity
					table.insert(cpscanproplist2, ent)--Adds the entity to the props to be iterated
					if MaxIterations <= 0 then --If we run over the iteration limit pause

						break

					end
				end

			end
				
			for id, ent in pairs(cpscanproplist2) do
--				print("Test")

				if IsValid(ent) then 

						
			
					if ent:IsConstrained() then --Brace for break
						cpscanproplist4 = {ent}
						for id, ent2 in pairs(constraint.GetAllConstrainedEntities( ent)) do --Do you want to be normal? NO? Ok.
							table.insert(cpscanproplist4, ent2)
						end

						ACE_CPro_scanEnt = ent
						local ScanPhys = ent:GetPhysicsObject()
						ACE_CPro_Mass = ScanPhys:GetMass()

						--print("Constrained -----------------------")

						--[[

			
							for id2, ent2 in pairs(constraint.GetAllConstrainedEntities( scanEnt)) do --Iteration of self hatred, F to pay respect for server, This is hellcode.
								--getconnected
								local tent2 = GetParent(ent2)
			
								local TestPhys = tent2:GetPhysicsObject()
			
								local TestMass = TestPhys:GetMass()
			
								if TestMass > Mass then
									Mass = TestMass
									scanEnt = tent2
								end
			
			
			
							end
			
			
			
								if TestHeat > 0 then
									scanEnt.THeat = (scanEnt.THeat or 0) + TestHeat
									--print(scanEnt.THeat)
									--print("Hot")
								end
			
								if not (table.HasValue(cpscanproplist3,scanEnt)) then
									
			
									table.insert(cpscanproplist3, scanEnt)
									--print("Added Entity")
								end
						]]--
						table.remove(cpscanproplist2,1) --Removed the entity since we already sorted it
						break --Break the cycle
							
					else
						--print("Test")
						scanEnt = GetParent(ent)

					--	print(ent:GetClass())
								if ((ent.Heat or 0) > 0) then
									--scanEnt.SCTHeat = (ent.SCTHeat or 0) + TestHeat
									--print("HotEnt")
								
									if IsValid(ent) then
			
										scanEnt.HotEnts = scanEnt.HotEnts or {}

										if not (table.HasValue(scanEnt.HotEnts,ent)) then
											--print("HotEnt")
											table.insert( scanEnt.HotEnts, ent )
										end
			
									end

								end

								
								if not (table.HasValue(cpscanproplist3,scanEnt)) then
			
									table.insert(cpscanproplist3, scanEnt)
									--print("Added Entity")
								end
			


								table.remove(cpscanproplist2,1) --Removed the entity since we already sorted it
					end
			
			
				else
					table.remove(cpscanproplist2,1)  --Found a bug!
				end
			end
		end
		--local cpscanproplistadd = ents.FindByClass( "prop_vehicle_prisoner_pod" ) 
		--table.Add( cpscanproplist, cpscanproplistadd )


		if table.IsEmpty( cpscanproplist ) then --Jobs done
			
			table.Add( ACE.contraptionEnts, cpscanproplist3 )
			print( "[ACE] Found ("..table.Count( ACE.contraptionEnts )..") contraptions in ("..math.Round(CurTime()-ScanTime-1)..") seconds." )	
			--PrintTable(ACE.contraptionEnts)

			--[[
					for id, ent in pairs(ACE.contraptionEnts) do

						if IsValid(ent) then
							ent.THeat = ent.SCTHeat
						end

					end
			]]--

			updateContraptionsTick = 0
			cpscanproplist2 = {} --Clear out table
			cpscanproplist3 = {}
		end


	end

	for id, ent in pairs(ACE.contraptionEnts) do

		if not IsValid(ent) then
			table.remove( ACE.contraptionEnts, id )
			print("[ACE] Removed a contraption")
		end

	end

end

function ACEdupeCategorizeContraptions(ArgTable)
	
	local proplist = ArgTable[1]["CreatedEntities"]

	for id, ent in pairs(proplist) do

		if IsValid(ent) then
			table.insert(cpscanproplist, ent)
		end

	end

	--	table.Add( cpscanproplist, proplist )

	ScanTime = CurTime()

	print("[ACE] ContraptionScan")

	ACE.ECMPods = ents.FindByClass( "ace_ecm" )

	ACE.radarEntities = ents.FindByClass( "ace_trackingradar" )

	for id, ent in pairs(ACE.radarEntities) do
		ACE.radarIDs[ent] = id
	end

	updateContraptionsTick = ScanTime + 1

	TestHeat = 0
--	print(table.Count( cpscanproplist ))

end

--CPPScanPro
function ACEUpdateContraptions() --Used to update information like HEAT, Weight, legality, stuff
	local TCount = table.Count( ACE.contraptionEnts )

	if TCount > 0 then

		CPPScanPro = CPPScanPro + 1
		if CPPScanPro > TCount then
			CPPScanPro = 1
		end

		local ScanEnt = ACE.contraptionEnts[CPPScanPro]
		if ScanEnt:IsValid() then
			ScanEnt.THeat = 0

			for id, ent in pairs(ScanEnt.HotEnts or {}) do --Iterate through all hot ents for object
				if ent:IsValid() then

				ScanEnt.THeat = ScanEnt.THeat + (ent.Heat or 0) + 20 --Makes every hot object add an extra 20 degrees. Done to make heli gunships and planes easier to target.
				else
					table.remove( ScanEnt.HotEnts, id )					
				end
			end		

			if ScanEnt.THeat > 50 then
				print(ScanEnt.THeat)
			end

	--		print(table.Count(ScanEnt.HotEnts))
	--		print("FoundHeat: "..ScanEnt.THeat)

		else
			table.remove( ACE.contraptionEnts, CPPScanPro )
			print("Remove")
		end
	end
end



hook.Add("AdvDupe_FinishPasting","ACE_CategorizeContraptions_dupefinished",ACEdupeCategorizeContraptions)


hook.Add("Think", "ACE_CategorizeContraptions", updateContraptionList)
hook.Add("Think", "ACE_UpdateContraptions", ACEUpdateContraptions)


function GetParent(Ent)
	if not IsValid(Ent) then return nil end

	local Parent = Ent

	while IsValid(Parent:GetParent()) do
		Parent = Parent:GetParent()
	end

	if Parent:GetClass() == gmod_wire_hologram then --Wire Holos don't act like things normally parented to, filter them out.
		return nil	
	else
		return Parent
	end
end

function ACF_UpdateVisualHealth(Entity)
	if Entity.ACF.PrHealth == Entity.ACF.Health then return end
	if not ACF_HealthUpdateList then
		ACF_HealthUpdateList = {}
		timer.Create("ACF_HealthUpdateList", 1, 1, function() // We should send things slowly to not overload traffic.
			local Table = {}
			for k,v in pairs(ACF_HealthUpdateList) do
				if IsValid( v ) then
					table.insert(Table,{ID = v:EntIndex(), Health = v.ACF.Health, MaxHealth = v.ACF.MaxHealth})
				end
			end
			net.Start("ACF_RenderDamage")
				net.WriteTable(Table)
			net.Broadcast()
			ACF_HealthUpdateList = nil
		end)
	end
	table.insert(ACF_HealthUpdateList, Entity)
end

function ACF_Activate ( Entity , Recalc )

	--Density of steel = 7.8g cm3 so 7.8kg for a 1mx1m plate 1m thick
	if Entity.SpecialHealth then
		Entity:ACF_Activate( Recalc )
		return
	end
	Entity.ACF = Entity.ACF or {} 

	local Count
	local PhysObj = Entity:GetPhysicsObject()
	if PhysObj:GetMesh() then Count = #PhysObj:GetMesh() end
	if PhysObj:IsValid() and Count and Count>100 then

		if not Entity.ACF.Aera then
			Entity.ACF.Aera = (PhysObj:GetSurfaceArea() * 6.45) * 0.52505066107
		end
		--if not Entity.ACF.Volume then
		--	Entity.ACF.Volume = (PhysObj:GetVolume() * 16.38)
		--end
	else
		local Size = Entity.OBBMaxs(Entity) - Entity.OBBMins(Entity)
		if not Entity.ACF.Aera then
			Entity.ACF.Aera = ((Size.x * Size.y)+(Size.x * Size.z)+(Size.y * Size.z)) * 6.45
		end
		--if not Entity.ACF.Volume then
		--	Entity.ACF.Volume = Size.x * Size.y * Size.z * 16.38
		--end
	end
	
	Entity.ACF.Ductility = Entity.ACF.Ductility or 0

	--local Area = (Entity.ACF.Aera+Entity.ACF.Aera*math.Clamp(Entity.ACF.Ductility,-0.8,0.8))
	local Area = Entity.ACF.Aera
	local Ductility = math.Clamp( Entity.ACF.Ductility, -0.8, 0.8 )
	
	local testMaterial = Entity.ACF.Material or 0  --The 5 causes it to default to RHA if it doesnt have a material
	local massMod = 1
	
	if testMaterial == 0 then --RHA	
		massMod = 1
	elseif ACF.EnableNewContent and ACF.Year >= 1955 then
		if testMaterial == 1 then --Cast
			massMod = 2
		elseif testMaterial == 2 then --Ceramic
			massMod = 0.8
		elseif testMaterial == 3 then--Rubber
			massMod = 0.2
		elseif testMaterial == 4 then --ERA
			massMod = 2
		elseif testMaterial == 5 then --Aluminum
			massMod = 0.221
		elseif testMaterial == 6 then --Textolite
		massMod = 0.35
		end
	else
			Entity.ACF.Material = 0 --Sets anything without a material to RHA and gives it a 1.0 massmod
			massMod = 1
	end
	
	local Armour = ACF_CalcArmor( Area, Ductility, Entity:GetPhysicsObject():GetMass() / massMod ) -- So we get the equivalent thickness of that prop in mm if all its weight was a steel plate
	local Health = ( Area / ACF.Threshold ) * ( 1 + Ductility ) -- Setting the threshold of the prop aera gone

	local Percent = 1 
	
	if Recalc and Entity.ACF.Health and Entity.ACF.MaxHealth then
		Percent = Entity.ACF.Health/Entity.ACF.MaxHealth
	end
	
	Entity.ACF.Health = Health * Percent
	Entity.ACF.MaxHealth = Health
	Entity.ACF.Armour = Armour * (0.5 + Percent/2)
	Entity.ACF.MaxArmour = Armour * ACF.ArmorMod
	Entity.ACF.Type = nil
	Entity.ACF.Mass = PhysObj:GetMass()
	--Entity.ACF.Density = (PhysObj:GetMass()*1000)/Entity.ACF.Volume
	
	if Entity:IsPlayer() || Entity:IsNPC() then
		Entity.ACF.Type = "Squishy"
	elseif Entity:IsVehicle() then
		Entity.ACF.Type = "Vehicle"
	else
		Entity.ACF.Type = "Prop"
	end
	--print(Entity.ACF.Health)
end

function ACF_Check ( Entity )
	
	if not IsValid(Entity) then return false end

	local physobj = Entity:GetPhysicsObject()
	if not ( physobj:IsValid() and (physobj:GetMass() or 0)>0 and !Entity:IsWorld() and !Entity:IsWeapon() ) then return false end

	local Class = Entity:GetClass()
	if ( Class == "gmod_ghost" or Class == "ace_debris" or Class == "prop_ragdoll" or string.find( Class , "func_" )  ) then return false end

	if !Entity.ACF then 
		ACF_Activate( Entity )
	elseif Entity.ACF.Mass != physobj:GetMass() then
		ACF_Activate( Entity , true )
	end
	--print("ACF_Check "..Entity.ACF.Type)
	return Entity.ACF.Type	
	
end

function ACF_Damage ( Entity , Energy , FrAera , Angle , Inflictor , Bone, Gun, Type ) 

	local Activated = ACF_Check( Entity )
	local CanDo = hook.Run("ACF_BulletDamage", Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun )
	if CanDo == false or Activated == false then -- above (default) hook does nothing with activated. Excludes godded players.
	return { Damage = 0, Overkill = 0, Loss = 0, Kill = false }		
	end
	
	if Entity.SpecialDamage then
		return Entity:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone, Type )
	elseif Activated == "Prop" then	
		
		return ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone , Type)
		
	elseif Activated == "Vehicle" then
	
		return ACF_VehicleDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone, Gun , Type)
		
	elseif Activated == "Squishy" then
	
		return ACF_SquishyDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone, Gun , Type)
		
	end
	
end

function ACF_CalcDamage( Entity , Energy , FrAera , Angle , Type) --y=-5/16x+b

	local armor    = Entity.ACF.Armour								-- Armor
	local losArmor = armor / math.abs( math.cos(math.rad(Angle)) ^ ACF.SlopeEffectFactor )  -- LOS Armor	
	local losArmorHealth = armor^1.1 * (3 + math.min(1 / math.abs( math.cos(math.rad(Angle)) ^ ACF.SlopeEffectFactor ),2.8)*0.5 )  -- Bc people had to abuse armor angling, FML	
--	local losArmorHealth = losArmor

--	local ductilitymult    = math.max((-5/16)*(Entity.ACF.Ductility or 1)*100+1,1)

	local ductilitymult    = 1
	local testMaterial = Entity.ACF.Material or 0
		--TestMat=3 = rubber
		--TestMat = 4 = ERA
	
	local damageMult = 1
--	print("DamageType: "..Type)

	if Type == "AP" then
	damageMult = ACF.APDamageMult
	elseif Type == "APC" then
	damageMult = ACF.APCDamageMult
	elseif Type == "APBC" then
	damageMult = ACF.APBCDamageMult
	elseif Type == "APCBC" then
	damageMult = ACF.APCBCDamageMult
	elseif Type == "APHE" then
	damageMult = ACF.APHEDamageMult
	elseif Type == "APDS" then
	damageMult = ACF.APDSDamageMult
	elseif Type == "HVAP" then
	damageMult = ACF.HVAPDamageMult
	elseif Type == "FL" then
	damageMult = ACF.FLDamageMult
	elseif Type == "HEAT" then
	damageMult = ACF.HEATDamageMult
	elseif Type == "HE" then
	damageMult = ACF.HEDamageMult
	elseif Type == "HESH" then
	damageMult = ACF.HESHDamageMult
	elseif Type == "HP" then
	damageMult = ACF.HPDamageMult
	end
		
--	print("Damage mult from type: "..damageMult)	
		
	if testMaterial == 0 then --RHA	
		armor = armor^ACF.CurveRHA
		losArmor = losArmor^ACF.CurveRHA
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

		if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
			HitRes.Damage   = var * dmul * FrAera * ductilitymult * damageMult							-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		elseif penProb > math.random() then									-- Penetration chance roll
			local Penetration = math.min( maxPenetration, losArmor )

			HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth )^2 * FrAera * ductilitymult * damageMult
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor )

		HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth )^2 * FrAera * ductilitymult * damageMult
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
	elseif testMaterial == 1 then --Cast	
		armor = armor^ACF.CurveCast
		losArmor = losArmor^ACF.CurveCast
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.CastEffectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / ACF.CastEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

		if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
			HitRes.Damage   = var * dmul * FrAera * ductilitymult * damageMult							-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		elseif penProb > math.random() then									-- Penetration chance roll
			local Penetration = math.min( maxPenetration, losArmor * ACF.CastEffectiveness )

			HitRes.Damage   = var * dmul * ( Penetration / armor / ACF.CastEffectiveness )^2 * FrAera / ACF.CastResilianceFactor  * ductilitymult * damageMult
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor * ACF.CastEffectiveness )

		HitRes.Damage 	= var * dmul * ( Penetration / armor / ACF.CastEffectiveness )^2 * FrAera * ductilitymult * damageMult	
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
	elseif testMaterial == 2 then --Ceramic	
		armor = armor^ACF.CurveCeram
		losArmor = losArmor^ACF.CurveCeram
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end

		dmul = losArmor / armor --Angled ceramic takes more damage. Fully angled ceramic takes up to 7x the damage
		
		if Type=="HE" then
		dmul = dmul*10
		end

		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.CeramicEffectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / ACF.CeramicEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

		if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
			HitRes.Damage   = var * dmul * FrAera * ACF.CeramicPierceDamage * ductilitymult * damageMult								-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		elseif penProb > math.random() then									-- Penetration chance roll
			local Penetration = math.min( maxPenetration, losArmor * ACF.CeramicEffectiveness )

		HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth / ACF.CeramicEffectiveness * ACF.CeramicPierceDamage )^2 * FrAera / ACF.CeramicResilianceFactor * ductilitymult * damageMult	  
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor * ACF.CeramicEffectiveness )

		HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth )^2 * FrAera / ACF.CeramicResilianceFactor * ductilitymult * damageMult	  
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
	
	elseif testMaterial == 3 then --Rubber	
		armor = armor^ACF.RubbCurve
		losArmor = losArmor^ACF.RubbCurve
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
		if(Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS" or Type == "Spall") then
		local DmgResist = 0.01+math.min(caliber*10/ACF.RubberSpecialEffect,5)*6
		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.RubberEffectivenessSpecial - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / ACF.RubberEffectivenessSpecial - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
				HitRes.Damage   = var * dmul * FrAera * ductilitymult * damageMult								-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

				return HitRes
			elseif penProb > math.random() then									-- Penetration chance roll
				local Penetration = math.min( maxPenetration, losArmor * ACF.RubberEffectivenessSpecial )

				HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth / ACF.RubberEffectivenessSpecial )^2 * FrAera / ACF.RubberResilianceFactorSpecial * DmgResist * ductilitymult	 * damageMult
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * ACF.RubberEffectivenessSpecial )

			HitRes.Damage 	= var * dmul * ( Penetration / losArmor / ACF.RubberEffectivenessSpecial )^2 * FrAera / ACF.RubberResilianceFactorSpecial * DmgResist * ductilitymult * damageMult	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
		elseif Type == "HE" then
		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.RubberHEVulnerbility - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / ACF.RubberEffectivenessSpecial - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
				HitRes.Damage   = var * dmul * FrAera * damageMult							-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

				return HitRes
			elseif penProb > math.random() then									-- Penetration chance roll
				local Penetration = math.min( maxPenetration, losArmor * ACF.RubberEffectivenessSpecial )

				HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth / ACF.RubberEffectivenessSpecial )^2 * FrAera / ACF.RubberHEVulnerbility * ductilitymult * damageMult	
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * ACF.RubberEffectivenessSpecial )

			HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth / ACF.RubberEffectivenessSpecial )^2 * FrAera / ACF.RubberHEVulnerbility * ductilitymult * damageMult	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
		else
			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.RubberEffectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / ACF.RubberEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
--			print("RubberBreach")
				HitRes.Damage   = var * dmul * FrAera * ductilitymult * damageMult								-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents
--				print("DmgBreach: "..HitRes.Damage)
				
				return HitRes
			elseif penProb > math.random() then									-- Penetration chance roll
--			print("RubberBreach")
				local Penetration = math.min( maxPenetration, losArmor * ACF.RubberEffectiveness )
				HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth * ACF.RubberEffectiveness)^2 * FrAera / ACF.RubberResilianceFactor * ductilitymult * damageMult	
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
--			print("DmgPen: "..HitRes.Damage)		
				return HitRes
			end
--			print("NoBreach")
			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * ACF.RubberEffectiveness)
			HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth * ACF.RubberEffectiveness)^2 * FrAera / ACF.RubberResilianceFactorCatch * ductilitymult * damageMult	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
--			print("DmgNoPen: "..HitRes.Damage)	
			return HitRes		
		
		end
		
	elseif testMaterial == 4 then --ERA	

		local blastArmor = armor
		if Type == "HEAT" or Type == "THEAT" or Type == "HEATFS" or Type == "THEATFS" then
		blastArmor = ACF.ERAEffectivenessMultHEAT * armor
		else
		blastArmor = ACF.ERAEffectivenessMult * armor * (Entity.ACF.Health/Entity.ACF.MaxHealth)
		end
--				print(ERABoom)	
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
		
		if maxPenetration > losArmor then
--			print(BOOM)
			Entity:EmitSound("ambient/explosions/explode_4.wav", math.Clamp(armor*7,350,510), math.Clamp(255-armor*1.8,50,140))
			HitRes.Damage   = 999999999999999										-- I have yet to meet one who can survive this Edit: NVM
			HitRes.Overkill = math.Clamp(maxPenetration - blastArmor,0.02,1)						-- Remaining penetration
			HitRes.Loss     = math.Clamp(blastArmor / maxPenetration,0,0.98)		
			
			local HEWeight = armor*0.1			
			local Radius = (HEWeight*0.0001)^0.33*8*39.37

			ACF_HE( Entity:GetPos() , Vector(0,0,1) , HEWeight , HEWeight*1 , Inflictor , Entity, Entity ) --ERABOOM
			local Flash = EffectData()
				Flash:SetOrigin( Entity:GetPos() )
				Flash:SetNormal( Vector(0,0,-1) )
				Flash:SetRadius( math.max( Radius, 1 ) )
			util.Effect( "ACF_Scaled_Explosion", Flash )

			--			HitRes.Overkill = 0						-- Remaining penetration
--			HitRes.Loss     = 1						-- Energy loss in percents 

			--ACF.ERAEffectivenessMult
			
			return HitRes
		else	
			local Penetration = math.min( maxPenetration , losArmor)
			-- Projectile did not breach nor penetrate armor
--			local Penetration = math.min( maxPenetration , losArmor )

			HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth)^2 * FrAera * ductilitymult * damageMult	
--			HitRes.Damage 	= 1
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
		end
	elseif testMaterial == 5 then --Aluminum	
		armor = armor^ACF.AluminumCurve
		losArmor = losArmor^ACF.AluminumCurve

		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local DamageModifier = 1
		
		if Type == "Spall" then
		DamageModifier = ACF.AluminumSpallResist
		elseif Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS" then
		DamageModifier = ACF.AluminumHeatMul
		end
			
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.AluminiumEffectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor/ACF.AluminiumEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

		if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
			HitRes.Damage   = var * dmul * FrAera / ACF.AluminumResialiance * DamageModifier * ductilitymult * damageMult							-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		elseif penProb > math.random() then									-- Penetration chance roll
			local Penetration = math.min( maxPenetration, losArmor*ACF.AluminiumEffectiveness )

			HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth )^2 * FrAera / ACF.AluminumResialiance * DamageModifier * ductilitymult * damageMult	
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
		end
		
			local Penetration = math.min( maxPenetration , losArmor*ACF.AluminiumEffectiveness)
			-- Projectile did not breach nor penetrate armor
--			local Penetration = math.min( maxPenetration , losArmor )

			HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth/ACF.AluminiumEffectiveness )^2 * FrAera / ACF.AluminumResialiance * DamageModifier * ductilitymult * damageMult	
--			HitRes.Damage 	= 1
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes

	elseif testMaterial == 6 then --Textolite	
		armor = armor^ACF.TextoliteCurve
		losArmor = losArmor^ACF.TextoliteCurve
	
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
		if(Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS") then
		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.TextoliteHEATEffectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / ACF.TextoliteHEATEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor * ACF.TextoliteHEATEffectiveness then				-- Breach chance roll
				HitRes.Damage   = var * dmul * FrAera * ductilitymult / ACF.TextoliteHEATResilianceFactor							-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor * ACF.TextoliteHEATEffectiveness						-- Remaining penetration
				HitRes.Loss     = armor * ACF.TextoliteHEATEffectiveness / maxPenetration						-- Energy loss in percents

				return HitRes
			elseif penProb > math.random() then									-- Penetration chance roll
				local Penetration = math.min( maxPenetration, losArmor * ACF.TextoliteHEATEffectiveness )

				HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth / ACF.TextoliteHEATEffectiveness )^2 * FrAera / ACF.TextoliteHEATResilianceFactor * ductilitymult
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * ACF.TextoliteHEATEffectiveness )

			HitRes.Damage 	= var * dmul * ( Penetration / losArmor / ACF.TextoliteHEATEffectiveness )^2 * FrAera / ACF.TextoliteHEATResilianceFactor * ductilitymult
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
		elseif Type == "HE" or Type == "Spall" or Type == "HESH" then
		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / ACF.TextoliteHEEffectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / ACF.TextoliteHEEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
				HitRes.Damage   = var * dmul * FrAera							-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

				return HitRes
			elseif penProb > math.random() then									-- Penetration chance roll
				local Penetration = math.min( maxPenetration, losArmor * ACF.TextoliteHEEffectiveness )

				HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth / ACF.TextoliteHEEffectiveness )^2 * FrAera / ACF.TextoliteHEResistance * ductilitymult	
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * ACF.TextoliteHEEffectiveness )

			HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth / ACF.TextoliteHEEffectiveness )^2 * FrAera / ACF.TextoliteHEResistance * ductilitymult	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
		else
			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour*ACF.TextoliteEffectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / ACF.TextoliteEffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
--			print("RubberBreach")
				HitRes.Damage   = var * dmul * FrAera * ductilitymult								-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents
--				print("DmgBreach: "..HitRes.Damage)
				
				return HitRes
			elseif penProb > math.random() then									-- Penetration chance roll
--			print("RubberBreach")
				local Penetration = math.min( maxPenetration, losArmor * ACF.TextoliteEffectiveness )
				HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth * ACF.TextoliteEffectiveness)^2 * FrAera / ACF.TextoliteResilianceFactor * ductilitymult	
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
--			print("DmgPen: "..HitRes.Damage)		
				return HitRes
			end
--			print("NoBreach")
			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * ACF.TextoliteEffectiveness)
			HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth * ACF.TextoliteEffectiveness)^2 * FrAera / ACF.TextoliteResilianceFactor * ductilitymult	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
--			print("DmgNoPen: "..HitRes.Damage)	
			return HitRes		
		
		end		
			
	else --If for some reason it doesnt identify what material it is
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		--BNK Stuff
		local dmul = 1
		if (ISBNK) then
			local cvar = GetConVarNumber("sbox_godmode")
	
			if (cvar == 1) then
				dmul = 0
			end
		end
		--SITP Stuff
		--TODO: comment out ISSITP when not necessary
		local var = 1
		if (ISSITP) then
			if(!Entity.sitp_spacetype) then
				Entity.sitp_spacetype = "space"
			end
			if(Entity.sitp_spacetype != "space" and Entity.sitp_spacetype != "planet") then
				var = 0
			end
		end

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

		if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
			HitRes.Damage   = var * dmul * FrAera * ductilitymult * damageMult								-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		elseif penProb > math.random() then									-- Penetration chance roll
			local Penetration = math.min( maxPenetration, losArmor )

			HitRes.Damage   = var * dmul * ( Penetration / losArmorHealth )^2 * FrAera * ductilitymult * damageMult	
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor )

		HitRes.Damage 	= var * dmul * ( Penetration / losArmorHealth )^2 * FrAera * ductilitymult * damageMult	
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
	end
end

function ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone , Type)

	local HitRes = ACF_CalcDamage( Entity , Energy , FrAera , Angle  , Type)
	
	HitRes.Kill = false
	if HitRes.Damage >= Entity.ACF.Health then
		HitRes.Kill = true 
	else
		Entity.ACF.Health = Entity.ACF.Health - HitRes.Damage
		Entity.ACF.Armour = Entity.ACF.MaxArmour * (0.5 + Entity.ACF.Health/Entity.ACF.MaxHealth/2) --Simulating the plate weakening after a hit
		
		if Entity.ACF.PrHealth then
			ACF_UpdateVisualHealth(Entity)
		end
		Entity.ACF.PrHealth = Entity.ACF.Health
	end
	
	return HitRes
	
end

function ACF_VehicleDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone, Gun  , Type)

	local HitRes = ACF_CalcDamage( Entity , Energy , FrAera , Angle  , Type)
	local Driver = Entity:GetDriver()
	local validd = Driver:IsValid()
	if validd then
		--if Ammo == true then
		--	Driver.KilledByAmmo = true
		--end
		Driver:TakeDamage( HitRes.Damage*40 , Inflictor, Gun )
		--if Ammo == true then
		--	Driver.KilledByAmmo = false
		--end
		
	end

	HitRes.Kill = false
	if HitRes.Damage >= Entity.ACF.Health then --Drivers will no longer survive seat destruction
			if validd then
				Driver:Kill()
			end
		HitRes.Kill = true 
	else
		Entity.ACF.Health = Entity.ACF.Health - HitRes.Damage
		Entity.ACF.Armour = Entity.ACF.Armour * (0.5 + Entity.ACF.Health/Entity.ACF.MaxHealth/2) --Simulating the plate weakening after a hit
	end
		
	return HitRes
end

function ACF_SquishyDamage( Entity , Energy , FrAera , Angle , Inflictor , Bone, Gun , Type)
	
	local Size = Entity:BoundingRadius()
	local Mass = Entity:GetPhysicsObject():GetMass()
	local HitRes = {}
	local Damage = 0
	local Target = {ACF = {Armour = 0.1}}		--We create a dummy table to pass armour values to the calc function
	if (Bone) then
		
		if ( Bone == 1 ) then		--This means we hit the head
			Target.ACF.Armour = Mass*0.02	--Set the skull thickness as a percentage of Squishy weight, this gives us 2mm for a player, about 22mm for an Antlion Guard. Seems about right
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , Angle , Type)		--This is hard bone, so still sensitive to impact angle
			Damage = HitRes.Damage*20
			if HitRes.Overkill > 0 then									--If we manage to penetrate the skull, then MASSIVE DAMAGE
				Target.ACF.Armour = Size*0.25*0.01						--A quarter the bounding radius seems about right for most critters head size
				HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 , Type)
				Damage = Damage + HitRes.Damage*100
			end
			Target.ACF.Armour = Mass*0.065	--Then to check if we can get out of the other side, 2x skull + 1x brains
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , Angle , Type)	
			Damage = Damage + HitRes.Damage*20				
			
		elseif ( Bone == 0 or Bone == 2 or Bone == 3 ) then		--This means we hit the torso. We are assuming body armour/tough exoskeleton/zombie don't give fuck here, so it's tough
			Target.ACF.Armour = Mass*0.04	--Set the armour thickness as a percentage of Squishy weight, this gives us 8mm for a player, about 90mm for an Antlion Guard. Seems about right
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , Angle , Type)		--Armour plate,, so sensitive to impact angle
			Damage = HitRes.Damage*5
			if HitRes.Overkill > 0 then
				Target.ACF.Armour = Size*0.5*0.02							--Half the bounding radius seems about right for most critters torso size
				HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 , Type)		
				Damage = Damage + HitRes.Damage*25							--If we penetrate the armour then we get into the important bits inside, so DAMAGE
			end
			Target.ACF.Armour = Mass*0.185	--Then to check if we can get out of the other side, 2x armour + 1x guts
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , Angle , Type)
			Damage = Damage + HitRes.Damage*5		
			
		elseif ( Bone == 4 or Bone == 5 ) then 		--This means we hit an arm or appendage, so ormal damage, no armour
		
			Target.ACF.Armour = Size*0.2*0.02							--A fitht the bounding radius seems about right for most critters appendages
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 , Type)		--This is flesh, angle doesn't matter
			Damage = HitRes.Damage*10							--Limbs are somewhat less important
		
		elseif ( Bone == 6 or Bone == 7 ) then
		
			Target.ACF.Armour = Size*0.2*0.02							--A fitht the bounding radius seems about right for most critters appendages
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 , Type)		--This is flesh, angle doesn't matter
			Damage = HitRes.Damage*10							--Limbs are somewhat less important
			
		elseif ( Bone == 10 ) then					--This means we hit a backpack or something
		
			Target.ACF.Armour = Size*0.1*0.02							--Arbitrary size, most of the gear carried is pretty small
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 , Type)		--This is random junk, angle doesn't matter
			Damage = HitRes.Damage*1								--Damage is going to be fright and shrapnel, nothing much		

		else 										--Just in case we hit something not standard
		
			Target.ACF.Armour = Size*0.2*0.02						
			HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 )
			Damage = HitRes.Damage*10	
			
		end
		
	else 										--Just in case we hit something not standard
	
		Target.ACF.Armour = Size*0.2*0.02						
		HitRes = ACF_CalcDamage( Target , Energy , FrAera , 0 , Type)
		Damage = HitRes.Damage*10	
	
	end
	
	local dmul = 2.5
	
	--BNK stuff
	if (ISBNK) then
		if(Entity.freq and Inflictor.freq) then
			if (Entity != Inflictor) and (Entity.freq == Inflictor.freq) then
				dmul = 0
			end
		end
	end
	
	--SITP stuff
	local var = 1
	if(!Entity.sitp_spacetype) then
		Entity.sitp_spacetype = "space"
	end
	if(Entity.sitp_spacetype == "homeworld") then
		var = 0
	end
	
	--if Ammo == true then
	--	Entity.KilledByAmmo = true
	--end
	Entity:TakeDamage( Damage * dmul * var, Inflictor, Gun )
	--if Ammo == true then
	--	Entity.KilledByAmmo = false
	--end
	
	HitRes.Kill = false
	--print(Damage)
	--print(Bone)
		
	return HitRes
end

----------------------------------------------------------
-- Returns a table of all physically connected entities
-- ignoring ents attached by only nocollides
----------------------------------------------------------
function ACF_GetAllPhysicalConstraints( ent, ResultTable )

	local ResultTable = ResultTable or {}
	
	if not IsValid( ent ) then return end
	if ResultTable[ ent ] then return end
	
	ResultTable[ ent ] = ent
	
	local ConTable = constraint.GetTable( ent )
	
	for k, con in ipairs( ConTable ) do
		
		-- skip shit that is attached by a nocollide
		if not (con.Type == "NoCollide") then
			for EntNum, Ent in pairs( con.Entity ) do
				ACF_GetAllPhysicalConstraints( Ent.Entity, ResultTable )
			end
		end
	
	end

	return ResultTable
	
end

-- for those extra sneaky bastards
function ACF_GetAllChildren( ent, ResultTable )
	
	--if not ent.GetChildren then return end  --shouldn't need to check anymore, built into glua now
	
	local ResultTable = ResultTable or {}
	
	if not IsValid( ent ) then return end
	if ResultTable[ ent ] then return end
	
	ResultTable[ ent ] = ent
	
	local ChildTable = ent:GetChildren()
	
	for k, v in pairs( ChildTable ) do
		
		ACF_GetAllChildren( v, ResultTable )
		
	end
	
	return ResultTable
	
end
