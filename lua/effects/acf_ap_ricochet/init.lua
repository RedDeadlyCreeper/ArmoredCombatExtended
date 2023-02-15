

--[[---------------------------------------------------------
Initializes the effect. The data is a table of data
which was passed from the server.
-----------------------------------------------------------]]
function EFFECT:Init( data )
	self.Origin	= data:GetOrigin()
	self.DirVec	= data:GetNormal()
	self.Velocity	= data:GetScale()			-- Velocity of the projectile in gmod units
	self.Mass		= data:GetMagnitude()		-- Mass of the projectile in kg
	self.Emitter	= ParticleEmitter( self.Origin )
	self.Ent		= data:GetEntity()			-- the Ammocrate entity
	self.Id		= self.Ent:GetNWString( "AmmoType", "AP" )
	self.Scale = math.max(self.Mass * (self.Velocity / 39.37) / 100, 1) ^ 0.3
	self.ParticleMul  = tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1

	local Tr		= {}
	Tr.start		= self.Origin + self.DirVec
	Tr.endpos		= self.Origin - self.DirVec * 12000
	Tr.mins		= Vector(0,0,0)
	Tr.maxs		= Vector(0,0,0)
	local SurfaceTr	= util.TraceHull( Tr )

	util.Decal("Impact.Concrete", self.Origin + self.DirVec * 10, self.Origin - self.DirVec * 10 )

	self.Cal		= self.Ent:GetNWFloat("Caliber", 2 )
	ACEE_SRico( self.Origin, self.Cal, self.Velocity, SurfaceTr.HitWorld )

	--this is crucial for subcaliber, this will boost the dust's size.
	self.SubCalBoost = {
	APDS	= true,
	APDSS	= true,
	APFSDS	= true,
	APFSDSS  = true,
	APCR	= true,
	HVAP	= true
	}

	--the dust is for non-explosive rounds, so lets skip this.
	--Note that APHE variants are not listed here but they still require it in case of rico vs ground.
	local TypeIgnore = {
	HE	= true,
	HEFS	= true,
	HESH	= true,
	HEAT	= true,
	HEATFS	= true,
	THEAT	= true,
	THEATFS  = true
	}

	--do this if we are dealing with non-explosive rounds
	if not TypeIgnore[self.Id] then

	local Mat = SurfaceTr.MatType

	--concrete
	local SmokeColor = Color(100,100,100,150)

	-- Dirt
	if Mat == 68 or Mat == 79 or Mat == 85 then
		SmokeColor = Color(117,101,70,150)

	-- Sand
	elseif Mat == 78 then
		SmokeColor = Color(200,180,116,150)

	-- Glass
	elseif Mat == 89 then
		SmokeColor = Color(255,255,255,50)
	end

	if Mat ~= 77 and Mat ~= 86 and Mat ~= 80 then
		self:Dust( SmokeColor )
	else
		self:Metal()
	end

	end

	local BulletEffect	= {}
	BulletEffect.Num	= 1
	BulletEffect.Src	= self.Origin - self.DirVec
	BulletEffect.Dir	= self.DirVec
	BulletEffect.Spread  = Vector(0,0,0)
	BulletEffect.Tracer  = 0
	BulletEffect.Force	= 0
	BulletEffect.Damage  = 0
	LocalPlayer():FireBullets(BulletEffect)

	if IsValid(self.Emitter) then self.Emitter:Finish() end
end

function EFFECT:Dust( SmokeColor )

	--local PMul		= self.ParticleMul
	local Vel		= self.Velocity / 2500
	local Mass		= self.Mass

	local HalfArea	= ( self.SubCalBoost[self.Id] and 0.75) or 1
	local ShellArea	= 3.141 * (self.Cal / 2) * HalfArea

	--print(ShellArea)

	--KE main formula
	local Energy = math.Clamp((((Mass * (Vel ^ 2)) / 2) / 2) * ShellArea, 4, math.max(ShellArea ^ 0.95, 4)) / 2

	--print(Energy)

	for _ = 1, 3 do

	local Dust = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), self.Origin )
	if (Dust) then
		Dust:SetVelocity(VectorRand() * math.random( 20,30 * Energy) )
		Dust:SetLifeTime( 0 )
		Dust:SetDieTime( math.Rand( 1 , 2 ) * (Energy / 3)  )
		Dust:SetStartAlpha( math.Rand( math.max(SmokeColor.a-20,10), SmokeColor.a ) )
		Dust:SetEndAlpha( 0 )
		Dust:SetStartSize( 5 * Energy )
		Dust:SetEndSize( 60 * Energy )
		Dust:SetRoll( math.Rand(150, 360) )
		Dust:SetRollDelta( math.Rand(-0.2, 0.2) )
		Dust:SetAirResistance( 350 )
		Dust:SetGravity( Vector( math.random(-5,5) * Energy, math.random(-5,5) * Energy, -70 ) )

		Dust:SetColor( SmokeColor.r,SmokeColor.g,SmokeColor.b )
	end
	end

end

function EFFECT:Metal()

	local Sparks = EffectData()
	Sparks:SetOrigin( self.Origin )
	Sparks:SetNormal( self.DirVec + VectorRand() * 1.5)
	Sparks:SetMagnitude( self.Scale / 1.75 )
	Sparks:SetScale( self.Scale / 1.75 )
	Sparks:SetRadius( self.Scale / 1.75 )
	util.Effect( "Sparks", Sparks )

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


