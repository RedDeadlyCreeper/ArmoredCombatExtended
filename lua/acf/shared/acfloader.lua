
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

-- add gui stuff to base classes if this is client
if CLIENT then
	gun_base.guicreate = function( Panel, Table ) ACFGunGUICreate( Table ) end or nil
	gun_base.guiupdate = function() return end
	
	engine_base.guicreate = function( panel, tbl ) ACFEngineGUICreate( tbl ) end or nil
	engine_base.guiupdate = function() return end
	
	gearbox_base.guicreate = function( panel, tbl ) ACFGearboxGUICreate( tbl ) end or nil
	gearbox_base.guiupdate = function() return end
	
	fueltank_base.guicreate = function( panel, tbl ) ACFFuelTankGUICreate( tbl ) end or nil
	fueltank_base.guiupdate = function( panel, tbl ) ACFFuelTankGUIUpdate( tbl ) end or nil

	radar_base.guicreate = function( Panel, Table ) ACFRadarGUICreate( Table ) end
	radar_base.guiupdate = function() return end
end

if game.IsDedicated() then
	ACE.IsDedicated = true
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

-- Material definition
function ACE_ConfigureMaterial( id, data )
	ACE.ArmorTypes[id] = data
    --print( 'Loaded Material: '..ACE.ArmorTypes[id].name )
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
local guns = file.Find( "acf/shared/guns/*.lua", "LUA" )
for k, v in pairs( guns ) do
	AddCSLuaFile( "acf/shared/guns/" .. v )
	include( "acf/shared/guns/" .. v )
end

local ammocrates = file.Find( "acf/shared/ammocrates/*.lua", "LUA" )
for k, v in pairs( ammocrates ) do
	AddCSLuaFile( "acf/shared/ammocrates/" .. v )
	include( "acf/shared/ammocrates/" .. v )
end

local engines = file.Find( "acf/shared/engines/*.lua", "LUA" )
for k, v in pairs( engines ) do
	AddCSLuaFile( "acf/shared/engines/" .. v )
	include( "acf/shared/engines/" .. v )
end

local gearboxes = file.Find( "acf/shared/gearboxes/*.lua", "LUA" )
for k, v in pairs( gearboxes ) do
	AddCSLuaFile( "acf/shared/gearboxes/" .. v )
	include( "acf/shared/gearboxes/" .. v )
end

local fueltanks = file.Find( "acf/shared/fueltanks/*.lua", "LUA" )
for k, v in pairs( fueltanks ) do
	AddCSLuaFile( "acf/shared/fueltanks/" .. v )
	include( "acf/shared/fueltanks/" .. v )
end

aaa_IncludeShared("acf/shared/missiles")
aaa_IncludeShared("acf/shared/guns")
aaa_IncludeShared("acf/shared/radars")

ACF.RoundTypes = list.Get("ACFRoundTypes")
ACF.IdRounds = list.Get("ACFIdRounds")	--Lookup tables so i can get rounds classes from clientside with just an integer

-- now that the tables are populated, throw them in the acf ents list
list.Set( "ACFClasses", "GunClass", GunClasses )
list.Set( "ACFEnts", "Guns", GunTable )            
list.Set( "ACFEnts", "Mobility", MobilityTable )
list.Set( "ACFEnts", "FuelTanks", FuelTankTable )

list.Set( "ACFClasses", "Rack", RackClasses )
list.Set( "ACFEnts", "Rack", Racks )

list.Set( "ACFClasses", "Radar", RadarClasses )
list.Set( "ACFEnts", "Radar", Radars )