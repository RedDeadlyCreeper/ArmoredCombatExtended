
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
Material.HEeffectiveness    = 3
Material.resiliance         = 0.1
Material.HEresiliance       = 0.05

Material.spallarmor     = 1
Material.spallresist    = 1

Material.spallmult      = 0
Material.ArmorMul       = 1
Material.NormMult       = 1

Material.IsExplosive    = true -- Tell to core that this material is explosive and their own explosions should be reduced vs other explosive mats in order to avoid chain reactions.

function Material.ArmorResolution( Entity, armor, losArmor, losArmorHealth, maxPenetration, FrAera, caliber, damageMult, Type)
    
    local HitRes = {}

    local curve         = Material.curve
    local effectiveness = Material.effectiveness
    local resiliance    = Material.resiliance
    
    local blastArmor = effectiveness * armor * (Entity.ACF.Health/Entity.ACF.MaxHealth)

    --ERA is more effective vs HEAT than vs kinetic 
    if Type == "HEAT" or Type == "THEAT" or Type == "HEATFS" or Type == "THEATFS" then      
        blastArmor = Material.HEATeffectiveness * armor
    elseif Type == 'HE' or Type == 'HESH' or Type == 'Frag' then
        blastArmor = Material.HEeffectiveness * armor
        resiliance = Material.HEresiliance
    end

    --print(( Type and 'Type: '..Type) or 'No type')
    --print('ERA Max pen: '..maxPenetration)
    --print('Blast Armor: '..blastArmor)

    --ERA detonates and shell is completely stopped
    if maxPenetration > blastArmor/2 or (Entity.ACF.Health/Entity.ACF.MaxHealth) < 0.45 then --ERA was penetrated
        --print('Detonated by:'..(Type or 'No type'))           

        --Importart to remove the ent before the explosions begin
        Entity:Remove()

        HitRes.Damage   = 9999999999999 
        HitRes.Overkill = math.Clamp(maxPenetration - blastArmor,0,1)                       -- Remaining penetration
        HitRes.Loss     = math.Clamp(blastArmor / maxPenetration,0,0.98)        

        --print('Remaining Pen:'..HitRes.Overkill)
        local HEWeight = armor*0.01         
        local Radius =( HEWeight*0.0001 )^0.33*8*39.37
            
        local Owner = (CPPI and Entity:CPPIGetOwner()) or NULL

        ACF_HE( Entity:GetPos() , Vector(0,0,1) , HEWeight , HEWeight , Owner , Entity, Entity ) --ERABOOM
            
        local Flash = EffectData()
            Flash:SetOrigin( Entity:GetPos() )
            Flash:SetNormal( Vector(0,0,-1) )
            Flash:SetRadius( math.max( Radius, 1 ) )
        util.Effect( "ACF_Scaled_Explosion", Flash )
            
        return HitRes
    else    

        -- Projectile did not breach nor penetrate armor            
        local Penetration = math.min( maxPenetration , losArmor)

        HitRes.Damage   = ( Penetration / losArmorHealth)^2 * FrAera / resiliance * damageMult  
        HitRes.Overkill = 0
        HitRes.Loss     = 1
    
        return HitRes
                    
    end
            
end 

list.Set( "ACE_MaterialTypes", Material.id, Material ) 