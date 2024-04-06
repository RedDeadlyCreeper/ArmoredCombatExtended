AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( _, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_rwr_sphere" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self.ThinkDelay = 0.1
	self.Weight = 65

	self.Active = false
	self.Detected = 0

	self:SetModel( "models/maxofs2d/hover_basic.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(self.Weight)

	self.Inputs = WireLib.CreateInputs( self, { "Active" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected"} )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Radar ID [ARRAY]", "Radar Power [ARRAY]"} )

	self:SetActive(false)

	self.NextLegalCheck	= ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal = true
	self.LegalIssues = ""
end

--ATGMs tracked

function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self.Legal)
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
		WireLib.TriggerOutput( self, "Radar ID", {} )
		WireLib.TriggerOutput( self, "Radar Power", {} )
	end

end

function ENT:Think()

	local curTime = ACF.CurTime
	self:NextThink(curTime + self.ThinkDelay)

	if ACF.CurTime > self.NextLegalCheck then

		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.Round(self.Weight, 2), nil, true, true)
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

	end

	if self.Active and self.Legal then

		local ScanArray = ACE.radarEntities
		local thisPos = self:GetPos()
		local detected = 0
		local radIDs = {}
		local radPOWs = {}


		for _, scanEnt in pairs(ScanArray) do

			if IsValid(scanEnt) then

				local entpos = scanEnt:GetPos()
				local difpos = (thisPos - entpos)
				local radActive = scanEnt.Active

				if radActive then
					local ang = angle_zero
					local absang = angle_zero

					local Eclass = scanEnt:GetClass()

					if Eclass == "acf_missileradar" then continue end

					local ScanCone1 = 5
					local ScanCone2 = 5

					if scanEnt:GetClass() ~= "ace_searchradar" then
						ang = scanEnt:WorldToLocalAngles(difpos:Angle())	--Used for testing if inrange
						absang = Angle(math.abs(ang.p), math.abs(ang.y), 0) --Since I like ABS so much

						ScanCone1 = scanEnt.Cone or 0
						ScanCone2 = scanEnt.Cone or 0
					else --Search radar
						ang	=  scanEnt:WorldToLocalAngles(difpos:Angle())  - Angle(0, scanEnt.CurrentScanAngle, 0)	--Used for testing if inrange
						--absang	= Angle(math.abs(math.NormalizeAngle(ang.p)),math.abs(math.NormalizeAngle(ang.y)), 0)  --Since I like ABS so much
						absang	= Angle(0,math.abs(math.NormalizeAngle(ang.y)), 0)  --Because elevation limits are disabled on search radars
						ScanCone1 = 99999
						ScanCone2 = scanEnt.Cone / 4
					end

					--if (absang.p < ScanCone and absang.y < ScanCone) then --Entity is within radar cone

					if (absang.p < ScanCone1 and absang.y < ScanCone2) then --Entity is within radar cone

						local LOStr = util.TraceLine( {
							start = thisPos,
							endpos = entpos,
							collisiongroup = COLLISION_GROUP_WORLD,
							filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end, --Hits anything in the world.
							mins = Vector(0, 0, 0),
							maxs = Vector(0, 0, 0)
							} )

						if not LOStr.Hit then --Trace did not hit world
							detected = 1

							table.insert(radIDs,ACE.radarIDs[scanEnt])
							table.insert(radPOWs,scanEnt.PowerID or 0)
						end
					end
				end
			end
		end

		self.Detected = detected
		WireLib.TriggerOutput( self, "Detected", detected )
		WireLib.TriggerOutput( self, "Radar ID", radIDs )
		WireLib.TriggerOutput( self, "Radar Power", radPOWs )
	end

	self:UpdateOverlayText()

	return true
end

function ENT:UpdateOverlayText()

	local Active = self.Active
	local Detected = self.Detected
	local str = string.format("Active: %s\nDetected: %s", Active, Detected)

	if not self.Legal then
		str = str .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText(str)
end