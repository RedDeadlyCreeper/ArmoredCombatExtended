-- init.lua

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include("shared.lua")

DEFINE_BASECLASS( "base_wire_entity" )

local GunClasses	= ACF.Classes.GunClass
local RackClasses	= ACF.Classes.Rack

local GunTable	= ACF.Weapons.Guns
local RackTable	= ACF.Weapons.Racks

local AmmoLinkDistBase = 512

function ENT:GetReloadTime(nextMsl)

	local Rack = RackTable[self.Id]
	local reloadMul = Rack.reloadmul or self.ReloadMultiplier or 1

	local reloadBonus = (self.ReloadMultiplierBonus or 0)
	local mag = (self.MagSize or 1)

	reloadMul = (reloadMul - (reloadMul - 1) * reloadBonus) / (mag ^ 1.1)

	local ret = math.max(self:GetFireDelay(nextMsl) * reloadMul, 0.5)
	self:SetNWFloat(	"Reload",	ret)

	return ret

end

function ENT:GetFireDelay(nextMsl)

	if not IsValid(nextMsl) then
		return self.LastValidFireDelay or 1
	end

	local bdata = nextMsl.BulletData
	local gun = GunTable[bdata.Id]

	if not gun then
		return self.LastValidFireDelay or 1
	end

	local class = GunClasses[gun.gunclass]

	local interval =  math.max(( (bdata.RoundVolume / 500) ^ 0.60 ) * (gun.rofmod or 1) * (class.rofmod or 1), 0.1)
	self.LastValidFireDelay = interval
	self:SetNWFloat( "Interval", interval)

	return interval

end

local RackWireDescs = {
	--Inputs
	["Reload"]       = "Arms this rack. Its mandatory to set this since racks don't reload automatically.",
	["Delay"]        = "Sets a specific delay to guidance control over the default one in seconds.\n Note that you cannot override lower values than default.",
	["TargetPos"]    = "Defines the Target position for the ordnance in this rack. This only works for Wire and laser guidances.",

	--Outputs
	["Ready"]        = "Returns if the rack is ready to fire."

}

function ENT:Initialize()

	self.BaseClass.Initialize(self)

	self.SpecialHealth   = false	--If true needs a special ACF_Activate function
	self.SpecialDamage   = false	--If true needs a special ACF_OnDamage function --NOTE: you can't "fix" missiles with setting this to false, it acts like a prop!!!!
	self.ReloadTime      = 1
	self.RackStatus      = "Empty"
	self.Ready           = true
	self.Firing          = nil
	self.NextFire        = 1
	self.PostReloadWait  = CurTime()
	self.WaitFunction    = self.GetFireDelay
	self.NextLegalCheck  = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal           = true
	self.LegalIssues     = ""
	self.LastSend        = 0
	self:CPPISetOwner(self)

	self.IsMaster              = true
	self.CurAmmo               = 1
	self.Sequence              = 1
	self.LastThink             = CurTime()

	self.BulletData            = {}
	self.BulletData.Type       = "Empty"
	self.BulletData.PropMass   = 0
	self.BulletData.ProjMass   = 0

	self.ForceTdelay           = 0
	self.Inaccuracy            = 1

	self.Inputs = WireLib.CreateSpecialInputs( self, { "Fire",	"Reload (" .. RackWireDescs["Reload"] .. ")", "Track Delay (" .. RackWireDescs["Delay"] .. ")",	"Target Pos (" .. RackWireDescs["TargetPos"] .. ")" },
													{ "NORMAL", "NORMAL", "NORMAL", "VECTOR" } )

	self.Outputs = WireLib.CreateSpecialOutputs( self,  { "Ready (" .. RackWireDescs["Ready"] .. ")",	"Entity",	"Shots Left",  "Position" },
														{ "NORMAL", "ENTITY", "NORMAL", "VECTOR" } )

	Wire_TriggerOutput(self, "Entity", self)
	Wire_TriggerOutput(self, "Ready", 1)
	self.WireDebugName = "ACF Rack"

	self.lastCol = self:GetColor() or Color(255, 255, 255)
	self.nextColCheck = CurTime() + 2

	self.Missiles = {}

	self.AmmoLink = {}

	self:GetOverlayText()

end

function ENT:CanLoadCaliber(cal)

	return ACF_RackCanLoadCaliber(self.Id, cal)

end




function ENT:CanLinkCrate(crate)

	local bdata = crate.BulletData

	-- Don't link if it's a refill crate
	if bdata["RoundType"] == "Refill" or bdata["Type"] == "Refill" then
		return false, "Refill crates cannot be linked!"
	end


	-- Don't link if it's a blacklisted round type for this rack
	local class = ACF_GetGunValue(bdata, "gunclass")
	local Blacklist = ACF.AmmoBlacklist[ bdata.RoundType or bdata.Type ] or {}

	if not class or table.HasValue( Blacklist, class ) then
		return false, "That round type cannot be used with this rack!"
	end


	-- Dont't link if it's too far from this rack
	if RetDist( self, crate ) >= AmmoLinkDistBase then
		return false, "That crate is too far to be connected with this rack!"
	end


	-- Don't link if it's not a missile.
	local ret, msg = ACF_CanLinkRack(self.Id, bdata.Id, bdata, self)
	if not ret then return ret, msg end


	-- Don't link if it's already linked
	for _, v in pairs( self.AmmoLink ) do
		if v == crate then
			return false, "That crate is already linked to this rack!"
		end
	end


	return true

end




function ENT:Link( Target )

	-- Don't link if it's not an ammo crate
	if not IsValid( Target ) or Target:GetClass() ~= "acf_ammo" then
		return false, "Racks can only be linked to ammo crates!"
	end

	-- Don't link if it's a blacklisted round type for this gun
	local Blacklist = ACF.AmmoBlacklist[ Target.RoundType ] or {}

	if table.HasValue( Blacklist, self.Class ) then
		return false, "That round type cannot be used with this gun!"
	end

	local ret, msg = self:CanLinkCrate(Target)
	if not ret then
		return false, msg
	end


	table.insert( self.AmmoLink, Target )
	table.insert( Target.Master, self )

	self:SetOverlayText(txt)

	return true, "Link successful!"



end

function ENT:Unlink( Target )

	local Success = false
	for Key,Value in pairs(self.AmmoLink) do
		if Value == Target then
			table.remove(self.AmmoLink,Key)
			Success = true
		end
	end

	if Success then

		self:GetOverlayText()

		return true, "Unlink successful!"
	else
		return false, "That entity is not linked to this gun!"
	end

end

function ENT:UnloadAmmo()
	-- we're ok with mixed munitions.
end

function ENT:TriggerInput( iname , value )

	if ( iname == "Fire" and value ~= 0 and ACF.GunfireEnabled and self.Legal ) then
		if self.NextFire >= 1 then
			self.User = ACE_GetWeaponUser( self, self.Inputs.Fire.Src )
			if not IsValid(self.User) then self.User = self:CPPIGetOwner() end
			self:FireMissile()
			self:Think()
		end
		self.Firing = true
	elseif iname == "Fire" and value == 0 then
		self.Firing = false
	elseif iname == "Reload" and value ~= 0 then
		self:Reload()
	elseif iname == "Target Pos" then
		Wire_TriggerOutput(self, "Position", value)
	elseif iname == "Track Delay" then
		self.ForceTdelay = math.max(value,0)

		if not table.IsEmpty(self.Missiles) then
			--ENT:TrimNullMissiles() could be used here, but i need to update force track delay to each missile, sad.
			for k, missile in ipairs(self.Missiles) do
				if not IsValid(missile) then table.remove(self.Missiles, k) end
				missile.ForceTdelay = self.ForceTdelay
			end
		end
	end
end

function ENT:Reload()


	if self.Ready or not IsValid(self:PeekMissile()) then
		self:LoadAmmo(true)
	end

end

function RetDist( enta, entb )
	if not ((enta and enta:IsValid()) or (entb and entb:IsValid())) then return 0 end
	return enta:GetPos():Distance(entb:GetPos())
end

function ENT:SetStatusString()

	local Missile = self:PeekMissile()

	if not IsValid(Missile) then
		self.RackStatus = "Empty"
		--self:SetNWString("Status", "Empty")
		self:GetOverlayText()
		return
	else
		if not self.Ready then

		self.RackStatus = "Loading"
		--self:SetNWString("Status", "Loading")
		self:GetOverlayText()
		return
		else

		self.RackStatus = "Ready"
		--self:SetNWString("Status", "Ready")
		self:GetOverlayText()
		return
		end
	end
	self:SetNWString("Linked", "")
	self:SetNWString("Status", "")
	self:GetOverlayText()

end

function ENT:TrimDistantCrates()

	for _, Crate in pairs(self.AmmoLink) do
		if IsValid( Crate ) and Crate.Load and RetDist( self, Crate ) >= AmmoLinkDistBase then
			self:Unlink( Crate )
			soundstr =  "physics/metal/metal_box_impact_bullet" .. tostring(math.random(1, 3)) .. ".wav"
			self:EmitSound(soundstr, 500, 100)
		end
	end

end

function ENT:UpdateRefillBonus()

	local totalBonus			= 0
	local selfPos			= self:GetPos()

	local Efficiency			= 0.11 * ACF.AmmoMod		-- Copied from acf_ammo, beware of changes!
	local minFullEfficiency	= 50000 * Efficiency	-- The minimum crate volume to provide full efficiency bonus all by itself.
	local maxDist			= ACF.RefillDistance

	for _, crate in pairs(ACF.AmmoCrates or {}) do

		if crate.RoundType ~= "Refill" then
			continue

		elseif crate.Ammo > 0 and crate.Load then
			local dist = selfPos:Distance(crate:GetPos())

			if dist < maxDist then

				dist = math.max(0, dist * 2 - maxDist)

				local bonus = ( (crate.Volume or 0.1) / minFullEfficiency ) * ( maxDist - dist ) / maxDist

				totalBonus = totalBonus + bonus

			end
		end

	end


	self.ReloadMultiplierBonus = math.min(totalBonus, 1)
	--self:SetNWFloat(  "ReloadBonus", self.ReloadMultiplierBonus)

	return self.ReloadMultiplierBonus

end




function ENT:Think()

	if ACF.CurTime > self.NextLegalCheck then
		self.Legal, self.LegalIssues = ACF_CheckLegal(self, nil, math.Round(self.Mass,2), self.ModelInertia, nil, true) -- requiresweld overrides parentable, need to set it false for parent-only gearboxes
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		if not self.Legal and self.Firing then
			self.Firing = false
		end
	end

	local Ammo = table.Count(self.Missiles or {})

	local Time = CurTime()
	if self.LastSend + 1 <= Time then

		self:TrimDistantCrates()
		self:UpdateRefillBonus()

		self:TrimNullMissiles()
		Wire_TriggerOutput(self, "Shots Left", Ammo)

		self:SetNWString("GunType",	self.Id)
		self:SetNWInt(  "Ammo",		Ammo)

		self:GetReloadTime(self:PeekMissile())
		self:SetStatusString()

		self.LastSend = Time

	end

	self.NextFire = math.min(self.NextFire + (Time - self.LastThink) / self:WaitFunction(self:PeekMissile()), 1)

	if self.NextFire >= 1 and Ammo > 0 and Ammo <= self.MagSize then
		self.Ready = true
		Wire_TriggerOutput(self, "Ready", 1)
		if self.Firing then
			self.ReloadTime = nil
			self:FireMissile()
		elseif (self.Inputs.Reload and self.Inputs.Reload.Value ~= 0) and self:CanReload() then
			self.ReloadTime = nil
			self:Reload()
		elseif self.ReloadTime and self.ReloadTime > 1 then
			self:EmitSound( "acf_extra/airfx/weapon_select.wav", 75, 100 )
			self.ReloadTime = nil
		end
	elseif self.NextFire >= 1 and Ammo == 0 then
		if (self.Inputs.Reload and self.Inputs.Reload.Value ~= 0) and self:CanReload() then
			self.ReloadTime = nil
			self:Reload()
		end
	end

	self:GetOverlayText()

	self:NextThink(Time + 0.5)

	self.LastThink = Time


	return true

end

function ENT:TrimNullMissiles()
	for k, v in pairs(self.Missiles) do
		if not IsValid(v) then
			table.remove(self.Missiles, k)
		end
	end
end




function ENT:PeekMissile()

	self:TrimNullMissiles()

	local NextIdx = #self.Missiles
	if NextIdx <= 0 then return false end

	local missile = self.Missiles[NextIdx]

	return missile, NextIdx

end




function ENT:PopMissile()

	local missile, curShot = self:PeekMissile()

	if missile == false then return false end

	self.Missiles[curShot] = nil

	return missile, curShot

end




function ENT:FindNextCrate( doSideEffect )

	local MaxAmmo = #self.AmmoLink
	local AmmoEnt = nil
	local i = 0

	local curAmmo = self.CurAmmo

	while i <= MaxAmmo and not (AmmoEnt and AmmoEnt:IsValid() and AmmoEnt.Ammo > 0) do

		curAmmo = curAmmo + 1
		if curAmmo > MaxAmmo then curAmmo = 1 end

		AmmoEnt = self.AmmoLink[curAmmo]
		if AmmoEnt and AmmoEnt:IsValid() and AmmoEnt.Ammo > 0 and AmmoEnt.Load then
			return AmmoEnt
		end
		AmmoEnt = nil

		i = i + 1
	end

	if doSideEffect then
		self.CurAmmo = curAmmo
	end

	return false
end




function ENT:CanReload()

	local Ammo = table.Count(self.Missiles)
	if Ammo >= self.MagSize then return false end

	local Crate = self:FindNextCrate()
	if not IsValid(Crate) then return false end

	if self.NextFire < 1 then return false end

	return true

end




function ENT:SetLoadedWeight()

	self:TrimNullMissiles()

	for _, missile in pairs(self.Missiles) do

		local phys = missile:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:SetMass( missile.RoundWeight ) --phys:SetMass( 5 )  -- Will result in slightly heavier rack but is probably a good idea to have some mass for any damage calcs.
		end
	end

end




function ENT:AddMissile()

	self:EmitSound( "acf_extra/tankfx/resupply_single.wav", 75, 100 )

	self:TrimNullMissiles()

	local Ammo = table.Count(self.Missiles)
	if Ammo >= self.MagSize then return false end

	local Crate = self:FindNextCrate(true)
	if not IsValid(Crate) then return false end

	local ply = self:CPPIGetOwner()

	local missile = ents.Create("acf_missile")
	missile:CPPISetOwner(ply)
	missile.DoNotDuplicate  = true
	missile.Launcher		= self
	missile.ForceTdelay	= self.ForceTdelay

	missile.ContrapId = ACF_Check( self ) and self.ACF.ContraptionId or 1

	local BulletData = ACFM_CompactBulletData(Crate)
	BulletData.IsShortForm  = true
	BulletData.Owner		= ply
	missile:SetBulletData(BulletData)

	--For pod based launchers
	local rackmodel = ACF_GetRackValue(self.Id, "rackmdl") or ACF_GetGunValue(BulletData.Id, "rackmdl")
	if rackmodel then
		missile:SetModelEasy( rackmodel )
		missile.RackModelApplied = true
	end

	local NextIdx = #self.Missiles
	local _, _, pos = self:GetMuzzle( NextIdx , missile )

	missile:SetPos(pos)
	missile:SetAngles(self:GetAngles())

	missile:SetParent(self)
	missile:SetParentPhysNum(0)

	if self.HideMissile then missile:SetNoDraw(true) end
	if self.ProtectMissile then missile:SetNotSolid(true) end

	missile:SetNWEntity( "Launcher", missile.Launcher )
	missile:Spawn()

	self.Missiles[NextIdx + 1] = missile

	Crate.Ammo = Crate.Ammo - 1

	self:SetLoadedWeight()

	return missile

end




function ENT:LoadAmmo()

	self:TrimDistantCrates()

	if not self:CanReload() then return false end

	local missile = self:AddMissile()

	self:TrimNullMissiles()
	Ammo = table.Count(self.Missiles)
	self:SetNWInt("Ammo",	Ammo)

	local ReloadTime = 1

	if IsValid(missile) then
		ReloadTime = self:GetReloadTime(missile)
	end

	self.NextFire = 0
	self.PostReloadWait = CurTime() -- + 5 --CurTime() + 4.5
	self.WaitFunction = self.GetReloadTime

	self.Ready = false
	self.ReloadTime = ReloadTime

	Wire_TriggerOutput(self, "Ready", 0)

	self:GetOverlayText()

	self:Think()
	return true

end

function MakeACF_Rack(Owner, Pos, Angle, Id)

	if not Owner:CheckLimit("_acf_rack") then return false end

	local Rack = ents.Create("acf_rack")

	if not IsValid(Rack) then return false end

	Rack:SetAngles(Angle)
	Rack:SetPos(Pos)
	Rack:Spawn()

	Owner:AddCount("_acf_rack", Rack)
	Owner:AddCleanup( "acfmenu", Rack )

	if not ACE_CheckRack( Id ) then
		Id = "1xRK"
	end

	local gundef = RackTable[Id]

	Rack:CPPISetOwner(Owner)
	Rack.Id	= Id

	Rack.MinCaliber	= gundef.mincaliber
	Rack.MaxCaliber	= gundef.maxcaliber
	Rack.Caliber		= gundef.caliber
	Rack.Model		= gundef.model
	Rack.Mass		= gundef.weight
	Rack.name		= gundef.name
	Rack.Class		= gundef.gunclass

	-- Custom BS for karbine. Per Rack ROF.
	Rack.PGRoFmod = 1
	if gundef["rofmod"] then
		Rack.PGRoFmod = math.max(0, gundef["rofmod"])
	end

	-- Custom BS for karbine. Magazine Size, Mag reload Time
	Rack.MagSize = table.Count(gundef.mountpoints) or 1
	Rack.MagReload = gundef.magreload or 0

	local gunclass = RackClasses[Rack.Class] or ErrorNoHalt("Couldn't find the " .. tostring(Rack.Class) .. " gun-class!")

	Rack.Muzzleflash       = gundef.muzzleflash	or gunclass.muzzleflash	or ""
	Rack.RoFmod            = gunclass["rofmod"]								or 1
	Rack.Sound             = gundef.sound		or gunclass.sound		or "acf_extra/airfx/rocket_fire2.wav"
	Rack.DefaultSound      = Rack.Sound
	Rack.SoundPitch        = 100
	Rack.Inaccuracy        = gundef["spread"]	or gunclass["spread"]	or 1

	Rack.HideMissile       = ACF_GetRackValue(Id, "hidemissile")			or false
	Rack.ProtectMissile    = gundef.protectmissile or gunclass.protectmissile  or false
	Rack.CustomArmour      = gundef.armour		or gunclass.armour		or 1

	Rack.ReloadMultiplier  = ACF_GetRackValue(Id, "reloadmul")
	Rack.WhitelistOnly     = ACF_GetRackValue(Id, "whitelistonly")

	Rack:SetNWString("WireName",Rack.name)
	Rack:SetNWString( "Class",  Rack.Class )
	Rack:SetNWString( "ID",	Rack.Id )
	Rack:SetNWString( "Sound",  Rack.Sound )
	Rack:SetNWInt( "SoundPitch",  Rack.SoundPitch )

	Rack:SetModel( Rack.Model )
	Rack:PhysicsInit( SOLID_VPHYSICS )
	Rack:SetMoveType( MOVETYPE_VPHYSICS )
	Rack:SetSolid( SOLID_VPHYSICS )

	local phys = Rack:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(Rack.Mass or 1)
	end

	hook.Call("ACF_RackCreate", nil, Rack)

	undo.Create( "acf_rack" )
		undo.AddEntity( Rack )
		undo.SetPlayer( Owner )
	undo.Finish()

	return Rack

end

list.Set( "ACFCvars", "acf_rack" , {"id"} )
duplicator.RegisterEntityClass("acf_rack", MakeACF_Rack, "Pos", "Angle", "Id")

function ENT:GetInaccuracy()
	return self.Inaccuracy * ACF.GunInaccuracyScale
end

function ENT:FireMissile()

	if self.Ready and self.Legal and (self.PostReloadWait < CurTime()) then

		self.BaseEntity = ACF_GetPhysicalParent(self) or game.GetWorld()

		local nextMsl = self:PeekMissile()

		local CanDo = true
		if nextMsl then CanDo = hook.Run("ACF_FireShell", self, nextMsl.BulletData ) end
		if CanDo == false then return end

		local ReloadTime = 0.5
		local missile, curShot = self:PopMissile()

		if missile then

			ReloadTime = self:GetFireDelay(missile)

			local attach, inverted, pos = self:GetMuzzle(curShot - 1, missile)

			local MuzzleVec		= self:GetAngles():Forward()

			local coneAng		= math.tan(math.rad(self:GetInaccuracy()))
			local randUnitSquare	= (self:GetUp() * (2 * math.random() - 1) + self:GetRight() * (2 * math.random() - 1))
			local spread			= randUnitSquare:GetNormalized() * coneAng * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4)))
			local ShootVec		= (MuzzleVec + spread):GetNormalized()

			local filter = {}
			for _, v in pairs(self.Missiles) do
				filter[#filter + 1] = v
			end
			filter[#filter + 1] = self
			filter[#filter + 1] = missile

			missile.Filter = filter

			missile:SetParent(nil)
			missile:SetNoDraw(false)
			missile:SetNotSolid(false)

			local bdata = missile.BulletData

			bdata.Pos = pos
			bdata.Flight = (self:GetAngles():Forward() + spread):GetNormalized() * (bdata.MuzzleVel or missile.MinimumSpeed or 1) * (inverted and -1 or 1)

			if missile.RackModelApplied then
				local model = ACF_GetGunValue(bdata.Id, "model")
				missile:SetModelEasy( model )
				missile.RackModelApplied = nil
			end

			local phys = missile:GetPhysicsObject()
			if (IsValid(phys)) then
				phys:SetMass( missile.RoundWeight )
			end

			if self.Sound and self.Sound ~= "" then
				missile.BulletData.Sound = self.Sound
				missile.BulletData.Pitch = self.SoundPitch
			end

			missile:DoFlight(pos, ShootVec)
			missile:Launch()

			self:SetLoadedWeight()

			self:MuzzleEffect( attach, missile.BulletData )

			Ammo = table.Count(self.Missiles)
			self:SetNWInt("Ammo",	Ammo)

		else
			self:EmitSound("weapons/shotgun/shotgun_empty.wav",68,100)
		end

		self.Ready = false
		Wire_TriggerOutput(self, "Ready", 0)
		self.NextFire = 0
		self.WaitFunction = self.GetFireDelay
		self.ReloadTime = ReloadTime

	else
		self:EmitSound("weapons/shotgun/shotgun_empty.wav",68,100)
	end

end

function ENT:MuzzleEffect()
	self:EmitSound( "phx/epicmetal_hard.wav", 75, 100 )
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}
	for _, Value in pairs(self.AmmoLink) do				--First clean the table of any invalid entities
		if not Value:IsValid() then
			table.remove(self.AmmoLink, Value)
		end
	end
	for _, Value in pairs(self.AmmoLink) do				--Then save it
		table.insert(entids, Value:EntIndex())
	end
	info.entities = entids
	if info.entities then
		duplicator.StoreEntityModifier( self, "ACFAmmoLink", info )
	end

	--Wire dupe info
	self.BaseClass.PreEntityCopy( self )

end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if Ent.EntityMods and Ent.EntityMods.ACFAmmoLink and Ent.EntityMods.ACFAmmoLink.entities then
		local AmmoLink = Ent.EntityMods.ACFAmmoLink
		if AmmoLink.entities and next(AmmoLink.entities) then
			for _,AmmoID in pairs(AmmoLink.entities) do
				local Ammo = CreatedEntities[ AmmoID ]
				if Ammo and Ammo:IsValid() and Ammo:GetClass() == "acf_ammo" then
					self:Link( Ammo )
				end
			end
		end
		Ent.EntityMods.ACFAmmoLink = nil
	end

	--Wire dupe info
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end

function ENT:OnRemove()
	Wire_Remove(self)
end

function ENT:OnRestore()
	Wire_Restored(self)
end

--New Overlay text that is shown when you are looking at the rack.
function ENT:GetOverlayText()

	local Ammo		= table.Count(self.Missiles)	-- Ammo count
	local FireRate	= self.LastValidFireDelay or 1	-- How many time take one lauch from another. in secs
	local Reload		= self:GetNWFloat("Reload")		-- reload time. in secs
	local ReloadBonus	= self.ReloadMultiplierBonus or 0  -- the word explains by itself
	local Status		= self.RackStatus				-- this was used to show ilegality issues before. Now this shows about rack state (reloading?, ready?, empty and so on...)

	local txt = "-  " .. Status .. "  -"

	if Ammo > 0 then
		if Ammo == 1 then
			txt = txt .. "\n" .. Ammo .. " Launch left"
		else
			txt = txt .. "\n" .. Ammo .. " Launches left"
		end

		txt = txt .. "\n\nFire Rate: " .. math.Round(FireRate, 2) .. " secs"
		txt = txt .. "\nReload Time: " .. math.Round(Reload, 2) .. " secs"

		if ReloadBonus > 0 then
			txt = txt .. "\n" .. math.floor(ReloadBonus * 100) .. "% Reload Time Decreased"
		end
	else
		if #self.AmmoLink ~= 0 then
			txt = txt .. "\n\nProvided with ammo.\n"
		else
			txt = txt .. "\n\nAmmo not found!\n"
		end
	end

	if not self.Legal then
		txt = txt .. "\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText(txt)

end
