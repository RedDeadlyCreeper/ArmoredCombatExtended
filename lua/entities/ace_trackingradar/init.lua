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

	self.Cone = 15 --30 degree default cone
	self.InaccuracyMul = (0.035 * (self.Cone/15)^2)*0.2 
	self.DPLRFAC = 65-(self.Cone/2)
	
	self.Heat = 21

	self.LegalTick = 0
	self.checkLegalIn = 50+math.random(0,50) --Random checks every 5-10 seconds
	self.IsLegal = true
	self.ConeInducedGCTRSize = self.Cone * 10
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
		self.Cone = math.Clamp(value/2,3,45)
		local curTime = CurTime()	
		self:NextThink(curTime + 10) --You are not going from a wide to narrow beam in half a second deal with it.
		self.InaccuracyMul = (0.035 * (self.Cone/15)^2)*0.2     -- +/- 5.3% 30 deg, +/- 1.3% 3 deg, +/- 3.5% 15 deg
		self.DPLRFAC = 90-(self.Cone/2)
		self.ConeInducedGCTRSize = self.Cone * 10
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

	    local radID = ACE.radarIDs[self]
	    local beingjammed = 0
	    for k, scanEnt in pairs(ACE.ECMPods) do

		    if scanEnt.CurrentlyJamming == radID then
		    	beingjammed = 1
		    end

	    end

	    WireLib.TriggerOutput( self, "IsJammed", beingjammed )

        if beingjammed < 1 then

        	--Get all ents collected by contraptionScan
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

	        	--check if ent is valid
		        if scanEnt:IsValid() then

		        	--skip any flare from vision
		        	if scanEnt:GetClass() == 'ace_flare' then goto cont end

		        	--skip the tracking itself
		        	if scanEnt:EntIndex() == self:EntIndex() then goto cont end

		        	--skip any parented entity
		        	if scanEnt:GetParent():IsValid() then goto cont end

			        local entvel = scanEnt:GetVelocity()
			        local velLength = entvel:Length()
			        local entpos = scanEnt:WorldSpaceCenter()

			        local difpos = (entpos - thisPos)
			        local ang = self:WorldToLocalAngles(difpos:Angle())	--Used for testing if inrange
			        local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much

				    --Doesn't want to see through peripheral vison since its easier to focus a radar on a target front and center of an array
			        local errorFromAng = Vector(0.05*(absang.y/self.Cone)^2,0.02*(absang.y/self.Cone)^2,0.02*(absang.p/self.Cone)^2)    

					--Entity is within radar cone
			        if (absang.p < self.Cone and absang.y < self.Cone) then

				        local LOStr = util.TraceHull( {
					
					        start = thisPos ,endpos = entpos,
					        collisiongroup = COLLISION_GROUP_WORLD, 
					        filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end,
					        mins = Vector( -0, -0, -0 ),
					        maxs = Vector( 0, 0, 0 )
						
				        }) --Hits anything in the world.

						--Trace did not hit world
				        if not LOStr.Hit then 
					
					        local DPLR
					        local Espeed = entvel:Length()
						
					        if Espeed > 0.5 then
						        DPLR = self:WorldToLocal(thisPos+entvel*2)
					        else
						        Espeed = 0
						        DPLR = Vector(0.001,0.001,0.001)
					        end
					
					        --print(Espeed)

					        local Dopplertest = math.min(math.abs( Espeed/math.abs(DPLR.Y))*100,10000)
					        local Dopplertest2 = math.min(math.abs( Espeed/math.abs(DPLR.Z))*100,10000)

				            --Also objects not coming directly towards the radar create more error.
					        local DopplerERR = (((math.abs(DPLR.y)^2+math.abs(DPLR.z)^2)^0.5)/velLength/2)*0.1

					        local GCtr = util.TraceHull( {
						
						        start = entpos,
						        endpos = entpos + difpos:GetNormalized() * 2000,
						        collisiongroup  = COLLISION_GROUP_DEBRIS,
						        filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end,
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
					        if ( (Dopplertest < self.DPLRFAC) or (Dopplertest2 < self.DPLRFAC) or (math.abs(DPLR.X) > 880) ) and ( (math.abs(DPLR.X/(Espeed+0.0001)) > 0.3) or (GCFr >= 0.4) ) then 
						        --1000 u = ~57 mph

						        --Could do pythagorean stuff but meh, works 98% of time
							    local err = absang.p + absang.y 

							    --Sorts targets as closest to being directly in front of radar
							    if err < besterr then 
								    testClosestToBeam = table.getn( ownArray ) + 1
								    besterr = err
							    end
						        --print((entpos - thisPos):Length())
							
						        table.insert(ownArray, CPPI and scanEnt:CPPIGetOwner():GetName() or scanEnt:GetOwner():GetName() or "")
						        table.insert(posArray,entpos + randinac * errorFromAng*2000 + randinac * ((entpos - thisPos):Length() * (self.InaccuracyMul * 0.8 + GCdis*0.1 ))) --3 

							    --IDK if this is more intensive than length
							    local finalvel = Vector(0,0,0)

						        if Espeed > 0 then
							        finalvel = entvel + velLength * ( randinac * errorFromAng + randinac2 * (DopplerERR + GCFr*0.03) )
							        finalvel = Vector(math.Clamp(finalvel.x,-7000,7000),math.Clamp(finalvel.y,-7000,7000),math.Clamp(finalvel.z,-7000,7000))
						        end
							
						        table.insert(velArray,finalvel)
					        else
						        --print("DopplerFail")
					        end

				        else
					        --print(LOStr.SurfaceFlags)
					        --print(LOStr.Entity )
				        end

			        end

		        end

		        ::cont::
	        end

	        --self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam"} )

			--Some entity passed the test to be valid
	        if testClosestToBeam != -1 then 

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









