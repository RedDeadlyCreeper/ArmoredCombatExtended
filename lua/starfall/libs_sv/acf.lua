--- Library for interfacing with ACF entities
-- @name acf
-- @class library
-- @libtbl acf_library
-- @src https://github.com/RedDeadlyCreeper/ArmoredCombatExtended/tree/master/lua/starfall/lib_sv/acf.lua
SF.RegisterLibrary("acf")

local min, max, clamp, abs, round = math.min, math.max, math.Clamp, math.abs, math.Round
local rad, cos = math.rad, math.cos

local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

registerprivilege("acf.createMobility", "Create acf engine", "Allows the user to create ACF engines and gearboxes", { usergroups = { default = 3 } })
registerprivilege("acf.createFuelTank", "Create acf fuel tank", "Allows the user to create ACF fuel tanks", { usergroups = { default = 3 } })
registerprivilege("acf.createGun", "Create acf gun", "Allows the user to create ACF guns", { usergroups = { default = 3 } })
registerprivilege("acf.createAmmo", "Create acf ammo", "Allows the user to create ACF ammoboxes", { usergroups = { default = 3 } } )
registerprivilege("entities.acf", "ACF", "Allows the user to control ACF components", { entities = {} })

-- Borrowed from https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/e2lib.lua#L188
local function validPhysics(ent)
	if IsValid(ent) then
		if ent:IsWorld() then return false end
		if ent:GetMoveType() ~= MOVETYPE_VPHYSICS then return false end

		return IsValid(ent:GetPhysicsObject())
	end

	return false
end

local function isEngine(ent)
	if not validPhysics( ent ) then return false end

	return ent:GetClass() == "acf_engine"
end

local function isGearbox(ent)
	if not validPhysics(ent) then return false end

	return ent:GetClass() == "acf_gearbox"
end

local function isGun(ent)
	if not validPhysics(ent) then return false end

	return ent:GetClass() == "acf_gun"
end

local function isAmmo(ent)
	if not validPhysics(ent) then return false end

	return ent:GetClass() == "acf_ammo"
end

local function isFuel(ent)
	if not validPhysics(ent) then return false end

	return ent:GetClass() == "acf_fueltank"
end

local radarTypes = {
	acf_missileradar = true,
	ace_irst = true,
	ace_trackingradar = true,
}

local function isRadar(ent)
	if not validPhysics(ent) then return false end

	return radarTypes[ent:GetClass()] or false
end

return function(instance)

local checktype = instance.CheckType
local acf_library = instance.Libraries.acf
local ents_methods, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local getent = instance.Types.Entity.GetEntity

local function restrictInfo(ent)
	if GetConVar("acf_restrictinfo"):GetInt() ~= 0 then
		return ent:CPPIGetOwner() ~= instance.player
	end

	return false
end

instance:AddHook("deinitialize", function()
end)

-- Utility functions
do
	--- Returns current ACF drag divisor
	-- @server
	-- @return number The current drag divisor
	function acf_library.dragDivisor()
		return ACF.DragDiv
	end

	--- Returns true if functions returning sensitive info are restricted to owned props
	-- @server
	-- @return boolean True if restriced, False if not
	function acf_library.infoRestricted()
		return GetConVar("acf_restrictinfo"):GetInt() ~= 0
	end

	--- Returns latest version of ACF
	-- @server
	-- @return number Version number
	function acf_library.getVersion()
		return ACF.CurrentVersion
	end

	--- Returns server version of acf
	-- @server
	-- @return number Version number
	function acf_library.getCurrentVersion()
		return ACF.Version
	end

	--- Returns velocity loss for every meter traveled. 0.2x means HEAT loses 20% of its energy every 2m traveled. 1m is about typical for the sideskirt spaced armor of most tanks.
	-- @server
	-- @return number Air gap factor
	function acf_library.getHEATAirGapFactor()
		return ACF.HEATAirGapFactor
	end

	--- Returns ACF wind direction
	-- @server
	-- @return vector Wind direction
	function acf_library.getWindVector()
		return vwrap(ACF.Wind)
	end

	--- Returns true if this entity contains sensitive info and is not accessable to us
	-- @server
	-- @return boolean Is the info restricted?
	function ents_methods:acfIsInfoRestricted()
		return restrictInfo(getent(self))
	end

	--- Returns the short name of an ACF entity
	-- @server
	-- @return string The short name
	function ents_methods:acfNameShort()
		local this = getent(self)

		if isEngine(this) then return this.Id or "" end
		if isGearbox(this) then return this.Id or "" end
		if isGun(this) then return this.Id or "" end
		if isAmmo(this) then return this.RoundId or "" end
		if isFuel(this) then return this.FuelType .. " " .. this.SizeId end

		return ""
	end
end

-- Spawning functions
do
end

-- Armor functions
do
	--- Returns the effective armor given an armor value and hit angle
	-- @param number armor The nominal armor value
	-- @param number hit The hit angle
	-- @server
	-- @return number The effective armor
	function acf_library.effectiveArmor(armor, angle)
		checkluatype(armor, TYPE_NUMBER)
		checkluatype(angle, TYPE_NUMBER)

		return round(armor / abs(cos(rad(min(angle, 89.999)))), 1)
	end
end

-- Mobility functions
do
end

end