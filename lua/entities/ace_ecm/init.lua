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

	self:SetModel( "models/missiles/minipod.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(1000)

	self.Inputs = WireLib.CreateInputs( self, { "Active", "JamDirection [VECTOR]", "JamPos [VECTOR]" } )
	self.Outputs = WireLib.CreateOutputs( self, {"JamCount"} )

	WireLib.TriggerOutput( self, "JamCount", 0 )

	--out radars jammed?
	self:SetActive(false)

	self.LegalTick = 0
	self.checkLegalIn = 5 + math.random(0,5) --Random checks every 5-10 seconds
	self.IsLegal = true

	self.CurrentlyJamming = 0
	self.JamDirection = vector_origin
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
	elseif inp == "JamDirection" then
		self.JamDirection = value
	elseif inp == "JamPos" then
		self.JamDirection = (value-self:GetPos()):GetNormalized()
	end

end

function ENT:SetActive(active)

	self.Active = active

	self:NextThink(curTime + 3) --ECM engaged, Warmup boot.

	if active  then
		local sequence = self:LookupSequence("active") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = true
	else
		local sequence = self:LookupSequence("idle") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = false
		self.CurrentlyJamming = 0
		WireLib.TriggerOutput( self, "JamCount", 0 )
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

	if self.Active and self.IsLegal then

		local thisPos = self:GetPos()


		for _, scanEnt in pairs(ACE.radarEntities) do

			--check if ent is valid
			if scanEnt:IsValid() then

				local entpos	= scanEnt:WorldSpaceCenter()

				local difpos	= (entpos - thisPos)

				local OffBoreAng = self.JamDirection:Angle()
				local ang	= difpos:Angle() - OffBoreAng	--Used for testing if inrange

				--local ang	= self:WorldToLocalAngles(difpos:Angle())	--Used for testing if inrange
				local absang	= Angle(math.abs(ang.p),math.abs(ang.y),0)  --Since I like ABS so much

				--Entity is within radar cone
				if (absang.p < 5 and absang.y < 5) then --5 degree jammer cone

					local LOStr = util.TraceLine( {

						start = thisPos ,endpos = entpos,
						collisiongroup = COLLISION_GROUP_WORLD,
						filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end,

					}) --Hits anything in the world.

					--Trace did not hit world
					if not LOStr.Hit then
						self.CurrentlyJamming = self.CurrentlyJamming + 1
						--ECM Beam width strength
						--Center beam 1x strength
						--1 axis off (90 deg) - 1/3x
						--2 axis off (180deg) - 1/6x
						local JamStrength = 1 / (1 + (absang.p / 5 + absang.y / 5) * 3)

						scanEnt.IsJammed			= 1
						scanEnt.JamStrength		= JamStrength
						scanEnt.JamDir				= -difpos:GetNormalized()

						--local JamID = ACE.radarIDs[scanEnt]

					end

				end

			end

		end
		WireLib.TriggerOutput( self, "JamCount", self.CurrentlyJamming )
	end
end

function ENT:OnRemove()

end









