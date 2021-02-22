
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Debris"

if CLIENT then return end

function ENT:Initialize()
	
	self.Timer = CurTime() + 30
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	
	local phys = self:GetPhysicsObject()
	local Mass = phys:GetVolume() * 0.005
	
	if IsValid( phys ) then
	    
		phys:Wake()
		phys:SetMass(Mass)
	    phys:SetMaterial('jeeptire')
		
	end
	

	
end

function ENT:Think()
	
	if self.Timer < CurTime() then
		self:Remove()
	end
	
	self:NextThink( CurTime() + 30 )
	
	return true
	
end

function ENT:OnTakeDamage( dmginfo )
	
	-- React physically when shot/getting blown
	-- not sure if this is actually necessary
	self:TakePhysicsDamage( dmginfo )
	
end
