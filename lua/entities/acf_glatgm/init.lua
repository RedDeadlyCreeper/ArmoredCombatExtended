AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	if self.BulletData.Caliber == 12.0 then
		self:SetModel( "models/missiles/glatgm/9m112.mdl" )
	elseif self.BulletData.Caliber > 12.0 then
		self:SetModel( "models/missiles/glatgm/mgm51.mdl" )
	else
		self:SetModel( "models/missiles/glatgm/9m117.mdl" )
		self:SetModelScale(self.BulletData.Caliber * 10 / 100,0)
	end

	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self.PhysObj = self:GetPhysicsObject()
	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableMotion( false )

	--Radar stuff
	self.ThinkDelay		= 1 / 66
	self.LastVel		= Vector(0,0,0)
	self.CurPos			= self:GetPos()
	self.LastPos		= self.CurPos
	ACF_ActiveMissiles[self] = true

	self.LastRun = 0

	--Missile stuff
	self.KillTime			= CurTime() + 20
	self.Time				= CurTime()
	self.Filter			= {self,self,self.Guidance}
	self.velocity			= 5000						-- self.velocity of the missile per second
	self.secondsOffset	= 0.5						-- seconds of forward flight to aim towards, to affect the beam-riding simulation

	--This only affects caliber below 100mm (10cms)
	self.Sub = self.BulletData.Caliber < 10
	if self.Sub then
		self.velocity = 2500
		self.secondsOffset = 0.25
		self.SpiralAm = (10-self.BulletData.Caliber) * 0.25 -- amount of artifical spiraling for <100 shells, caliber in acf is in cm
	end

	-- how far off the forward offset is for the targeting position
	self.offsetLength = self.velocity * self.secondsOffset

	--You need to declare the CPPI owner before seeing if the optic's owner is equal to the GLATGM's owner!
	self:CPPISetOwner(self.BulletData.Owner)

	--Gets the Closest computer to spawned missile to override gun´s guidance
	--Dont bother at using this if the table is empty
	if next(ACE.Opticals) then

		for _, Optical in pairs(ACE.Opticals) do
			--print("Looking for computer...")

			if not IsValid(Optical) then
				continue
			end

			--Range: 250. Note im using squared distance. So 250 ^ 2 means distance is 250
			if Optical:GetPos():DistToSqr(self:GetPos()) < 250 ^ 2 and Optical:CPPIGetOwner() == self:CPPIGetOwner() then

				--print("Attaching Nearest Computer...")
				--debugoverlay.Cross(Optical:GetPos(), 10, 10, Color(255,100,0), true)

				self.Guidance = Optical
				self.Optic = true

			end
		end
	end

	--Rocket Trail effect
	timer.Simple(0.1,function() ParticleEffectAttach("Rocket_Smoke_Trail",4, self,1)  end)

end

function ENT:Think()

	if IsValid(self) then

		local TimeNew = CurTime()

		local d = Vector(0,0,0)
		local dir = AngleRand() * 0.01
		local Dist = 0.01--100/10000

		if IsValid(self.Guidance) and self.Guidance:GetPos():Distance(self:GetPos()) < self.Distance then

			local di = self.Guidance:WorldToLocalAngles((self:GetPos() - self.Guidance:GetPos()):Angle())
			if di.p < 15 and di.p > -15 and di.y < 15 and di.y > -15 then
				local glpos = self.Guidance:GetPos() + self.Guidance:GetForward()

				if not self.Optic then
					glpos = self.Guidance:GetAttachment(1).Pos + self.Guidance:GetForward() * 20
				end

				local tr = util.QuickTrace(glpos, self.Guidance:GetForward() * (self.Guidance:GetPos():Distance(self:GetPos()) + self.offsetLength), {self.Guidance, self, self})

				d = tr.HitPos - self:GetPos()
				dir = self:WorldToLocalAngles(d:Angle()) * 0.02 --0.01 controls agility but is not scaled to timestep; bug poly
				Dist = self.Guidance:GetPos():Distance(self:GetPos()) / 39.37 / 10000
			end
		end

		local Spiral = d:Length() / 39370 or 0.5

		if self.Sub then
			Spiral = self.SpiralAm + (math.random(-self.SpiralAm * 0.5,self.SpiralAm) ) --Spaghett
		end

		local Inacc = math.random(-1, 1) * Dist
		self:SetAngles(self:LocalToWorldAngles(dir + Angle(Inacc, -Inacc, 5)))
		self:SetPos(self:LocalToWorld(Vector(self.velocity * (TimeNew - self.Time), Spiral, 0)))
		local tr = util.QuickTrace(self:GetPos() + self:GetForward() * -28, self:GetForward() * (self.velocity * (TimeNew - self.Time) + 300), self.Filter)

		self.Time = TimeNew

		--Break glatgms in contact with water. Assuming they are fast.
		if tr.Hit or self:WaterLevel() == 3 then
			self:Detonate()
		end

		self.CurPos = self:GetPos()

		local dT = CurTime() - self.LastRun
		self.LastRun = CurTime()
		self.LastVel = (self.CurPos - self.LastPos) / dT
		self.LastPos = self:GetPos()

		self:NextThink( CurTime() + 0,0151 )
		return true
	end
end

function ENT:Detonate()

	if IsValid(self) and not self.Detonated then

		ACF_ActiveMissiles[self] = nil
		self.Detonated = true

		self:Remove()

		btdat = {}
		btdat["Type"]		= "HEAT"
		btdat["Accel"]		= self.BulletData.Accel
		btdat["BoomPower"]	= self.BulletData.BoomPower
		btdat["Caliber"]		= self.BulletData.Caliber
		btdat["Crate"]		= self.BulletData.Crate
		btdat["DragCoef"]	= self.BulletData.DragCoef
		btdat["FillerMass"]	= self.BulletData.FillerMass
		btdat["Filter"]		= { self , self }
		btdat["Flight"]		= self.BulletData.Flight
		btdat["FlightTime"]	= 0
		btdat["FrArea"]		= self.BulletData.FrArea
		btdat["FuseLength"]	= 0
		btdat["Gun"]			= self
		btdat["Id"]			= self.BulletData.Id
		btdat["KETransfert"]	= self.BulletData.KETransfert
		btdat["LimitVel"]	= 100
		btdat["MuzzleVel"]	= self.BulletData.MuzzleVel
		btdat["Owner"]		= self.BulletData.Owner
		btdat["PenArea"]		= self.BulletData.PenArea
		btdat["Pos"]			= self.BulletData.Pos
		btdat["ProjLength"]	= self.BulletData.ProjLength
		btdat["ProjMass"]	= self.BulletData.ProjMass
		btdat["PropLength"]	= self.BulletData.PropLength
		btdat["PropMass"]	= self.BulletData.PropMass
		btdat["Ricochet"]	= self.BulletData.Ricochet
		btdat["DetonatorAngle"] = self.BulletData.DetonatorAngle
		btdat["RoundVolume"]	= self.BulletData.RoundVolume
		btdat["ShovePower"]	= self.BulletData.ShovePower
		btdat["Tracer"]		= self.BulletData.Tracer

		btdat["SlugMass"]	= self.BulletData.SlugMass
		btdat["SlugCaliber"]	= self.BulletData.SlugCaliber
		btdat["SlugDragCoef"]	= self.BulletData.SlugDragCoef
		btdat["SlugMV"]		= self.BulletData.SlugMV
		btdat["SlugPenArea"]	= self.BulletData.SlugPenArea
		btdat["SlugRicochet"]	= self.BulletData.SlugRicochet
		btdat["ConeVol"]		= self.BulletData.ConeVol
		btdat["CasingMass"]	= self.BulletData.CasingMass
		btdat["BoomFillerMass"] = self.BulletData.BoomFillerMass


		self.FakeCrate = ents.Create("acf_fakecrate2")
		self.FakeCrate:RegisterTo(btdat)
		btdat["Crate"] = self.FakeCrate:EntIndex()
		self:DeleteOnRemove(self.FakeCrate)

		btdat["Flight"] = self:GetForward():GetNormalized() * btdat["MuzzleVel"] * 39.37

		btdat.Pos = self:GetPos() + self:GetForward() * 2

		self.CreateShell = ACF.RoundTypes[btdat.Type].create
		self:CreateShell( btdat )

		local Flash = EffectData()
			Flash:SetOrigin( self:GetPos() )
			Flash:SetNormal( self:GetForward() )
			Flash:SetRadius(self.BulletData.FillerMass ^ 0.33 * 8 * 39.37 )
		util.Effect( "ACF_Scaled_Explosion", Flash )

	end
end
