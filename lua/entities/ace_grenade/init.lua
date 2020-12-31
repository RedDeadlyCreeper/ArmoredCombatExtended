AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel( "models/weapons/w_eq_fraggrenade_thrown.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	local phys = self:GetPhysicsObject()
	phys:SetMass(4.5) --4.1 kg mine, round down.
	
	self.FuseTime = 4
	self.phys = phys
	self.LastTime = CurTime()
	if ( IsValid( phys ) ) then phys:Wake() end
end


function ENT:Think()

	local curtime = CurTime()
	self.FuseTime = self.FuseTime-(curtime-self.LastTime)
	self.LastTime = CurTime()

	if self.FuseTime < 0 then
		
		local HEWeight=4	
		local Radius = (HEWeight)^0.33*8*39.37

		ACF_HE( self:GetPos() + Vector(0,0,8) , Vector(0,0,1) , HEWeight , HEWeight*0.5 , self:GetOwner(), nil, self) --0.5 is standard antipersonal mine

		local Flash = EffectData()
		Flash:SetOrigin( self:GetPos() + Vector(0,0,8) )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( math.max( Radius, 1 ) )
		util.Effect( "ACF_Scaled_Explosion", Flash )

		self:Remove()
	end


end


function ENT:OnRemove()
end









