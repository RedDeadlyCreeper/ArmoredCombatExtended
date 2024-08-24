AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS( "base_wire_entity" )

function ENT:Initialize()

	self.ThinkDelay			= 0.1
	self.LastThink			= 0
	self.ResetJamDelay		= 0.45 --Periodically resets jamming strength to zero for the jammer to apply the highest noise available. This means the jamming won't always remain at full strength without a lot of networking.
	self.NextJamCheck		= 0
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= ACF.CurTime
	self.Active				= false

	self.Heat				= 21
	self.IsJammed			= 0
	self.JamStrength		= 0
	self.JamDir				= vector_origin

	self.NextLegalCheck		= ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal				= true
	self.LegalIssues			= ""

	--self.MaxElev		= 80
	--self.MinElev		= -20

	self.CurrentScanAngle = 0
	--self.RadarPitchRange		= (self.MaxElev - self.MinElev) / 2

	self.ClosestToBeam		= -1

	self.AcquiredTargets		= {}

	self.Inputs = WireLib.CreateInputs( self, { "Active", "Cone" } )
	self.Outputs = WireLib.CreateOutputs( self, {"LocalSweepAngle","Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam", "IsJammed", "JamDirection [VECTOR]"} )
	self.OutputData = {
		LocalSweepAngle = 0,
		Detected        = 0,
		Owner           = {},
		Position        = {},
		Velocity        = {},
		ClosestToBeam   = -1,
		IsJammed        = 0,
		JamDirection    = vector_origin
	}

end

local function SetConeParameters( Radar )

	Radar.ConeInducedGCTRSize    = Radar.Cone * 10

end

function MakeACE_SearchRadar(Owner, Pos, Angle, Id)

	if not Owner:CheckLimit("_acf_missileradar") then return false end

	Id = Id or "Large-SEARCH"

	local radar = ACF.Weapons.Radars[Id]

	if not radar then return false end

	local Radar = ents.Create("ace_searchradar")
	if not IsValid(Radar) then return false end

	Radar:SetAngles(Angle)
	Radar:SetPos(Pos)

	Radar.Model    = radar.model
	Radar.Weight   = radar.weight
	Radar.ACFName  = radar.name
	Radar.ICone    = radar.viewcone	--Note: intentional. --Recorded initial cone
	Radar.Cone     = Radar.ICone
	Radar.PowerID     = radar.powerid
	Radar.AnimationRate     = radar.animspeed
	Radar.ACEPoints		= radar.acepoints or 0.9

	Radar.InaccuracyMul          = (0.035 * (Radar.ICone / 15) ^ 2) * 0.2
	Radar.DPLRFAC                = 65 - (Radar.ICone / 2)

	Radar.Burnthrough = radar.burnthrough

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
list.Set( "ACFCvars", "ace_searchradar", {"id"} )
duplicator.RegisterEntityClass("ace_searchradar", MakeACE_SearchRadar, "Pos", "Angle", "Id" )

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

		local curTime = CurTime()
		self.LastThink = ACF.CurTime
		self:NextThink(curTime + 3) --Radar takes a moment to power up. Used to prevent radar flickering to avoid ECM.
	elseif inp == "Cone" then
		if value > 0 then

			self.Cone = math.Clamp(value / 2, 1 ,self.ICone )

			SetConeParameters( self )

			local curTime = CurTime()
			self:NextThink(curTime + 3) --Switching beam width will take time. This is to balance jamming.
		else
			self.Cone = self.ICone
		end

		self:UpdateOverlayText()
	end
end

function ENT:SetActive(active)

	self.Active = active
	self.AcquiredTargets		= {}

	if active  then
		local sequence = self:LookupSequence("active") or 0
		self:ResetSequence(sequence)
		self:SetPlaybackRate( self.AnimationRate )
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
		WireLib.TriggerOutput( self, "Velocity", vector_origin )

		self.OutputData.Detected = 0
		self.OutputData.Owner = {}
		self.OutputData.Position = {}
		self.OutputData.Velocity = {}
		self.OutputData.ClosestToBeam = -1
		self.OutputData.IsJammed = 0

		self.Heat = 21
	end

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

txt = txt .. "\n\nRotation Rate: " .. math.Round(cone, 2) .. " deg/s"
--txt = txt .. "\nElevation: +" .. math.Round(self.MaxElev, 2) .. " / " .. math.Round(self.MinElev, 2) .. " degrees"

txt = txt .. "\n\n360 Sweep Time: " .. math.Round(360 / cone, 2) .. " sec"

--txt = txt .. "\nMax Range: " .. (isnumber(range) and math.Round(range / 39.37 , 2) .. " m" or "Unlimited" )

if Jammed > 0 then
	txt = txt .. "\n\n! ! ! Warning: Jammed ! ! !"
end
if detected then
	txt = txt .. "\n\nTarget Detected!"
end

if not self.Legal then
txt = txt .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
end


txt = txt .. "\nTemp: " .. math.Round(self.Heat) .. "C / " .. math.Round((self.Heat * (9 / 5)) + 32) .. "F"

self:SetOverlayText(txt)

end


function ENT:Think()
	local curTime = ACF.CurTime

	local DeltaTime = curTime - self.LastThink


	self:NextThink(curTime + self.ThinkDelay)

	if ACF.CurTime > self.NextLegalCheck then

		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.Round(self.Weight, 2), nil, true, true)
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		if not self.Legal then
			self.Active = false
			self:SetActive(false)
		end

	end

	if self.Active and self.Legal then

		self.CurrentScanAngle = self.CurrentScanAngle + self.Cone * DeltaTime
		if self.CurrentScanAngle >= 360 then self.CurrentScanAngle = math.min(self.CurrentScanAngle - 360, 360) end

		--local radID = ACE.radarIDs[self]

		WireLib.TriggerOutput( self, "IsJammed", self.IsJammed )
		self.OutputData.IsJammed = self.IsJammed

			--Get all ents collected by contraptionScan
			local ScanArray = ACE.contraptionEnts

			local thisPos	= self:GetPos()
			--local thisforward	= self:GetForward()
			--local randinac	= Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))	--Using the same accuracy var for inaccuracy, what could possibly go wrong?

			local ownArray	= {}
			local posArray	= {}
			local velArray	= {}
			self.AcquiredTargets		= {}

			self.ClosestToBeam  = -1
			local besterr = math.huge --Hugh mungus number


			for _, scanEnt in pairs(ScanArray) do

				--check if ent is valid
				if scanEnt:IsValid() then

					--skip the tracking itself
					if scanEnt:EntIndex() == self:EntIndex() then continue end --Wouldn't be needed with CFRAME

					--skip any parented entity
					if scanEnt:GetParent():IsValid() then continue end --Wouldn't be needed with CFRAME

					local entvel	= scanEnt:GetVelocity()
					local entpos	= scanEnt:WorldSpaceCenter()

					local difpos	= (entpos - thisPos)
					local entdistance  = difpos:Length()

					local ang	=  self:WorldToLocalAngles(difpos:Angle())  - Angle(0, -self.CurrentScanAngle, 0)	--Used for testing if inrange

					local absang	= Angle(math.abs(math.NormalizeAngle(ang.p)), math.abs(math.NormalizeAngle(ang.y)), 0)  --Since I like ABS so much

					--Entity is within radar cone

					if (absang.y < self.Cone / 4) then
					--if (absang.p < 180 and absang.y < self.Cone / 2) then

						if self.IsJammed ~= 0 and ((self.Burnthrough * 3937) / self.JamStrength < entdistance) then continue end --39.37 * 1000 from burnthrough factor to convert to meters.

						local LOStr = util.TraceLine( {

							start = thisPos ,endpos = entpos,
							collisiongroup = COLLISION_GROUP_WORLD,
							filter = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end,

						}) --Hits anything in the world.

						--Trace did not hit world
						if not LOStr.Hit then

							local DPLR
							local Espeed = entvel:Length()

							if Espeed > 0.5 then --Target is moving, test for doppler.
								DPLR = self:WorldToLocal(thisPos + entvel * 2) --Gets velocity of target in line with radar
							else
								Espeed = 0
								DPLR = Vector(0.001,0.001,0.001)
							end

							--0.6 ratio fails test.
							local Dopplertest = math.min(math.abs(Espeed / math.abs(DPLR.Y)) * 100, 10000) --Side to side speed ratio. If all speed is up ratio is 0.5, half 1.0, quarter, 2.0, etc. x100.
							local Dopplertest2 = math.min(math.abs(Espeed / math.abs(DPLR.Z)) * 100, 10000) --Vertical speed ratio.

							local GCtr = util.TraceHull( { --  Ground clutter trace

								start = entpos,
								endpos = entpos + difpos:GetNormalized() * 8000,
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

							--Tests if radar target. If it doesn't pass a ground clutter check, do a pulse doppler test.
							--DPLRFAC is 60 on large radar. Requiring a dopplertest below that.
							--On DPLRFAC X term, if a target is moving away or towards the radar at 50 mph the radar will also classify the target
							if (GCFr >= 0.4) or (( (Dopplertest < self.DPLRFAC) or (Dopplertest2 < self.DPLRFAC) or (math.abs(DPLR.X) > 880) ) and ( math.abs(DPLR.X / (Espeed + 0.0001)) > 0.3 )) then


								--Chaff can be used to gunk up radars.
								local Multiplier = 1

								if scanEnt:GetClass() == "ace_flare" then
									Multiplier = scanEnt.RadarSig
								end

								--Could do pythagorean stuff but meh, works 98% of time
								local err = absang.p + absang.y

								local BaseInacc = VectorRand()  * ( entdistance / 50 ) --39.37 cancels out.

								--For Owner table
								local Owner = scanEnt:CPPIGetOwner()
								local NickName = IsValid(Owner) and Owner:GetName() or ""

								err = err * Multiplier

								--Sorts targets as closest to being directly in front of radar
								if err < besterr then
									self.ClosestToBeam = #ownArray + 1
									besterr = err
								end

								table.insert(ownArray , NickName)
								table.insert(posArray ,entpos + BaseInacc ) --3 --Inaccuracy goes hereValidTargets
								table.insert(self.AcquiredTargets , scanEnt)

								--IDK if this is more intensive than length
								local finalvel = Vector(0, 0, 0)

								if Espeed > 0.5 then
									finalvel = entvel
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

	if (self.LastStatusUpdate + self.StatusUpdateDelay < curTime) then
		self:UpdateStatus()
		self.LastStatusUpdate = curTime
	end

	WireLib.TriggerOutput( self, "JamDirection", self.JamDir )
	self:UpdateOverlayText()

	if self.IsJammed ~= 0 and ACF.CurTime > self.NextJamCheck then
		self.NextJamCheck = ACF.CurTime + self.ResetJamDelay

		--Reset everything for next check
		self.IsJammed			= 0
		self.JamStrength		= 0
		self.JamDir				= vector_origin

	end

	WireLib.TriggerOutput( self, "LocalSweepAngle", self.CurrentScanAngle )

	self.LastThink = curTime

	return true  --Needed for think delay override
end
