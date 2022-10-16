--[[
              _____ ______   __  __ _         _ _           
        /\   / ____|  ____| |  \/  (_)       (_) |          
       /  \ | |    | |__    | \  / |_ ___ ___ _| | ___  ___ 
      / /\ \| |    |  __|   | |\/| | / __/ __| | |/ _ \/ __|
     / ____ \ |____| |      | |  | | \__ \__ \ | |  __/\__ \
    /_/    \_\_____|_|      |_|  |_|_|___/___/_|_|\___||___/
                                                         
    By Bubbus + Cre8or
    
    A reimplementation of XCF missiles and bombs, with guidance and more.
]]

-- Lookup table of all currently flying missiles.
ACF_ActiveMissiles = ACF_ActiveMissiles or {}

include("acf/shared/sh_acfm_getters.lua")

function ACFM_BulletLaunch(BData)

    debugoverlay.Text(BData.Pos, "Here its spawning", 10)

    ACF.CurBulletIndex = ACF.CurBulletIndex + 1        --Increment the index
    if ACF.CurBulletIndex > ACF.BulletIndexLimit then
        ACF.CurBulletIndex = 1
    end

    local cvarGrav      = GetConVar("sv_gravity")  --gravity
    BData.Accel         = Vector(0,0,-600)            --Those are BData settings that are global and shouldn't change round to round
    BData.LastThink     = BData.LastThink or SysTime()
    BData["FlightTime"] = 0

    local Owner = BData.Owner  --owner of bullet
    
    if BData["FuseLength"] then
        BData["InitTime"] = SysTime()
    end
    
    if not BData.TraceBackComp then                                            --Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
        if IsValid(BData.Gun) then
            BData["TraceBackComp"] = BData.Gun:GetPhysicsObject():GetVelocity():Dot(BData.Flight:GetNormalized())
        else
            BData["TraceBackComp"] = 0
        end
    end
    
    BData.Filter = BData.Filter or { BData["Gun"] }
    
    BData.Index = ACF.CurBulletIndex
    ACF.Bullet[ACF.CurBulletIndex] = BData        --Place the bullet at the current index pos
    ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )

end




function ACFM_ExpandBulletData(bullet)

    -- print("==== ACFM_ExpandBulletData")
    -- pbn(bullet)
    

    local toconvert         = {}
    toconvert["Id"]         = bullet["Id"]              or "12.7mmMG"
    toconvert["Type"]       = bullet["Type"]            or "AP"
    toconvert["PropLength"] = bullet["PropLength"]      or 0
    toconvert["ProjLength"] = bullet["ProjLength"]      or 0
    toconvert["Data5"]      = bullet["FillerVol"]       or bullet["Flechettes"] or bullet["Data5"]      or 0
    toconvert["Data6"]      = bullet["ConeAng"]         or bullet["FlechetteSpread"] or bullet["Data6"] or 0
    toconvert["Data7"]      = bullet["Data7"]           or 0
    toconvert["Data8"]      = bullet["Data8"]           or 0
    toconvert["Data9"]      = bullet["Data9"]           or 0
    toconvert["Data10"]     = bullet["Tracer"]          or bullet["Data10"]         or 0
    toconvert["Colour"]     = bullet["Colour"]          or Color(255, 255, 255)
    toconvert["Data13"]     = bullet["ConeAng2"]        or bullet["Data13"]         or 0
    toconvert["Data14"]     = bullet["HEAllocation"]    or bullet["Data14"]         or 0
    toconvert["Data15"]     = bullet["Data15"]          or 0            
        
    local rounddef      = ACF.RoundTypes[bullet.Type] or error("No definition for the shell-type", bullet.Type)
    local conversion    = rounddef.convert
    
    if not conversion then error("No conversion available for this shell!") end
    local ret = conversion( nil, toconvert )
    
    ret.Pos         = bullet.Pos    or Vector(0,0,0)
    ret.Flight      = bullet.Flight or Vector(0,0,0)
    ret.Type        = ret.Type      or bullet.Type
    
    local cvarGrav  = GetConVar("sv_gravity")
    ret.Accel       = cvarGrav
    if ret.Tracer == 0 and bullet["Tracer"] and bullet["Tracer"] > 0 then ret.Tracer = bullet["Tracer"] end
    ret.Colour      = toconvert["Colour"]
    
    ret.Sound = bullet.Sound
    
    return ret

end




function ACFM_MakeCrateForBullet(self, bullet)

    if not (type(bullet) == "table") then
        if bullet.BulletData then
            self:SetNWString( "Sound", bullet.Sound or (bullet.Primary and bullet.Primary.Sound))
            self.Owner = bullet:GetOwner()
            self:SetOwner(bullet:GetOwner())
            bullet = bullet.BulletData
        end
    end
    
    
    self:SetNWInt( "Caliber", bullet.Caliber or 10)
    self:SetNWInt( "ProjMass", bullet.ProjMass or 10)
    self:SetNWInt( "FillerMass", bullet.FillerMass or 0)
    self:SetNWInt( "DragCoef", bullet.DragCoef or 1)
    self:SetNWString( "AmmoType", bullet.Type or "AP")
    self:SetNWInt( "Tracer" , bullet.Tracer or 0)
    local col = bullet.Colour or self:GetColor()
    self:SetNWVector( "Color" , Vector(col.r, col.g, col.b))
    self:SetNWVector( "TracerColour" , Vector(col.r, col.g, col.b))
    self:SetColor(col)

end




-- TODO: modify ACF to use this global table, so any future tweaks won't break anything here.
ACF.FillerDensity = 
{
    SM =    2000,
    HE =    1000,
    HEAT =  1450,
    THEAT =  1450,
}




function ACFM_CompactBulletData(crate)
    
    local compact = {}

    compact["Id"] = 			crate.RoundId       or crate.Id
    compact["Type"] = 		    crate.RoundType     or crate.Type
    compact["PropLength"] = 	crate.PropLength    or crate.RoundPropellant
    compact["ProjLength"] = 	crate.ProjLength    or crate.RoundProjectile
    compact["Data5"] = 		    crate.Data5         or crate.RoundData5         or crate.FillerVol      or crate.CavVol             or crate.Flechettes
    compact["Data6"] = 		    crate.Data6         or crate.RoundData6         or crate.ConeAng        or crate.FlechetteSpread
    compact["Data7"] = 		    crate.Data7         or crate.RoundData7
    compact["Data8"] = 		    crate.Data8         or crate.RoundData8
    compact["Data9"] = 		    crate.Data9         or crate.RoundData9
    compact["Data10"] = 		crate.Data10        or crate.RoundData10        or crate.Tracer
--11
--12
    compact["Data13"] = 		crate.Data13         or crate.RoundData13
    compact["Data14"] = 		crate.Data14         or crate.RoundData14
    compact["Data15"] = 		crate.Data15         or crate.RoundData15
	
    compact["Colour"] = 		crate.GetColor and crate:GetColor() or crate.Colour
    compact["Sound"] =          crate.Sound
    
    
    if not compact.Data5 and crate.FillerMass then
        local Filler = ACF.FillerDensity[compact.Type]
        
        if Filler then
            compact.Data5 = crate.FillerMass / ACF.HEDensity * Filler
        end
    end
    
    return compact
end

local ResetVelocity = {}

function ResetVelocity.AP(bdata)    
    
    if not bdata.MuzzleVel then return end

    bdata.Flight:Normalize()
    
    bdata.Flight = bdata.Flight * (bdata.MuzzleVel * 39.37)
    
end
            
ResetVelocity.HE = ResetVelocity.AP
ResetVelocity.HEP = ResetVelocity.AP
ResetVelocity.SM = ResetVelocity.AP
--ResetVelocity.HEAT = ResetVelocity.AP
 
         
function ResetVelocity.HEAT(bdata)    
      
    if not (bdata.MuzzleVel and bdata.SlugMV) then return end
    
    bdata.Flight:Normalize()
    
    local penmul = (bdata.penmul or ACF_GetGunValue(bdata, "penmul") or 1.2)*0.77     --local penmul = (bdata.penmul or ACF_GetGunValue(bdata, "penmul") or 1.2)*0.77
    
    bdata.Flight = bdata.Flight * (bdata.SlugMV * penmul) * 39.37 
    bdata.NotFirstPen = false

end    

function ResetVelocity.THEAT(bdata)    

	DetCount = bdata.Detonated or 0
    
    if not (bdata.MuzzleVel and bdata.SlugMV and bdata.SlugMV1 and bdata.SlugMV2) then return end
    
    bdata.Flight:Normalize()
    
    local penmul = (bdata.penmul or ACF_GetGunValue(bdata, "penmul") or 1.2)*0.77
    
	if DetCount==1 then 
        --print("Detonation1")
        bdata.Flight = bdata.Flight * (bdata.SlugMV * penmul) * 39.37 
        bdata.NotFirstPen = false
    elseif DetCount == 2 then
        --print("Detonation2")
        bdata.Flight = bdata.Flight * (bdata.SlugMV2 * penmul) * 39.37 
        bdata.NotFirstPen = false	
	end
end     

-- Resets the velocity of the bullet based on its current state on the serverside only.
-- This will de-sync the clientside effect!
function ACFM_ResetVelocity(bdata)

    local resetFunc = ResetVelocity[bdata.Type]

    if not resetFunc then return end
    
    return resetFunc(bdata)

end

include("autorun/server/duplicatorDeny.lua")

hook.Add( "InitPostEntity", "ACFMissiles_DupeDeny", function()
    -- Need to ensure this is called after InitPostEntity because Adv. Dupe 2 resets its whitelist upon this event.
    timer.Simple(1, function() duplicator.Deny("acf_missile") end)
end )


hook.Add( "InitPostEntity", "ACFMissiles_AddLinkable", function()
    -- Need to ensure this is called after InitPostEntity because Adv. Dupe 2 resets its whitelist upon this event.
    timer.Simple(1, function() ACF_E2_LinkTables["acf_rack"] = {AmmoLink = false} end)
end )
