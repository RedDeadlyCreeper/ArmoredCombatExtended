
local Material          = {}

Material.id             = "ERA"
Material.name           = "Explosive Reactive Armor"
Material.sname          = "ERA"
Material.desc           = "An explosive layered between 2 plates, when a shell penetrates it, the plate triggers its detonation, damaging or even destroying the incoming shell and saving the target, however, this material is as 2 times heavier than RHA and unlike other materials, this IS an explosive, so it will damage nearby props to the detonation. Explosive rounds can make life short for this material."
Material.year           = 1955

Material.massMod        = 2
Material.curve          = 0.95

Material.effectiveness      = 5
Material.HEATeffectiveness  = 20

Material.resiliance         = 1
Material.HEATresiliance     = 1

-- Used when ERA fails to detonate. This will act like a RHA at its 25% from ERA thickness. Used by HE
Material.NCurve             = 1     
Material.Neffectiveness     = 0.25 
Material.Nresiliance        = 1

Material.APSensorFactor     = 4     -- quotient used to determinate minimal pen for detonation for Kinetic shells
Material.HEATSensorFactor   = 16    -- quotient used to determinate minimal pen for detonation for chemical shells

Material.spallarmor     = 1
Material.spallresist    = 1

Material.spallmult      = 0
Material.ArmorMul       = 1
Material.NormMult       = 1

if SERVER then

    ACE.ERABoomPerTick = 0 --Used to count how many bricks are being detonated per tick

    Material.IsExplosive    = true -- Tell to core that this material is explosive and their own explosions should be reduced vs other explosive mats in order to avoid chain reactions.

    -- Ammo Types to be considered HEAT. Hardcoded
    Material.HEATList = {

        HEAT    = true,
        THEAT   = true,
        HEATFS  = true,
        THEATFS = true
    }

    -- Ammo Types to be considered HE. Hardcoded
    Material.HEList = {

        HE      = true,
        HESH    = true,
        Frag    = true
    }

    -- NOTE: When an explosive shell hits the bricks, can cause lag spikes since each brick is detonating by its own way and not as ammo crates / fuel tanks do.
    -- Possible Fix: Iterates through each affected brick to check if they should detonate or not (jugding by its hp), if so, then a scaled explosion function is called only for those bricks.
    -- Possible Complications: When an explosion occurs in an ERA corner and average explosion pos is inside of contraption.
    function Material.ArmorResolution( Entity, armor, losArmor, losArmorHealth, maxPenetration, FrAera, caliber, damageMult, Type)

        local HitRes = {}

        local curve         = Material.curve

        local effectiveness = Material.effectiveness
        local resiliance    = Material.resiliance
        local sensor        = Material.APSensorFactor
        
        local blastArmor = effectiveness * armor * (Entity.ACF.Health/Entity.ACF.MaxHealth)

        --ERA is more effective vs HEAT than vs kinetic 
        if Material.HEATList[Type] then    

            blastArmor  = Material.HEATeffectiveness * armor
            resiliance  = Material.HEATresiliance
            sensor      = Material.HEATSensorFactor

        elseif Material.HEList[Type] then

            blastArmor  = Material.Neffectiveness * armor
            resiliance  = Material.Nresiliance
            sensor      = 1

        end
        
        --ERA detonates and shell is completely stopped
        if not Material.HEList[Type] and maxPenetration > (blastArmor/sensor) or (Entity.ACF.Health/Entity.ACF.MaxHealth) < 0.15 then --ERA was penetrated       

            --Importart to remove the ent before the explosions begin
            Entity:Remove()

            HitRes.Damage   = 9999999999999 
            HitRes.Overkill = math.Clamp(maxPenetration - blastArmor,0,1)                       -- Remaining penetration.
            HitRes.Loss     = math.Clamp(blastArmor / maxPenetration,0,0.98)                    -- leaves 2% max penetration to pass

            ACE.ERABoomPerTick = ACE.ERABoomPerTick + 1

            if not timer.Exists("ACE_ERA_Reset") then
                timer.Create("ACE_ERA_Reset", 0.01, 1, function()
                    ACE.ERABoomPerTick = 0                          -- print("Max ERA boom per tick: "..ACE.ERABoomPerTick)
                end )
            end

            --I will only allow 3 bricks to really detonate around of 1 tick. The rest can kill themselves
            if ACE.ERABoomPerTick > 3 then return HitRes end

            --print("----------------------------------------Boom")

            local HEWeight  = armor*0.25  
            local Radius    = ACE_CalculateHERadius( HEWeight )
            local Owner     = (CPPI and Entity:CPPIGetOwner()) or NULL
            local EntPos    = Entity:GetPos()

            ACF_HE( EntPos , vector_up , HEWeight , HEWeight , Owner , Entity, Entity ) --ERABOOM
            
            --util.Effect not working during MP workaround. Waiting a while fixes the issue.
            timer.Simple(0.001, function()
                local Flash = EffectData()
                    Flash:SetOrigin( EntPos )
                    Flash:SetNormal( -vector_up )
                    Flash:SetRadius( math.max( Radius*0.25, 1 ) )
                util.Effect( "ACF_Scaled_Explosion", Flash ) 
            end)

            return HitRes
        else    
            
            curve         = Material.NCurve
            effectiveness = Material.Neffectiveness
            resiliance    = Material.Nresiliance

            ----- Deal it as RHA in its 25% effectiveness

            armor       = armor^curve
            losArmor    = losArmor^curve
        
            -- Breach probability
            local breachProb = math.Clamp((caliber / armor / effectiveness - 1.3) / (7 - 1.3), 0, 1)

            -- Penetration probability
            local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/ losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;   

            -- Breach chance roll
            if breachProb > math.random() and maxPenetration > armor then

                HitRes.Damage   = FrAera / resiliance * damageMult          -- Inflicted Damage
                HitRes.Overkill = maxPenetration - armor                    -- Remaining penetration
                HitRes.Loss     = armor / maxPenetration                    -- Energy loss in percents

                return HitRes
                            
            -- Penetration chance roll  
            elseif penProb > math.random() then                                 
        
                local Penetration = math.min( maxPenetration, losArmor * effectiveness)

                HitRes.Damage   = ( ( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult )
                HitRes.Overkill = ( maxPenetration - Penetration )
                HitRes.Loss     = Penetration / maxPenetration
            
                return HitRes
                            
            end

            -- Projectile did not breach nor penetrate armor
            local Penetration = math.min( maxPenetration , losArmor * effectiveness )

            HitRes.Damage   = (( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult )/ resiliance
            HitRes.Overkill = 0
            HitRes.Loss     = 1
        
            return HitRes
                         
        end
                
    end 
end

list.Set( "ACE_MaterialTypes", Material.id, Material ) 
ACE.Armors      = list.Get("ACE_MaterialTypes")