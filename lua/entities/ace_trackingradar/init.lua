AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self.ThinkDelay = 0.1

	self.Active = false
	curTime = 0

	self:SetModel( "models/missiles/radar_big.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(600)

	self.Inputs = WireLib.CreateInputs( self, { "Active", "Cone" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam","IsJammed"} )

	self:SetActive(false)

	self.Cone = 15
	self.InaccuracyMul = (0.035 * (self.Cone/15)^0.6)*0.2 
	self.DPLRFAC = 65-(self.Cone/2)
	
	self.Heat = 21

	self.LegalTick = 0
	self.checkLegalIn = 50+math.random(0,50) --Random checks every 5-10 seconds
	self.IsLegal = true
end

--ATGMs tracked

function ENT:isLegal()

	if self:GetPhysicsObject():GetMass() < 600 then return false end
	if not self:IsSolid() then return false end

	ACF_GetPhysicalParent(self)
	
	self.IsLegal = self.acfphysparent:IsSolid()

	return self.IsLegal

end



function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self:isLegal())
	end
	if inp == "Cone" then
		self.Cone = math.Clamp(value,3,30)
		local curTime = CurTime()	
		self:NextThink(curTime + 10) --You are not going from a wide to narrow beam in half a second deal with it.
		self.InaccuracyMul = (0.035 * (self.Cone/15)^0.6)*0.2     -- +/- 5.3% 30 deg, +/- 1.3% 3 deg, +/- 3.5% 15 deg
		self.DPLRFAC = 65-(self.Cone/2)
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
		self.Heat = 21
	end

end

function ENT:Think()

	local curTime = CurTime()	
	self:NextThink(curTime + self.ThinkDelay)

self.LegalTick = (self.LegalTick or 0) + 1

if 	self.LegalTick >= (self.checkLegalIn or 0) then
	
self.LegalTick = 0
self.checkLegalIn = 50+math.random(0,50) --Random checks every 5-10 seconds
self:isLegal()

end

if self.Active and self.IsLegal then


--	ACE.ECMPods
	local radID = ACE.radarIDs[self]
	local beingjammed = 0
	for k, scanEnt in pairs(ACE.ECMPods) do

		if scanEnt.CurrentlyJamming == radID then
			beingjammed = 1
		end

	end

	WireLib.TriggerOutput( self, "IsJammed", beingjammed )

if beingjammed < 1 then

--	local ScanArray = player.GetAll() --For testing
--	local ScanArray = ents.FindByClass( "prop_vehicle_prisoner_pod" ) 
	local ScanArray = ACE.contraptionEnts

	local thisPos = self:GetPos()
	local thisforward = self:GetForward()
	local randinac = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) --Using the same accuracy var for inaccuracy, what could possibly go wrong?
	local randinac2 = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) --Using one inaccuracy was boring

	local ownArray = {}
	local posArray = {}
	local velArray = {}

	local testClosestToBeam = -1
	local besterr = math.huge --Hugh mungus number


	for k, scanEnt in pairs(ScanArray) do

		if(IsValid(scanEnt))then

--			if (scanEnt.THeat or 0) > 0 then
--				print(scanEnt.THeat)

--			end

			local entvel = scanEnt:GetVelocity() --Test on parented props
			local velLength = entvel:Length()

			local entpos = scanEnt:WorldSpaceCenter()

			local difpos = (entpos - thisPos)
			local ang = self:WorldToLocalAngles(difpos:Angle())	--Used for testing if inrange
			local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much

				--Doesn't want to see through peripheral vison since its easier to focus a radar on a target front and center of an array
			local errorFromAng = Vector(0.05*(absang.y/self.Cone)^2,0.02*(absang.y/self.Cone)^2,0.02*(absang.p/self.Cone)^2)    

			if (absang.p < self.Cone and absang.y < self.Cone) then --Entity is within radar cone

				local LOStr = util.TraceLine( {start = thisPos ,endpos = entpos,collisiongroup = COLLISION_GROUP_WORLD,filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end}) --Hits anything in the world.

				if not LOStr.Hit then --Trace did not hit world
					
					local DPLR = self:WorldToLocal(thisPos+entvel*2)
					local Dopplertest = math.min(math.abs( entvel:Length()/math.max(math.abs(DPLR.Y),0.01))*100,10000)
					local Dopplertest2 = math.min(math.abs(entvel:Length()/math.max(math.abs(DPLR.Z),0.01))*100,10000)

				--Also objects not coming directly towards the radar create more error.
					local DopplerERR = (((math.abs(DPLR.y)^2+math.abs(DPLR.z)^2)^0.5)/velLength/2)*0.1

					local GCtr = util.TraceLine( {start = entpos, endpos = entpos + difpos:GetNormalized() * 1000 ,collisiongroup  = COLLISION_GROUP_DEBRIS}) --Hits anything in the world.
					local GCdis = (1-GCtr.Fraction) --returns amount of ground clutter
--					print(GCtr.Fraction)
--					if GCdis <= 0.5 then --Get canceled by ground clutter

					if (Dopplertest < self.DPLRFAC or Dopplertest2 < self.DPLRFAC or (math.abs(DPLR.X) > 880) ) and ( (math.abs(DPLR.X/entvel:Length()) > 0.3) or (GCdis <= 0.5) ) then --Qualifies as radar target, if a target is moving towards the radar at 30 mph the radar will also classify the target.
						--1000 u = ~57 mph


							local err = absang.p + absang.y --Could do pythagorean stuff but meh, works 98% of time

							if err < besterr then --Sorts targets as closest to being directly in front of radar
								testClosestToBeam = k
								besterr = err
							end
						--print((entpos - thisPos):Length())
						ownArray[k] = scanEnt:CPPIGetOwner():GetName() or scanEnt:GetOwner():GetName() or ""

						posArray[k] = entpos + randinac * errorFromAng*2000 + randinac * ((entpos - thisPos):Length() * (self.InaccuracyMul * 0.4 + GCdis*0.1 )) --3 

						velArray[k] = entvel + velLength * ( randinac * errorFromAng + randinac2 * (DopplerERR + GCdis*0.05) )
						velArray[k] = Vector(math.Clamp(velArray[k].x,-7000,7000),math.Clamp(velArray[k].y,-7000,7000),math.Clamp(velArray[k].z,-7000,7000))

						if math.abs(velArray[k].x) >= 7000 or math.abs(velArray[k].y) >= 7000 or math.abs(velArray[k].z) >= 7000 then --IDK if this is more intensive than length
						velArray[k] = Vector(0,0,0)
						end

					end

				else
--					print(LOStr.SurfaceFlags)
--					print(LOStr.Entity )
				end

			end

		end
	end

--	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam"} )

	if testClosestToBeam != -1 then --Some entity passed the test to be valid

		WireLib.TriggerOutput( self, "Detected", 1 )
		WireLib.TriggerOutput( self, "Owner", ownArray )
		WireLib.TriggerOutput( self, "Position", posArray )
		WireLib.TriggerOutput( self, "Velocity", velArray )
		WireLib.TriggerOutput( self, "ClosestToBeam", testClosestToBeam )		

	else --Nothing detected
		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Position", {} )
		WireLib.TriggerOutput( self, "Velocity", {} )
		WireLib.TriggerOutput( self, "ClosestToBeam", -1 )	
	end

	end
end

end


function ENT:OnRemove()

end









