



function ACF_GetGunValue(bdata, val)

    bdata = (type(bdata) == "table" and bdata.Id) or bdata

    local guns = list.Get("ACFEnts").Guns
    local class = guns[bdata]

    if class then
        local ret 
        
        if class.round then ret = class.round[val] end
        if ret == nil then ret = class[val] end
        
        if ret ~= nil then
            return ret
        else
            local classes = list.Get("ACFClasses").GunClass
            class = classes[class.gunclass]

            if class then
                return class[val]
            end
        end
    end
    
end





function ACF_GetRackValue(rdata, val)

    rdata = (type(rdata) == "table" and rdata.Id) or rdata

    local guns = ACF.Weapons.Rack
    local class = guns[rdata]

    if class then        
        if class[val] ~= nil then
            return class[val]
        else
            local classes = ACF.Classes.Rack
            class = classes[class.gunclass]

            if class then
                return class[val]
            end
        end
    end
    
end




function ACF_RackCanLoadCaliber(rackId, cal)

    local rack = ACF.Weapons.Rack[rackId]
    if not rack then return false, "Rack '" .. tostring(rackId) .. "' does not exist." end

    if rack.caliber then 
        local ret = (rack.caliber == cal)
        if ret then return true, ""
        else return false, "Only " .. math.Round(rack.caliber * 10, 2) .. "mm rounds can fit in this gun." end
    end
    
    if rack.mincaliber and cal < rack.mincaliber then 
        return false, "Rounds must be at least " .. math.Round(rack.mincaliber * 10, 2) .. "mm to fit in this gun."
    end
    
    if rack.maxcaliber and cal > rack.maxcaliber then 
        return false, "Rounds cannot be more than " .. math.Round(rack.maxcaliber * 10, 2) .. "mm to fit in this gun."
    end
    
    return true
    
end




function ACF_CanLinkRack(rackId, ammoId, bdata, rack)

    local rack = ACF.Weapons.Rack[rackId]
    if not rack then return false, "Rack '" .. tostring(rackId) .. "' does not exist." end

    local gun = list.Get("ACFEnts").Guns[ammoId]
    if not rack then return false, "Ammo '" .. tostring(ammoId) .. "' does not exist." end
    
    
    local rackAllow = ACF_GetGunValue(ammoId, "racks")
    
    local rackAllowed = true
    local allowType = type(rackAllow)
    
    if rackAllow == nil and rack.whitelistonly then
        rackAllowed = false
    elseif allowType == "table" then 
        rackAllowed = rackAllow[rackId]
    elseif allowType == "function" then
        rackAllowed = rackAllow(bdata or ammoId, rack or rackId)
    end
    
    if not rackAllowed then
        return false, ammoId .. " rounds are not compatible with a " .. tostring(rackId) .. "!"
    end
    
    
    local canCaliber, calMsg = ACF_RackCanLoadCaliber(rackId, gun.caliber)
    if not canCaliber then
        return false, calMsg
    end
    
    local Classes = list.Get("ACFClasses").GunClass
    if "missile" ~= Classes[gun.gunclass].type then 
        return false, "Racks cannot be linked to ammo crates of type '" .. tostring(ammoId) .. "'!" 
    end
    
    return true
    
end




function ACF_GetCompatibleRacks(ammoId)

    local ret = {}

    for rackId, data in pairs(ACF.Weapons.Rack) do
        if ACF_CanLinkRack(rackId, ammoId) then
            ret[#ret+1] = rackId
        end
    end
    
    return ret
    
end




function ACF_GetRoundFromCVars()
    
    local round = {}
    
    round.Id            = GetConVarString( "acfmenu_data1" )
	round.Type          = GetConVarString( "acfmenu_data2" )
	round.PropLength    = GetConVarNumber( "acfmenu_data3" )
	round.ProjLength    = GetConVarNumber( "acfmenu_data4" )
	round.Data5         = GetConVarNumber( "acfmenu_data5" )
    round.Data6         = GetConVarNumber( "acfmenu_data6" )
    round.Data7         = GetConVarString( "acfmenu_data7" )
    round.Data8         = GetConVarString( "acfmenu_data8" )
    round.Data9         = GetConVarString( "acfmenu_data9" )
	round.Data10        = GetConVarNumber( "acfmenu_data10" )
    
    return round
    
end