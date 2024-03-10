--[[---------------------------------------------------------
	Initializes the effect. The data is a table of data
	which was passed from the server.
-----------------------------------------------------------]]

--this is crucial for subcaliber, this will boost the dust's size.
local RoundTypesSubCaliberBoost = {
	APDS    = true,
	APDSS   = true,
	APFSDS  = true,
	APFSDSS = true,
	APCR    = true,
	HVAP    = true
}

--the dust is for non-explosive rounds, so lets skip this
local RoundTypesIgnore = {
	APHE    = true,
	APHECBC = true,
	HE      = true,
	HEFS    = true,
	HESH    = true,
	HEAT    = true,
	HEATFS  = true,
	THEAT   = true,
	THEATFS = true
}

local EntityFilter = {
	player = true
}

local function PerformDecalTrace( Effect )
	local Tr = {}
	Tr.start = Effect.Origin - Effect.DirVec * 10
	Tr.endpos = Effect.Origin + Effect.DirVec * 10
	return util.TraceLine( Tr )
end

local function PerformBulletEffect( Effect )
	local BulletEffect = {}
	BulletEffect.Num       = 1
	BulletEffect.Src       = Effect.Origin - Effect.DirVec
	BulletEffect.Dir       = Effect.DirVec
	BulletEffect.Spread    = Vector(0,0,0)
	BulletEffect.Tracer    = 0
	BulletEffect.Force     = 0
	BulletEffect.Damage    = 0
	LocalPlayer():FireBullets(BulletEffect)
end

function EFFECT:Init( data )

	self.AmmoCrate   = data:GetEntity() 		-- The ammo crate Entity of this round.
	self.Origin      = data:GetOrigin() 		-- where the round did hit.
	self.DirVec      = data:GetNormal() 		-- the direction of the shell when did hit
	self.Velocity    = data:GetScale() 			-- Mass of the projectile in kg
	self.Mass        = data:GetMagnitude() 		-- Velocity of the projectile in gmod units

	local ValidCrate = IsValid(self.AmmoCrate)

	self.Scale       = math.max(self.Mass * (self.Velocity / 39.37) / 100,1) ^ 0.3
	self.Id          = ValidCrate and self.AmmoCrate:GetNWString( "AmmoType", "AP" ) or "AP"
	self.Caliber     = ValidCrate and self.AmmoCrate:GetNWFloat( "Caliber", 2 ) or 2
	self.Emitter     = ParticleEmitter( self.Origin )

	local SurfaceTr = PerformDecalTrace( self )
	local TraceEntity = SurfaceTr.Entity

	--do this if we are dealing with non-explosive rounds. nil types are being created by HEAT, so skip it too
	if self.Id and not RoundTypesIgnore[self.Id] or (IsValid(TraceEntity) and not EntityFilter[TraceEntity:GetClass()]) then

		local Mat = SurfaceTr.MatType
		local Material = ACE_GetMaterialName( Mat )
		local SmokeColor = ACE.DustMaterialColor[Material] or ACE.DustMaterialColor["Concrete"]

		if Material == "Metal" then
			self:Metal( SmokeColor )
		else
			self:Dust( SmokeColor )
		end
	end

	PerformBulletEffect( self )
	util.Decal("Impact.Concrete", SurfaceTr.StartPos, self.Origin + self.DirVec * 10 )

	if self.Emitter then self.Emitter:Finish() end
end

function EFFECT:Dust( SmokeColor )

	if not self.Emitter then return end

	local Vel = self.Velocity / 2500
	local Mass = self.Mass

	local HalfArea = (RoundTypesSubCaliberBoost[self.Id] and 0.75) or 1
	local ShellArea = 3.141 * (self.Caliber / 2) * HalfArea

	--KE main formula
	local Energy = math.Clamp((((Mass * (Vel ^ 2)) / 2) / 2) * ShellArea, 4, math.max(ShellArea ^ 0.95, 4))

	for _ = 1, 3 do
		local Dust = self.Emitter:Add("particle/smokesprites_000" .. math.random(1, 9), self.Origin - self.DirVec * 5)

		if Dust then
			Dust:SetVelocity(VectorRand() * math.random(20, 30 * Energy))
			Dust:SetLifeTime(0)
			Dust:SetDieTime(math.Rand(1, 2) * (Energy / 3))
			Dust:SetStartAlpha(math.Rand(math.max(SmokeColor.a - 20, 10), SmokeColor.a))
			Dust:SetEndAlpha(0)
			Dust:SetStartSize(5 * Energy)
			Dust:SetEndSize(30 * Energy)
			Dust:SetRoll(math.Rand(150, 360))
			Dust:SetRollDelta(math.Rand(-0.2, 0.2))
			Dust:SetAirResistance(350)
			Dust:SetGravity(Vector(math.random(-5, 5) * Energy, math.random(-5, 5) * Energy, -70))
			Dust:SetColor(SmokeColor.r, SmokeColor.g, SmokeColor.b)
		end
	end

end

function EFFECT:Metal( SmokeColor )

	if not self.Emitter then return end

	local Vel = self.Velocity / 2500
	local Mass = self.Mass

	--this is the size boost fo subcaliber rounds
	local Boost = ( RoundTypesSubCaliberBoost[self.Id] and 2) or 1

	--KE main formula
	local Energy = math.max(((Mass * (Vel ^ 2)) / 2) * 0.005 * Boost, 2)

	-- Smoke Alpha
	local SmokeAlpha = SmokeColor.a * 0.5

	for _ = 0, math.max(self.Caliber / 3, 1) do
		local Dust = self.Emitter:Add("particle/smokesprites_000" .. math.random(1, 9), self.Origin - self.DirVec * 5)

		if Dust then
			Dust:SetVelocity(VectorRand() * math.random(25, 35 * Energy))
			Dust:SetLifeTime(0)
			Dust:SetDieTime(math.Rand(0.1, 4) * math.max(Energy, 2) / 3)
			Dust:SetStartAlpha(math.Rand(math.max(SmokeAlpha - 25, 10), SmokeAlpha))
			Dust:SetEndAlpha(0)
			Dust:SetStartSize(5 * Energy)
			Dust:SetEndSize(15 * Energy)
			Dust:SetRoll(math.Rand(150, 360))
			Dust:SetRollDelta(math.Rand(-0.2, 0.2))
			Dust:SetAirResistance(100)
			Dust:SetGravity(Vector(math.random(-5, 5) * Energy, math.random(-5, 5) * Energy, -70))
			Dust:SetColor(SmokeColor.r, SmokeColor.g, SmokeColor.b)
		end
	end

	local Sparks = EffectData()
	Sparks:SetOrigin(self.Origin)
	Sparks:SetNormal(self.DirVec + VectorRand() * 1.5)
	Sparks:SetMagnitude(self.Scale / 1.75)
	Sparks:SetScale(self.Scale / 1.75)
	Sparks:SetRadius(self.Scale / 1.75)
	util.Effect("Sparks", Sparks)

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