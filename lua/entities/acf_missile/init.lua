AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("acf_explosive")

local GunTable	= ACF.Weapons.Guns
local GuidanceTable = ACF.Guidance
local FuseTable	= ACF.Fuse

function ENT:Initialize()

	self.PhysObj = self:GetPhysicsObject()

	if not IsValid(self.PhysObj) then self:Remove() return end --Prevent duping missiles (to stop errors)

	self.BaseClass.Initialize(self)

	if not IsValid(self:CPPIGetOwner()) then
		self:CPPISetOwner(player.GetAll()[1])
	end

	self.DetonateOffset = nil

	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableMotion( false )

	self.SpecialDamage = true	-- If true needs a special ACF_OnDamage function
	self.SpecialHealth = true	-- If true needs a special ACF_Activate function

	self.CanTrack	= false		-- Used when the missile has waited the required time to guide
	self.Timer	= false

	self.CutoutTime = CurTime() + 10000

	self:SetNWFloat("LightSize", 0)

end



--===========================================================================================
----- BulletData functions
--===========================================================================================
function ENT:SetBulletData(bdata) -- Called before to Initialize()

	self.BaseClass.SetBulletData(self, bdata)

	local gun = GunTable[bdata.Id]

	self:SetModelEasy( gun and (gun.round.model or gun.model) or "models/missiles/aim9.mdl" )

	self:ParseBulletData(bdata)

	local roundWeight = ACF_GetGunValue(bdata, "weight") or 10

	self.PhysObj = self:GetPhysicsObject()

	self.PhysObj:SetMass( roundWeight )

	self.RoundWeight = roundWeight

	self:ConfigureFlight()

	self.TrackDelay = gun.guidelay or 0

end

function ENT:ParseBulletData(bdata)

	local guidance  = bdata.Data7
	local fuse	= bdata.Data8

	if guidance then
		guidance = ACFM_CreateConfigurable(guidance, GuidanceTable, bdata, "guidance")
		if guidance then self:SetGuidance(guidance) end
	end

	if fuse then
		fuse = ACFM_CreateConfigurable(fuse, FuseTable, bdata, "fuses")
		if fuse then self:SetFuse(fuse) end
	end

end

--===========================================================================================
----- Physics functions
--===========================================================================================
function ENT:CalcFlight()

	if self.MissileDetonated then return end

	local Pos	= self.CurPos
	local Dir	= self.CurDir

	local LastVel	= self.LastVel
	local Flight	= self.FlightTime

	local Speed	= LastVel:Length()

	local Time	= CurTime()
	local DeltaTime = Time - self.LastThink

	if DeltaTime <= 0 then return end

	self.LastThink = Time
	Flight = Flight + DeltaTime

	if Speed == 0 then
		LastVel = Dir
		Speed = 1
	end

	-- Guidance calculations
	local Guidance  = self.Guidance:GetGuidance(self)
	local TargetPos = self.CanTrack and Guidance.TargetPos or nil
	local Tdelay	= self.ForceTdelay >= self.TrackDelay and self.ForceTdelay or self.TrackDelay

	-- Track delay calculation
	if Guidance.TargetPos then
		if Tdelay > self.TrackDelay then
			if not self.Timer then
				self.Timer = true

				timer.Simple(Tdelay, function()
					if not IsValid(self) then return end
						self.CanTrack = true
				end )
			end
		else
			self.CanTrack = true
		end
	end

	-- Physics calculations:
	-- If the missile has guidance and can turn
	if TargetPos then

		local missileInac = self.guidanceInac

		local Dist	= Pos:Distance(TargetPos)
		TargetPos	= TargetPos + (Vector(0,0,self.Gravity * Dist / 100000)) + Vector(math.random(-missileInac,missileInac),math.random(-missileInac,missileInac),math.random(-missileInac,missileInac))
		local LOS	= (TargetPos - Pos):GetNormalized()
		local LastLOS	= self.LastLOS
		local NewDir	= Dir
		local DirDiff	= 0

		if LastLOS then

			local Agility	= self.Agility
			local SpeedMul  = math.min((Speed / DeltaTime / self.MinimumSpeed) ^ 3,1)

			local LOSDiff	= math.deg(math.acos( LastLOS:Dot(LOS) )) * 20
			local MaxTurn	= Agility * SpeedMul * 5

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
		-- has not guidance

		local DirAng        = Dir:Angle()
		local VelNorm       = LastVel / Speed
		local AimDiff       = Dir - VelNorm
		local DiffLength    = AimDiff:Length()

		if DiffLength >= 0.001 and DiffLength < 1.95 and  Time > self.GhostPeriod then

			local Torque       = DiffLength * self.TorqueMul * Speed * self.RotMultipler
			local AngVelDiff   = Torque / self.Inertia * DeltaTime
			local DiffAxis     = AimDiff:Cross(Dir):GetNormalized()

			self.RotAxis       = self.RotAxis + DiffAxis * AngVelDiff
		end

		self.RotAxis = self.RotAxis * 0.99

		DirAng:RotateAroundAxis(self.RotAxis, self.RotAxis:Length())
		Dir = DirAng:Forward()

		self.LastLOS = nil
	end

	--Rocket motor is out or drowned
	local DragCoef = 0
	if Time > self.CutoutTime or (self:WaterLevel() == 3 and self.NotDrownable ) then

		DragCoef = (self:WaterLevel() == 3 and self.NotDrownable ) and self.DragCoef * 5 or self.DragCoef --5 times extra drag underwater

		if self.Motor ~= 0 then
			self.Motor = 0
			self:StopParticles()
			self:SetNWFloat("LightSize", 0)
		end
	else
		DragCoef = self.DragCoefFlight
	end

	-- Inertia/Motor thrust calculation

	local Vel        = LastVel + (Dir * self.Motor - Vector(0,0,self.Gravity )) * ACF.VelScale * DeltaTime ^ 2
	local Up         = Dir:Cross(Vel):Cross(Dir):GetNormalized()
	local Speed      = Vel:Length()
	local VelNorm    = Vel / Speed
	local DotSimple  = Up.x * VelNorm.x + Up.y * VelNorm.y + Up.z * VelNorm.z

	Vel = Vel - Up * Speed * DotSimple * self.FinMultiplier

	local SpeedSq	= Vel:LengthSqr()
	local Drag		= Vel:GetNormalized() * (DragCoef * SpeedSq) / ACF.DragDiv * ACF.VelScale

	Vel				= Vel - Drag

	local EndPos		= Pos + Vel

	do

		-- Hit/Impact detection

		local tracedata	= {}
		tracedata.start	= Pos
		tracedata.endpos	= EndPos
		tracedata.filter	= self.Filter
		tracedata.mins	= vector_origin
		tracedata.maxs	= tracedata.mins

		--Becomes volumetric once ghosting is over. So we avoid most of expensive calculations below
		if Time > self.GhostPeriod then

			local MRadius = (self.BulletData.Caliber / 2) * 0.5
			local maxs = Vector(MRadius,MRadius,MRadius)
			local mins = -maxs

			tracedata.mins	= mins
			tracedata.maxs	= maxs
		end

		local trace = util.TraceHull(tracedata)

		-- We have CFW
		if trace.Hit then

			local HitTarget  = trace.Entity

			-- Detonate when ghost time allows to.
			if not (IsValid(HitTarget) and Time < self.GhostPeriod) then

				self.HitNorm	= trace.HitNormal
				self:DoFlight(trace.HitPos)
				self.LastVel	= Vel / DeltaTime
				self:Detonate()
				return

			-- Determine if the detected ent is not part of the same contraption that fired this missile.
			elseif HitTarget:GetClass() ~= "acf_missile" then

				local IsPart = false

				if CFW then

					local conTarget	= HitTarget:GetContraption() or {}
					local conLauncher = self.Launcher:GetContraption() or {}

					if conTarget == conLauncher then -- Not required to do anything else.

						local mi, ma = HitTarget:GetCollisionBounds()
						debugoverlay.BoxAngles(HitTarget:GetPos(), mi, ma, HitTarget:GetAngles(), 5, Color(0,255,0,100))

						IsPart = true
					end

				else -- Press F to pay respects for the low end PCs by this. USE CFW.

					local RootTarget = ACF_GetPhysicalParent( HitTarget ) or game.GetWorld()
					local RootLauncher = self.Launcher.BaseEntity

					if RootLauncher:EntIndex() == RootTarget:EntIndex() then

						IsPart = true
					else

						--Note: caching the filter once can be easily bypassed by putting a prop of your own vehicle in front to fill the filter, then not caching any other prop.
						self.physentities = self.physentities or constraint.GetAllConstrainedEntities( RootTarget ) -- how expensive will be this with contraptions over 100 constrained ents?

						for _, physEnt in pairs(self.physentities) do

							if not IsValid(physEnt) then continue end

							if physEnt:EntIndex() == RootLauncher:EntIndex() then

								local mi, ma = physEnt:GetCollisionBounds()
								debugoverlay.BoxAngles(physEnt:GetPos(), mi, ma, physEnt:GetAngles(), 5, Color(0,255,0,100))

								IsPart = true
								break
							end


						end

					end
				end

				if not IsPart then

					self.HitNorm	= trace.HitNormal
					self:DoFlight(trace.HitPos)
					self.LastVel	= Vel / DeltaTime
					self:Detonate()
					return
				end

			end
		end



		--Detonation by fuse, if available
		if Time > self.GhostPeriod and self.Fuse:GetDetonate(self, self.Guidance) then
			self.LastVel = Vel / DeltaTime
			self:Detonate()
			return
		end

	end

	self.TrueVel = (EndPos - Pos) / DeltaTime
	self.LastVel	= Vel
	self.LastPos	= Pos
	self.CurPos	= EndPos
	self.CurDir	= Dir
	self.FlightTime = Flight

	--Missile trajectory debugging
	--.Line(Pos, EndPos, 10, Color(0, 255, 0))
	--debugoverlay.Line(EndPos, EndPos + Dir:GetNormalized()  * 50, 10, Color(0, 0, 255))

	self:DoFlight()
end

function ENT:DoFlight(ToPos, ToDir)

	local setPos = ToPos or self.CurPos
	local setDir = ToDir or self.CurDir

	self:SetPos(setPos)
	self:SetAngles(setDir:Angle())

	self.BulletData.Pos = setPos

end

--===========================================================================================
----- Launch function
--===========================================================================================
function ENT:Launch()

	if not IsValid(self.PhysObj) then self.PhysObj = self:GetPhysicsObject() end

	if not self.Guidance then
		self:SetGuidance(GuidanceTable.Dumb())
	end

	if not self.Fuse then
		self:SetFuse(FuseTable.Contact())
	end

	self.Guidance:Configure(self)
	self.Fuse:Configure(self, self.Guidance)

	self.Launched	= true
	self.ThinkDelay = 1 / 66
	self.Filter	= self.Filter or {self}

	self:SetParent(nil)

	self:ConfigureFlight()
	self.PhysObj:EnableMotion(false)

	ACF_ActiveMissiles[self] = true

	self:Think()
end

do

	local PushThrust = 30000

	-- WARNING: Hardcoded
	function ENT:MotorStart( GunData, Round, BulletData )

		if not self.Launched then return end

		if GunData.prepush then

			--Put a little of gunpowder to missile so it can fly a few meters before main rocket starts
			self.Motor = PushThrust

			--Small push
			timer.Simple( 0.01, function()
				if not IsValid(self) then return end

				self.Motor = 0
			end )

			--Ignition
			timer.Simple( 0.5, function()
				if not IsValid(self) then return end
				if self.MissileDetonated then return end
				if self:WaterLevel() > 0 and self.NotDrownable then return end

				local Time = CurTime()

				self.MotorLength	= BulletData.PropMass / (Round.burnrate / 1000) * (1 - Round.starterpct)
				self.Motor		= Round.thrust

				if self.Motor > 0 or self.MotorLength > 0.1 then --Ignition -- must not be called here
					self.MissileIgnited = true
					self.CacheParticleEffect = CurTime() + 0.1
					self:SetNWFloat("LightSize", BulletData.Caliber * 3)
					self.CutoutTime	= Time + self.MotorLength -- must not be called here
				end

				if self.Motor > 0 then
					self:LaunchEffect()
				end

			end )
		elseif not GunData.prepush then

			local noThrust  = ACF_GetGunValue(BulletData, "nothrust")
			local Time	= CurTime()

			if noThrust then
				self.MotorLength	= 0
				self.Motor		= 0
			else
				self.MotorLength	= BulletData.PropMass / (Round.burnrate / 1000) * (1 - Round.starterpct)
				self.Motor		= Round.thrust
			end

			if self.Motor > 0 or self.MotorLength > 0.1 then
				self.MissileIgnited = true
				self.CacheParticleEffect = CurTime() + 0.1
				self:SetNWFloat("LightSize", BulletData.Caliber * 3)
				self.CutoutTime	= Time + self.MotorLength
			end

			if self.Motor > 0 then
				self:LaunchEffect()
			end

		end

		local DRTime = 1250 / self.Motor

		timer.Simple( DRTime , function()
			self.NotDrownable = true --Given time to allow missiles to escape from the water before their motors are drowned
		end)

	end
end

function ENT:ConfigureFlight()

	local BulletData	= self.BulletData
	local GunData	= GunTable[BulletData.Id]
	local Round		= GunData.round

	self:MotorStart( GunData, Round, BulletData )

	self.FlightTime	= 0
	self.Gravity		= GetConVar("sv_gravity"):GetFloat()
	self.DragCoef	= Round.dragcoef
	self.DragCoefFlight = Round.dragcoefflight or Round.dragcoef
	self.MinimumSpeed	= Round.minspeed

	self.FinMultiplier  = Round.finmul
	self.Agility		= GunData.agility or 1
	self.guidanceInac	= GunData.guidanceInac or 0
	self.CurPos		= BulletData.Pos
	self.CurDir		= BulletData.Flight:GetNormalized()
	self.LastPos		= self.CurPos
	self.HitNorm		= vector_origin
	self.FirstThink	= true
	self.MinArmingDelay = math.max(Round.armdelay or GunData.armdelay, GunData.armdelay)

	local Mass		= GunData.weight
	local Length		= GunData.length
	local Width		= GunData.caliber

	self.RotMultipler	= GunData.rotmult or 1
	self.MaxTorque	= GunData.maxrottq or 1000000
	self.Inertia		= 0.08333 * Mass * (3.1416 * (Width / 2) ^ 2 + Length)
	self.TorqueMul	= Length * 3
	self.RotAxis		= vector_origin

	self.GhostPeriod = CurTime() + (GunData.ghosttime or 1)

	self:UpdateBodygroups()
	self:UpdateSkin()

end

--===========================================================================================
----- Guidance and Fuse functions
--===========================================================================================
function ENT:SetGuidance(guidance)

	self.Guidance = guidance
	guidance:Configure(self)

	return guidance

end

function ENT:SetFuse(fuse)

	self.Fuse = fuse
	fuse:Configure(self, self.Guidance or self:SetGuidance(GuidanceTable.Dumb()))

	return fuse

end

--===========================================================================================
----- Think
--===========================================================================================
function ENT:Think()

	if self.Launched and not self.MissileDetonated then

		local Time = CurTime()

		if self.FirstThink == true then
			self.FirstThink = false
			self.LastThink  = Time - self.ThinkDelay
			self.LastVel	= self.Launcher.acfphysparent:GetVelocity() * self.ThinkDelay
			self.TrueVel = self.Launcher.acfphysparent:GetVelocity()
		end

		self:CalcFlight()

		if self.CacheParticleEffect and (self.CacheParticleEffect <= Time) and (Time < self.CutoutTime) then

			if not (self:WaterLevel() == 3 and self.NotDrownable) then

				local effect = ACF_GetGunValue(self.BulletData, "effect")

				if effect then
					ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, self:LookupAttachment("exhaust") or 0 )
				end

			end

			self.CacheParticleEffect = nil
		end

		--Delete the missile if it was fired outside of the map
		if not self:IsInWorld() then
			self:Remove()
			return
		end

	end

	return self.BaseClass.Think(self)
end

--===========================================================================================
----- Detonation functions
--===========================================================================================
function ENT:Detonate()

	self:StopParticles()
	self.Motor = 0
	self:SetNWFloat("LightSize", 0)

	--Missile is below min arming time, so it becomes physical and useless
	if self.Fuse and (CurTime() - self.Fuse.TimeStarted < self.MinArmingDelay or not self.Fuse:IsArmed()) then
		self:Dud()
		return
	end

	self.BulletData.Flight = self:GetForward() * (self.BulletData.MuzzleVel or 10)
	self:ForceDetonate()

end

function ENT:ForceDetonate()

	-- careful not to conflict with base class's self.Detonated
	self.MissileDetonated = true

	ACF_ActiveMissiles[self] = nil

	self.DetonateOffset = self.LastVel and self.LastVel:GetNormalized() * -1
	self.BaseClass.Detonate(self, self.BulletData)

end

function ENT:Dud()

	self.MissileDetonated = true

	ACF_ActiveMissiles[self] = nil

	local Dud = self
	Dud:SetPos( self.CurPos )
	Dud:SetAngles( self.CurDir:Angle() )

	local Phys = Dud.PhysObj
	Phys:EnableGravity(true)
	Phys:EnableMotion(true)
	local Vel = self.LastVel

	if self.HitNorm ~= Vector(0,0,0) then
		local Dot	= self.CurDir:Dot(self.HitNorm)
		local NewDir	= self.CurDir - 2 * Dot * self.HitNorm
		local VelMul	= (0.8 + Dot * 0.7) * Vel:Length()
		Vel = NewDir * VelMul
	end

	if Vel then	--making check
		Phys:SetVelocity(Vel)
	end

	timer.Simple(30, function() if IsValid(self) then self:Remove() end end)
end

--===========================================================================================
----- Skin/Bodygroup/effect/Sound functions
--===========================================================================================
function ENT:LaunchEffect()
	local Effect = EffectData()
		Effect:SetEntity( self )
	util.Effect( "acf_missilelaunch", Effect, true, true )
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

function ENT:UpdateBodygroups()

	local bodygroups = self:GetBodyGroups()

	for _, group in pairs(bodygroups) do

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

--===========================================================================================
----- OnDamage functions
--===========================================================================================
function ENT:ACF_Activate( Recalc )

	local EmptyMass = self.RoundWeight or self.Mass or 10

	self.ACF = self.ACF or {}

	local PhysObj = self.PhysObj
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
	self.ACF.Density	= (self.PhysObj:GetMass() * 1000) / self.ACF.Volume
	self.ACF.Type	= "Prop"

	self.ACF.Material	= not isstring(self.ACF.Material) and ACE.BackCompMat[self.ACF.Material] or self.ACF.Material or "RHA"

end

do

	local nullhit = {Damage = 0, Overkill = 1, Loss = 0, Kill = false}

	function ENT:ACF_OnDamage( Entity , Energy , FrArea , Angle , Inflictor )	--This function needs to return HitRes

		if self.Detonated or self.DisableDamage then return table.Copy(nullhit) end

		local HitRes = ACF_PropDamage( Entity , Energy , FrArea , Angle , Inflictor )	--Calling the standard damage prop function

		-- Detonate if the shot penetrates the casing.
		HitRes.Kill = HitRes.Kill or HitRes.Overkill > 0

		if HitRes.Kill then

			local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
			if CanDo == false then return HitRes end

			self.Exploding = true

			if IsValid(Inflictor) and Inflictor:IsPlayer() then
				self.Inflictor = Inflictor
			end

			--self:ForceDetonate()

		end
		return HitRes
	end
end

local dontDrive = {
	acf_missile = true,
	ace_missile_swep_guided = true
}


hook.Add("CanDrive", "acf_missile_CanDrive", function(_, ent)
	if dontDrive[ent:GetClass()] then return false end
end)

function ENT:CanTool(ply, _, mode)
	if mode ~= "wire_adv" or (CPPI and ply ~= self:CPPIGetOwner()) then return false end
	return true
end

function ENT:OnRemove()

	self.BaseClass.OnRemove(self)

	ACF_ActiveMissiles[self] = nil

end
