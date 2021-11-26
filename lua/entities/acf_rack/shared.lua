-- shared.lua

DEFINE_BASECLASS("base_wire_entity")

ENT.Type        	= "anim"
ENT.Base        	= "base_wire_entity"
ENT.PrintName 		= "ACF Missile Rack"

ENT.Spawnable 		= false
ENT.AdminOnly		= false
ENT.AdminSpawnable = false



function ENT:GetMuzzle(shot, missile)
	--print('total shots: '..shot)
	shot = (shot or 0) + 1
	
	local trymissile = "missile" .. shot
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetMunitionAngPos(missile, attach, trymissile) end
	
	trymissile = "missile1"
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetMunitionAngPos(missile, attach, trymissile) end

	trymissile = "muzzle"
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetMunitionAngPos(missile, attach, trymissile) end
	
	return 0, {Pos = self:GetPos(), Ang = self:GetAngles()}
end



function ENT:GetMunitionAngPos(missile, attach, attachname)

	local angpos
	
	if attach ~= 0 then
		angpos = self:GetAttachment(attach)
	else
		angpos = {Pos = self:GetPos(), Ang = self:GetAngles()}
	end
	
	--print(angpos.Pos)

    local guns = list.Get("ACFEnts").Guns
    local gun = guns[missile.BulletData.Id]

    if not gun then return angpos end
	
    local offset = (gun.modeldiameter or gun.caliber) / (2.54 * 2)
    local rack = ACF.Weapons.Rack[self.Id]

    if not rack then return angpos end
    
	mountpoint = rack.mountpoints[attachname] or {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0, 0, -1)}
	
	if !IsValid(self:GetParent()) then
		angpos.Pos = angpos.Pos + (self:LocalToWorld(mountpoint.offset) - self:GetPos()) + (self:LocalToWorld(mountpoint.scaledir) - self:GetPos()) * offset
	else

		if table.Count(self:GetAttachments()) != 1 then offset = gun.modeldiameter or gun.caliber*2 end
		angpos.Pos =  Vector(0,0,0) + (mountpoint.offset - Vector(0,0,0)) + (mountpoint.scaledir - Vector(0,0,0)) * offset

	end

	return angpos
end
