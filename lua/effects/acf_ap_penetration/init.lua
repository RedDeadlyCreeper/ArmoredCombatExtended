
--[[---------------------------------------------------------
Initializes the effect. The data is a table of data
which was passed from the server.
-----------------------------------------------------------]]

local function DoubleSidedTraceResult( Effect )

	local BackTraceFilter = {}

	local FrontTraceData = {}
	FrontTraceData.start = Effect.Origin - Effect.DirVec:GetNormalized()
	FrontTraceData.endpos = Effect.Origin + Effect.DirVec * 150 --IK that. I prefer big props dont have a exit point than simply faking it if it never was.
	local FTrace = util.TraceLine(FrontTraceData)

	local BackTraceData = {}
	BackTraceData.start = FrontTraceData.endpos
	BackTraceData.endpos = FrontTraceData.start
	BackTraceData.filter = function( ent ) if ent == FTrace.Entity then return true else table.insert(BackTraceFilter, ent) return false end end
	local BTrace = util.TraceLine(BackTraceData)

	debugoverlay.Line(FrontTraceData.start, FTrace.HitPos , 5, Color(0,255,255))
	debugoverlay.Line(BackTraceData.start, BTrace.HitPos, 5, Color(191,255,0))

	return FTrace, BTrace, BackTraceFilter
end


function EFFECT:Init( data )
	self.AmmoCrate   = data:GetEntity()
	self.Origin      = data:GetOrigin()
	self.DirVec      = data:GetNormal()
	self.Velocity    = data:GetScale() --Mass of the projectile in kg
	self.Mass        = data:GetMagnitude() --Velocity of the projectile in gmod units

	self.Emitter     = ParticleEmitter( self.Origin )
	self.ParticleMul = math.Max( tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 0, 0)
	self.Scale       = math.max(self.Mass * (self.Velocity / 39.37) / 100, 1) ^ 0.3
	self.Caliber     = self.AmmoCrate:GetNWFloat( "Caliber", 10 )

	local FTrace, BTrace, BackTraceFilter = DoubleSidedTraceResult( self )

	util.Decal("Impact.Concrete", FTrace.StartPos, FTrace.HitPos + self.DirVec * 50, nil )
	util.Decal("Impact.Concrete", BTrace.StartPos, BTrace.HitPos - self.DirVec * 50, BackTraceFilter )

	self.Normal = FTrace.HitNormal
	if IsValid(FTrace.Entity) then
		debugoverlay.Text(self.Origin - self.DirVec * 20, FTrace.Entity:GetClass(), 5)
	end


	self:CreatePenetrationEffect()
	ACE_SPenetration( self.Origin, self.Velocity, self.Mass )

	if IsValid(self.Emitter) then self.Emitter:Finish() end
end

function EFFECT:CreatePenetrationEffect()

	for _ = 0, self.Scale * self.ParticleMul do

		local Debris = self.Emitter:Add( "effects/fleck_tile" .. math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( self.Normal * math.random( 20,140 * self.Scale) + VectorRand() * math.random( 25,150 * self.Scale) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 1.5 , 3 ) * self.Scale / 3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 1 * self.Scale )
			Debris:SetEndSize( 1 * self.Scale )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )
			Debris:SetAirResistance( 100 )
			Debris:SetGravity( Vector( 0, 0, -650 ) )
			Debris:SetColor( 120,120,120 )
		end
	end

	for _ = 0, self.Scale * self.ParticleMul do

		local Smoke = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 20,40 * self.Scale) + VectorRand() * math.random( 25,50 * self.Scale) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 ) * self.Scale / 3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 1 * self.Scale )
			Smoke:SetEndSize( 2 * self.Scale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 200 )
			Smoke:SetGravity( Vector( math.random(-5,5) * self.Scale, math.random(-5,5) * self.Scale, -50 ) )
			Smoke:SetColor( 90,90,90 )
		end

	end

	for _ = 0, self.Scale * self.ParticleMul do

		local Embers = self.Emitter:Add( "particles/flamelet" .. math.random(1,5), self.Origin )
		if (Embers) then
			Embers:SetVelocity ( (self.Normal - VectorRand()) * math.random(30 * self.Scale,80 * self.Scale) )
			Embers:SetLifeTime( 0 )
			Embers:SetDieTime( math.Rand( 0.3 , 1 ) * self.Scale / 5 )
			Embers:SetStartAlpha( 255 )
			Embers:SetEndAlpha( 0 )
			Embers:SetStartSize( 10 * self.Scale )
			Embers:SetEndSize( 0 * self.Scale )
			Embers:SetStartLength( 5 * self.Scale )
			Embers:SetEndLength ( 0 * self.Scale )
			Embers:SetRoll( math.Rand(0, 360) )
			Embers:SetRollDelta( math.Rand(-0.2, 0.2) )
			Embers:SetAirResistance( 20 )
			Embers:SetGravity( VectorRand() * 10 )
			Embers:SetColor( 200,200,200 )
		end
	end

	local Sparks = EffectData()
		Sparks:SetOrigin( self.Origin )
		Sparks:SetNormal( self.Normal + VectorRand() * 1.5)
		Sparks:SetMagnitude( self.Scale )
		Sparks:SetScale( self.Scale )
		Sparks:SetRadius( self.Scale )
	util.Effect( "sparks", Sparks )

end

--[[---------------------------------------------------------
	THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
	Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end


