
   
 --[[------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------]]
function EFFECT:Init( data ) 
	
	self.Entity = data:GetEntity() or NULL
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Radius = math.max( data:GetRadius() / 50 ,1)
	self.Emitter = ParticleEmitter( self.Origin )
	self.ParticleMul = tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1
	
	local GroundTr = { }
		GroundTr.start = self.Origin + Vector(0,0,1)
		GroundTr.endpos = self.Origin - Vector(0,0,1)*self.Radius*10
		GroundTr.mask = MASK_NPCWORLDSTATIC
	local Ground = util.TraceLine( GroundTr )

	local WaterTr = { }

		local startposition = self.Origin + Vector(0,0,100 * self.Radius)
		local endposition = self.Origin + Vector(0,0,1)

		WaterTr.start = startposition
		WaterTr.endpos = endposition
		WaterTr.mask = MASK_WATER
	local Water = util.TraceLine( WaterTr )

	debugoverlay.Line( startposition, endposition, 10, Color(255,0,0))
	debugoverlay.Cross( Water.HitPos, 10, 10, Color( 0, 0, 255 ))

	self.HitWater = false
	self.UnderWater = false
	self.Normal = Ground.HitNormal			
	
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

	--print(Mat)
	--print( Ground.HitWorld )

	if Water.HitWorld then
		if not Water.StartSolid then
			self.HitWater = true
		else
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
		if self.HitWater then
			self:Water( Water )
		else
			self:Shockwave( Ground, SmokeColor )
		end
	end

	--Main explosion
	self:Core()

	--print('Current Radius Explosion: '..self.Radius)

	local closeDist
	local MidDist
	local FarDist

	--Distances between each sound level MUST NOT too long, otherwise you will not hear anything at certain distance. Reason of why certain explosions sounds are weak at far distances 
	--TODO: Remove all this below and build something like acf sound proyect (i did some tests, but i don't have planned to include it yet, maybe next update. Just Admit, it's good enough anyways)
	--Temporal: make level sound divided into sections, tiny, small, medium and big booms. Maybe there i can adjust all sound scales correctly

	--small arm 
	if self.Radius <= 3 then

		closeDist = math.Clamp( self.Radius*5, 75, 90 )
		MidDist = math.Clamp( self.Radius*5.5, 85, 105 )
		FarDist = math.Clamp( self.Radius*6, 95, 115 )

	--grenade & other small calibers
	elseif self.Radius > 3 and self.Radius <= 5 then

		closeDist = math.Clamp( self.Radius*7.25, 100, 150)
		MidDist = math.Clamp( self.Radius*9.25, 150, 170)
		FarDist = math.Clamp( self.Radius*11.25, 170, 180)

	--most of atgms
	elseif self.Radius > 5 and self.Radius <= 10 then

		closeDist = math.Clamp( self.Radius*7.25, 100 , 150)
		MidDist = math.Clamp( self.Radius*9.25, 150 , 170)
		FarDist = math.Clamp( self.Radius*11.25, 170 ,180)

	--aim9
	elseif self.Radius > 10 and self.Radius <= 15 then

		closeDist = math.Clamp( self.Radius*7.25, 100 , 150)
		MidDist = math.Clamp( self.Radius*9.25, 150 , 170)
		FarDist = math.Clamp( self.Radius*11.25, 170 ,180)

	--aim 120
	elseif self.Radius > 15 and self.Radius <= 20 then

		closeDist = math.Clamp( self.Radius*6, 105 , 105)
		MidDist = math.Clamp( self.Radius*8, 150 , 150)
		FarDist = math.Clamp( self.Radius*10, 170 ,170)

	--big booms
	elseif self.Radius > 20 then

		closeDist = math.Clamp( self.Radius*6, 150 , 150)
		MidDist = math.Clamp( self.Radius*8, 170 , 170)
		FarDist = math.Clamp( self.Radius*10, 180 ,180)

	end

	local closepitch =  math.Clamp(1000/self.Radius,25,130)

	--print('----------Resolution----------')
	--print('CloseDist: '..closeDist)
	--print('MidDist: '..MidDist)
	--print('FarDist: '..FarDist)

	--print('Current Pitch: '..closepitch)
 
	--Defined when an explosion is big
	--CloseDist sound
	if self.Radius >= 10 then
		if not self.HitWater and not self.UnderWater then
			sound.Play( "acf_other/explosions/ambient/dist_close_"..math.random(1,3)..".wav", self.Origin , closeDist, closepitch, 255)

			if self.Radius >= 20 then
				sound.Play("ambient/explosions/explode_5.wav", self.Origin, closeDist , closepitch, 1)

			end
		elseif self.HitWater and not self.UnderWater then
			sound.Play( "ambient/water/water_splash"..math.random(1,3)..".wav", self.Origin, closeDist, closepitch-closepitch*0.25, math.Clamp(300 - self.Radius*12,100,255))
			sound.Play( "^weapons/underwater_explode3.wav", self.Origin, closeDist, closepitch, math.Clamp(300 - self.Radius*12,100,255))

		else
			sound.Play( "^weapons/underwater_explode3.wav", self.Origin, closeDist, closepitch, math.Clamp(300 - self.Radius*12,100,255))

		end
	else
		--Defined if an explosion is small
		if not self.HitWater then
			sound.Play( "acf_other/explosions/cookoff/cookOff"..math.random(1,4)..".wav", self.Origin , closeDist, closepitch, math.Clamp(300 - self.Radius*25,15,255))

		end
	end


	--MidDist sound
	--print('MidDist activated!')
	sound.Play( "acf_other/explosions/ambient/dist_medium_"..math.random(1,3)..".wav", self.Origin , MidDist, math.Clamp(closepitch,95,130), 255)

	--FarDist sound
	--print('FarDist activated!')
	sound.Play( "acf_other/explosions/ambient/dist_far_"..math.random(1,3)..".wav", self.Origin , FarDist, math.Clamp(closepitch,95,130), 255)


	if self.Emitter then self.Emitter:Finish() end
end   


function EFFECT:Core()

	local Radius = self.Radius
	local PMul = self.ParticleMul

	--if explosion is due to the ammo, fuel, create smoke embers
	--if self.Entity:IsValid() and (self.Entity:GetClass() == 'acf_ammo' or self.Entity:GetClass() == 'acf_fuel') then
	--	if (Radius*PMul)/2 > 10 then --Smoke Embers
	--		for i=0, (0.5*Radius*PMul)^0.1 do	
	--			--ParticleEffect( "ACF_BlastEmber", self.Origin+Vector(math.Rand(-Radius*5,Radius*5),math.Rand(-Radius*5,Radius*5),20+Radius), Angle(math.Rand(-10,10),0,math.Rand(-10,10))) --self.DirVec:Angle()
	--			ParticleEffect( "EmberCluster", self.Origin+Vector(0,0,5+Radius*5), Angle(math.Rand(-45,45),0,math.Rand(-45,45))) --self.DirVec:Angle()
	--		end
	--	end
	--end

	local RandColor = 0

	for i=0, 1*Radius*PMul * 2 do --Explosion Core
	 
		local Flame = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Origin)
		if (Flame) then
			Flame:SetVelocity( VectorRand() * math.random(50,150*Radius) )
			Flame:SetLifeTime( 0 )
			Flame:SetDieTime( 0.2 )
			Flame:SetStartAlpha( math.Rand( 200, 255 ) )
			Flame:SetEndAlpha( 0 )
			Flame:SetStartSize( 15*Radius )
			Flame:SetEndSize( 20*Radius )
			Flame:SetRoll( math.random(120, 360) )
			Flame:SetRollDelta( math.Rand(-1, 1) )			
			Flame:SetAirResistance( 300 ) 			 
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

		local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin + VectorRand() * 10 )
		if (Whisp) then
			Whisp:SetVelocity(VectorRand() * math.random( 50,150*Radius) )
			Whisp:SetLifeTime( 0 )
			Whisp:SetDieTime( math.Rand( 3 , 5 )*Radius/3  )
			Whisp:SetStartAlpha( math.Rand( 125, 150 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 10*Radius )
			Whisp:SetEndSize( 80*Radius )
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Whisp:SetAirResistance( 100 ) 			 
			Whisp:SetGravity( Vector( math.random(-5,5)*Radius, math.random(-5,5)*Radius, -50 ) )

			RandColor = 100-math.random( 0 , 45 )
			Whisp:SetColor( RandColor,RandColor,RandColor )		
		end
	end

end

function EFFECT:Shockwave( Ground, SmokeColor )

	local Radius = (1-Ground.Fraction)*self.Radius
	local Density = 15*Radius
	local Angle = Ground.HitNormal:Angle()
	for i=0, Density*self.ParticleMul do

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

	local WaterColor = Color(255,255,255,100)

	local Radius = self.Radius
	local Density = 15*Radius
	local Angle = Water.HitNormal:Angle()

	for i=0, Density*self.ParticleMul do	

		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), Water.HitPos + Vector(0,0,5) )

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

	for i=0, 2*Radius*self.ParticleMul do

		local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), Water.HitPos )

		if (Whisp) then
			local Randvec = VectorRand()
			local absvec = math.abs(Randvec.y)

			Whisp:SetVelocity(Vector(Randvec.x,Randvec.y,absvec) * math.random( 100*Radius,150*Radius) * Vector(0.15,0.15,1))
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

	for i=0, 3*self.Radius*self.ParticleMul do --Flying Debris
	
	local Fragments = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
	if (Fragments) then
		Fragments:SetVelocity ( VectorRand() * math.random(150*self.Radius,250*self.Radius) )
		Fragments:SetLifeTime( 0 )
		Fragments:SetDieTime( math.Rand( 1.5 , 2 )*self.Radius/3 )
		Fragments:SetStartAlpha( 255 )
		Fragments:SetEndAlpha( 0 )
		Fragments:SetStartSize( 0.5*self.Radius )
		Fragments:SetEndSize( 0.5*self.Radius )
		Fragments:SetRoll( math.Rand(0, 360) )
		Fragments:SetRollDelta( math.Rand(-3, 3) )			
		Fragments:SetAirResistance( 125 ) 			 
		Fragments:SetGravity( Vector( 0, 0, -650 ) ) 			
		Fragments:SetColor( 120,120,120 )

		RandColor = 80-math.random( 0 , 50 )
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
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*self.Radius) + VectorRand() * math.random( 30,60*self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 5 )*self.Radius/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*self.Radius )
			Smoke:SetEndSize( 30*self.Radius )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*self.Radius, math.random(-5,5)*self.Radius, -50 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
		
end

function EFFECT:Sand( SmokeColor )

	for i=0, 3*self.Radius*self.ParticleMul*2 do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*self.Radius) + VectorRand() * math.random( 30,60*self.Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 5 )*self.Radius/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*self.Radius )
			Smoke:SetEndSize( 30*self.Radius )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*self.Radius, math.random(-5,5)*self.Radius, -50 ) ) 			
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
	
		for i=0, (2*Radius*self.ParticleMul)^0.7 do	
	--		ParticleEffect( "ACF_BlastEmber", self.Origin+Vector(math.Rand(-Radius*5,Radius*5),math.Rand(-Radius*5,Radius*5),20+Radius), Angle(math.Rand(-10,10),0,math.Rand(-10,10))) --self.DirVec:Angle()
			ParticleEffect( "ACF_AirburstDebris", self.Origin+Vector(0,0,0), self.DirVec:Angle()) --self.DirVec:Angle()
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

 
