AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( ply, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_crewseat_driver" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self:SetModel( "models/vehicles/pilot_seat.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);

	self.Master = {}
	self.ACF = {}
	self.ACF.Health = 1
	self.ACF.MaxHealth = 1
end


function ENT:Think()
	self:GetPhysicsObject():SetMass(65) --62 kilo people plus 3 kg seat, hooray
    
	if self.ACF.Health < self.ACF.MaxHealth*0.989 then
		ACF_HEKill( self, VectorRand() , 0)	
		self:EmitSound("npc/combine_soldier/die" .. tostring(math.random(1, 3)) .. ".wav",500,100)
	end

end


function ENT:OnRemove()
	
	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
		end
	end
	
end









