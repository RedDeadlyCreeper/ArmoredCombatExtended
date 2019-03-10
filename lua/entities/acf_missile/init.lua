AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


DEFINE_BASECLASS("acf_explosive")




function ENT:Initialize()

	self.BaseClass.Initialize(self)

	if !IsValid(self.Entity.Owner) then
		self.Owner = player.GetAll()[1]
	end

	self.Entity:SetOwner(self.Entity.Owner)
	self.DetonateOffset = nil

	self.PhysObj = self.Entity:GetPhysicsObject()
	if !self.PhysObj:IsValid() then
		self:Remove()	--Prevent duping missiles (to stop errors)
		return
	end
	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableMotion( false )

	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.SpecialHealth = true	--If true needs a special ACF_Activate function

	self:SetNWFloat("LightSize", 0)

end




function ENT:SetBulletData(bdata)

    self.BaseClass.SetBulletData(self, bdata)

    local gun = list.Get("ACFEnts").Guns[bdata.Id]

    self:SetModelEasy( gun.round.model or gun.model or "models/missiles/aim9.mdl" )

    self:ParseBulletData(bdata)

    local roundWeight = ACF_GetGunValue(bdata, "weight") or 10

    local phys = self.Entity:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass( roundWeight )
	end

    self.RoundWeight = roundWeight

    self:ConfigureFlight()

end




function ENT:ParseBulletData(bdata)

    local guidance  = bdata.Data7
    local fuse      = bdata.Data8

    if guidance then
		guidance = ACFM_CreateConfigurable(guidance, ACF.Guidance, bdata, "guidance")
		if guidance then self:SetGuidance(guidance) end
    end

    if fuse then
		fuse = ACFM_CreateConfigurable(fuse, ACF.Fuse, bdata, "fuses")
		if fuse then self:SetFuse(fuse) end
    end

end




function ENT:CalcFlight()

	if self.MissileDetonated then return end

	local Ent = self.Entity
	local Pos = self.CurPos
	local Dir = self.CurDir

	local LastPos = self.LastPos
	local LastVel = self.LastVel
	local Speed = LastVel:Length()
	local Flight = self.FlightTime

    	local Time = CurTime()
    	local DeltaTime = Time - self.LastThink

	if DeltaTime <= 0 then return end

	self.LastThink = Time
	Flight = Flight + DeltaTime

	if Speed == 0 then
		LastVel = Dir
		Speed = 1
	end

	--Guidance calculations
	local Guidance = self.Guidance:GetGuidance(self)
	local TargetPos = Guidance.TargetPos

	if TargetPos then
		local Dist = Pos:Distance(TargetPos)
		TargetPos = TargetPos + (Vector(0,0,self.Gravity * Dist / 100000))
		local LOS = (TargetPos - Pos):GetNormalized()
		local LastLOS = self.LastLOS
		local NewDir = Dir
		local DirDiff = 0

		if LastLOS then
			local Agility = self.Agility
			local SpeedMul = math.min((Speed / DeltaTime / self.MinimumSpeed) ^ 3,1)

			local LOSDiff = math.deg(math.acos( LastLOS:Dot(LOS) )) * 20
			local MaxTurn = Agility * SpeedMul * 5

			if LOSDiff > 0.01 and MaxTurn > 0.1 then
				local LOSNormal = LastLOS:Cross(LOS):GetNormalized()
				local Ang = NewDir:Angle()
				Ang:RotateAroundAxis(LOSNormal, math.min(LOSDiff, MaxTurn))
				NewDir = Ang:Forward()
			end

			DirDiff = math.deg(math.acos( NewDir:Dot(LOS) ))
			if DirDiff > 0.01 then
				local DirNormal = NewDir:Cross(LOS):GetNormalized()
				local TurnAng = math.min(DirDiff, MaxTurn) / 10
				local Ang = NewDir:Angle()
				Ang:RotateAroundAxis(DirNormal, TurnAng)
				NewDir = Ang:Forward()
				DirDiff = DirDiff - TurnAng
			end
		end
		--FOV check
		if not Guidance.ViewCone or DirDiff <= Guidance.ViewCone then  -- ViewCone is active-seeker specific
			Dir = NewDir
		end
		self.LastLOS = LOS
	else
		local DirAng = Dir:Angle()
		local VelNorm = LastVel / Speed
		local AimDiff = Dir - VelNorm
		local DiffLength = AimDiff:Length()
		if DiffLength >= 0.001 then
			local Torque = DiffLength * self.TorqueMul
			local AngVelDiff = Torque / self.Inertia * DeltaTime
			local DiffAxis = AimDiff:Cross(Dir):GetNormalized()
			self.RotAxis = self.RotAxis + DiffAxis * AngVelDiff
		end

		self.RotAxis = self.RotAxis * 0.99
        	DirAng:RotateAroundAxis(self.RotAxis, self.RotAxis:Length())
		Dir = DirAng:Forward()

		self.LastLOS = nil
	end

	--Motor cutout
	local DragCoef = 0
	if Time > self.CutoutTime then
		DragCoef = self.DragCoef

		if self.Motor ~= 0 then
			self.Entity:StopParticles()
			self.Motor = 0
			self:SetNWFloat("LightSize", 0)
		end
	else
		DragCoef = self.DragCoefFlight
	end

	--Physics calculations
	local Vel = LastVel + (Dir * self.Motor - Vector(0,0,self.Gravity)) * ACF.VelScale * DeltaTime ^ 2
	local Up = Dir:Cross(Vel):Cross(Dir):GetNormalized()
	local Speed = Vel:Length()
	local VelNorm = Vel / Speed
	local DotSimple = Up.x * VelNorm.x + Up.y * VelNorm.y + Up.z * VelNorm.z

	Vel = Vel - Up * Speed * DotSimple * self.FinMultiplier

	local SpeedSq = Vel:LengthSqr()
	local Drag = Vel:GetNormalized() * (DragCoef * SpeedSq) / ACF.DragDiv * ACF.VelScale
	Vel = Vel - Drag
	local EndPos = Pos + Vel

	--Hit detection
	local tracedata={}
	tracedata.start = Pos
	tracedata.endpos = EndPos
	tracedata.filter = self.Filter
	local trace = util.TraceLine(tracedata)

	if trace.Hit then

		if not (IsValid(trace.Entity) and CurTime() < self.GhostPeriod) then
			self.HitNorm = trace.HitNormal
			self:DoFlight(trace.HitPos)
			self.LastVel = Vel / DeltaTime
			self:Detonate()
			return
		end

	end

	--print("Vel = "..math.Round(Vel:Length() / DeltaTime))

	if self.Fuse:GetDetonate(self, self.Guidance) then
		self.LastVel = Vel / DeltaTime
		self:Detonate()
		return
	end

	self.LastVel = Vel
	self.LastPos = Pos
	self.CurPos = EndPos
	self.CurDir = Dir
	self.FlightTime = Flight

	--Missile trajectory debugging
	debugoverlay.Line(Pos, EndPos, 10, Color(0, 255, 0))
	--debugoverlay.Line(EndPos, EndPos + Dir:GetNormalized()  * 50, 10, Color(0, 0, 255))

	self:DoFlight()
end




function ENT:SetGuidance(guidance)

	self.Guidance = guidance
	guidance:Configure(self)

    return guidance

end




function ENT:SetFuse(fuse)

	self.Fuse = fuse
    fuse:Configure(self, self.Guidance or self:SetGuidance(ACF.Guidance.Dumb()))

    return fuse

end




function ENT:UpdateBodygroups()

	local bodygroups = self:GetBodyGroups()

	for idx, group in pairs(bodygroups) do

		if string.lower(group.name) == "guidance" and self.Guidance then

			self:ApplyBodySubgroup(group, self.Guidance.Name)
			continue

		end


		if string.lower(group.name) == "warhead" and self.BulletData then

			self:ApplyBodySubgroup(group, self.BulletData.Type)
			continue

		end

	end

end




function ENT:ApplyBodySubgroup(group, targetname)

	local name = string.lower(targetname) .. ".smd"

	for subId, subName in pairs(group.submodels) do
		if string.lower(subName) == name then
			self:SetBodygroup(group.id, subId)
			return
		end
	end

end




function ENT:Launch()

	if not self.Guidance then
		self:SetGuidance(ACF.Guidance.Dumb())
	end

    if not self.Fuse then
        self:SetFuse(ACF.Fuse.Contact())
    end

    self.Guidance:Configure(self)
    self.Fuse:Configure(self, self.Guidance)

	self.Launched = true
	self.ThinkDelay = 1 / 66
	self.Filter = self.Filter or {self}

	self.GhostPeriod = CurTime() + ACFM_GhostPeriod:GetFloat()

    self:SetParent(nil)

    self:ConfigureFlight()

	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)

	if self.Motor > 0 or self.MotorLength > 0.1 then
		self.CacheParticleEffect = CurTime() + 0.01
		self:SetNWFloat("LightSize", self.BulletData.Caliber)
	end

    self:LaunchEffect()

	ACF_ActiveMissiles[self] = true

	self:Think()
end




function ENT:LaunchEffect()

    local guns = list.Get("ACFEnts").Guns
    local class = guns[self.BulletData.Id]

    local sound = self.BulletData.Sound or ACF_GetGunValue(self.BulletData, "sound")

    if sound then
			if( ACF_SOUND_EXT ) then
				hook.Call( "ACF_SOUND_MISSILE", nil, self, sound )
			else
        self:EmitSound(sound, 511, 100)
			end
    end

end




function ENT:ConfigureFlight()

	local BulletData = self.BulletData

	local GunData = list.Get("ACFEnts").Guns[BulletData.Id]

	local Round = GunData.round
	local BurnRate = Round.burnrate

    local Time = CurTime()
	local noThrust = ACF_GetGunValue(self.BulletData, "nothrust")

	if noThrust then
		self.MotorLength = 0
		self.Motor = 0
	else
		self.MotorLength = BulletData.PropMass / (Round.burnrate / 1000) * (1 - Round.starterpct)
		self.Motor = Round.thrust
	end

	self.Gravity = GetConVar("sv_gravity"):GetFloat()
	self.DragCoef = Round.dragcoef
	self.DragCoefFlight = (Round.dragcoefflight or Round.dragcoef)
	self.MinimumSpeed = Round.minspeed
	self.FlightTime = 0
	self.FinMultiplier = Round.finmul
	self.Agility = GunData.agility or 1
	self.CutoutTime = Time + self.MotorLength
	self.CurPos = BulletData.Pos
	self.CurDir = BulletData.Flight:GetNormalized()
	self.LastPos = self.CurPos
    self.Hit = false
	self.HitNorm = Vector(0,0,0)
	self.FirstThink = true
    self.MinArmingDelay = math.max(Round.armdelay or GunData.armdelay, GunData.armdelay)

    local Mass = GunData.weight
    local Length = GunData.length
	local Width = GunData.caliber
	self.Inertia = 0.08333 * Mass * (3.1416 * (Width / 2) ^ 2 + Length)
	self.TorqueMul = Length * 25
	self.RotAxis = Vector(0,0,0)

	self:UpdateBodygroups()
	self:UpdateSkin()

end




function ENT:UpdateSkin()

	if self.BulletData then

		local warhead = self.BulletData.Type

		local skins = ACF_GetGunValue(self.BulletData, "skinindex")
		if not skins then return end

		local skin = skins[warhead] or 0

		self:SetSkin(skin)

	end

end




function ENT:DoFlight(ToPos, ToDir)
	--if !IsValid(self.Entity) or self.MissileDetonated then return end

	local setPos = ToPos or self.CurPos
	local setDir = ToDir or self.CurDir

	self:SetPos(setPos)
	self:SetAngles(setDir:Angle())

    self.BulletData.Pos = setPos
    --self.BulletData.Flight = self.LastVel
end




function ENT:Detonate()

	self.Entity:StopParticles()
	self.Motor = 0
	self:SetNWFloat("LightSize", 0)

    if self.Fuse and (CurTime() - self.Fuse.TimeStarted < self.MinArmingDelay or not self.Fuse:IsArmed()) then
        self:Dud()
        return
    end

    self.BulletData.Flight = self:GetForward() * (self.BulletData.MuzzleVel or 10)
    --debugoverlay.Line(self.BulletData.Pos, self.BulletData.Pos + self.BulletData.Flight, 10, Color(255, 0, 0))

    self:ForceDetonate()

end




function ENT:ForceDetonate()

	self.MissileDetonated = true    -- careful not to conflict with base class's self.Detonated

	ACF_ActiveMissiles[self] = nil

	self.DetonateOffset = self.LastVel:GetNormalized() * -1

    self.BaseClass.Detonate(self, self.BulletData)

end




function ENT:Dud()

    self.MissileDetonated = true

	ACF_ActiveMissiles[self] = nil

	local Dud = self
	Dud:SetPos( self.CurPos )
	Dud:SetAngles( self.CurDir:Angle() )

	local Phys = Dud:GetPhysicsObject()
	Phys:EnableGravity(true)
	Phys:EnableMotion(true)
	local Vel = self.LastVel

	if self.HitNorm != Vector(0,0,0) then
		local Dot = self.CurDir:Dot(self.HitNorm)
		local NewDir = self.CurDir - 2 * Dot * self.HitNorm
		local VelMul = (0.8 + Dot * 0.7) * Vel:Length()
		Vel = NewDir * VelMul
	end

	Phys:SetVelocity(Vel)

	timer.Simple(30, function() if IsValid(self) then self:Remove() end end)
end




function ENT:Think()
	local Time = CurTime()

	if self.Launched and not self.MissileDetonated then

		if self.Hit then
			self:Detonate()
			return false
		end

		if self.FirstThink == true then
			self.FirstThink = false
			self.LastThink = CurTime() - self.ThinkDelay
			self.LastVel = self.Launcher:GetVelocity() * self.ThinkDelay
		end
		self:CalcFlight()

        if self.CacheParticleEffect and (self.CacheParticleEffect <= CurTime()) and (CurTime() < self.CutoutTime) then
            local effect = ACF_GetGunValue(self.BulletData, "effect")

            if effect then
                ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, self:LookupAttachment("exhaust") or 0 )
            end

            self.CacheParticleEffect = nil
        end

	end

	return self.BaseClass.Think(self)
end




function ENT:PhysicsCollide()

	if self.Launched then

		if not self.MissileDetonated then
			self:Detonate()
			return
		end

	end

end




function ENT:OnRemove()

	self.BaseClass.OnRemove(self)

	ACF_ActiveMissiles[self] = nil

end




function ENT:ACF_Activate( Recalc )

	local EmptyMass = self.RoundWeight or self.Mass or 10

	self.ACF = self.ACF or {}

	local PhysObj = self:GetPhysicsObject()
	if not self.ACF.Aera then
		self.ACF.Aera = PhysObj:GetSurfaceArea() * 6.45
	end
	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end

	local ForceArmour = ACF_GetGunValue(self.BulletData, "armour")

	local Armour = ForceArmour or (EmptyMass*1000 / self.ACF.Aera / 0.78) --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume/ACF.Threshold							--Setting the threshold of the prop aera gone
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health/self.ACF.MaxHealth
	end

	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent/2)
	self.ACF.MaxArmour = Armour
	self.ACF.Type = nil
	self.ACF.Mass = self.Mass
	self.ACF.Density = (self:GetPhysicsObject():GetMass()*1000) / self.ACF.Volume
	self.ACF.Type = "Prop"

end




local nullhit = {Damage = 0, Overkill = 1, Loss = 0, Kill = false}

function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )	--This function needs to return HitRes

	if self.Detonated or self.DisableDamage then return table.Copy(nullhit) end

	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function

	-- Detonate if the shot penetrates the casing.
	HitRes.Kill = HitRes.Kill or HitRes.Overkill > 0

	if HitRes.Kill then

		local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
		if CanDo == false then return HitRes end

		self.Exploding = true

		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end

		self:ForceDetonate()

	end

	return HitRes

end




hook.Add("CanDrive", "acf_missile_CanDrive", function(ply, ent)
    if ent:GetClass() == "acf_missile" then return false end
end)
