-- shared.lua

DEFINE_BASECLASS("base_wire_entity")

ENT.Type            = "anim"
ENT.Base            = "base_wire_entity"
ENT.PrintName       = "ACF Missile Rack"

ENT.Spawnable       = false
ENT.AdminOnly       = false
ENT.AdminSpawnable  = false


function ENT:GetMunitionAngPos(missile, attach, attachname)

    local angpos
    
    if attach ~= 0 then
        angpos = self:GetAttachment(attach)
    else
        angpos = {Pos = self:GetPos(), Ang = self:GetAngles()}
    end

    local guns         = list.Get("ACFEnts").Guns
    local gun       = guns[missile.BulletData.Id]

    if not gun then return angpos end
    
    local offset    = (gun.modeldiameter or gun.caliber) / (2.54 * 2)
    local rack      = ACF.Weapons.Rack[self.Id]

    if not rack then return angpos end
    
    mountpoint = rack.mountpoints[attachname] or {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0, 0, -1)}
    inverted = rack.inverted or false


    if mountpoint.pos then
        angpos.Pos = mountpoint.pos
    end

    angpos.Pos = self:LocalToWorld(angpos.Pos + mountpoint.offset + (mountpoint.scaledir)*offset)

    return inverted, angpos
end

function ENT:GetMuzzle(shot, missile)
    shot = (shot or 0) + 1

    local attachname        = "missile" .. shot
    local attach            = self:LookupAttachment(attachname)
    local inverted, angpos  = self:GetMunitionAngPos(missile, attach, attachname)
    if attach ~= 0 then return attach, inverted, angpos  end
    
    attachname              = "missile1"
    local attach            = self:LookupAttachment(attachname)
    local inverted, angpos  = self:GetMunitionAngPos(missile, attach, attachname)
    if attach ~= 0 then return attach, inverted, angpos end

    attachname              = "muzzle"
    local attach            = self:LookupAttachment(attachname)
    local inverted, angpos  = self:GetMunitionAngPos(missile, attach, attachname)
    if attach ~= 0 then return attach, inverted, angpos end
    
    return 0, false, {Pos = self:GetPos(), Ang = self:GetAngles()}
end
