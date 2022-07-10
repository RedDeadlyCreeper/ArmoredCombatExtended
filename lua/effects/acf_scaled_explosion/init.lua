
   
 --[[------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------]]
function EFFECT:Init( data ) 

	self.Origin 		= data:GetOrigin()
	self.DirVec 		= data:GetNormal()
	self.Radius 		= math.max( data:GetRadius()  / 50 ,1)
	self.Emitter 		= ParticleEmitter( self.Origin )
	self.ParticleMul 	= math.Max( tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1, 1)
	
	local GroundTr = { }
		GroundTr.start = self.Origin + Vector(0,0,1)*self.Radius
		GroundTr.endpos = self.Origin - Vector(0,0,1)*self.Radius*10
		GroundTr.mask = MASK_NPCWORLDSTATIC
		GroundTr.mins = Vector(0,0,0)
		GroundTr.maxs = Vector(0,0,0)

	local Ground = util.TraceHull( GroundTr )

	local WaterTr = { }

		local startposition = self.Origin + Vector(0,0,60 * self.Radius)
		local endposition = self.Origin + Vector(0,0,1)

		WaterTr.start = startposition
		WaterTr.endpos = endposition
		WaterTr.mask = MASK_WATER
		WaterTr.mins = Vector(0,0,0)
		WaterTr.maxs = Vector(0,0,0)
	local Water = util.TraceHull( WaterTr )

	debugoverlay.Line( startposition, endposition, 10, Color(255,0,0))
	debugoverlay.Cross( Water.HitPos, 10, 10, Color( 0, 0, 255 ))

	self.HitWater = false
	self.UnderWater = false
	self.Normal = Ground.HitNormal			

	--print('Radius: '..self.Radius)
	-- Material Enum
	-- 65  ANTLION
	-- 66 BLOODYFLESH
	-- 67 CONCRETE / NODRAW
	-- 68 DIRT
	-- 70 FLESH
	-- 71 GRATE
	-- 72 ALIENFLESH
	-- 73 CLIP
	-- 76 PLASTIC
	-- 77 METAL
	-- 78 SAND
	-- 79 FOLIAGE
	-- 80 COMPUTER
	-- 83 SLOSH
	-- 84 TILE
	-- 86 VENT
	-- 87 WOOD
	-- 89 GLASS

	local Mat = Ground.MatType
	local SmokeColor = Vector(100,100,100)

	if Water.HitWorld then

		self.HitWater = true
		if Water.StartSolid then
			self.UnderWater = true
		end
	end

	if not self.HitWater then

		-- when detonation is in midair
		if Ground.HitSky or not Ground.Hit then

			SmokeColor = Vector(100,100,100)
			self:Airburst( SmokeColor )

		-- Metal
		elseif Mat == 71 or Mat == 73 or Mat == 77 or Mat == 80 then 

			SmokeColor = Vector(170,170,170)
			self:Metal( SmokeColor )

		-- Dirt
		elseif Mat == 68 or Mat == 79 or Mat == 85 then 

			SmokeColor = Vector(117,101,70)
			self:Dirt( SmokeColor )	

		-- Sand
		elseif Mat == 78 then 

			SmokeColor = Vector(200,180,116)
			self:Sand( SmokeColor )

		-- Nonspecific
		else 

			SmokeColor = Vector(100,100,100)
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

	ACEE_SBlast( self.Origin, self.Radius, self.HitWater, Ground.HitWorld )

	if IsValid(self.Emitter) then self.Emitter:Finish() end
end   


function EFFECT:Core( HitWater )

	local Radius = self.Radius
	local PMul = self.ParticleMul

	local RandColor = 0
	local WaterColor = Color(255,255,255,100)

	local NumRand, Texture, TScale

	for i=0, Radius*PMul * 3 do --Explosion Core
	 
		local Flame = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Origin)
		if (Flame) then
			Flame:SetVelocity( VectorRand() * math.random(50,150*Radius) )
			Flame:SetLifeTime( 0 )
			Flame:SetDieTime( 0.2 )
			Flame:SetStartAlpha( math.Rand( 220, 255 ) )
			Flame:SetEndAlpha( 0 )
			Flame:SetStartSize( 10*Radius )
			Flame:SetEndSize( 15*Radius )
			Flame:SetRoll( math.random(120, 360) )
			Flame:SetRollDelta( math.Rand(-1, 1) )			
			Flame:SetAirResistance( 350 ) 			 
			Flame:SetGravity( Vector( 0, 0, 4 ) ) 			
			Flame:SetColor( 255,255,255 )
		end
	
	end

	for i=0, 3*Radius*PMul do --Flying Debris
	
		local Debris = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( VectorRand() * math.random(50*Radius,100*Radius) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 1.5 , 4 )*Radius/3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(0.1*Radius , 1*Radius) )
			Debris:SetEndSize( 0.5*Radius )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )			
			Debris:SetAirResistance( 25 ) 			 
			Debris:SetGravity( Vector( 0, 0, -650 ) ) 			
			Debris:SetColor( 120,120,120 )

			RandColor = 80-math.random( 0 , 50 )
			Debris:SetColor( RandColor,RandColor,RandColor )
		end
	end

	for i=0, 2*Radius*PMul do

		local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin + VectorRand() * Radius * 11 )
		if (Whisp) then
			Whisp:SetVelocity(VectorRand() * math.random( 50,150*Radius) )
			Whisp:SetLifeTime( 0 )
			Whisp:SetDieTime( math.Rand( 0.1 , 3 )*Radius/3  )
			Whisp:SetStartAlpha( math.Rand( 125, 150 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 10*Radius )
			Whisp:SetEndSize( 80*Radius)
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Whisp:SetAirResistance( 100 ) 			 
			Whisp:SetGravity( Vector( math.random(-5,5)*Radius, math.random(-5,5)*Radius, -140 ) )

			RandColor = 100-math.random( 0 , 45 )

			if HitWater or Underwater then
				RandColor = math.random( 0 , 50 )
				Whisp:SetColor( WaterColor.r-RandColor, WaterColor.g-RandColor, WaterColor.b-RandColor, 255 )
			else
				Whisp:SetColor( RandColor, RandColor, RandColor )
			end		
		end
	end

end

function EFFECT:Shockwave( Ground, SmokeColor )

	local PMul = self.ParticleMul

	local Radius = (1-Ground.Fraction)*self.Radius
	local Density = 15*Radius
	local Angle = Ground.HitNormal:Angle()
	for i=0, Density*PMul do

		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), Ground.HitPos )

		if (Smoke) then
			Smoke:SetVelocity( ShootVector * math.Rand(5,300*Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*Radius /3 )
			Smoke:SetStartAlpha( math.Rand( 50, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 10*Radius )
			Smoke:SetEndSize( 16*Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 200 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( 25 , 100 ) ) )	

			local SMKColor = math.random( 0 , 50 )
			Smoke:SetColor( SmokeColor.x-SMKColor,SmokeColor.y-SMKColor,SmokeColor.z-SMKColor )
		end	
	
	end

end

function EFFECT:Water( Water )

	local PMul = self.ParticleMul

	local WaterColor = Color(255,255,255,100)

	local Radius = self.Radius
	local Density = 15*Radius
	local Angle = Water.HitNormal:Angle()

	local Dist = math.max(math.abs((self.Origin - Water.HitPos):Length())*0.01,1)

	--print('R: '..Radius)
	--print('D: '..Dist)

	for i=0, Density*PMul do

		local TextureTb = {
			"particle/smokesprites_000"..math.random(1,9),
			"effects/splash4"
		}

		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( TextureTb[math.random(1,2)], Water.HitPos + Vector(0,0,5) )

		if (Smoke) then
			Smoke:SetVelocity( ShootVector * math.Rand(5,100*Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 2 , 6 )*Radius /3 )
			Smoke:SetStartAlpha( math.Rand( 50, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 10*Radius )
			Smoke:SetEndSize( 16*Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( -25 , -150 ) ) )	

			local SMKColor = math.random( 0 , 50 )
			Smoke:SetColor( WaterColor.r-SMKColor,WaterColor.g-SMKColor,WaterColor.b-SMKColor )
		end	
	end

	for i=0, 2*Radius*PMul do

		local TextureTb = {
			"particle/smokesprites_000"..math.random(1,9),
			"effects/splash4"
		}

		local Whisp = self.Emitter:Add( TextureTb[math.random(1,2)], Water.HitPos )

		if (Whisp) then
			local Randvec = VectorRand()
			local absvec = math.abs(Randvec.y)

			Whisp:SetVelocity(Vector(Randvec.x,Randvec.y,absvec) * math.random( 100*Radius/Dist,150*Radius/Dist) * Vector(0.15,0.15,1))
			Whisp:SetLifeTime( 0 )
			Whisp:SetDieTime( math.Rand( 3 , 5 )*Radius/3  )
			Whisp:SetStartAlpha( math.Rand( 100, 125 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 10*Radius )
			Whisp:SetEndSize( 80*Radius )
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Whisp:SetAirResistance( 100 ) 			 
			Whisp:SetGravity( Vector( math.random(-5,5)*Radius, math.random(-5,5)*Radius, -400 ) ) 	

			local SMKColor = math.random( 0 , 50 )
			Whisp:SetColor( WaterColor.r-SMKColor,WaterColor.g-SMKColor,WaterColor.b-SMKColor )
		end
	end

end

function EFFECT:Metal( SmokeColor )

--[[	
	for i=0, 3*self.Radius*self.ParticleMul do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*self.Radius) + VectorRand() * math.random( 30,60*self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*self.Radius/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*self.Radius )
			Smoke:SetEndSize( 30*self.Radius )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*self.Radius, math.random(-5,5)*self.Radius, -50 ) ) 			
			Smoke:SetColor( SmokeColor.x,SmokeColor.y,SmokeColor.z )
		end
	
	end
]]--
end

function EFFECT:Concrete( SmokeColor )

	for i=0, 5*self.Radius*self.ParticleMul do --Flying Debris
	
	local Fragments = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
	if (Fragments) then
		Fragments:SetVelocity ( VectorRand() * math.random(50*self.Radius,150*self.Radius) )
		Fragments:SetLifeTime( 0 )
		Fragments:SetDieTime( math.Rand( 1 , 2 )*self.Radius/3 )
		Fragments:SetStartAlpha( 255 )
		Fragments:SetEndAlpha( 0 )
		Fragments:SetStartSize( 0.25*self.Radius )
		Fragments:SetEndSize( 0.25*self.Radius )
		Fragments:SetRoll( math.Rand(0, 360) )
		Fragments:SetRollDelta( math.Rand(-3, 3) )			
		Fragments:SetAirResistance( 5 ) 			 
		Fragments:SetGravity( Vector( 0, 0, -650 ) ) 			
		
		RandColor = 80-math.random( 0 , 50 )

		Fragments:SetColor( RandColor,RandColor,RandColor )
		Fragments:SetColor( RandColor,RandColor,RandColor )
	end
end

	for i=0, 3*self.Radius*self.ParticleMul do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*self.Radius) + VectorRand() * math.random( 30,60*self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*self.Radius/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*self.Radius )
			Smoke:SetEndSize( 30*self.Radius )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 50 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*self.Radius, math.random(-5,5)*self.Radius, -250 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
	
end

function EFFECT:Dirt( SmokeColor )

	for i=0, 3*self.Radius*self.ParticleMul do

		NumRand = math.random(-1, 2)
		TScale = 1
		Texture = "particle/smokesprites_000"..math.random(1,9)

		if NumRand then
			TScale = 0.75
			Texture = "effects/splash4"
		end

		local Smoke = self.Emitter:Add( Texture, self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*self.Radius) + VectorRand() * math.random( 40,80*self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 5 )*self.Radius/3  )
			Smoke:SetStartAlpha( math.Rand( 150, 200 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 15*self.Radius * TScale )
			Smoke:SetEndSize( 30*self.Radius * TScale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-2,2)*self.Radius, math.random(-2,2)*self.Radius, -300 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
		
end

function EFFECT:Sand( SmokeColor )

	for i=0, 3*self.Radius*self.ParticleMul*2 do

		NumRand = math.random(-1, 2)
		TScale = 1
		Texture = "particle/smokesprites_000"..math.random(1,9)

		if NumRand then
			TScale = 0.75
			Texture = "effects/splash4"
		end

		local Smoke = self.Emitter:Add( Texture, self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*self.Radius) + VectorRand() * math.random( 30,60*self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 5 )*self.Radius/3  )
			Smoke:SetStartAlpha( math.Rand( 150, 200 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 15*self.Radius * TScale )
			Smoke:SetEndSize( 30*self.Radius * TScale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*self.Radius, math.random(-5,5)*self.Radius, -275 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end


end

function EFFECT:Airburst( SmokeColor )

	local Radius = self.Radius
	for i=0, 0.5*Radius*self.ParticleMul do --Flying Debris
	
		local Debris = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( VectorRand() * math.random(150*Radius,450*Radius) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 0.2 , 0.4 )*Radius/3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 0.5*Radius )
			Debris:SetEndSize( 0.5*Radius )
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
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
		
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end

 
