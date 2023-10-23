AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS( "base_wire_entity" )

function ENT:Initialize()

	self.ThinkDelay			= 0.1
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= CurTime()
	self.Active				= false

	self.Heat				= 21
	self.IsJammed			= 0

	self.NextLegalCheck		= ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal				= true
	self.LegalIssues			= ""

	self.MinViewCone = 3
	self.MaxViewCone = 45

	self.ClosestToBeam		= -1

	self.Inputs = WireLib.CreateInputs( self, { "Active", "Cone" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam","IsJammed"} )
	self.OutputData = {
		Detected        = 0,
		Owner           = {},
		Position        = {},
		Velocity        = {},
		ClosestToBeam   = -1,
		IsJammed        = 0
	}

end

local function SetConeParameters( Radar )

	Radar.InaccuracyMul          = (0.035 * (Radar.Cone / 15) ^ 2) * 0.2
	Radar.DPLRFAC                = 65 - (Radar.Cone / 2)
	Radar.ConeInducedGCTRSize    = Radar.Cone * 10

end

function MakeACE_TrackingRadar(Owner, Pos, Angle, Id)

	if not Owner:CheckLimit("_acf_missileradar") then return false end

	Id = Id or "Large-TRACK"

	local radar = ACF.Weapons.Radars[Id]

	if not radar then return false end

	local Radar = ents.Create("ace_trackingradar")
	if not IsValid(Radar) then return false end

	Radar:SetAngles(Angle)
	Radar:SetPos(Pos)

	Radar.Model    = radar.model
	Radar.Weight   = radar.weight
	Radar.ACFName  = radar.name
	Radar.ICone    = radar.viewcone	--Note: intentional. --Recorded initial cone
	Radar.Cone     = Radar.ICone

	SetConeParameters( Radar )

	Radar.Id					= Id
	Radar.Class				= radar.class

	Radar:Spawn()

	Radar:CPPISetOwner(Owner)

	Radar:SetModelEasy(radar.model)

	Radar:SetNWString( "WireName", Radar.ACFName )

	Radar:UpdateOverlayText()

	Owner:AddCount( "_acf_missileradar", Radar )
	Owner:AddCleanup( "acfmenu", Radar )

	return Radar

end
list.Set( "ACFCvars", "ace_trackingradar", {"id"} )
duplicator.RegisterEntityClass("ace_trackingradar", MakeACE_TrackingRadar, "Pos", "Angle", "Id" )

function ENT:SetModelEasy(mdl)

	local Rack = self

	Rack:SetModel( mdl )
	Rack.Model = mdl

	Rack:PhysicsInit( SOLID_VPHYSICS )
	Rack:SetMoveType( MOVETYPE_VPHYSICS )
	Rack:SetSolid( SOLID_VPHYSICS )

	local phys = Rack:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(Rack.Weight)
	end

end

function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self.Legal)
	elseif inp == "Cone" then
		if value > 0 then

			self.Cone = math.Clamp(value / 2, self.MinViewCone ,self.MaxViewCone )

			SetConeParameters( self )

			local curTime = CurTime()
			self:NextThink(curTime + 10) --You are not going from a wide to narrow beam in half a second deal with it.
		else
			self.Cone = self.ICone
		end

		self:UpdateOverlayText()
	end
end

function ENT:SetActive(active)

	self.Active = active

	if active  then
		local sequence = self:LookupSequence("active") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = true
		self.Heat = 21 + 40
	else
		local sequence = self:LookupSequence("idle") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = false

		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Position", {} )
		WireLib.TriggerOutput( self, "Velocity", {} )
		WireLib.TriggerOutput( self, "ClosestToBeam", -1 )
		WireLib.TriggerOutput( self, "IsJammed", 0 )

		self.OutputData.Detected = 0
		self.OutputData.Owner = {}
		self.OutputData.Position = {}
		self.OutputData.Velocity = {}
		self.OutputData.ClosestToBeam = -1
		self.OutputData.IsJammed = 0

		self.Heat = 21
	end

end

function ENT:Think()

	local curTime = CurTime()
	self:NextThink(curTime + self.ThinkDelay)

	if ACF.CurTime > self.NextLegalCheck then

		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.Round(self.Weight,2), nil, true, true)
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		if not self.Legal then
			self.Active = false
			self:SetActive(false)
		end

	end

	if self.Active and self.Legal then

		local radID = ACE.radarIDs[self]
		self.IsJammed = 0
		for _, scanEnt in pairs(ACE.ECMPods) do

			if scanEnt.CurrentlyJamming == radID then
				self.IsJammed = 1
			end

		end

		WireLib.TriggerOutput( self, "IsJammed", self.IsJammed )
		self.OutputData.IsJammed = self.IsJammed

		if self.IsJammed <= 0 then

			--Get all ents collected by contraptionScan
			local ScanArray = ACE.contraptionEnts

			local thisPos	= self:GetPos()
			--local thisforward	= self:GetForward()
			local randinac	= Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))	--Using the same accuracy var for inaccuracy, what could possibly go wrong?
			local randinac2	= Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))	--Using one inaccuracy was boring

			local ownArray	= {}
			local posArray	= {}
			local velArray	= {}

			self.ClosestToBeam  = -1
			local besterr = math.huge --Hugh mungus number


			for _, scanEnt in pairs(ScanArray) do

				--check if ent is valid
				if scanEnt:IsValid() then

					--skip any flare from vision
					if scanEnt:GetClass() == "ace_flare" then continue end

					--skip the tracking itself
					if scanEnt:EntIndex() == self:EntIndex() then continue end

					--skip any parented entity
					if scanEnt:GetParent():IsValid() then continue end

					local entvel	= scanEnt:GetVelocity()
					local velLength = entvel:Length()
					local entpos	= scanEnt:WorldSpaceCenter()

					local difpos	= (entpos - thisPos)
					local ang	= self:WorldToLocalAngles(difpos:Angle())	--Used for testing if inrange
					local absang	= Angle(math.abs(ang.p),math.abs(ang.y),0)  --Since I like ABS so much

					--Doesn't want to see through peripheral vison since its easier to focus a radar on a target front and center of an array
					local errorFromAng = Vector(0.05 * (absang.y / self.Cone) ^ 2, 0.02 * (absang.y / self.Cone) ^ 2, 0.02 * (absang.p / self.Cone) ^ 2)

					--Entity is within radar cone
					if (absang.p < self.Cone and absang.y < self.Cone) then

						local LOStr = util.TraceLine( {

							start = thisPos ,endpos = entpos,
							collisiongroup = COLLISION_GROUP_WORLD,
							filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end,

						}) --Hits anything in the world.

						--Trace did not hit world
						if not LOStr.Hit then

							local DPLR
							local Espeed = entvel:Length()

							if Espeed > 0.5 then
								DPLR = self:WorldToLocal(thisPos + entvel * 2)
							else
								Espeed = 0
								DPLR = Vector(0.001,0.001,0.001)
							end

							--print(Espeed)

							local Dopplertest = math.min(math.abs(Espeed / math.abs(DPLR.Y)) * 100, 10000)
							local Dopplertest2 = math.min(math.abs(Espeed / math.abs(DPLR.Z)) * 100, 10000)

							--Also objects not coming directly towards the radar create more error.
							local DopplerERR = (((math.abs(DPLR.y) ^ 2 + math.abs(DPLR.z) ^ 2) ^ 0.5) / velLength / 2) * 0.1

							local GCtr = util.TraceHull( {

								start = entpos,
								endpos = entpos + difpos:GetNormalized() * 2000,
								collisiongroup  = COLLISION_GROUP_DEBRIS,
								filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end,
								mins = Vector( -self.ConeInducedGCTRSize, -self.ConeInducedGCTRSize, -self.ConeInducedGCTRSize ),
								maxs = Vector( self.ConeInducedGCTRSize, self.ConeInducedGCTRSize, self.ConeInducedGCTRSize )

							}) --Hits anything in the world.

							--returns amount of ground clutter
							if not GCtr.HitSky then
								GCdis = (1-GCtr.Fraction)
								GCFr = GCtr.Fraction
							else
								--returns amount of ground clutter
								GCdis = 0
								GCFr = 1
							end

							--print(GCdis)
							--if GCdis <= 0.5 then --Get canceled by ground clutter

							--Qualifies as radar target, if a target is moving towards the radar at 30 mph the radar will also classify the target
							if ( (Dopplertest < self.DPLRFAC) or (Dopplertest2 < self.DPLRFAC) or (math.abs(DPLR.X) > 880) ) and ( (math.abs(DPLR.X / (Espeed + 0.0001)) > 0.3) or (GCFr >= 0.4) ) then
								--1000 u = ~57 mph

								--Could do pythagorean stuff but meh, works 98% of time
								local err = absang.p + absang.y

								--Sorts targets as closest to being directly in front of radar
								if err < besterr then
									self.ClosestToBeam = #ownArray + 1
									besterr = err
								end

								--For Owner table
								local Owner = scanEnt:CPPIGetOwner()
								local NickName = IsValid(Owner) and Owner:GetName() or ""

								table.insert(ownArray , NickName)
								table.insert(posArray ,entpos + randinac * errorFromAng * 2000 + randinac * ((entpos - thisPos):Length() * (self.InaccuracyMul * 0.8 + GCdis * 0.1 ))) --3

								--IDK if this is more intensive than length
								local finalvel = Vector(0,0,0)

								if Espeed > 0 then
									finalvel = entvel + velLength * ( randinac * errorFromAng + randinac2 * (DopplerERR + GCFr * 0.03) )
									finalvel = Vector(math.Clamp(finalvel.x,-7000,7000),math.Clamp(finalvel.y,-7000,7000),math.Clamp(finalvel.z,-7000,7000))
								end

								table.insert(velArray,finalvel)

							end
						end
					end
				end


			end

			--self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam"} )

			--Some entity passed the test to be valid
			if self.ClosestToBeam ~= -1 then

				WireLib.TriggerOutput( self, "Detected", 1 )
				WireLib.TriggerOutput( self, "Owner", ownArray )
				WireLib.TriggerOutput( self, "Position", posArray )
				WireLib.TriggerOutput( self, "Velocity", velArray )
				WireLib.TriggerOutput( self, "ClosestToBeam", self.ClosestToBeam )

				self.OutputData.Detected = 1
				self.OutputData.Owner = ownArray
				self.OutputData.Position = posArray
				self.OutputData.Velocity = velArray
				self.OutputData.ClosestToBeam = self.ClosestToBeam

			else --Nothing detected
				WireLib.TriggerOutput( self, "Detected", 0 )
				WireLib.TriggerOutput( self, "Owner", {} )
				WireLib.TriggerOutput( self, "Position", {} )
				WireLib.TriggerOutput( self, "Velocity", {} )
				WireLib.TriggerOutput( self, "ClosestToBeam", -1 )

				self.OutputData.Detected = 0
				self.OutputData.Owner = {}
				self.OutputData.Position = {}
				self.OutputData.Velocity = {}
				self.OutputData.ClosestToBeam = -1
			end
		end
	end

	if (self.LastStatusUpdate + self.StatusUpdateDelay < curTime) then
		self:UpdateStatus()
		self.LastStatusUpdate = curTime
	end

	self:UpdateOverlayText()

end

function ENT:UpdateStatus()
		self.Status = self.Active and "On" or "Off"
end

function ENT:UpdateOverlayText()

	local cone	= self.Cone
	local status	= self.Status or "Off"
	local detected  = status ~= "Off" and self.ClosestToBeam ~= -1 or false
	local Jammed	= self.IsJammed

	local txt = "Status: " .. status

	txt = txt .. "\n\nView Cone: " .. math.Round(cone * 2, 2) .. " deg"

	--txt = txt .. "\nMax Range: " .. (isnumber(range) and math.Round(range / 39.37 , 2) .. " m" or "Unlimited" )

	if detected then
		txt = txt .. "\n\nTarget Detected!"
	end

	if Jammed > 0 then
		txt = txt .. "\n\nWarning: Jammed"
	end

	if not self.Legal then
	txt = txt .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText(txt)

end
