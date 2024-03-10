AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( _, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_rwr_dir" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self.ThinkDelay = 0.1

	self.Active = false
	curTime = 0

	self:SetModel( "models/missiles/radar_sml.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(165)

	self.Inputs = WireLib.CreateInputs( self, { "Active" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Radar ID [ARRAY]", "Angle [ARRAY]"} )

	self:SetActive(false)

	self.Cone = 45

	self.LegalTick = 0
	self.checkLegalIn = 50 + math.random(0,50) --Random checks every 5-10 seconds
	self.IsLegal = true
end

--ATGMs tracked
function ENT:isLegal()

	if self:GetPhysicsObject():GetMass() < 165 then return false end
	if not self:IsSolid() then return false end

	ACF_GetPhysicalParent(self)

	self.IsLegal = self.acfphysparent:IsSolid()

	return self.IsLegal

end



function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self:isLegal())
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

		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Angle", {} )
		WireLib.TriggerOutput( self, "Radar ID", {} )
	end

end

function ENT:Think()

	local curTime = CurTime()
	self:NextThink(curTime + self.ThinkDelay)

	self.LegalTick = (self.LegalTick or 0) + 1

	if	self.LegalTick >= (self.checkLegalIn or 0) then

		self.LegalTick = 0
		self.checkLegalIn = 50 + math.random(0,50) --Random checks every 5-10 seconds
		self:isLegal()
	end

	if self.Active and self.IsLegal then

		local ScanArray = ACE.radarEntities

		local thisPos = self:GetPos()
		local detected = 0
		local radIDs = {}
		local detAngs = {}
		local randinac = Angle(1 + math.Rand(-0.15,0.15),1 + math.Rand(-0.05,0.05),0)

		for _, scanEnt in pairs(ScanArray) do

			local entpos = scanEnt:GetPos()
			local difpos = (thisPos - entpos)

			if IsValid(scanEnt) then
				local radActive = scanEnt.Active

				if radActive then
					local nonlocang = (-difpos):Angle()
					local ang = scanEnt:WorldToLocalAngles(difpos:Angle())	--Used for testing if inrange
					local ang2 = self:WorldToLocalAngles(nonlocang)
					local absang = Angle(math.abs(ang.p),math.abs(ang.y),0) --Since I like ABS so much
					local absang2 = Angle(math.abs(ang2.p),math.abs(ang2.y),0) --Since I like ABS so much


					if absang.p < (scanEnt.Cone + 8)  and absang.y < (scanEnt.Cone + 8) and absang2.p < self.Cone and absang2.y < self.Cone then --Entity is within radar cone

						local LOStr = util.TraceLine( {
							start = thisPos ,
							endpos = entpos,collisiongroup = COLLISION_GROUP_WORLD,
							filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end, --Hits anything in the world.
							mins = Vector(0,0,0),
							maxs = Vector(0,0,0)
							} )

						if not LOStr.Hit then --Trace did not hit world

							detected = 1

							table.insert(radIDs,ACE.radarIDs[scanEnt])
							table.insert(detAngs, Angle(nonlocang.p * randinac.p, nonlocang.y * randinac.y, nonlocang.r * randinac.r) ) --3
						end
					end
				end
			end
		end

		WireLib.TriggerOutput( self, "Detected", detected )
		WireLib.TriggerOutput( self, "Radar ID", radIDs )
		WireLib.TriggerOutput( self, "Angle", detAngs )

	end
end
