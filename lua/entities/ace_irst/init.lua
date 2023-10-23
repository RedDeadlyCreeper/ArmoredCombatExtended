AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local RadarTable = ACF.Weapons.Radars

function ENT:Initialize()

	self.ThinkDelay			= 0.1
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= CurTime()
	self.Active				= false

	self.Inputs	= WireLib.CreateInputs( self, { "Active", "Cone" } )
	self.Outputs	= WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Angle [ARRAY]", "EffHeat [ARRAY]", "ClosestToBeam"} )
	self.OutputData = {
		Detected		= 0,
		Owner			= {},
		Angle			= {},
		EffHeat			= {},
		ClosestToBeam	= -1
	}

	self:SetActive(false)

	self.Heat                = 21	-- Heat
	self.HeatAboveAmbient    = 5	-- How many degrees above Ambient Temperature this irst will start to track?
	self.HeatNoLoss 	     = 200  -- Required heat to make the tracker not to lose accuracy. Below this value, inaccuracy starts to take effect.

	self.MinViewCone         = 3
	self.MaxViewCone         = 45

	self.NextLegalCheck      = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal               = true
	self.LegalIssues         = ""

	self.ClosestToBeam       = -1

	self:UpdateOverlayText()

end

local function SetConeParameter( IRST )
	IRST.inac = math.max( (IRST.Cone / 15) ^ 2, 2 )
end

function MakeACE_IRST(Owner, Pos, Angle, Id)

	if not Owner:CheckLimit("_acf_missileradar") then return false end

	Id = Id or "Small-IRST"

	local radar = RadarTable[Id]
	if not radar then return false end

	local IRST = ents.Create("ace_irst")
	if IsValid(IRST) then

		IRST:SetAngles(Angle)
		IRST:SetPos(Pos)

		IRST.Model				= radar.model
		IRST.Weight				= radar.weight
		IRST.ACFName			= radar.name
		IRST.ICone				= radar.viewcone	--Note: intentional. --Recorded initial cone
		IRST.Cone				= IRST.ICone

		SetConeParameter( IRST )

		IRST.SeekSensitivity	= radar.SeekSensitivity

		IRST.MinimumDistance	= radar.mindist
		IRST.MaximumDistance	= radar.maxdist

		IRST.Id					= Id
		IRST.Class				= radar.class

		IRST:Spawn()

		IRST:CPPISetOwner(Owner)

		IRST:SetNWNetwork()
		IRST:SetModelEasy(radar.model)
		IRST:UpdateOverlayText()

		Owner:AddCount( "_acf_missileradar", IRST )
		Owner:AddCleanup( "acfmenu", IRST )

		return IRST
	end

	return false
end
list.Set( "ACFCvars", "ace_irst", {"id"} )
duplicator.RegisterEntityClass("ace_irst", MakeACE_IRST, "Pos", "Angle", "Id" )

function ENT:SetNWNetwork()
	self:SetNWString( "WireName", self.ACFName )
end

function ENT:SetModelEasy(mdl)

	self:SetModel( mdl )
	self.Model = mdl

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(self.Weight)
	end

end

function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive((value ~= 0) and self.Legal)
	elseif inp == "Cone" then
		if value > 0 then

			self.Cone = math.Clamp(value / 2, self.MinViewCone ,self.MaxViewCone )

			SetConeParameter( self )

			--You are not going from a wide to narrow beam in half a second deal with it.
			local curTime = CurTime()
			self:NextThink(curTime + 10)
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

		WireLib.TriggerOutput( self, "Detected"	, 0 )
		WireLib.TriggerOutput( self, "Owner"		, {} )
		WireLib.TriggerOutput( self, "Angle"		, {} )
		WireLib.TriggerOutput( self, "EffHeat"	, {} )
		WireLib.TriggerOutput( self, "ClosestToBeam", -1 )

		self.OutputData.Detected = 0
		self.OutputData.Owner = {}
		self.OutputData.Angle = {}
		self.OutputData.EffHeat = {}
		self.OutputData.ClosestToBeam = -1

		self.Heat = 21
	end

end

function ENT:GetWhitelistedEntsInCone()

	local ScanArray = ACE.contraptionEnts
	if not next(ScanArray) then return {} end

	local WhitelistEnts    = {}
	local LOSdata          = {}
	local LOStr            = {}

	local IRSTPos          = self:GetPos()

	local entpos           = Vector()
	local difpos           = Vector()
	local dist             = 0

	for _, scanEnt in ipairs(ScanArray) do

		-- skip any invalid entity
		if not IsValid(scanEnt) then continue end

		--Why IRST should track itself?
		if self == scanEnt then continue end

		entpos  = scanEnt:GetPos()
		difpos  = entpos - IRSTPos
		dist	= difpos:Length()

		-- skip any ent outside of minimun distance
		if dist < self.MinimumDistance then continue end

		-- skip any ent far than maximum distance
		if dist > self.MaximumDistance then continue end

		LOSdata.start             = IRSTPos
		LOSdata.endpos            = entpos
		LOSdata.collisiongroup    = COLLISION_GROUP_WORLD
		LOSdata.filter            = function( ent ) if ( ent:GetClass() ~= "worldspawn" ) then return false end end
		LOSdata.mins              = vector_origin
		LOSdata.maxs              = LOSdata.mins

		LOStr = util.TraceHull( LOSdata )

		--Trace did not hit world
		if not LOStr.Hit then
			table.insert(WhitelistEnts, scanEnt)
		end
	end

	return WhitelistEnts
end

local function IsInCone( Angle, Cone )
	return Angle.p < Cone and Angle.y < Cone
end

function ENT:AcquireLock()

	local IRSTPos        = self:GetPos()
	local inac           = self.inac

	--Table definition
	local Owners         = {}
	local Temperatures   = {}
	local AngTable       = {}

	self.ClosestToBeam   = -1
	local besterr        = math.huge --Hugh mungus number

	local entpos         = vector_origin
	local difpos         = vector_origin

	local nonlocang      = angle_zero
	local ang            = angle_zero
	local absang         = angle_zero
	local errorFromAng   = 0
	local dist           = 0

	local physEnt		= NULL

	for _, scanEnt in ipairs(self:GetWhitelistedEntsInCone()) do

		local randanginac	= math.Rand(-inac,inac) --Using the same accuracy var for inaccuracy, what could possibly go wrong?

		entpos	= scanEnt:WorldSpaceCenter()
		difpos	= (entpos - IRSTPos)

		nonlocang   = difpos:Angle()
		ang         = self:WorldToLocalAngles(nonlocang)		--Used for testing if inrange
		absang      = Angle(math.abs(ang.p),math.abs(ang.y),0)  --Since I like ABS so much

		--Doesn't want to see through peripheral vison since its easier to focus a seeker on a target front and center of an array
		errorFromAng = 0.4 * (absang.y / 90) ^ 2 + 0.4 * (absang.y / 90) ^ 2 + 0.4 * (absang.p / 90) ^ 2

		-- Check if the target is within the cone.
		if IsInCone( absang, self.Cone ) then

			--if the target is a Heat Emitter, track its heat
			if scanEnt.Heat then

				Heat = self.SeekSensitivity * scanEnt.Heat

			--if is not a Heat Emitter, track the friction's heat
			else

				physEnt = scanEnt:GetPhysicsObject()

				--skip if it has not a valid physic object. It's amazing how gmod can break this. . .
				--check if it's not frozen. If so, skip it, unmoveable stuff should not be even considered
				if IsValid(physEnt) and not physEnt:IsMoveable() then continue end

				dist = difpos:Length()
				Heat = ACE_InfraredHeatFromProp( self, scanEnt , dist )

			end

			--Skip if not Hotter than AmbientTemp in deg C.
			if Heat <= ACE.AmbientTemp + self.HeatAboveAmbient then continue end

			--Could do pythagorean stuff but meh, works 98% of time
			local err = absang.p + absang.y

			--Sorts targets as closest to being directly in front of radar
			if err < besterr then
				self.ClosestToBeam =  #Owners + 1
				besterr = err
			end

			local errorFromHeat = math.max((self.HeatNoLoss - Heat) / 5000, 0) --200 degrees to the seeker causes no loss in accuracy
			local finalerror = errorFromAng + errorFromHeat
			local angerr = Angle(finalerror, finalerror, finalerror) * randanginac

			--For Owner table
			local Owner = scanEnt:CPPIGetOwner()
			local NickName = IsValid(Owner) and Owner:GetName() or ""


			table.insert(Owners, NickName)
			table.insert(Temperatures, Heat)
			table.insert(AngTable, -ang + angerr) -- Negative means that if the target is higher than irst = positive pitch

		end


	end

	if self.ClosestToBeam ~= -1 then --Some entity passed the test to be valid

		WireLib.TriggerOutput( self, "Detected"	, 1 )
		WireLib.TriggerOutput( self, "Owner"		, Owners )
		WireLib.TriggerOutput( self, "Angle"		, AngTable )
		WireLib.TriggerOutput( self, "EffHeat"	, Temperatures )
		WireLib.TriggerOutput( self, "ClosestToBeam", self.ClosestToBeam )

		self.OutputData.Detected = 1
		self.OutputData.Owner = Owners
		self.OutputData.Angle = AngTable
		self.OutputData.EffHeat = Temperatures
		self.OutputData.ClosestToBeam = self.ClosestToBeam
	else --Nothing detected

		WireLib.TriggerOutput( self, "Detected"	, 0 )
		WireLib.TriggerOutput( self, "Owner"		, {} )
		WireLib.TriggerOutput( self, "Angle"		, {} )
		WireLib.TriggerOutput( self, "EffHeat"	, {} )
		WireLib.TriggerOutput( self, "ClosestToBeam", -1 )

		self.OutputData.Detected = 0
		self.OutputData.Owner = {}
		self.OutputData.Angle = {}
		self.OutputData.EffHeat = {}
		self.OutputData.ClosestToBeam = -1
	end
end

function ENT:UpdateStatus()
	self.Status = self.Active and "On" or "Off"
end

function ENT:Think()

	local curTime = CurTime()

	-- Legal check system
	if ACF.CurTime > self.NextLegalCheck then

		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.Round(self.Weight,2), nil, true, true)
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		if not self.Legal then
			self.Active = false
			self:SetActive(false)
		end

	end

	if self.Active and self.Legal then
		self:AcquireLock()
	end

	if (self.LastStatusUpdate + self.StatusUpdateDelay) < curTime then
		self:UpdateStatus()
		self.LastStatusUpdate = curTime
	end

	self:UpdateOverlayText()

	self:NextThink(curTime + self.ThinkDelay)
	return true
end

function ENT:UpdateOverlayText()

	local cone	= self.Cone
	local status	= self.Status or "Off"
	local detected  = status ~= "Off" and self.ClosestToBeam ~= -1 or false
	local range	= self.MaximumDistance or 0

	local txt = "Status: " .. status

	txt = txt .. "\n\nView Cone: " .. math.Round(cone * 2, 2) .. " deg"

	txt = txt .. "\nMax Range: " .. (isnumber(range) and math.Round(range / 39.37 , 2) .. " m" or "Unlimited" )

	if detected then
		txt = txt .. "\n\nTarget Detected!"
	end

	if not self.Legal then
		txt = txt .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText(txt)


end
