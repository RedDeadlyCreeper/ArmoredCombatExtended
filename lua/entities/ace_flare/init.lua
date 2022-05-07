AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.Heat 		= self.Heat or 1
	self.Life 		= self.Life or 0.1

	self.Owner 		= self:GetOwner() print(self.Owner)

	if CPPI then
		--self:CPPISetOwner(self:GetOwner())
	end

	local phys = self:GetPhysicsObject()
	phys:SetMass(5) --4.1 kg mine, round down.
	phys:EnableDrag( true )
	phys:SetDragCoefficient( 50 )
	self:SetGravity( 0.01 )

	timer.Simple(0.1,function() 
		if not IsValid(self) then return end

		table.insert( ACE.contraptionEnts, self )

		ParticleEffectAttach("ACFM_Flare",4, self,1)  
	end)

	timer.Simple(self.Life, function()
		if IsValid(self) then
			self:Remove()
		end
	end)

	if ( IsValid( phys ) ) then phys:Wake() end

end

function ENT:PhysicsCollide( Table , PhysObj )

	local HitEnt = Table.HitEntity

	if not IsValid(HitEnt) then return end
	if not HitEnt:IsPlayer() or HitEnt:IsNPC() then return end

	HitEnt:Ignite( self.Heat, 1 )

end