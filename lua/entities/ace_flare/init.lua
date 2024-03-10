AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetGravity( 0.01 )

	self.Heat		= self.Heat or 1
	self.Life		= self.Life or 0.1

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass(3)
		phys:EnableDrag( true )
		phys:SetDragCoefficient( 50 )
		phys:SetBuoyancyRatio( 2 )
		phys:Wake()
	end

	timer.Simple(self.Life, function()
		if IsValid(self) then
			self:Remove()
		end
	end)

	table.insert( ACE.contraptionEnts, self )
end

function ENT:Think()

	if self:WaterLevel() == 3 then
		self.Heat = 0
		self:StopParticles()

		return false
	end

	self:NextThink( CurTime() + 0.1 )
	return true
end

function ENT:PhysicsCollide( Table )

	local HitEnt = Table.HitEntity

	if not IsValid(HitEnt) then return end

	if HitEnt:IsNPC() or (HitEnt:IsPlayer() and not HitEnt:HasGodMode()) then
		if vFireInstalled then
			CreateVFireEntFires(HitEnt, 3)
		else
			HitEnt:Ignite( self.Heat, 1 )
		end
	end
end

function ENT:CanTool()
	return false
end
