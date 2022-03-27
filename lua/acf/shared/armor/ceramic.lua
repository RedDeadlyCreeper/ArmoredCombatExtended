
local Material          = {}

Material.id             = "Cer"
Material.name           = "Ceramic"
Material.sname          = "Ceramic"
Material.desc           = "The ceramic is mostly used to stop shells and penetrations in general, but its too fragil and tends to break easily."
Material.year           = 1955

Material.massMod        = 0.8
Material.curve          = 0.95

Material.effectiveness  = 2.4
Material.resiliance     = 0.01

Material.spallarmor     = 1
Material.spallresist    = 1

Material.spallmult      = 2.5
Material.ArmorMul       = 1.8
Material.NormMult       = 1.5

function Material.ArmorResolution( Entity, armor, losArmor, losArmorHealth, maxPenetration, FrAera, caliber, damageMult, Type)
    
    local HitRes = {}

    local curve         = Material.curve
    local effectiveness = Material.effectiveness
    local resiliance    = Material.resiliance
        
    armor = armor^curve
    losArmor = losArmor^curve
            
    local slopeDmg = ( losArmor / armor ) --Angled ceramic takes more damage. Fully angled ceramic takes up to 7x the damage
        
    if Type == 'HE' or Type == 'HESH' then
        slopeDmg = slopeDmg * 5 
    end

    local dmul = slopeDmg   

    -- Breach probability
    local breachProb = math.Clamp((caliber / armor / effectiveness - 1.3) / (7 - 1.3), 0, 1)

    -- Penetration probability
    local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration/losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;    
        
    -- Breach chance roll
    if breachProb > math.random() and maxPenetration > armor then               
        
        HitRes.Damage   = FrAera / resiliance * damageMult * dmul   -- Inflicted Damage
        HitRes.Overkill = maxPenetration - armor                                                -- Remaining penetration
        HitRes.Loss     = armor / maxPenetration                                                -- Energy loss in percents

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

    HitRes.Damage   = ( Penetration / losArmorHealth / effectiveness )^2 * FrAera / resiliance * damageMult * dmul 
    HitRes.Overkill = 0
    HitRes.Loss     = 1
    
    return HitRes

end 

list.Set( "ACE_MaterialTypes", Material.id, Material ) 