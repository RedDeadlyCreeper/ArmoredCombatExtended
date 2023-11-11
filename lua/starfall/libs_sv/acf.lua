--- Library for interfacing with ACF entities
-- @name acf
-- @class library
-- @libtbl acf_library
-- @src https://github.com/RedDeadlyCreeper/ArmoredCombatExtended/tree/master/lua/starfall/lib_sv/acf.lua
SF.RegisterLibrary("acf")

local min, max, clamp, abs, round = math.min, math.max, math.Clamp, math.abs, math.Round
local rad, cos = math.rad, math.cos

local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

registerprivilege("acf.createMobility", "Create acf engine", "Allows the user to create ACF engines and gearboxes", { usergroups = { default = 3 } })
registerprivilege("acf.createFuelTank", "Create acf fuel tank", "Allows the user to create ACF fuel tanks", { usergroups = { default = 3 } })
registerprivilege("acf.createGun", "Create acf gun", "Allows the user to create ACF guns", { usergroups = { default = 3 } })
registerprivilege("acf.createAmmo", "Create acf ammo", "Allows the user to create ACF ammoboxes", { usergroups = { default = 3 } } )
registerprivilege("entities.acf", "ACF", "Allows the user to control ACF components", { entities = {} })

local function isEngine(ent)
	return ent:GetClass() == "acf_engine"
end

local function isGearbox(ent)
	return ent:GetClass() == "acf_gearbox"
end

local function isGun(ent)
	return ent:GetClass() == "acf_gun"
end

local function isAmmo(ent)
	return ent:GetClass() == "acf_ammo"
end

local function isFuel(ent)
	return ent:GetClass() == "acf_fueltank"
end

local radarTypes = {
	acf_missileradar = true,
	ace_irst = true,
	ace_trackingradar = true,
}

local function isRadar(ent)
	return radarTypes[ent:GetClass()] or false
end

-- link resources within each ent type. should point to an ent: true if adding link.Ent, false to add link itself
local linkTables = {
	acf_engine		= { GearLink = true, FuelLink = false },
	acf_gearbox		= { WheelLink = true, Master = false },
	acf_fueltank	= { Master = false },
	acf_gun			= { AmmoLink = false },
	acf_ammo		= { Master = false }
}

local function getLinks(ent, enttype)
	local ret = {}
	-- find the link resources available for this ent type
	for entry, mode in pairs(linkTables[enttype]) do
		if not ent[entry] then
			SF.Throw("[Internal ACE Error] Couldn't find link resource " .. entry .. " for entity " .. tostring(ent), 2)

			return
		end

		-- find all the links inside the resources
		for _, link in pairs(ent[entry]) do
			ret[#ret + 1] = mode and link.Ent or link
		end
	end

	return ret
end

local function searchForGearboxLinks(ent)
	local boxes = ents.FindByClass("acf_gearbox")
	local ret = {}
	for _, box in ipairs(boxes) do
		if IsValid(box) then
			for _, link in pairs(box.WheelLink) do
				if link.Ent == ent then
					ret[#ret + 1] = box

					break
				end
			end
		end
	end

	return ret
end


return function(instance)


local checktype = instance.CheckType
local acf_library = instance.Libraries.acf
local ents_methods, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local sanitize = instance.Sanitize
local getent = instance.Types.Entity.GetEntity

local function restrictInfo(ent)
	if GetConVar("acf_restrictinfo"):GetInt() ~= 0 then
		return ent:CPPIGetOwner() ~= instance.player
	end

	return false
end

local idNameCache = {}
local function listIDFromName(list, name)
	idNameCache[list] = idNameCache[list] or {}

	if idNameCache[list][name] then return idNameCache[list][name] end

	for id, data in pairs(list) do
		if data.name == name then
			idNameCache[list][name] = id

			return id
		end
	end
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

	--- Returns the maximum capacity of an acf ammo crate or fuel tank
	-- @server
	-- @return number The capacity
	function ents_methods:acfCapacity()
		local this = getent(self)

		if not (isAmmo(this) or isFuel(this)) then return 0 end
		if restrictInfo(this) then return 0 end

		return this.Capacity or 1
	end

	--- Returns true if the acf engine, fuel tank, or ammo crate is active
	-- @server
	-- @return boolean Is the entity active?
	function ents_methods:acfGetActive()
		local this = getent(self)

		if not (isEngine(this) or isAmmo(this) or isFuel(this)) then return false end
		if restrictInfo(this) then return false end
		if not isAmmo(this) then
			if this.Active then return true end
		else
			if this.Load then return true end
		end

		return false
	end

	--- Turns an ACF engine, ammo crate, or fuel tank on or off
	-- @server
	-- @param boolean state The state to set the entity to
	function ents_methods:acfSetActive(on)
		local this = getent(self)

		checkpermission(instance, this, "entities.acf")

		if not (isEngine(this) or isAmmo(this) or isFuel(this)) then return end

		this:TriggerInput("Active", on and 1 or 0)
	end

	--- Returns true if hitpos is on a clipped part of prop
	-- @server
	-- @param Vector hitpos The hit position
	-- @return boolean Is the hit position on a clipped part of the prop?
	function ents_methods:acfHitClip(hitpos)
		checktype(hitpos, vec_meta)

		local this = getent(self)
		hitpos = vunwrap(hitpos)

		checkpermission(instance, this, "entities.acf")
		if ACF_CheckClips(nil, nil, this, hitpos) then
			return true
		else
			return false
		end
	end

	--- Returns the ACF links associated with the entity
	-- @server
	-- @return table The links
	function ents_methods:acfLinks()
		local this = getent(self)

		local enttype = this:GetClass()
		if not linkTables[enttype] then return searchForGearboxLinks(this) end

		return sanitize(getLinks(this, enttype))
	end

	--- Returns the full name of an ACF entity
	-- @server
	-- @return string The full name
	function ents_methods:acfName()
		local this = getent(self)

		if isAmmo(this) then return this.RoundId .. " " .. this.RoundType end
		if isFuel(this) then return this.FuelType .. " " .. this.SizeId end

		local acftype = ""

		if isEngine(this) then acftype = "Mobility" end
		if isGearbox(this) then acftype = "Mobility" end
		if isGun(this) then acftype = "Guns" end

		if acftype == "" then return "" end
		local List = ACF.Weapons

		return List[acftype][this.Id].name or ""
	end

	--- Returns the type of ACF entity
	-- @server
	-- @return string The type
	function ents_methods:acfType()
		local this = getent(self)

		if isEngine(this) or isGearbox(this) then
			return ACF.Weapons["Mobility"][this.Id].category or ""
		end

		if isGun(this) then
			return ACF.Classes["GunClass"][this.Class].name or ""
		end

		if isAmmo(this) then return this.RoundType or "" end
		if isFuel(this) then return this.FuelType or "" end

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

-- Weapon functions
do
	--- Returns the specs of gun
	-- @param string id id or name of the gun
	-- @server
	-- @return table The specs table
	function acf_library.getGunSpecs(id)
		checkluatype(id, TYPE_STRING)

		local listEntries = ACF.Weapons.Guns

		-- Not a valid id, try name
		if not listEntries[id] then
			id = listIDFromName(listEntries, id)

			-- Name is also invalid, error
			if not id or not listEntries[id] then
				SF.Throw("Invalid id or name", 2)
			end
		end

		local specs = table.Copy(listEntries[id])
		specs.BaseClass = nil

		return sanitize(specs)
	end

	--- Returns a list of all guns
	-- @server
	-- @return table The guns list
	function acf_library.getAllGuns()
		local tbl = {}

		for id, _ in pairs(ACF.Weapons.Guns) do
			tbl[#tbl + 1] = id
		end

		return tbl
	end
end

-- Ammo functions
do
end

-- Mobility functions
do
	--- Returns the specs of an engine or gearbox
	-- @param string id ID or name of the engine or gearbox
	-- @server
	-- @return table The specs table
	function acf_library.getMobilitySpecs(id)
		checkluatype(id, TYPE_STRING)

		local listEntries = ACF.Weapons.Mobility

		-- Not a valid id, try name
		if not listEntries[id] then
			id = listIDFromName(listEntries, id)

			-- Name is also invalid, error
			if not id or not listEntries[id] then
				SF.Throw("Invalid id or name", 2)
			end
		end

		local specs = table.Copy(listEntries[id])
		specs.BaseClass = nil

		return sanitize(specs)
	end

	--- Returns a list of all mobility components
	-- @server
	-- @return table The mobility component list
	function acf_library.getAllMobility()
		local tbl = {}

		for id, _ in pairs(ACF.Weapons.Mobility) do
			tbl[#tbl + 1] = id
		end

		return tbl
	end

	--- Returns a list of all engines
	-- @server
	-- @return table The engine list
	function acf_library.getAllEngines()
		local tbl = {}

		for id, d in pairs(ACF.Weapons.Mobility) do
			if d.ent == "acf_engine" then
				tbl[#tbl + 1] = id
			end
		end

		return tbl
	end

	--- Returns a list of all gearboxes
	-- @server
	-- @return table The gearbox list
	function acf_library.getAllGearboxes()
		local tbl = {}

		for id, d in pairs(ACF.Weapons.Mobility) do
			if d.ent == "acf_gearbox" then
				tbl[#tbl + 1] = id
			end
		end

		return tbl
	end

	--- Returns the specs of the fuel tank
	-- @param string id id of the engine or gearbox
	-- @server
	-- @return table The specs table
	function acf_library.getFuelTankSpecs(id)
		checkluatype(id, TYPE_STRING)

		local list_entries = ACF.Weapons.FuelTanks
		if not list_entries[id] then SF.Throw("Invalid id", 2) end

		local specs = table.Copy(list_entries[id])
		specs.BaseClass = nil

		return sanitize(specs)
	end
end

end