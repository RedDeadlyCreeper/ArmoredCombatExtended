AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self.ThinkDelay = 0.1

	self.Active = false
	curTime = 0

	self:SetModel( "models/props_lab/monitor01b.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)

	self:GetPhysicsObject():SetMass(400)

	self.Inputs = WireLib.CreateInputs( self, { "Active" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Angle [ARRAY]", "EffHeat [ARRAY]", "ClosestToBeam"} )

	self:SetActive(false)

	self.Cone = 45 --120 degree forward facing cone
	
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

if 	self.LegalTick >= (self.checkLegalIn or 0) then
	
self.LegalTick = 0
self.checkLegalIn = 50+math.random(0,50) --Random checks every 5-10 seconds
self:isLegal()

end

if self.Active and self.IsLegal then

--	local ScanArray = player.GetAll() --For testing
--	local ScanArray = ents.FindByClass( "prop_vehicle_prisoner_pod" ) 
	local ScanArray = ACE.contraptionEnts

	local thisPos = self:GetPos()
	local thisforward = self:GetForward()
	local randinac = math.Rand(-2,2) --Using the same accuracy var for inaccuracy, what could possibly go wrong?

	local ownArray = {}
	local effHeatArray = {}
	local posArray = {}

	local testClosestToBeam = -1
	local besterr = math.huge --Hugh mungus number

--	PrintTable(ScanArray)
	for k, scanEnt in pairs(ScanArray) do

		if(IsValid(scanEnt))then

--			if (scanEnt.THeat or 0) > 0 then
--				print(scanEnt.THeat)

--			end

			local entpos = scanEnt:WorldSpaceCenter()

			local difpos = (entpos - thisPos)
			local dist = difpos:Length()
			local nonlocang = difpos:Angle()
			local ang = self:WorldToLocalAngles(nonlocang)	--Used for testing if inrange
			local absang = Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much
			local entvel = scanEnt:GetVelocity()

			--Doesn't want to see through peripheral vison since its easier to focus a seeker on a target front and center of an array
			local errorFromAng = 0.01*(absang.y/90)^2+0.01*(absang.y/90)^2+0.01*(absang.p/90)^2 

			if (absang.p < self.Cone and absang.y < self.Cone) then --Entity is within seeker cone

				local LOStr = util.TraceLine( {start = thisPos ,endpos = entpos,collisiongroup = COLLISION_GROUP_WORLD,filter = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end}) --Hits anything in the world.

				if not LOStr.Hit then --Trace did not hit world

					local testHeat = ((scanEnt.THeat or 0) + 2*entvel:Length()/17.6)*math.min(4000/math.max(dist,1),1)
--					local testHeat = (scanEnt.THeat or 0)--
					local errorFromHeat = math.max((200-testHeat)/5000,0) --200 degrees to the seeker causes no loss in accuracy
				
					if testHeat > 50 then --Hotter than 50 deg C
						--1000 u = ~57 mph


							local err = absang.p + absang.y --Could do pythagorean stuff but meh, works 98% of time

							if err < besterr then --Sorts targets as closest to being directly in front of radar
								testClosestToBeam =  table.getn( ownArray ) + 1
								besterr = err
							end
						--print((entpos - thisPos):Length())


--						ownArray[k] = scanEnt:CPPIGetOwner():GetName() or scanEnt:GetOwner():GetName() or ""
						table.insert(ownArray, scanEnt:CPPIGetOwner():GetName() or scanEnt:GetOwner():GetName() or "")
--						ownArray[k] = scanEnt:CPPIGetOwner():GetName()
--						print(scanEnt:CPPIGetOwner():GetName())

						local angerr = 1 + randinac * (errorFromAng + errorFromHeat)
						table.insert(effHeatArray, testHeat)
						table.insert(posArray,nonlocang * angerr )

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
		WireLib.TriggerOutput( self, "Angle", posArray )
		WireLib.TriggerOutput( self, "EffHeat", effHeatArray )
		WireLib.TriggerOutput( self, "ClosestToBeam", testClosestToBeam )		

	else --Nothing detected
		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Angle", {} )
		WireLib.TriggerOutput( self, "EffHeat", {} )
		WireLib.TriggerOutput( self, "ClosestToBeam", -1 )	
	end
--	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Angle [ARRAY]", "ClosestToBeam"} )

end

end


function ENT:OnRemove()

end









