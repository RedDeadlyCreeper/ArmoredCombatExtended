AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( _, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_crewseat_driver" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	if self:GetModel() == "models/vehicles/pilot_seat.mdl" then
		self:SetPos(self:LocalToWorld(Vector(0, 15.3, -14)))
	end
	self:SetModel( "models/chairs_playerstart/sitpose.mdl" )
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

	if self.ACF.Health < self.ACF.MaxHealth * 0.989 then
		ACF_HEKill( self, VectorRand() , 0)
		self:EmitSound("npc/combine_soldier/die" .. tostring(math.random(1, 3)) .. ".wav")
	end

end


function ENT:OnRemove()

	for Key in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
		end
	end

end