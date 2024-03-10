AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( _, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_ecm" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self.ThinkDelay = 1 --1 second delay, hopefully enough to prevent ECM flashing

	self.Active = false
	curTime = 0

	self:SetModel( "models/missiles/ecm.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(1000)

	self.Inputs = WireLib.CreateInputs( self, { "Active", "Radar ID" } )
	self.Outputs = WireLib.CreateOutputs( self, { "Energy" } )

	self:SetActive(false)

	self.JamEnergy = 100 --Enough to last 10 seconds, Fully recharges in 20 seconds
	self.OutOfEnergy = false

	self.LegalTick = 0
	self.checkLegalIn = 5 + math.random(0,5) --Random checks every 5-10 seconds
	self.IsLegal = true

	self.JamID = 0
	self.CurrentlyJamming = 0
end

--ATGMs tracked
function ENT:isLegal()

	if self:GetPhysicsObject():GetMass() < 1000 then return false end
	if not self:IsSolid() then return false end

	ACF_GetPhysicalParent(self)

	self.IsLegal = self.acfphysparent:IsSolid()

	return self.IsLegal

end

function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self:isLegal())
	elseif inp == "Radar ID" then
		self.JamID = value
	end

end

function ENT:SetActive(active)

	self.Active = active

	if active  then
		local sequence = self:LookupSequence("active") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = true
	else
		local sequence = self:LookupSequence("idle") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = false
		self.CurrentlyJamming = 0
	end

end

function ENT:Think()

	local curTime = CurTime()
	self:NextThink(curTime + self.ThinkDelay)

	self.LegalTick = (self.LegalTick or 0) + 1

	if	self.LegalTick >= (self.checkLegalIn or 0) then

		self.LegalTick = 0
		self.checkLegalIn = 5 + math.random(0,5) --Random checks every 5-10 seconds
		self:isLegal()

	end

	self.CurrentlyJamming = 0

	if self.Active and self.IsLegal and not self.OutOfEnergy then

		self.JamEnergy = math.max(self.JamEnergy - 2,0)

		if self.JamEnergy == 0 then
			self.OutOfEnergy = true
		end

		local thisPos = self:GetPos()

		scanEnt = ACE.radarEntities[self.JamID]

		if IsValid( scanEnt ) then

			--local radActive = scanEnt.Active
			local entpos = scanEnt:GetPos()

			local LOStr = util.TraceLine( {
				start = thisPos ,
				endpos = entpos,
				collisiongroup = COLLISION_GROUP_WORLD,
				filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end, --Hits anything in the world.
				mins = Vector(0,0,0),
				maxs = Vector(0,0,0)
				} )

			if not LOStr.Hit then --Trace did not hit world
				self.CurrentlyJamming = self.JamID
			end
		end
	else

		self.JamEnergy = math.min(self.JamEnergy + 1,100)

		if self.JamEnergy == 100 then
			self.OutOfEnergy = false
		end
	end

	if self.OutOfEnergy then
		WireLib.TriggerOutput( self, "Energy", 0 )
	else
		WireLib.TriggerOutput( self, "Energy", self.JamEnergy )
	end
end

function ENT:OnRemove()

end









