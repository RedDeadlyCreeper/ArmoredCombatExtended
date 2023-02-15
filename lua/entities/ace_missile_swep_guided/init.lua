AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( -2 , -2 , -2 ) , Vector( 2 , 2 , 2 ) )
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:PhysicsInit(MOVECOLLIDE_FLY_CUSTOM)
	self:SetUseType(SIMPLE_USE)

	self.MissileThrust = 1000
	self.MissileBurnTime = 15
	self.EnergyRetention = 0.98
	self.MaxTurnRate = 30

	self.SpecialHealth  = true  --If true, use the ACF_Activate function defined by this ent
	self.SpecialDamage  = true  --If true, use the ACF_OnDamage function defined by this ent

	self.Gravity = 0
	self.lastTravelTime = 50000000

	self.FuseTime = 10
	self.LastTime = CurTime()
	self.HeightOffset = Vector()

	self.LastVel = Vector()
	self.CurPos = self:GetPos()

	local phys = self:GetPhysicsObject()
	self.phys = phys

	if IsValid( phys ) then
		phys:EnableMotion( true )
		phys:SetMass(20)
		phys:Wake()
		phys:SetBuoyancyRatio( 5 )
		phys:SetDragCoefficient( 0 )
		phys:SetDamping( 0, 0 )
		phys:SetMaterial( "grenade" )
		phys:EnableGravity(false)
		phys:SetInertia(Vector(100))
	end

	self:EmitSound( "acf_extra/airfx/tow2.wav", 100, 100, 2, CHAN_AUTO )

	ACF_ActiveMissiles[self] = true
end

local function GetRootVelocity(ent)
	local parent = ent:GetParent()

	if IsValid(parent) then
		return GetRootVelocity(parent)
	else
		return ent:GetVelocity()
	end
end

function ENT:Detonate()
	if self.Exploded then return end

	self.Exploded = true
	ACF_ActiveMissiles[self] = nil

	self:Remove()

	local HEWeight = 4
	local Radius = HEWeight ^ 0.33 * 8 * 39.37

	self.FakeCrate = ents.Create("acf_fakecrate2")
	self.FakeCrate:RegisterTo(self.Bulletdata)
	self.Bulletdata["Crate"] = self.FakeCrate:EntIndex()
	self:DeleteOnRemove(self.FakeCrate)

	self.Bulletdata["Flight"] = self:GetForward():GetNormalized() * self.Bulletdata["MuzzleVel"] * 39.37
	self.Bulletdata.Pos = self:GetPos() + self:GetForward() * 2
	self.Bulletdata.Owner = self:CPPIGetOwner()

	self.CreateShell = ACF.RoundTypes[self.Bulletdata.Type].create
	self:CreateShell( self.Bulletdata )


	local Flash = EffectData()
	Flash:SetOrigin(self:GetPos() + Vector(0, 0, 8))
	Flash:SetNormal(Vector(0, 0, -1))
	Flash:SetRadius(math.max(Radius, 1))
	util.Effect( "ACF_Scaled_Explosion", Flash )
end

function ENT:OnRemove()
	ACF_ActiveMissiles[self] = nil
end

function ENT:PhysicsCollide()
	if self.FuseTime < 0 then return end

	self:Detonate()
end

function ENT:Think()
	local curtime = CurTime()
	local DelTime = curtime-self.LastTime

	local pos = self:GetPos()

	self.FuseTime = self.FuseTime - DelTime
	self.MissileBurnTime = self.MissileBurnTime - DelTime
	self.LastTime = curtime

	-- These are needed for missile radars to work
	self.LastVel = self:GetVelocity()
	self.CurPos = pos

	if self.IsJavelin and not self.StartDist and IsValid(self.tarent) then
		local posDiff = (self.tarent:GetPos() - pos)
		self.StartDist = Vector(posDiff.x, posDiff.y, 0):Length()
	end

	if not self.LastPos then
		self.LastPos = pos
	end

	local tr = util.QuickTrace(pos + self:GetForward() * -30, self:GetVelocity() * DelTime * 1.25, {self})

	if tr.Hit then
		debugoverlay.Cross(tr.StartPos, 10, 10, Color(255, 0, 0))
		debugoverlay.Cross(tr.HitPos, 10, 10, Color(0, 255, 0))

		self:SetPos(tr.HitPos + self:GetForward() * -18)
		self:Detonate()
	else
		if self.MissileBurnTime < 0 then
			if self.MissileBurnTime > -1 then
				self:StopParticles()
			end

			self.MissileThrust = self.MissileThrust * self.EnergyRetention
			self.Gravity = 9.8 * 39.37 * DelTime
		end

		self.phys:ApplyForceCenter(20 * (self:GetForward() * self.MissileThrust + Vector(0, 0, -self.Gravity)))

		debugoverlay.Line(self.LastPos, pos, 10, Color(0, 0, 255))

		self.LastPos = pos
	end


	if IsValid( self.tarent ) then
		local posDiff = (self.tarent:GetPos() - pos)
		local dist = posDiff:Length()
		local distXY = Vector(posDiff.x, posDiff.y, 0):Length()
		local travelTime = dist / self:GetVelocity():Length()
		local TPos = (self.tarent:GetPos() + GetRootVelocity(self.tarent) * travelTime * (self.LeadMul or 1))

		if self.IsJavelin then
			-- Angle of attack increases with distance if we're in top attack mode, because the missile needs time to turn
			-- Start at 15 degrees, max at 30 degrees, increase by 1 degree every 200 units
			if self.TopAttack and math.deg(math.acos(distXY / dist)) < math.Clamp((self.StartDist - self.DirectFireDist) / 200 + 15, 15, 30) then
				self.HeightOffset = Vector(0, 0, self.StartDist / 2)
			else
				self.HeightOffset = Vector()
			end
		end

		local d = (TPos + self.HeightOffset) - pos

		if self.RadioDist and d:Length() < self.RadioDist then
			self:Detonate()
		end

		local deltaTravelTime = self.lastTravelTime - travelTime
		self.lastTravelTime = travelTime

		if deltaTravelTime > 0 then -- Missile is moving towards target
			local AngAdjust = self:WorldToLocalAngles((d):Angle())
			local adjustedrate = self.MaxTurnRate * DelTime
			AngAdjust = self:LocalToWorldAngles(Angle(math.Clamp(AngAdjust.pitch, -adjustedrate, adjustedrate), math.Clamp(AngAdjust.yaw, -adjustedrate, adjustedrate), math.Clamp(AngAdjust.roll, -adjustedrate, adjustedrate)))

			self:SetAngles(AngAdjust)
		else
			if not self.IsJavelin then
				self:Detonate()
			else
				self.FuseTime = self.FuseTime * 0.5
			end
		end
	else
		self:Detonate()
	end

	if self.FuseTime < 0 then
		self:Detonate()
	end
end

--===========================================================================================
----- OnDamage functions
--===========================================================================================
function ENT:ACF_Activate( Recalc )

	local EmptyMass = self.RoundWeight or self.Mass or 10

	self.ACF = self.ACF or {}

	local PhysObj = self.phys
	if not self.ACF.Area then
		self.ACF.Area = PhysObj:GetSurfaceArea() * 6.45
	end


	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end

	local ForceArmour = ACF_GetGunValue(self.BulletData, "armour")

	local Armour = ForceArmour or (EmptyMass * 1000 / self.ACF.Area / 0.78)	--So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume / ACF.Threshold							--Setting the threshold of the prop Area gone
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Health	= Health * Percent
	self.ACF.MaxHealth  = Health
	self.ACF.Armour	= Armour * (0.5 + Percent / 2)
	self.ACF.MaxArmour  = Armour
	self.ACF.Type	= nil
	self.ACF.Mass	= self.Mass
	self.ACF.Density	= (PhysObj:GetMass() * 1000) / self.ACF.Volume
	self.ACF.Type	= "Prop"

	self.ACF.Material	= not isstring(self.ACF.Material) and ACE.BackCompMat[self.ACF.Material] or self.ACF.Material or "RHA"

end

local nullhit = {Damage = 0, Overkill = 1, Loss = 0, Kill = false}

function ENT:ACF_OnDamage( Entity , Energy , FrArea , Ang , Inflictor )	--This function needs to return HitRes

	if self.Detonated or self.DisableDamage then return table.Copy(nullhit) end

	local HitRes = ACF_PropDamage( Entity , Energy , FrArea , Ang , Inflictor )	--Calling the standard damage prop function

	-- Detonate if the shot penetrates the casing.
	HitRes.Kill = HitRes.Kill or HitRes.Overkill > 0

	if HitRes.Kill then

		local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
		if CanDo == false then return HitRes end

		self:Remove()

		if IsValid(Inflictor) and Inflictor:IsPlayer() then
			self.Inflictor = Inflictor
		end

	end
	return HitRes
end
