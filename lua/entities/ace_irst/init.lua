AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local deg, acos = math.deg, math.acos
local min, Clamp = math.min, math.Clamp
local Remap = math.Remap
local insert = table.insert
local Rand = math.Rand
local TraceHull = util.TraceHull
local RadarTable = ACF.Weapons.Radars

function ENT:Initialize()

	self.ThinkDelay			= 0.05
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= CurTime()
	self.Active				= false

	self.Inputs	= WireLib.CreateInputs( self, {
		"Active (Activates the IRST)",
		"Cone (Sets the view cone angle of the IRST)"
	})

	self.Outputs = WireLib.CreateOutputs( self, {
		"Detected (Returns 1 if the IRST is detecting at least one target)",
		"Owner (Returns an array of the players who own the detected targets) [ARRAY]",
		"Angle (Returns an array of angles towards the detected targets) [ARRAY]",
		"EffHeat (Returns an array of the temperature of the detected targets) [ARRAY]",
		"ID (Returns an array of unique IDs for each target that can be used to track a specific contraption) [ARRAY]",
		"Distance (Returns an array of distances to each target, in GMod units) [ARRAY]"
	})

	self.OutputData = {
		Detected		= 0,
		Owner			= {},
		Angle			= {},
		EffHeat			= {},
		ID				= {},
		Distance		= {}
	}

	self:SetActive(false)

	self.Heat               = ACE.AmbientTemp
	self.HeatAboveAmbient   = 10 -- Targets below this temperature above ambient will be ignored

	self.MinViewCone        = 3
	self.MaxViewCone        = 20

	self.LowHeatErrorTemp 	= 75 -- Inaccuracy for anything below this temperature will be LowHeatError
	self.LowHeatError		= 10

	self.PeakAccuracyTemp	= 600 -- Inaccuracy for anything at or above this temperature will be PeakAccuracyError
	self.PeakAccuracyError	= 0.25

	self.AircraftAltitude	= 500 -- As this altitude is approached (source units), the accuracy of the IRST will increase
	self.AircraftAccuracy	= 0.1 -- At AircraftAltitude and above, the error will be multiplied by this value

	self.NextLegalCheck     = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal              = true
	self.LegalIssues        = ""

	self.TargetDetected		= false

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
		IRST.ACEPoints			= radar.acepoints or 0.9

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

			self.Cone = Clamp(value / 2, self.MinViewCone ,self.MaxViewCone )

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
		self.Heat = ACE.AmbientTemp + 40
	else
		WireLib.TriggerOutput( self, "Detected"	, 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Angle", {} )
		WireLib.TriggerOutput( self, "EffHeat", {} )
		WireLib.TriggerOutput( self, "ID", {} )
		WireLib.TriggerOutput( self, "Distance", {} )

		self.OutputData.Detected = 0
		self.OutputData.Owner = {}
		self.OutputData.Angle = {}
		self.OutputData.EffHeat = {}
		self.OutputData.ID = {}
		self.OutputData.Distance = {}

		self.Heat = ACE.AmbientTemp
	end

end

local function GetAngleBetweenVectors(v1, v2)
	return deg(acos(v1:Dot(v2)))
end

local LOSTraceData = {
	mask = MASK_SOLID_BRUSHONLY,
	mins = vector_origin,
	maxs = vector_origin,
}

function ENT:ScanForContraptions()
	self.TargetDetected = false

	local Owners        = {}
	local Temperatures  = {}
	local AngTable      = {}
	local IDs			= {}
	local Distances		= {}

	local SelfContraption = self:GetContraption()
	local SelfForward = self:GetForward()
	local SelfPos = self:GetPos()
	local MinTrackingHeat = ACE.AmbientTemp + self.HeatAboveAmbient

	local LowHeatError = self.LowHeatError
	local LowHeatErrorTemp = self.LowHeatErrorTemp

	local PeakAccuracyError = self.PeakAccuracyError
	local PeakAccuracyTemp = self.PeakAccuracyTemp

	local AircraftAltitude = self.AircraftAltitude
	local AircraftAccuracy = self.AircraftAccuracy

	for Contraption in pairs(CFW.Contraptions) do
		if Contraption ~= SelfContraption then
			local _, HottestEntityTemp = Contraption:GetACEHottestEntity()
			HottestEntityTemp = HottestEntityTemp or 0
			local Base = Contraption:GetACEBaseplate()

			if not IsValid(Base) then continue end

			local BasePhys = Base:GetPhysicsObject()
			local BaseTemp = 0

			if IsValid(BasePhys) and BasePhys:IsMoveable() then
				BaseTemp = ACE_InfraredHeatFromProp(Base, self.HeatAboveAmbient)
			end

			local Pos
			if not Contraption.aceEntities or (HottestEntityTemp and BaseTemp > HottestEntityTemp) then
				Pos = Base:GetPos()
			else
				Pos = Contraption:GetACEHeatPosition()
			end
			local PosDiff = Pos - SelfPos
			local Distance = PosDiff:Length()

			local Heat = BaseTemp + math.max(ACE.AmbientTemp,HottestEntityTemp)

			--0x heat @ 1200m
			--0.25x heat @ 900m
			--0.5x heat @ 600m
			--0.75x heat @ 300m
			--1.0x heat @ 0m
			local HeatMulFromDist = 1 - min(Distance / 47244, 1) -- 39.37 * 1200 = 47244
			Heat = Heat * HeatMulFromDist

			LOSTraceData.start = SelfPos
			LOSTraceData.endpos = Pos
			local LOSTrace = TraceHull(LOSTraceData)

			local AngleFromTarget = GetAngleBetweenVectors(PosDiff:GetNormalized(), SelfForward)

			if AngleFromTarget < self.Cone and Heat > MinTrackingHeat and not LOSTrace.Hit then
				debugoverlay.Line(SelfPos, Pos, 0.1, Color(255, 0, 0))

				self.TargetDetected = true

				local ErrorFromAngle = 0--AngleFromTarget / 45 -- Better accuracy when directly facing the target
				-- Smoothly decrease error as we go between LowHeatErrorTemp and PeakAccuracyTemp
				local ErrorFromHeat = Clamp(Remap(Heat, LowHeatErrorTemp, PeakAccuracyTemp, LowHeatError, PeakAccuracyError), PeakAccuracyError, LowHeatError)

				local Altitude = Contraption:GetACEAltitude()

				-- As altitude increases to AircraftAltitude, the error decreases to AircraftAccuracy
				local AltitudeErrorMul = Clamp(Remap(Altitude, 0, AircraftAltitude, 1, AircraftAccuracy), AircraftAccuracy, 1)

				local FinalError = ErrorFromAngle + ErrorFromHeat * AltitudeErrorMul
				local AngleError = Angle(Rand(-1, 1), Rand(-1, 1)) * FinalError
				local FinalAngle = -self:WorldToLocalAngles(PosDiff:Angle()) + AngleError

				local debugDir = self:LocalToWorldAngles(-FinalAngle):Forward()

				debugoverlay.Line(SelfPos, SelfPos + debugDir * Distance, 0.1, Color(0, 255, 0))

				FinalAngle.r = 0

				local Index = ACE_GetContraptionIndex(Contraption)
				local InsertionIndex = ACE_GetBinaryInsertIndex(Distances, Distance)

				local Owner = Base:CPPIGetOwner()

				insert(Distances, InsertionIndex, Distance)
				insert(Owners, InsertionIndex, IsValid(Owner) and Owner:GetName() or "")
				insert(AngTable, InsertionIndex, FinalAngle)
				insert(Temperatures, InsertionIndex, Heat)
				insert(IDs, InsertionIndex, Index)
			end
		end
	end

	local OutputData = self.OutputData

	if self.TargetDetected then
		WireLib.TriggerOutput( self, "Detected", 1 )
		WireLib.TriggerOutput( self, "Owner", Owners )
		WireLib.TriggerOutput( self, "Angle", AngTable )
		WireLib.TriggerOutput( self, "EffHeat", Temperatures )
		WireLib.TriggerOutput( self, "ID", IDs )
		WireLib.TriggerOutput( self, "Distance", Distances )


		OutputData.Detected = 1
		OutputData.Owner = Owners
		OutputData.Angle = AngTable
		OutputData.EffHeat = Temperatures
		OutputData.ID = IDs
		OutputData.Distance = Distances
	else
		WireLib.TriggerOutput( self, "Detected", 0 )
		WireLib.TriggerOutput( self, "Owner", {} )
		WireLib.TriggerOutput( self, "Angle", {} )
		WireLib.TriggerOutput( self, "EffHeat", {} )
		WireLib.TriggerOutput( self, "ID", {} )
		WireLib.TriggerOutput( self, "Distance", {} )

		OutputData.Detected = 0
		OutputData.Owner = {}
		OutputData.Angle = {}
		OutputData.EffHeat = {}
		OutputData.ID = {}
		OutputData.Distance = {}
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
	local cone		= self.Cone
	local status	= self.Status or "Off"
	local detected  = status ~= "Off" and self.TargetDetected or false
	local range		= self.MaximumDistance or 0

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
