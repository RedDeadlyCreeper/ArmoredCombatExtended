--visual concept: Here's where should be every acf function 


-- returns last parent in chain, which has physics
function ACF_GetPhysicalParent( obj )
	if not IsValid(obj) then return nil end
	
	--check for fresh cached parent
	if obj.acfphysparent and ACF.CurTime < obj.acfphysstale then
		return obj.acfphysparent
	end
	
	local Parent = obj
	
	while Parent:GetParent():IsValid() do
		Parent = Parent:GetParent()
	end
	
	--update cached parent
	obj.acfphysparent = Parent
	obj.acfphysstale = ACF.CurTime + 10 --when cached parent is considered stale and needs updating
	
	return Parent
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
	Entity.ACF.Material = Entity.ACF.Material or 0

	--local Area = (Entity.ACF.Aera+Entity.ACF.Aera*math.Clamp(Entity.ACF.Ductility,-0.8,0.8))
	local Area = Entity.ACF.Aera
	local Ductility = math.Clamp( Entity.ACF.Ductility, -0.8, 0.8 )
	
	local MaterialID = Entity.ACF.Material or 0  --The 5 causes it to default to RHA if it doesnt have a material
	
	local massMod = ACE.ArmorTypes[ MaterialID ].massMod
	
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


	local MaterialID = Entity.ACF.Material or 0    --very important thing


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

	local curve         = ACE.ArmorTypes[ MaterialID ].curve
    local effectiveness = ACE.ArmorTypes[ MaterialID ].effectiveness
    local resiliance    = ACE.ArmorTypes[ MaterialID ].resiliance
    
	--print('resiliance: '..resiliance)

--im really disagreed with this format.
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------RHA-------
	--------------------------------------------------------------------------------------------------------------------------------		
	if MaterialID == 0 or MaterialID == nil then --RHA	
		    --print('RHA')		
		armor = armor^curve
		losArmor = losArmor^curve
		
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration

		local HitRes = {}

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / effectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/ losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

        -- Breach chance roll
		if breachProb > math.random() and maxPenetration > armor then				
			--print('BREACH!')
			HitRes.Damage   = FrAera / resiliance * damageMult			-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
						
		-- Penetration chance roll	
		elseif penProb > math.random() then									
			--print('PENETRATED!')	
			local Penetration = math.min( maxPenetration, losArmor * effectiveness)

			HitRes.Damage   = ( ( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult )
			HitRes.Overkill = ( maxPenetration - Penetration )
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
						
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor * effectiveness )
        --print('BULLET STOPPED!')	
		HitRes.Damage 	= (( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult )/ resiliance
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
			
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------CAST-------
	--------------------------------------------------------------------------------------------------------------------------------		
	elseif MaterialID == 1 then --Cast	
		    --print('Cast')		   	
		armor = armor^curve
		losArmor = losArmor^curve
		
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}

		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / effectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	
        
		-- Breach chance roll
		if breachProb > math.random() and maxPenetration > armor then				
		    --print('BREACH!')
			
			HitRes.Damage   = FrAera / resiliance * damageMult			-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		
        -- Penetration chance roll		
		elseif penProb > math.random() then									
		    --print('PENETRATED!')
			
			local Penetration = math.min( maxPenetration, losArmor * effectiveness )

			HitRes.Damage   = (( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult ) / resiliance
			HitRes.Overkill = ( maxPenetration - Penetration )
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
				
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor * effectiveness )
        --print('BULLET STOPPED!')
		
		HitRes.Damage 	= (( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult ) / resiliance
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
		
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------CERAMIC-------
	--------------------------------------------------------------------------------------------------------------------------------
	elseif MaterialID == 2 then --Ceramic	
		    --print('Ceramic')			
		armor = armor^curve
		losArmor = losArmor^curve
			
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
	    
		local slopeDmg = ( losArmor / armor ) --Angled ceramic takes more damage. Fully angled ceramic takes up to 7x the damage
		
		if Type == 'HE' or Type == 'HESH' then
		
		    slopeDmg = slopeDmg * 5
			
		end
			
        local dmul = slopeDmg 	
        
		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
		
		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / effectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	
        
		-- Breach chance roll
		if breachProb > math.random() and maxPenetration > armor then				
		
			HitRes.Damage   = FrAera / resiliance * damageMult * dmul	-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						                        -- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						                        -- Energy loss in percents

			return HitRes
		
        -- Penetration chance roll		
		elseif penProb > math.random() then									
		
			local Penetration = math.min( maxPenetration, losArmor * effectiveness )

		    HitRes.Damage   = ( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult * dmul	
			HitRes.Overkill = ( maxPenetration - Penetration )
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
			
		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor * effectiveness )

		HitRes.Damage 	= ( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult * dmul 
		HitRes.Overkill = 0
		HitRes.Loss 	= 1
	
		return HitRes
	
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------RUBBER-------
	--------------------------------------------------------------------------------------------------------------------------------	
	elseif MaterialID == 3 then --Rubber	
		    --print('Rubber')		
		armor = armor^curve
		losArmor = losArmor^curve
			
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		
		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
		
    --=========================================================================================================\
    --------------------------------------------------------- For HEAT shells & Spall -------------------------->
    --=========================================================================================================/
		if(Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS" or Type == "Spall") then
		
		    local specialeffect = ACE.ArmorTypes[ MaterialID ].specialeffect
			local specialeffectiveness = ACE.ArmorTypes[ MaterialID ].specialeffectiveness
			local specialresiliance = ACE.ArmorTypes[ MaterialID ].specialresiliance
			
		    local DmgResist = 0.01+math.min(caliber*10/specialeffect,5)*6
		
		    -- Breach probability
		    local breachProb = math.Clamp((caliber / Entity.ACF.Armour / specialeffectiveness - 1.3) / (7 - 1.3), 0, 1)

		    -- Penetration probability
		    local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * ( maxPenetration / losArmor / specialeffectiveness - 1 ))), 0.0015, 0.9985) - 0.0015) / 0.997;	
			
            -- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then		                    
					
				HitRes.Damage   = FrAera / specialresiliance * damageMult			-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						                    -- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						                    -- Energy loss in percents

				return HitRes
			
            -- Penetration chance roll			
			elseif penProb > math.random() then									
					
				local Penetration = math.min( maxPenetration, losArmor * specialeffectiveness )

				HitRes.Damage   = ( Penetration / losArmorHealth / specialeffectiveness )^2 * FrAera / specialresiliance * DmgResist * damageMult
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
							
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * specialeffectiveness )
			
			HitRes.Damage 	= ( Penetration / losArmor / specialeffectiveness )^2 * FrAera / specialresiliance * DmgResist * damageMult	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
			
	--===============================================================================================\	
    --------------------------------------------------------- For HE shells -------------------------->	
    --===============================================================================================/
		elseif Type == "HE" then

            local specialeffectiveness = ACE.ArmorTypes[ MaterialID ].specialeffectiveness
		    local HEresiliance = ACE.ArmorTypes[ MaterialID ].HEresiliance
			
		    -- Breach probability
		    local breachProb = math.Clamp((caliber / Entity.ACF.Armour / HEresiliance - 1.3) / (7 - 1.3), 0, 1)

		    -- Penetration probability
		    local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / specialeffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	
                
				-- Breach chance roll
			    if breachProb > math.random() and maxPenetration > armor then				
					
				    HitRes.Damage   = FrAera / HEresiliance  * damageMult	 -- Inflicted Damage
				    HitRes.Overkill = maxPenetration - armor						     -- Remaining penetration
				    HitRes.Loss     = armor / maxPenetration						     -- Energy loss in percents

				    return HitRes
				
                -- Penetration chance roll				
			    elseif penProb > math.random() then									
							
				    local Penetration = math.min( maxPenetration, losArmor * specialeffectiveness )

				    HitRes.Damage   = ( Penetration / losArmorHealth / specialeffectiveness )^2 * FrAera / HEresiliance * damageMult	
				    HitRes.Overkill = (maxPenetration - Penetration)
				    HitRes.Loss     = Penetration / maxPenetration
		
				    return HitRes
										
			    end

			    -- Projectile did not breach nor penetrate armor
			    local Penetration = math.min( maxPenetration , losArmor * specialeffectiveness )

			    HitRes.Damage 	= ( Penetration / losArmorHealth / specialeffectiveness )^2 * FrAera / HEresiliance * damageMult	
			    HitRes.Overkill = 0
			    HitRes.Loss 	= 1
	
			    return HitRes
	
	--===============================================================================================\
    --------------------------------------------------------- For AP shells -------------------------->
	--===============================================================================================/
		else
	    
			local Catchresiliance = ACE.ArmorTypes[ MaterialID ].Catchresiliance
		
			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour / effectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

            -- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then							
			
				HitRes.Damage   = FrAera / resiliance * damageMult			                -- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents
			
				return HitRes
			
            -- Penetration chance roll			
			elseif penProb > math.random() then									
			
				local Penetration = math.min( maxPenetration, losArmor * effectiveness )
				HitRes.Damage   = ( Penetration / losArmorHealth * effectiveness )^2 * FrAera / resiliance * damageMult	
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
	
				return HitRes
						
			end
		
			-- Projectile did not breach nor penetrate armor
			    local Penetration = math.min( maxPenetration , losArmor * effectiveness )
			    HitRes.Damage 	= ( Penetration / losArmorHealth * effectiveness )^2 * FrAera / Catchresiliance * damageMult	
			    HitRes.Overkill = 0
			    HitRes.Loss 	= 1
			
			    return HitRes		
		
		end
			
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------ERA-------
	--------------------------------------------------------------------------------------------------------------------------------		
	elseif MaterialID == 4 then --ERA	
		    --print('ERA')		
	
		local blastArmor = effectiveness * armor * (Entity.ACF.Health/Entity.ACF.MaxHealth)
			
		if Type == "HEAT" or Type == "THEAT" or Type == "HEATFS" or Type == "THEATFS" then
		
		    blastArmor = ACE.ArmorTypes[ MaterialID ].HEATeffectiveness * armor
		end
		
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		
		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
		
		if maxPenetration > losArmor then --ERA was penetrated
		    
			--print('Detonating. . .')
			
			Entity:EmitSound("ambient/explosions/explode_4.wav", math.Clamp(armor*7,350,510), math.Clamp(255-armor*1.8,50,140))
			HitRes.Damage   = 9999999										-- I have yet to meet one who can survive this Edit: NVM
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
			
			Entity:Remove()
			
			return HitRes
				
		else	
			
			local Penetration = math.min( maxPenetration , losArmor)
			-- Projectile did not breach nor penetrate armor
--			local Penetration = math.min( maxPenetration , losArmor )

			HitRes.Damage 	= ( Penetration / losArmorHealth)^2 * FrAera / resiliance * damageMult	
--			HitRes.Damage 	= 1
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
					
		end
			
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------ALUMINUM-------
	--------------------------------------------------------------------------------------------------------------------------------		
	elseif MaterialID == 5 then --Aluminum	
		    --print('Aluminum')		
		armor = armor^curve
		losArmor = losArmor^curve

		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local DamageModifier = 1
			
		if Type == "Spall" then
		
		    DamageModifier = ACE.ArmorTypes[ MaterialID ].spallresist
					
		elseif Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS" then
		
		    DamageModifier = ACE.ArmorTypes[ MaterialID ].HEATMul
		
		end
					
		local HitRes = {}
		
		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)

		-- Breach probability
		local breachProb = math.Clamp((caliber / Entity.ACF.Armour / effectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * ( maxPenetration / losArmor/ effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

		if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
		
			HitRes.Damage   = FrAera / resiliance * DamageModifier * damageMult							-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

			return HitRes
		
        -- Penetration chance roll		
		elseif penProb > math.random() then				
		
			local Penetration = math.min( maxPenetration, losArmor * effectiveness )

			HitRes.Damage   = (( Penetration / losArmorHealth / effectiveness )^2 * FrAera * DamageModifier * damageMult )/ resiliance	
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss     = Penetration / maxPenetration
		
			return HitRes
			
		end
		
			local Penetration = math.min( maxPenetration , losArmor * effectiveness)
			-- Projectile did not breach nor penetrate armor

			HitRes.Damage 	= (( Penetration / losArmorHealth / effectiveness )^2 * FrAera * DamageModifier * damageMult )/ resiliance
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
					
	--------------------------------------------------------------------------------------------------------------------------------	
		                                                  ------TEXTOLITE-------
	--------------------------------------------------------------------------------------------------------------------------------
	elseif MaterialID == 6 then --Textolite	
		    --print('Textolite')		
		armor = armor^curve
		losArmor = losArmor^curve
	
		local maxPenetration = (Energy.Penetration / FrAera) * ACF.KEtoRHA	--RHA Penetration
	
		local HitRes = {}
		
		-- Projectile caliber. Messy, function signature
		local caliber = 20 * ( FrAera^(1 / ACF.PenAreaMod) / 3.1416 )^(0.5)
				
		if(Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS") then
			
			local HEATeffectiveness = ACE.ArmorTypes[ MaterialID ].HEATeffectiveness
			local HEATresiliance = ACE.ArmorTypes[ MaterialID ].HEATresiliance
			
			
		    -- Breach probability
		    local breachProb = math.Clamp((caliber / Entity.ACF.Armour / HEATeffectiveness - 1.3) / (7 - 1.3), 0, 1)
		
		    -- Penetration probability
		    local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / HEATeffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	
		
			if breachProb > math.random() and maxPenetration > armor * HEATeffectiveness then				-- Breach chance roll
			
				HitRes.Damage   = FrAera / HEATresiliance							-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor * HEATeffectiveness						-- Remaining penetration
				HitRes.Loss     = armor * HEATeffectiveness / maxPenetration						-- Energy loss in percents

				return HitRes
			
			-- Penetration chance roll
			elseif penProb > math.random() then									
			
				local Penetration = math.min( maxPenetration, losArmor * HEATeffectiveness )

				HitRes.Damage   = ( Penetration / losArmorHealth / HEATeffectiveness )^2 * FrAera / HEATresiliance
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
				
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * HEATeffectiveness )

			HitRes.Damage 	= ( Penetration / losArmor / HEATeffectiveness )^2 * FrAera / HEATresiliance
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
			
		elseif Type == "HE" or Type == "Spall" or Type == "HESH" then
		
			local HEeffectiveness = ACE.ArmorTypes[ MaterialID ].HEeffectiveness
			local HEresiliance = ACE.ArmorTypes[ MaterialID ].HEresiliance
		
		    -- Breach probability
		    local breachProb = math.Clamp((caliber / Entity.ACF.Armour / HEeffectiveness - 1.3) / (7 - 1.3), 0, 1)

		    -- Penetration probability
		    local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / HEeffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

            -- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then				
			
				HitRes.Damage   = FrAera / HEresiliance							-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents

				return HitRes
				
			-- Penetration chance roll	
			elseif penProb > math.random() then									
			
				local Penetration = math.min( maxPenetration, losArmor * HEeffectiveness )

				HitRes.Damage   = ( Penetration / losArmorHealth / HEeffectiveness )^2 * FrAera / HEresiliance
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
		
				return HitRes
				
			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * HEeffectiveness )

			HitRes.Damage 	= ( Penetration / losArmorHealth / HEeffectiveness )^2 * FrAera / HEresiliance	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
	
			return HitRes
			
		else
		
			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour* effectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;	

			if breachProb > math.random() and maxPenetration > armor then				-- Breach chance roll
			
--			print("RubberBreach")
				HitRes.Damage   = FrAera / resiliance								-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss     = armor / maxPenetration						-- Energy loss in percents
--				print("DmgBreach: "..HitRes.Damage)
				
				return HitRes
				
			elseif penProb > math.random() then									-- Penetration chance roll
			
--			print("RubberBreach")
				local Penetration = math.min( maxPenetration, losArmor * effectiveness )
				HitRes.Damage   = ( Penetration / losArmorHealth * effectiveness)^2 * FrAera / resiliance	
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss     = Penetration / maxPenetration
--			print("DmgPen: "..HitRes.Damage)		

				return HitRes
				
			end
			
--			print("NoBreach")
			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * effectiveness )
			HitRes.Damage 	= ( Penetration / losArmorHealth * effectiveness )^2 * FrAera / resiliance	
			HitRes.Overkill = 0
			HitRes.Loss 	= 1
--			print("DmgNoPen: "..HitRes.Damage)	
			return HitRes		
		
		end		
			
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

-- returns any wheels linked to this or child gearboxes
function ACF_GetLinkedWheels( MobilityEnt )
	if not IsValid( MobilityEnt ) then return {} end

	local ToCheck = {}
	local Wheels = {}

	local links = MobilityEnt.GearLink or MobilityEnt.WheelLink -- handling for usage on engine or gearbox
	for k,link in pairs( links ) do table.insert(ToCheck, link.Ent) end

	-- use a stack to traverse the link tree looking for wheels at the end
	while #ToCheck > 0 do
		local Ent = table.remove(ToCheck,#ToCheck)
		if IsValid(Ent) then
			if Ent:GetClass() == "acf_gearbox" then
				for k,v in pairs( Ent.WheelLink ) do
					table.insert(ToCheck, v.Ent)
				end
			else
				Wheels[Ent] = Ent -- indexing it same as ACF_GetAllPhysicalConstraints, for easy merge.  whoever indexed by entity in that function, uuuuuuggghhhhh
			end
		end
	end

	return Wheels
end