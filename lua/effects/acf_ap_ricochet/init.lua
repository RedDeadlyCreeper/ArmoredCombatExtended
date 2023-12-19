

--[[---------------------------------------------------------
Initializes the effect. The data is a table of data
which was passed from the server.
-----------------------------------------------------------]]

--this is crucial for subcaliber, this will boost the dust's size.
local RoundTypesSubCaliberBoost = {
	APDS       = true,
	APDSS      = true,
	APFSDS     = true,
	APFSDSS    = true,
	APCR       = true,
	HVAP       = true
}

--the dust is for non-explosive rounds, so lets skip this.
--Note that APHE variants are not listed here but they still require it in case of rico vs ground.
local RoundTypesIgnore = {
	HE       = true,
	HEFS     = true,
	HESH     = true,
	HEAT     = true,
	HEATFS   = true,
	THEAT    = true,
	THEATFS  = true
}

local function PerformDecalTrace( Effect )
	local Tr = {}
	Tr.start = Effect.Origin + Effect.DirVec
	Tr.endpos = Effect.Origin - Effect.DirVec * 12000
	return util.TraceLine( Tr )
end

local function GetParticleMul()
	return math.max( tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1, 1)
end

function EFFECT:Init( data )

	self.AmmoCrate   = data:GetEntity() 		-- The ammo crate Entity of this round.
	self.Origin      = data:GetOrigin() 		-- where the round did hit.
	self.DirVec      = data:GetNormal() 		-- the direction of the shell when did hit
	self.Velocity    = data:GetScale() 			-- Mass of the projectile in kg
	self.Mass        = data:GetMagnitude() 		-- Velocity of the projectile in gmod units

	local ValidCrate = IsValid( self.AmmoCrate )

	self.Scale         = math.max(self.Mass * (self.Velocity / 39.37) / 100, 1) ^ 0.3
	self.Id            = ValidCrate and self.AmmoCrate:GetNWString( "AmmoType", "AP" ) or "AP"
	self.Caliber       = ValidCrate and self.AmmoCrate:GetNWFloat( "Caliber", 2 ) or 2
	self.Emitter       = ParticleEmitter( self.Origin )
	self.ParticleMul   = GetParticleMul()

	local SurfaceTr	= PerformDecalTrace( self )

	--do this if we are dealing with non-explosive rounds
	if not RoundTypesIgnore[self.Id] then

		local Mat = SurfaceTr.MatType
		local Material = ACE_GetMaterialName( Mat )
		local SmokeColor = ACE.DustMaterialColor[Material] or ACE.DustMaterialColor["Concrete"]

		if Material == "Metal" then
			self:Metal( SmokeColor )
		else
			self:Dust( SmokeColor )
		end
	end

	util.Decal("Impact.Concrete", self.Origin + self.DirVec * 10, self.Origin - self.DirVec * 10 )
	ACE_SRicochet( self.Origin, self.Caliber, self.Velocity, SurfaceTr.HitWorld )

	if IsValid(self.Emitter) then self.Emitter:Finish() end
end

function EFFECT:Dust( SmokeColor )

	if not self.Emitter then return end

	local Vel		= self.Velocity / 2500
	local Mass		= self.Mass

	local HalfArea	= ( RoundTypesSubCaliberBoost[self.Id] and 0.75) or 1
	local ShellArea	= 3.141 * (self.Caliber / 2) * HalfArea

	--KE main formula
	local Energy = math.Clamp((((Mass * (Vel ^ 2)) / 2) / 2) * ShellArea, 4, math.max(ShellArea ^ 0.95, 4)) / 2

	for _ = 1, 3 do
		local Dust = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), self.Origin )
		if Dust then
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


