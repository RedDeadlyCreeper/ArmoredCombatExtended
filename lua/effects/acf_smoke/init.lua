--[[---------------------------------------------------------
Initializes the effect. The data is a table of data
which was passed from the server.
-----------------------------------------------------------]]

function EFFECT:Init( data )
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal() --Used for shell flight velocity
	self.DirVecNormal = self.DirVec:GetNormalized()
	self.Colour = data:GetStart()
	self.Radius = data:GetRadius() --Slow deployinging smoke. Radius in meters
	self.Magnitude = data:GetMagnitude() --Fast deploying WP. Radius in meters
	--print(self.Radius .. " " .. self.Magnitude)
	self.Emitter = ParticleEmitter( self.Origin )

	local ImpactTr = { }
		ImpactTr.start = self.Origin - self.DirVecNormal * 20
		ImpactTr.endpos = self.Origin + self.DirVecNormal * 20
		ImpactTr.mins = Vector(0,0,0)
		ImpactTr.maxs = Vector(0,0,0)
	local Impact = util.TraceHull(ImpactTr)										--Trace to see if it will hit anything
	self.Normal = Impact.HitNormal

	local GroundTr = { }
		GroundTr.start = self.Origin + Vector(0,0,1)
		GroundTr.endpos = self.Origin - Vector(0,0,1) * self.Radius
		GroundTr.mask = 131083
		GroundTr.mins = Vector(0,0,0)
		GroundTr.maxs = Vector(0,0,0)
	local Ground = util.TraceHull(GroundTr)

	local SmokeColor = self.Colour or Vector(255,255,255)
	if not Ground.HitWorld then Ground.HitNormal = Vector(0,0,1) end

	--[[if adjusting, update display data / crate text in smoke round
	if self.Magnitude > 0 then
		--self:SmokeFiller( Ground, SmokeColor, self.Magnitude * 1.25, 1.0, 6 + self.Magnitude / 10 ) --quick build and dissipate
	end

	if self.Radius > 0 then
		--self:SmokeFiller( Ground, SmokeColor, self.Radius * 1.25, 0.15, 20 + self.Radius / 4 ) --slow build but long lasting
	end
	]]--
	local SmokeMul = 3

	self:StartSmoke(Ground, SmokeColor, self.DirVec, self.Magnitude * SmokeMul, math.max(self.Radius * 4,self.Magnitude) * SmokeMul ) --The initial puff and streamers before the smoke gets up to size

	local Radius = math.max(self.Radius + self.Magnitude) * 5
	local Flash = EffectData()
		Flash:SetOrigin( self.Origin)
		Flash:SetNormal( self.DirVecNormal )
		Flash:SetRadius( math.max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )

	ACE_SBlast( self.Origin, self.Magnitude, false, Ground.HitWorld ) --hitwater is false

	self.Emitter:Finish()
end

--"particle/smokesprites_000" .. math.random(1,6)


function EFFECT:StartSmoke( SmokeColor, ShootVector, WPRadius, SRadius )

	local SmokeRadiusMul = 40 --Size multiplier for smoke particles to be 1 meter
	local StartTime = 0.5

	-- Calculate the wind effect on velocity and gravity
	-- Apply wind effect based on wind direction and windStrength
	local snorm = ShootVector:GetNormalized()
	local velocity = snorm * 7 * 39.37
	local gravity1 = Vector(0, 0, -75) --Used for initial smoke puff. Meant to be predictable.
	local gravity2 = gravity1 + ACF.Wind * 0.2
	--velocity = Vector(0, 0, 0)
	--gravity = Vector(0, 0, 0)

	for _ = 0, 3 do

		local Smoke = self.Emitter:Add("particle/smokesprites_000" .. math.random(1,6), self.Origin)
		if Smoke then
			Smoke:SetVelocity(velocity)
			Smoke:SetLifeTime(0)
			Smoke:SetDieTime(StartTime)
			Smoke:SetStartAlpha(0)
			Smoke:SetEndAlpha(120)
			Smoke:SetStartSize(WPRadius * SmokeRadiusMul / StartTime / 4 * 1)
			Smoke:SetEndSize(WPRadius * SmokeRadiusMul * 1)
			Smoke:SetAirResistance(0)
			Smoke:SetGravity(gravity1)
			Smoke:SetCollide( true )
			Smoke:SetColor(SmokeColor.x, SmokeColor.y, SmokeColor.z)
		end

	end

	for _ = 0, 6 do

		local Smoke = self.Emitter:Add("particle/smokesprites_000" .. math.random(1,6), self.Origin + velocity * StartTime + 0.5 * gravity1 * StartTime^2)
		if Smoke then
			Smoke:SetVelocity(velocity + gravity1 * StartTime)
			Smoke:SetLifeTime(-StartTime)
			Smoke:SetDieTime(20) --20
			Smoke:SetStartAlpha(150)
			Smoke:SetEndAlpha(255)
			Smoke:SetStartSize(WPRadius * SmokeRadiusMul)
			Smoke:SetEndSize(WPRadius * SmokeRadiusMul)
			Smoke:SetRollDelta(math.Rand(-0.2, 0.2))
			Smoke:SetAirResistance(50)
			Smoke:SetGravity(gravity2 + VectorRand() * WPRadius * 5)
			Smoke:SetCollide( true )
			Smoke:SetColor(SmokeColor.x, SmokeColor.y, SmokeColor.z)
		end

	end

	for _ = 0, 3 do

		local Smoke = self.Emitter:Add("particle/smokesprites_000" .. math.random(1,6), self.Origin + velocity * StartTime + 0.5 * gravity1 * StartTime^2)
		if Smoke then
			Smoke:SetVelocity(velocity + gravity1 * StartTime)
			Smoke:SetLifeTime(-StartTime)
			Smoke:SetDieTime(0) --25
			Smoke:SetStartAlpha(150)
			Smoke:SetEndAlpha(255)
			Smoke:SetStartSize(math.max(WPRadius * SmokeRadiusMul,SRadius * SmokeRadiusMul / 25))
			Smoke:SetEndSize(SRadius * SmokeRadiusMul)
			Smoke:SetRollDelta(math.Rand(-0.2, 0.2))
			Smoke:SetAirResistance(50)
			Smoke:SetGravity(gravity2)
			Smoke:SetCollide( true )
			Smoke:SetColor(SmokeColor.x, SmokeColor.y, SmokeColor.z)
		end

	end



--	self:SmokeStreamer(self.Origin, snorm * 14*39.37, SmokeColor, 3)

	--[[
	--Radius Debugging Circle
	local Test = SRadius * 1.3 * 1 --1.3 for lethal radius. 1.0 for Indicated radius of HE
	local B = self.Emitter:Add( "effects/splashwake3", self.Origin )

	if B then
		B:SetLifeTime( 0 )
		B:SetDieTime( 6 )
		B:SetStartAlpha( 255 )
		B:SetEndAlpha( 255 )
		B:SetStartSize( 20.915 * Test )
		B:SetEndSize( 20.915 * Test )
		B:SetColor( 255, 255, 255 )
	end
	]]--

end





function EFFECT:SmokeStreamer(ShootPos, ShootVector, SmokeColor, SRadius )


	local ParticleCount = math.ceil( math.Clamp( SRadius , 10, 300 ) )

	for i = 1, ParticleCount do
		local Dust = self.Emitter:Add("particles/smokey", ShootPos )

		if Dust then
			Dust:SetVelocity(ShootVector)
			Dust:SetLifeTime(-0.025 * i)
			Dust:SetDieTime(3)
			Dust:SetStartAlpha(255)
			Dust:SetEndAlpha(255)
			Dust:SetStartSize(3 * SRadius)
			Dust:SetEndSize(30 * SRadius)
			Dust:SetRoll(math.Rand(150, 360))
			Dust:SetRollDelta(math.Rand(-0.5, 0.5))
			Dust:SetAirResistance(10)
			Dust:SetGravity(Vector(0, 0, -250))
			Dust:SetCollide( true )
			Dust:SetColor(SmokeColor.r, SmokeColor.g, SmokeColor.b)
			local Length = 0.05 * ShootVector:Length()
			Dust:SetStartLength( Length )
			Dust:SetEndLength( Length ) --Length
		end
	end

end
















local function smokePuff(self, Ground, ShootVector, Radius, RadiusMod, SmokeColor, DeploySpeed, Lifetime)

	local Smoke = self.Emitter:Add("particle/smokesprites_000" .. math.random(1,6), Ground.HitPos)
	if Smoke then
		-- Calculate the wind effect on velocity and gravity
		-- Apply wind effect based on wind direction and windStrength
		local velocity = (ShootVector + Vector(0, 0, 0.2)) * DeploySpeed
		local gravity = Vector(0, 0, -200) + ACF.Wind * 0.2


		Smoke:SetVelocity(velocity)
		Smoke:SetLifeTime(0)
		Smoke:SetDieTime(math.Clamp(Lifetime, 1, 60))
		Smoke:SetStartAlpha(math.Rand(200, 255))
		Smoke:SetEndAlpha(0)
		Smoke:SetStartSize(math.Clamp((Radius * RadiusMod) * DeploySpeed, 5, 1000))
		Smoke:SetEndSize(math.Clamp(Radius * RadiusMod * 4, 150, 4000))
		Smoke:SetRoll(math.Rand(0, 360))
		Smoke:SetRollDelta(math.Rand(-0.2, 0.2))
		Smoke:SetAirResistance(100)
		Smoke:SetGravity(gravity)
		Smoke:SetCollide( true )
		Smoke:SetColor(SmokeColor.x, SmokeColor.y, SmokeColor.z)
	end
end




function EFFECT:SmokeFiller( Ground, SmokeColor, Radius, DeploySpeed, Lifetime )

	local Density = Radius / 18
	local Angle = Ground.HitNormal:Angle()
	local ShootVector = Ground.HitNormal * 0.5
	--print(Radius .. ", " .. Density)

	smokePuff(self, Ground, Vector(0, 0, 0.3), Radius, 1.5, SmokeColor, DeploySpeed, Lifetime) --smoke filler initial upward puff
	for _ = 0, math.floor(Density) do
		smokePuff(self, Ground, ShootVector, Radius, 1, SmokeColor, DeploySpeed, Lifetime)

		ShootVector = Angle and Angle:Up()
		Angle:RotateAroundAxis(Angle:Forward(), 360 / Density)
	end
end

--keep this here, error pops up if it's removed
function EFFECT:Render()
end

