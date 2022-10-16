
local Material          = {}

Material.id             = "RHA"
Material.name           = "Rolled homogeneous Armor"
Material.sname          = "RHA"
Material.desc           = "Material which has no special traits. Your standart ACF armor."
Material.year           = 1900 -- Dont blame about this, ik that RHA has existed before this year but it would be cool to see: when?

Material.massMod        = 1
Material.curve          = 1

Material.effectiveness  = 1
Material.resiliance     = 1

Material.spallarmor     = 1
Material.spallresist    = 1

Material.spallmult      = 1
Material.ArmorMul       = 1
Material.NormMult       = 1

if SERVER then
    function Material.ArmorResolution( Entity, armor, losArmor, losArmorHealth, maxPenetration, FrArea, caliber, damageMult, Type)

        local HitRes = {}

        local curve         = Material.curve
        local effectiveness = Material.effectiveness
        local resiliance    = Material.resiliance

        armor       = armor^curve
        losArmor    = losArmor^curve
        
        -- Breach probability
        local breachProb = math.Clamp((caliber / armor / effectiveness - 1.3) / (7 - 1.3), 0, 1)

        -- Penetration probability
        local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/ losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;   

        -- Breach chance roll
        if breachProb > math.random() and maxPenetration > armor then

            HitRes.Damage   = FrArea / resiliance * damageMult          -- Inflicted Damage
            HitRes.Overkill = maxPenetration - armor                    -- Remaining penetration
            HitRes.Loss     = armor / maxPenetration                    -- Energy loss in percents

            return HitRes
                            
        -- Penetration chance roll  
        elseif penProb > math.random() then                                 
        
            local Penetration = math.min( maxPenetration, losArmor * effectiveness)

            HitRes.Damage   = ( ( Penetration / losArmorHealth / effectiveness )^2 * FrArea / resiliance * damageMult )
            HitRes.Overkill = ( maxPenetration - Penetration )
            HitRes.Loss     = Penetration / maxPenetration
            
            return HitRes
                            
        end

        -- Projectile did not breach nor penetrate armor
        local Penetration = math.min( maxPenetration , losArmor * effectiveness )

        HitRes.Damage   = (( Penetration / losArmorHealth / effectiveness )^2 * FrArea / resiliance * damageMult )/ resiliance
        HitRes.Overkill = 0
        HitRes.Loss     = 1
        
        return HitRes
                
    end 
end

list.Set( "ACE_MaterialTypes", Material.id, Material ) 