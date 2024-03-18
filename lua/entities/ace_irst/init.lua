AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local deg, acos = math.deg, math.acos
local min, max = math.min, math.max
local Rand = math.Rand
local TraceHull = util.TraceHull
local Inf = math.huge

local RadarTable = ACF.Weapons.Radars

function ENT:Initialize()

	self.ThinkDelay			= 0.1
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= CurTime()
	self.Active				= false

	self.Inputs	= WireLib.CreateInputs( self, { "Active", "Cone" } )
	self.Outputs = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Angle [ARRAY]", "EffHeat [ARRAY]", "ClosestToBeam"} )
	self.OutputData = {
		Detected		= 0,
		Owner			= {},
		Angle			= {},
		EffHeat			= {},
		ClosestToBeam	= -1
	}

	self:SetActive(false)

	self.Heat               = 21
	self.HeatAboveAmbient   = 10 -- Targets below this temperature above ambient will be ignored

	self.MinViewCone        = 3
	self.MaxViewCone        = 20

	self.BaseAngularError	= 1 -- Minimum angular error
	self.LowHeatError		= 15 -- Angular error for things with very low temperature
	self.LowHeatErrorTemp 	= 75 -- Anything below this temperature, the error will be LowHeatError

	self.NextLegalCheck     = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal              = true
	self.LegalIssues        = ""

	self.ClosestToBeam      = -1

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
		self.Heat = 21 + 40
	else
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

local function GetAngleFromTarget(direction, forwardVector)
	return deg(acos(direction:Dot(forwardVector)))
end

local LOSTraceData = {
	mask = MASK_SOLID_BRUSHONLY,
	mins = vector_origin,
	maxs = vector_origin,
}

function ENT:ScanForContraptions()
	local Owners         = {}
	local Temperatures   = {}
	local AngTable       = {}

	self.ClosestToBeam   = -1

	local SelfContraption = self:GetContraption()
	local SelfForward = self:GetForward()
	local SelfPos = self:GetPos()
	local MinDistance = Inf
	local MinTrackingHeat = ACE.AmbientTemp + self.HeatAboveAmbient
	local Cone = self.Cone

	local BaseAngularError = self.BaseAngularError
	local LowHeatError = self.LowHeatError
	local LowHeatErrorTemp = self.LowHeatErrorTemp

	for Contraption in pairs(CFW.contraptions) do
		if Contraption ~= SelfContraption then
			local _, HottestEntityTemp = Contraption:GetACEHottestEntity()
			local Base = Contraption.aceBaseplate
			local BasePhys = Base:GetPhysicsObject()
			local BaseTemp = 0

			if IsValid(Base) and IsValid(BasePhys) and BasePhys:IsMoveable() then
				BaseTemp = ACE_InfraredHeatFromProp(Base, self.HeatAboveAmbient)
			end

			local Pos = BaseTemp > HottestEntityTemp and Base:GetPos() or Contraption:GetACEHeatPosition()
			local PosDiff = Pos - SelfPos
			local Distance = PosDiff:Length()

			--0x heat @ 1200m
			--0.25x heat @ 900m
			--0.5x heat @ 600m
			--0.75x heat @ 300m
			--1.0x heat @ 0m
			local Heat = max(BaseTemp, HottestEntityTemp)
			local HeatMulFromDist = 1 - min(Distance / 47244, 1) -- 39.37 * 1200 = 47244
			Heat = Heat * HeatMulFromDist

			LOSTraceData.start = SelfPos
			LOSTraceData.endpos = Pos
			local LOSTrace = TraceHull(LOSTraceData)

			local AngleFromTarget = GetAngleFromTarget(PosDiff:GetNormalized(), SelfForward)

			if AngleFromTarget < Cone and Heat > MinTrackingHeat and not LOSTrace.Hit then
				local ErrorFromAngle = 1 + AngleFromTarget / 90 -- Better accuracy when directly facing the target
				local ErrorFromHeat = 5 / max(Heat / 40, 1) --200 degrees to the seeker causes no loss in accuracy
				--100C becomes 2
				--200C becomes 1
				--400C becomes 0.5

				if Heat < LowHeatErrorTemp then
					ErrorFromHeat = LowHeatError
				end

				local FinalError = BaseAngularError + ErrorFromAngle * ErrorFromHeat
				local AngleError = Angle(Rand(-1, 1), Rand(-1, 1)) * FinalError
				local FinalAngle = -self:WorldToLocalAngles(PosDiff:Angle()) + AngleError
				FinalAngle.r = 0

				Owners[#Owners + 1] = Base:CPPIGetOwner()
				AngTable[#AngTable + 1] = FinalAngle
				Temperatures[#Temperatures + 1] = Heat

				if Distance < MinDistance then
					self.ClosestToBeam = #Owners
					MinDistance = Distance
				end
			end
		end
	end

	if self.ClosestToBeam ~= -1 then
		WireLib.TriggerOutput( self, "Detected", 1 )
		WireLib.TriggerOutput( self, "Owner", Owners )
		WireLib.TriggerOutput( self, "Angle", AngTable )
		WireLib.TriggerOutput( self, "EffHeat", Temperatures )
		WireLib.TriggerOutput( self, "ClosestToBeam", self.ClosestToBeam )

		self.OutputData.Detected = 1
		self.OutputData.Owner = Owners
		self.OutputData.Angle = AngTable
		self.OutputData.EffHeat = Temperatures
		self.OutputData.ClosestToBeam = self.ClosestToBeam
	else
		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Angle", {} )
		WireLib.TriggerOutput( self, "EffHeat", {} )
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
		self:ScanForContraptions()
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
