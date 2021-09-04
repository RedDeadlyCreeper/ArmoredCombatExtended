AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);

	self.Heat = self.Heat or 1
	self.Life = self.Life or 0.1
	self.DieTime = CurTime() + self.Life

	local phys = self:GetPhysicsObject()
	phys:SetMass(5) --4.1 kg mine, round down.
	phys:EnableDrag( true )
	phys:SetDragCoefficient( 50 )
	self:SetGravity( 0.01 )

	timer.Simple(0.1,function() 
		ParticleEffectAttach("ACFM_Flare",4, self,1)  
			self.HotEnts = {ent}

			table.insert( ACE.contraptionEnts, self ) --Disgusting re-use of the contraption entity table. I like it.
			--print(table.Count( ACE.contraptionEnts ))
	
	end)

	self.phys = phys
	if ( IsValid( phys ) ) then phys:Wake() end

end


function ENT:Think()
	local CTime = CurTime()

	if self.DieTime < CTime then
		ACF_HEKill( self, VectorRand() , 0)	
		self:EmitSound("npc/barnacle/barnacle_pull2.wav",500,100)
		self:Remove()
	end

end


function ENT:OnRemove()
	
end









