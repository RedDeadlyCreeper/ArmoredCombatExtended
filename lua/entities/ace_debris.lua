
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Debris"

if CLIENT then return end

function ENT:Initialize()

	if ACF.DebrisLifeTime > 0 then
		self.Timer = CurTime() + ACF.DebrisLifeTime
	end
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	
	local phys = self:GetPhysicsObject()
	
	if IsValid( phys ) then
	    
		phys:Wake()
	    phys:SetMaterial('jeeptire')
		
	end   
end

function ENT:Think()
	if ACF.DebrisLifeTime > 0 and self.Timer then
		if self.Timer < CurTime() then self:Remove() end

		self:NextThink( CurTime() + ACF.DebrisLifeTime)	
		return true	
	else
		return false
	end
end

