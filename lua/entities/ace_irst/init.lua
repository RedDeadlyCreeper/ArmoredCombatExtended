AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( ply, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_irst" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self.ThinkDelay = 0.1

	self.Active = false

	self:SetModel( "models/props_lab/monitor01b.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(400)

	self.Inputs = WireLib.CreateInputs( self, { "Active" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Angle [ARRAY]", "EffHeat [ARRAY]", "ClosestToBeam"} )

	self:SetActive(false)

	self.SeekSensitivity = 1

	--How many degrees above Ambient Temperature this irst will start to track?
	self.HeatAboveAmbient = 5

	--120 degree forward facing cone
	self.Cone = 45 
	
	--Heat
	self.Heat = 21

	self.LegalTick = 0
	self.checkLegalIn = 50+math.random(0,50) --Random checks every 5-10 seconds
	self.IsLegal = true
end

--ATGMs tracked

function ENT:isLegal()

	if self:GetPhysicsObject():GetMass() < 400 then return false end
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
		self.Heat = 21 + 40
	else
		local sequence = self:LookupSequence("idle") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = false

		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Angle", {} )
		WireLib.TriggerOutput( self, "EffHeat", {} )
		WireLib.TriggerOutput( self, "ClosestToBeam", -1 )	
		self.Heat = 21
	end

end

function ENT:Think()

	local curTime = CurTime()	
	self:NextThink(curTime + self.ThinkDelay)

	self.LegalTick = (self.LegalTick or 0) + 1

	if self.LegalTick >= (self.checkLegalIn or 0) then
	
		self.LegalTick = 0
		self.checkLegalIn = 50+math.random(0,50) --Random checks every 5-10 seconds
		self:isLegal()

	end

	if self.Active and self.IsLegal then

		--Get all collected ents from contraptionScan
		local ScanArray = ACE.contraptionEnts

		local thisPos = self:GetPos()
		local randinac = math.Rand(-2,2) --Using the same accuracy var for inaccuracy, what could possibly go wrong?

		--Table definition
		local OwnerTable = {}
		local effHeatTable = {}
		local posTable = {}

		local testClosestToBeam = -1
		local besterr = math.huge --Hugh mungus number

		for k, scanEnt in pairs(ScanArray) do

			--check if it's valid
			if scanEnt:IsValid() then

				--Why IRST should track itself?
				if scanEnt:EntIndex() == self:EntIndex() then goto cont end

				local entpos = scanEnt:WorldSpaceCenter()
				local difpos = (entpos - thisPos)

				local nonlocang = difpos:Angle()
				local ang = self:WorldToLocalAngles(nonlocang)	--Used for testing if inrange
				local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much

				--Doesn't want to see through peripheral vison since its easier to focus a seeker on a target front and center of an array
				local errorFromAng = 0.01*(absang.y/90)^2+0.01*(absang.y/90)^2+0.01*(absang.p/90)^2 

				if (absang.p < self.Cone and absang.y < self.Cone) then --Entity is within seeker cone
					--print(scanEnt:GetModel()..' is in cone!')

					--Hits anything in the world.
					local LOStr = util.TraceLine( {
							start = thisPos ,
							endpos = entpos,
							collisiongroup = COLLISION_GROUP_WORLD,
							filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end	
						}) 

					--Trace did not hit world
					if not LOStr.Hit then
						--print(scanEnt:GetModel()..' is in sight!')


						--if the target is a Heat Emitter, track its heat
		    			if scanEnt.Heat then
		    				print(scanEnt:GetModel()..' is Heat emitter!')
			    
			    			Heat = self.SeekSensitivity * scanEnt.Heat 
			
						--if is not a Heat Emitter, track the friction's heat			
		    			else

			    			local physEnt = scanEnt:GetPhysicsObject()
		
							--skip if it has not a valid physic object. It's amazing how gmod can break this. . .
							if physEnt:IsValid() then  	
							--check if it's not frozen. If so, skip it, unmoveable stuff should not be even considered
                    			if not physEnt:IsMoveable() then goto cont end
                			end

							local dist = difpos:Length()				
							Heat = ACE_InfraredHeatFromProp( self, scanEnt , dist )

							--print(scanEnt:GetModel()..' is '..Heat..'°c')
			
		    			end
				
						if Heat <= ACE.AmbientTemp + self.HeatAboveAmbient then goto cont end --Hotter than 50 deg C
						--1000 u = ~57 mph

						--Could do pythagorean stuff but meh, works 98% of time
						local err = absang.p + absang.y 

						--Sorts targets as closest to being directly in front of radar
						if err < besterr then 
							testClosestToBeam =  table.getn( OwnerTable ) + 1
							besterr = err
						end

						local errorFromHeat = math.max((200-Heat)/5000,0) --200 degrees to the seeker causes no loss in accuracy
						local angerr = 1 + randinac * (errorFromAng + errorFromHeat)

						--For Owner table
						table.insert( OwnerTable, CPPI and scanEnt:CPPIGetOwner():GetName() or scanEnt:GetOwner():GetName() or "")
						table.insert( effHeatTable, Heat )
						table.insert( posTable , nonlocang * angerr )

					end
				end
			end

			::cont::
		end

		--	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]", "ClosestToBeam"} )

		if testClosestToBeam != -1 then --Some entity passed the test to be valid

			WireLib.TriggerOutput( self, "Detected", 1 )
			WireLib.TriggerOutput( self, "Owner", OwnerTable )
			WireLib.TriggerOutput( self, "Angle", posTable )
			WireLib.TriggerOutput( self, "EffHeat", effHeatTable )
			WireLib.TriggerOutput( self, "ClosestToBeam", testClosestToBeam )		
		else --Nothing detected

			WireLib.TriggerOutput( self, "Detected", 0 )
			WireLib.TriggerOutput( self, "Owner", {} )
			WireLib.TriggerOutput( self, "Angle", {} )
			WireLib.TriggerOutput( self, "EffHeat", {} )
			WireLib.TriggerOutput( self, "ClosestToBeam", -1 )	
		end
	end
end