
-- Loads all files from shared folder

AddCSLuaFile()

local GunClasses    = {}
local GunTable      = {}
local MobilityTable = {}
local FuelTankTable = {}

local Racks         = {}
local RackClasses   = {}

local Radars        = {}
local RadarClasses  = {}

local GSoundData    = {}

-- setup base classes
local gun_base = {
    ent = "acf_gun",
    type = "Guns"
}
local engine_base = {
    ent = "acf_engine",
    type = "Mobility"
}
local gearbox_base = {
    ent = "acf_gearbox",
    type = "Mobility",
    sound = "vehicles/junker/jnk_fourth_cruise_loop2.wav"
}
local fueltank_base = {
    ent = "acf_fueltank",
    type = "Mobility"
}
local rack_base = {
    ent =   "acf_rack",
    type =  "Rack"
}
local radar_base = {
    ent =   "acf_missileradar",
    type =  "Radar"
}
local trackradar_base = {
    ent =   "ace_trackingradar",
    type =  "Radar"
}
local irst_base = {
    ent = "ace_irst",
    type = "Radar"
}

-- add gui stuff to base classes if this is client
if CLIENT then
    gun_base.guicreate          = function( Panel, Table ) ACFGunGUICreate( Table )         end or nil
    gun_base.guiupdate          = function() return end
    
    --engine_base.guicreate       = function( panel, tbl ) ACE_EngineGUI_Create( tbl )        end or nil -- experimental
    --engine_base.guiupdate       = function( panel, tbl ) ACE_EngineGUI_Update( tbl )        end or nil
    
    engine_base.guicreate       = function( panel, tbl ) ACE_EngineGUI_Update( tbl )        end or nil 

    gearbox_base.guicreate      = function( panel, tbl ) ACFGearboxGUICreate( tbl )         end or nil
    gearbox_base.guiupdate      = function() return end
    
    fueltank_base.guicreate     = function( panel, tbl ) ACFFuelTankGUICreate( tbl )        end or nil
    fueltank_base.guiupdate     = function( panel, tbl ) ACFFuelTankGUIUpdate( tbl )        end or nil

    radar_base.guicreate        = function( Panel, Table ) ACFRadarGUICreate( Table )       end
    radar_base.guiupdate        = function() return end

    trackradar_base.guicreate   = function( Panel, Table ) ACFTrackRadarGUICreate( Table )  end or nil
    trackradar_base.guiupdate   = function() return end

    irst_base.guicreate         = function( Panel, Table ) ACFIRSTGUICreate( Table )        end or nil
    irst_base.guiupdate         = function() return end
end

-- some factory functions for defining ents

--Gun class definition
function ACF_defineGunClass( id, data )
    if (data.year or 0) < ACF.Year then
        data.id = id
        GunClasses[ id ] = data
    end
end

-- Gun definition
function ACF_defineGun( id, data )
    if (data.year or 0) < ACF.Year then
        data.id = id
        data.round.id = id
        table.Inherit( data, gun_base )
        GunTable[ id ] = data
    end
end

-- Rack definition
function ACF_DefineRack( id, data )
    data.id = id
    table.Inherit( data, rack_base )
    Racks[ id ] = data
end

-- Rack class definition
function ACF_DefineRackClass( id, data )
    data.id = id
    RackClasses[ id ] = data
end

--Engine definition
function ACF_DefineEngine( id, data )
    if (data.year or 0) < ACF.Year then
        local engineData = ACF_CalcEnginePerformanceData(data.torquecurve or ACF.GenericTorqueCurves[data.enginetype], data.torque, data.idlerpm, data.limitrpm)

        data.peaktqrpm      = engineData.peakTqRPM
        data.peakpower      = engineData.peakPower
        data.peakpowerrpm   = engineData.peakPowerRPM
        data.peakminrpm     = engineData.powerbandMinRPM
        data.peakmaxrpm     = engineData.powerbandMaxRPM
        data.curvefactor    = (data.limitrpm - data.idlerpm) / data.limitrpm

        data.id = id
        table.Inherit( data, engine_base )
        MobilityTable[ id ] = data
    end
end

-- Gearbox definition
function ACF_DefineGearbox( id, data )
    data.id = id
    table.Inherit( data, gearbox_base )
    MobilityTable[ id ] = data
end


-- fueltank definition
function ACF_DefineFuelTank( id, data )
    data.id = id
    table.Inherit( data, fueltank_base )
    MobilityTable[ id ] = data
end

-- fueltank size definition
function ACF_DefineFuelTankSize( id, data )
    data.id = id
    table.Inherit( data, fueltank_base )
    FuelTankTable[ id ] = data
end


-- Radar definition
function ACF_DefineRadar( id, data )
    data.id = id
    table.Inherit( data, radar_base )
    Radars[ id ] = data
end

-- Radar Class definition
function ACF_DefineRadarClass( id, data )
    data.id = id
    RadarClasses[ id ] = data
end


-- Tracking Radar definition
function ACF_DefineTrackRadar( id, data )
    data.id = id
    table.Inherit( data, trackradar_base )
    Radars[ id ] = data
end

-- Tracking Radar Class definition
function ACF_DefineTrackRadarClass( id, data )
    data.id = id
    RadarClasses[ id ] = data
end


-- Tracking Radar definition
function ACF_DefineIRST( id, data )
    data.id = id
    table.Inherit( data, irst_base )
    Radars[ id ] = data
end

-- Tracking Radar Class definition
function ACF_DefineIRSTClass( id, data )
    data.id = id
    RadarClasses[ id ] = data
end

--Step 2: gather specialized sounds. Normally sounds that have associated sounds into it. Literally using the string path as id.
function ACE_DefineGunFireSound( id, data )
    data.id = id
    GSoundData[id] = data
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

-- search for and load a bunch of files or whatever

do

    local Gpath = "acf/shared/"
    local folders = {
        "armor",
        "guns",
        "missiles",
        "radars",
        "ammocrates",
        "engines",
        "gearboxes",
        "guidances",
        "fueltanks",
        "fuses",
        "sounds"
    }

    for k, folder in ipairs(folders) do
    
        local folderData = file.Find( Gpath..folder.."/*.lua", "LUA" )
        for k, v in pairs( folderData ) do
            AddCSLuaFile( "acf/shared/"..folder.."/" .. v )
            include( "acf/shared/"..folder.."/" .. v )
        end

    end

end

ACF.RoundTypes = list.Get("ACFRoundTypes")
ACF.IdRounds = list.Get("ACFIdRounds")  --Lookup tables so i can get rounds classes from clientside with just an integer

-- now that the tables are populated, throw them in the acf ents list
list.Set( "ACFClasses"  , "GunClass"    , GunClasses    )
list.Set( "ACFEnts"     , "Guns"        , GunTable      )            
list.Set( "ACFEnts"     , "Mobility"    , MobilityTable )
list.Set( "ACFEnts"     , "FuelTanks"   , FuelTankTable )

list.Set( "ACFClasses"  , "Rack"        , RackClasses   )
list.Set( "ACFEnts"     , "Rack"        , Racks         )

list.Set( "ACFClasses"  , "Radar"       , RadarClasses  )
list.Set( "ACFEnts"     , "Radar"       , Radars        )

list.Set( "ACESounds"   , "GunFire"     , GSoundData    )
