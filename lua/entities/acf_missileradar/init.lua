
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")
include("radar_types_support.lua")

CreateConVar("sbox_max_acf_missileradar", 6)

DEFINE_BASECLASS( "base_wire_entity" )


local RadarWireDescs = {

	--Outputs
	["Detected"]  = "Returns the amount of missiles that this radar is currently detecting.",
	["Entities"]  = "Returns all the detected missiles into an array.",
	["Position"]  = "Returns the current position of all the flying missiles of this radar",
	["Velocity"]  = "Returns the velocity of all the active missiles into an array.",

}

function ENT:Initialize()

	self.BaseClass.Initialize(self)

	self.Inputs				= WireLib.CreateInputs( self, { "Active" } )
	self.Outputs			= WireLib.CreateOutputs( self, {"Detected (" .. RadarWireDescs["Detected"] .. ")", "ClosestDistance", "Entities (" .. RadarWireDescs["Entities"] .. ") [ARRAY]", "Position (" .. RadarWireDescs["Position"] .. ") [ARRAY]", "Velocity (" .. RadarWireDescs["Velocity"] .. ") [ARRAY]"} )
	self.OutputData = {
		Detected = 0,
		ClosestDistance = 0,
		Entities = {},
		Position = {},
		Velocity = {},
	}

	self.ThinkDelay			= 0.1
	self.StatusUpdateDelay	= 0.5
	self.LastStatusUpdate	= CurTime()

	self.NextLegalCheck		= ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal				= true
	self.LegalIssues		= ""

	self.Active				= false

	self:CreateRadar(self.ACFName or "Missile Radar", self.ConeDegs or 180)

	self:EnableClientInfo(true)

	self:ConfigureForClass()

	self:GetOverlayText()

	self:SetActive(false)

end




function ENT:ConfigureForClass()

	local behaviour = ACFM.RadarBehaviour[self.Class]

	if not behaviour then return end

	self.GetDetectedEnts = behaviour.GetDetectedEnts

end




function ENT:TriggerInput( inp, value )
	if inp == "Active" then
		self:SetActive(value ~= 0 and self.Legal)
	end
end




function ENT:SetActive(active)

	self.Active = active

	if active then
		local sequence = self:LookupSequence("active") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = true
	else
		local sequence = self:LookupSequence("idle") or 0
		self:ResetSequence(sequence)
		self.AutomaticFrameAdvance = false
	end

end




function MakeACF_MissileRadar(Owner, Pos, Angle, Id)

	if not Owner:CheckLimit("_acf_missileradar") then return false end

	local radar = ACF.Weapons.Radars[Id]

	if not radar then return false end

	local Radar = ents.Create("acf_missileradar")
	if not Radar:IsValid() then return false end
	Radar:SetAngles(Angle)
	Radar:SetPos(Pos)

	Radar.Model        = radar.model
	Radar.Weight       = radar.weight
	Radar.ACFName      = radar.name
	Radar.ConeDegs     = radar.viewcone
	Radar.Range        = radar.range
	Radar.Id           = Id
	Radar.Class        = radar.class

	Radar.Sound        = ACFM.DefaultRadarSound
	Radar.DefaultSound = Radar.Sound
	Radar.SoundPitch   = 100

	Radar:Spawn()
	Radar:SetPlayer(Owner)

	Radar:CPPISetOwner(Owner)

	Radar:SetModelEasy(radar.model)

	Owner:AddCount( "_acf_missileradar", Radar )
	Owner:AddCleanup( "acfmenu", Radar )

	Radar:SetNWString( "WireName", Radar.ACFName )
	Radar:SetNWString( "Sound", Radar.Sound )
	Radar:SetNWInt( "SoundPitch",  Radar.SoundPitch )

	return Radar

end
list.Set( "ACFCvars", "acf_missileradar", {"id"} )
duplicator.RegisterEntityClass("acf_missileradar", MakeACF_MissileRadar, "Pos", "Angle", "Id" )

function ENT:CreateRadar(ACFName, ConeDegs)

	self.ConeDegs = ConeDegs
	self.ACFName = ACFName

	self:RefreshClientInfo()

end

function ENT:RefreshClientInfo()

	self:SetNWFloat("ConeDegs", self.ConeDegs)
	self:SetNWFloat("Range", self.Range)
	self:SetNWString("Id", self.ACFName)
	self:SetNWString("Name", self.ACFName)

end

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

function ENT:Think()

	if self.Inputs.Active.Value ~= 0 and self.Active and self.Legal then
		self:ScanForMissiles()
	else
		self:ClearOutputs()
	end

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

	if (self.LastStatusUpdate + self.StatusUpdateDelay < curTime) then
		self:UpdateStatus()
		self.LastStatusUpdate = curTime
	end

	self:GetOverlayText()

	return true
end

function ENT:UpdateStatus()

	if self.Active then
		self.Status = "On"
	else
		self.Status = "Off"
	end
end

function ENT:GetDetectedEnts()

	--print("reached base GetDetectedEnts")

end

function ENT:ScanForMissiles()

	local missiles = self:GetDetectedEnts() or {}

	local entArray = {}
	local posArray = {}
	local velArray = {}

	local i = 0

	local closest
	local closestSqr = math.huge

	local thisPos = self:GetPos()

	for _, missile in pairs(missiles) do

		i = i + 1

		entArray[i] = missile
		posArray[i] = missile.CurPos
		velArray[i] = missile.TrueVel or missile.LastVel

		local curSqr = thisPos:DistToSqr(missile.CurPos)

		if curSqr < closestSqr then
			closest = missile.CurPos
			closestSqr = curSqr
		end
	end

	if not closest then closestSqr = 0 end

	local closestOutput = math.sqrt(closestSqr)

	WireLib.TriggerOutput( self, "Detected", i )
	WireLib.TriggerOutput( self, "ClosestDistance", closestOutput )
	WireLib.TriggerOutput( self, "Entities", entArray )
	WireLib.TriggerOutput( self, "Position", posArray )
	WireLib.TriggerOutput( self, "Velocity", velArray )

	self.OutputData.Detected = i
	self.OutputData.ClosestDistance = closestOutput
	self.OutputData.Entities = entArray
	self.OutputData.Position = posArray
	self.OutputData.Velocity = velArray

	if i > (self.LastMissileCount or 0) then
		self:EmitRadarSound()
	end

	self.LastMissileCount = i

end

function ENT:EmitRadarSound()
	local Effect = EffectData()
		Effect:SetEntity( self )
	util.Effect( "acf_radar_noise", Effect, true, true )
end

function ENT:ClearOutputs()

	if #self.Outputs.Entities.Value > 0 then
		WireLib.TriggerOutput( self, "Entities", {} )
		self.OutputData.Entities = {}
	end

	if #self.Outputs.Position.Value > 0 then
		WireLib.TriggerOutput( self, "Position", {} )
		WireLib.TriggerOutput( self, "ClosestDistance", 0 )
		self.OutputData.Position = {}
		self.OutputData.ClosestDistance = 0
	end

	if #self.Outputs.Velocity.Value > 0 then
		WireLib.TriggerOutput( self, "Velocity", {} )
		self.OutputData.Velocity = {}
	end

end

function ENT:EnableClientInfo(bool)
	self.ClientInfo = bool
	self:SetNWBool("VisInfo", bool)

	if bool then
		self:RefreshClientInfo()
	end
end

--New Overlay text that is shown when you are looking at the radar
function ENT:GetOverlayText()

	local cone	= self.ConeDegs
	local range	= self.Range
	local status	= self.Status or "Off"
	local detected  = self.Outputs.Detected.Value

	local txt = "Status: " .. status

	txt = txt .. "\n\nView Cone: " .. math.Round(cone * 2, 2) .. " deg"

	txt = txt .. "\nMax Range: " .. (isnumber(range) and math.Round(range / 39.37 , 2) .. " m" or "Unlimited" )

	if detected and detected > 0 then
		txt = txt .. "\n\nMissiles detected: " .. detected
	end

	if not self.Legal then
		txt = txt .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText(txt)

end
