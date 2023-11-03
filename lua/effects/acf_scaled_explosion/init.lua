--[[-------------------------------------------------------
Initializes the effect. The data is a table of data
which was passed from the server.
---------------------------------------------------------]]

local function GetParticleMul()
	return math.max( tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1, 1)
end

function EFFECT:Init( data )

	self.HitWater = false
	self.UnderWater = false

	self.Origin        = data:GetOrigin()
	self.DirVec        = data:GetNormal()
	self.Radius        = math.max( data:GetRadius()  / 50 ,1)
	self.Emitter       = ParticleEmitter( self.Origin )
	self.ParticleMul   = GetParticleMul()

	local GroundTr = { }
		GroundTr.start = self.Origin + Vector(0,0,1) * self.Radius
		GroundTr.endpos = self.Origin - Vector(0,0,1) * self.Radius * 10
		GroundTr.mask = MASK_NPCWORLDSTATIC
	local Ground = util.TraceLine( GroundTr )

	local WaterTr = { }
		WaterTr.start = self.Origin + Vector(0,0,60 * self.Radius)
		WaterTr.endpos = self.Origin + Vector(0,0,1)
		WaterTr.mask = MASK_WATER
	local Water = util.TraceLine( WaterTr )

	if Water.HitWorld then
		self.HitWater = true
		if Water.StartSolid then
			self.UnderWater = true
		end
	end

	local Mat = Ground.MatType
	local Material = ACE_GetMaterialName( Mat )
	local SmokeColor = ACE.DustMaterialColor[Material] or ACE.DustMaterialColor["Concrete"]
	self.HitNormal = Ground.HitNormal

	if not self.HitWater then
		-- when detonation is in midair
		if Ground.HitSky or not Ground.Hit then
			self:Airburst( SmokeColor )
		elseif Material == "Dirt" then
			self:Dirt( SmokeColor )
		elseif Material == "Sand" then
			self:Sand( SmokeColor )
		else -- Nonspecific
			self:Concrete( SmokeColor )
		end
	end

	if Ground.HitWorld then

		if self.HitWater and not self.UnderWater then
			self:Water( Water )
		else
			self:Shockwave( Ground, SmokeColor )
		end
	end

	--Main explosion
	self:Core( self.HitWater )
	ACE_SBlast( self.Origin, self.Radius, self.HitWater, Ground.HitWorld )
	ACF_RenderLight( 0, self.Radius * 1800, Color(255, 128, 48), self.Origin, 0.1) -- idx 0: world

	if IsValid(self.Emitter) then self.Emitter:Finish() end
end


function EFFECT:Core( HitWater )

	if not self.Emitter then return end

	local Radius = self.Radius
	local PMul = self.ParticleMul

	local RandColor = 0
	local WaterColor = Color(255,255,255,100)

	--local NumRand, Texture, TScale

	for _ = 0, 3 * Radius * PMul do --Flying Debris

		local Debris = self.Emitter:Add( "effects/fleck_tile" .. math.random(1,2), self.Origin )
		if Debris then
			Debris:SetVelocity ( VectorRand() * math.random(50 * Radius,100 * Radius) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 1.5 , 4 ) * Radius / 3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(0.1 * Radius , 1 * Radius) )
			Debris:SetEndSize( 0.5 * Radius )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )
			Debris:SetAirResistance( 25 )
			Debris:SetGravity( Vector( 0, 0, -650 ) )
			Debris:SetColor( 120,120,120 )

			RandColor = 80-math.random( 0 , 50 )
			Debris:SetColor( RandColor,RandColor,RandColor )
		end
	end

	for _ = 0, 2 * Radius * PMul do

		local Whisp = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), self.Origin + VectorRand() * Radius * 11 )
		if Whisp then
			Whisp:SetVelocity(VectorRand() * math.random( 50,150 * Radius) )
			Whisp:SetLifeTime( 0 )
			Whisp:SetDieTime( math.Rand( 0.1 , 3 ) * Radius / 3  )
			Whisp:SetStartAlpha( math.Rand( 125, 150 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 10 * Radius )
			Whisp:SetEndSize( 80 * Radius)
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )
			Whisp:SetAirResistance( 100 )
			Whisp:SetGravity( Vector( math.random(-5,5) * Radius, math.random(-5,5) * Radius, -140 ) )

			RandColor = 100-math.random( 0 , 45 )

			if HitWater or Underwater then
				RandColor = math.random( 0 , 50 )
				Whisp:SetColor( WaterColor.r-RandColor, WaterColor.g-RandColor, WaterColor.b-RandColor, 255 )
			else
				Whisp:SetColor( RandColor, RandColor, RandColor )
			end
		end
	end

	local Glow = self.Emitter:Add( "sprites/orangeflare1", self.Origin )

	if Glow then
			Glow:SetLifeTime( 0 )
			Glow:SetDieTime( 0.15 )
			Glow:SetStartAlpha( math.Rand( 25, 50 ) )
			Glow:SetEndAlpha( 0 )
			Glow:SetStartSize( 200 * Radius )
			Glow:SetEndSize( 1 * Radius )
			Glow:SetColor( 255, 255, 255 )
	end

	for _ = 0, Radius * PMul * 3 do --Explosion Core

		local Flame = self.Emitter:Add( "particles/flamelet" .. math.random(1,5), self.Origin)
		if Flame then
			Flame:SetVelocity( VectorRand() * math.random(50,150 * Radius) )
			Flame:SetLifeTime( 0 )
			Flame:SetDieTime( 0.2 )
			Flame:SetStartAlpha( 255 )
			Flame:SetEndAlpha( 0 )
			Flame:SetStartSize( 10 * Radius )
			Flame:SetEndSize( 15 * Radius )
			Flame:SetRoll( math.random(120, 360) )
			Flame:SetRollDelta( math.Rand(-1, 1) )
			Flame:SetAirResistance( 350 )
			Flame:SetGravity( Vector( 0, 0, 4 ) )
			Flame:SetColor( 255,255,255 )
		end
	end
end

function EFFECT:Shockwave( Ground, SmokeColor )

	if not self.Emitter then return end

	local PMul       = self.ParticleMul
	local Radius     = (1-Ground.Fraction) * self.Radius
	local Density    = Radius
	local Angle      = Ground.HitNormal:Angle()

	for _ = 0, Density * PMul do

		Angle:RotateAroundAxis(Angle:Forward(), 360 / Density)
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), Ground.HitPos )

		if Smoke then
			Smoke:SetVelocity( ShootVector * math.Rand(5,300 * Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 ) * Radius / 3 )
			Smoke:SetStartAlpha( math.Rand( 50, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 10 * Radius )
			Smoke:SetEndSize( 16 * Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 200 )
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( 25 , 100 ) ) )

			local SMKColor = math.random( 0 , 50 )
			Smoke:SetColor( SmokeColor.r-SMKColor,SmokeColor.g-SMKColor,SmokeColor.b-SMKColor )
		end
	end
end

local TextureTb = {
	"effects/splash4",
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",

}

function EFFECT:Water( Water )

	if not self.Emitter then return end

	local PMul = self.ParticleMul

	local WaterColor = Color(255,255,255,100)

	local Radius   = self.Radius
	local Density  = Radius * 15
	local Angle    = Water.HitNormal:Angle()
	local Dist     = math.max(math.abs((self.Origin - Water.HitPos):Length()) * 0.01,1)

	for _ = 0, Density * PMul do

		Angle:RotateAroundAxis(Angle:Forward(), 360 / Density)
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( TextureTb[math.random(#TextureTb)], Water.HitPos + Vector(0,0,5) )

		if Smoke then
			Smoke:SetVelocity( ShootVector * math.Rand(5,100 * Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 2 , 6 ) * Radius / 3 )
			Smoke:SetStartAlpha( math.Rand( 50, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 10 * Radius )
			Smoke:SetEndSize( 16 * Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 100 )
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( -25 , -150 ) ) )

			local SMKColor = math.random( 0 , 50 )
			Smoke:SetColor( WaterColor.r-SMKColor,WaterColor.g-SMKColor,WaterColor.b-SMKColor )
		end
	end

	for _ = 0, 2 * Radius * PMul do

		local Whisp = self.Emitter:Add( TextureTb[math.random(#TextureTb)], Water.HitPos )

		if Whisp then
			local Randvec = VectorRand()
			local absvec = math.abs(Randvec.y)

			Whisp:SetVelocity(Vector(Randvec.x,Randvec.y,absvec) * math.random( 100 * Radius / Dist,150 * Radius / Dist) * Vector(0.15,0.15,1))
			Whisp:SetLifeTime( 0 )
			Whisp:SetDieTime( math.Rand( 3 , 5 ) * Radius / 3  )
			Whisp:SetStartAlpha( math.Rand( 100, 125 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 10 * Radius )
			Whisp:SetEndSize( 80 * Radius )
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )
			Whisp:SetAirResistance( 100 )
			Whisp:SetGravity( Vector( math.random(-5,5) * Radius, math.random(-5,5) * Radius, -400 ) )

			local SMKColor = math.random( 0 , 50 )
			Whisp:SetColor( WaterColor.r-SMKColor,WaterColor.g-SMKColor,WaterColor.b-SMKColor )
		end
	end
end

function EFFECT:Concrete( SmokeColor )

	if not self.Emitter then return end

	for _ = 0, 5 * self.Radius * self.ParticleMul do --Flying Debris

		local Fragments = self.Emitter:Add( "effects/fleck_tile" .. math.random(1,2), self.Origin )
		if Fragments then
			Fragments:SetVelocity ( VectorRand() * math.random(50 * self.Radius,150 * self.Radius) )
			Fragments:SetLifeTime( 0 )
			Fragments:SetDieTime( math.Rand( 1 , 2 ) * self.Radius / 3 )
			Fragments:SetStartAlpha( 255 )
			Fragments:SetEndAlpha( 0 )
			Fragments:SetStartSize( 0.25 * self.Radius )
			Fragments:SetEndSize( 0.25 * self.Radius )
			Fragments:SetRoll( math.Rand(0, 360) )
			Fragments:SetRollDelta( math.Rand(-3, 3) )
			Fragments:SetAirResistance( 5 )
			Fragments:SetGravity( Vector( 0, 0, -650 ) )

			RandColor = 80-math.random( 0 , 50 )

			Fragments:SetColor( RandColor,RandColor,RandColor )
			Fragments:SetColor( RandColor,RandColor,RandColor )
		end
	end

	for _ = 0, 3 * self.Radius * self.ParticleMul do

		local Smoke = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1,9), self.Origin )
		if Smoke then
			Smoke:SetVelocity( self.HitNormal * math.random( 50,80 * self.Radius) + VectorRand() * math.random( 30,60 * self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 ) * self.Radius / 3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5 * self.Radius )
			Smoke:SetEndSize( 30 * self.Radius )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 50 )
			Smoke:SetGravity( Vector( math.random(-5,5) * self.Radius, math.random(-5,5) * self.Radius, -250 ) )

			Smoke:SetColor(  SmokeColor.r,SmokeColor.g,SmokeColor.b  )
		end
	end
end

function EFFECT:Dirt( SmokeColor )

	if not self.Emitter then return end

	for _ = 0, 3 * self.Radius * self.ParticleMul do

		NumRand = math.random(-1, 2)
		TScale = 1
		Texture = "particle/smokesprites_000" .. math.random(1,9)

		if NumRand then
			TScale = 0.75
			Texture = "effects/splash4"
		end

		local Smoke = self.Emitter:Add( Texture, self.Origin )
		if Smoke then
			Smoke:SetVelocity( self.HitNormal * math.random( 50,80 * self.Radius) + VectorRand() * math.random( 40,80 * self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 5 ) * self.Radius / 3  )
			Smoke:SetStartAlpha( math.Rand( 150, 200 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 15 * self.Radius * TScale )
			Smoke:SetEndSize( 30 * self.Radius * TScale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 100 )
			Smoke:SetGravity( Vector( math.random(-2,2) * self.Radius, math.random(-2,2) * self.Radius, -300 ) )

			Smoke:SetColor(  SmokeColor.r,SmokeColor.g,SmokeColor.b  )

		end
	end
end

function EFFECT:Sand( SmokeColor )

	if not self.Emitter then return end

	for _ = 0, 3 * self.Radius * self.ParticleMul * 2 do

		NumRand = math.random(-1, 2)
		TScale = 1
		Texture = "particle/smokesprites_000" .. math.random(1,9)

		if NumRand then
			TScale = 0.75
			Texture = "effects/splash4"
		end

		local Smoke = self.Emitter:Add( Texture, self.Origin )
		if Smoke then
			Smoke:SetVelocity( self.HitNormal * math.random( 50,80 * self.Radius) + VectorRand() * math.random( 30,60 * self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 5 ) * self.Radius / 3  )
			Smoke:SetStartAlpha( math.Rand( 150, 200 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 15 * self.Radius * TScale )
			Smoke:SetEndSize( 30 * self.Radius * TScale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )
			Smoke:SetAirResistance( 100 )
			Smoke:SetGravity( Vector( math.random(-5,5) * self.Radius, math.random(-5,5) * self.Radius, -275 ) )

			Smoke:SetColor(  SmokeColor.r,SmokeColor.g,SmokeColor.b  )
		end
	end
end

function EFFECT:Airburst()

	if not self.Emitter then return end

	local Radius = self.Radius
	for _ = 0, 0.5 * Radius * self.ParticleMul do --Flying Debris

		local Debris = self.Emitter:Add( "effects/fleck_tile" .. math.random(1,2), self.Origin )
		if Debris then
			Debris:SetVelocity ( VectorRand() * math.random(150 * Radius,450 * Radius) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 0.2 , 0.4 ) * Radius / 3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 0.5 * Radius )
			Debris:SetEndSize( 0.5 * Radius )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )
			Debris:SetAirResistance( 5 )
			Debris:SetGravity( Vector( 0, 0, -650 ) )
			Debris:SetColor( 120,120,120 )

			RandColor = 50-math.random( 0 , 50 )
			Debris:SetColor( RandColor,RandColor,RandColor )
		end
	end
end

--[[---------------------------------------------------------
	THINK
-----------------------------------------------------------]]
function EFFECT:Think( )

end

--[[---------------------------------------------------------
	Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end


