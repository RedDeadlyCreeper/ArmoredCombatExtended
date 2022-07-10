
local Material          = {}

Material.id             = "CHA"
Material.name           = "Cast homogeneous Armor"
Material.sname          = "CHA"
Material.desc           = "A material that depiste of being heavier than RHA, provides more resiliance agaisnt the damage than its rolled version. Highly vulnerable to spalling."
Material.year           = 1930

Material.massMod        = 1.25
Material.curve          = 1

Material.effectiveness  = 0.98
Material.resiliance     = 2.25

Material.spallarmor     = 1
Material.spallresist    = 0.5

Material.spallmult      = 2
Material.ArmorMul       = 1
Material.NormMult       = 0.8

if SERVER then
    function Material.ArmorResolution( Entity, armor, losArmor, losArmorHealth, maxPenetration, FrAera, caliber, damageMult, Type)
        
        local HitRes = {}

        local curve         = Material.curve
        local effectiveness = Material.effectiveness
        local resiliance    = Material.resiliance
        
        armor       = armor^curve
        losArmor    = losArmor^curve
            
        -- Breach probability
        local breachProb = math.Clamp((caliber / armor / effectiveness - 1.3) / (7 - 1.3), 0, 1)

        -- Penetration probability
        local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;    
            
        -- Breach chance roll
        if breachProb > math.random() and maxPenetration > armor then
                
            HitRes.Damage   = FrAera / resiliance * damageMult          -- Inflicted Damage
            HitRes.Overkill = maxPenetration - armor                        -- Remaining penetration
            HitRes.Loss     = armor / maxPenetration                        -- Energy loss in percents

            return HitRes

        -- Penetration chance roll      
        elseif penProb > math.random() then                                 
                
            local Penetration = math.min( maxPenetration, losArmor * effectiveness )

            HitRes.Damage   = (( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult ) / resiliance
            HitRes.Overkill = ( maxPenetration - Penetration )
            HitRes.Loss     = Penetration / maxPenetration
            
            return HitRes
                    
        end

        -- Projectile did not breach nor penetrate armor
        local Penetration = math.min( maxPenetration , losArmor * effectiveness )
            
        HitRes.Damage   = (( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult ) / resiliance
        HitRes.Overkill = 0
        HitRes.Loss     = 1
        
        return HitRes
            
    end 
end

list.Set( "ACE_MaterialTypes", Material.id, Material ) 