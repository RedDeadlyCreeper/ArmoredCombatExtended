
-- This loads the files in the engine, gearbox, fuel, and gun folders!
-- Go edit those files instead of this one.
-- Thanks ferv <3


AddCSLuaFile()

if ACF.Weapons then
    --print('WEAPONS!!!')

ACF.Weapons.Rack = {}
ACF.Classes.Rack = {}

ACF.Weapons.Radar = {}
ACF.Classes.Radar = {}


local Racks =  ACF.Weapons.Rack
local RackClasses = ACF.Classes.Rack

local Radars = ACF.Weapons.Radar
local RadarClasses = ACF.Classes.Radar


-- setup base classes
local gun_base = {
	ent = "acf_gun",
	type = "Guns"
}

local rack_base = {
	ent =   "acf_rack",
	type =  "Rack"
}

local radar_base = {
	ent =   "acf_missileradar",
	type =  "Radar"
}



-- add gui stuff to base classes if this is client
if CLIENT then
	gun_base.guicreate = function( Panel, Table ) ACFGunGUICreate( Table ) end
	gun_base.guiupdate = function() return end
	
	radar_base.guicreate = function( Panel, Table ) ACFRadarGUICreate( Table ) end
	radar_base.guiupdate = function() return end
	
end



function ACF_DefineRack( id, data )
	data.id = id
	table.Inherit( data, rack_base )
	Racks[ id ] = data
end


function ACF_DefineRackClass( id, data )
	data.id = id
	RackClasses[ id ] = data
end



function ACF_DefineRadar( id, data )
	data.id = id
	table.Inherit( data, radar_base )
	Radars[ id ] = data
end


function ACF_DefineRadarClass( id, data )
	data.id = id
	RadarClasses[ id ] = data
end


local Weapons = list.GetForEdit("ACFEnts")
local Classes = list.GetForEdit("ACFClasses")


-- some factory functions for defining ents
function ACF_defineGunClass( id, data )

	if (data.year or 0) < ACF.Year then
	
	    data.id = id
    
        Classes.GunClass[ id ] = data
	    ACF.Classes.GunClass[ id ] = data
		
	end

end




function ACF_defineGun( id, data )

	if (data.year or 0) < ACF.Year then
	
	    data.id = id
	    data.round.id = id
	    table.Inherit( data, gun_base )
    
	    Weapons.Guns[ id ] = data
        ACF.Weapons.Guns[ id ] = data
		
	else
	
--	print("Did not load Gun: "..data.name.." Gun exceeds time period.")

	return false
	
	end
end



-- Getters for guidance names, for use in missile definitions.


local function GetAllInTableExcept(tbl, list)

    for k, name in ipairs(list) do
        list[name] = k
        list[k] = nil
    end

    local ret = {}

    for name, _ in pairs(tbl) do
        if not list[name] then 
            ret[#ret+1] = name
        end
    end
    
    return ret
    
end



function ACF_GetAllGuidanceNames()

    local ret = {}

    for name, _ in pairs(ACF.Guidance) do
        ret[#ret+1] = name
    end
    
    return ret
    
end



function ACF_GetAllGuidanceNamesExcept(list)

    return GetAllInTableExcept(ACF.Guidance, list)
    
end




-- Getters for fuse names, for use in missile definitions.


function ACF_GetAllFuseNames()

    local ret = {}

    for name, _ in pairs(ACF.Fuse) do
        ret[#ret+1] = name
    end
    
    return ret
    
end



function ACF_GetAllFuseNamesExcept(list)

    return GetAllInTableExcept(ACF.Fuse, list)
    
end

aaa_IncludeShared("acf/shared/missiles")
aaa_IncludeShared("acf/shared/guns")
aaa_IncludeShared("acf/shared/radars")



ACF.RoundTypes = list.Get("ACFRoundTypes")
ACF.IdRounds = list.Get("ACFIdRounds")	--Lookup tables so i can get rounds classes from clientside with just an integer

else 
    --print('No ACF.Weapons')

end