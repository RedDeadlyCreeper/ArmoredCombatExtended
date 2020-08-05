
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Radius = math.max(data:GetRadius()/50,1)
	self.Emitter = ParticleEmitter( self.Origin )
	self.ParticleMul = tonumber(LocalPlayer():GetInfo("acf_cl_particlemul")) or 1
	
	local ImpactTr = { }
		ImpactTr.start = self.Origin - self.DirVec*20
		ImpactTr.endpos = self.Origin + self.DirVec*20
	local Impact = util.TraceLine(ImpactTr)					--Trace to see if it will hit anything
	self.Normal = Impact.HitNormal
	
	local GroundTr = { }
		GroundTr.start = self.Origin + Vector(0,0,1)
		GroundTr.endpos = self.Origin - Vector(0,0,1)*self.Radius*10
		GroundTr.mask = 131083
	local Ground = util.TraceLine(GroundTr)				
	
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

	local Mat = Impact.MatType
	local SmokeColor = Vector(90,90,90)
	if Impact.HitSky or not Impact.Hit then
		SmokeColor = Vector(90,90,90)
		self:Airburst( SmokeColor )
	elseif Mat == 71 or Mat == 73 or Mat == 77 or Mat == 80 then -- Metal
		SmokeColor = Vector(170,170,170)
		self:Metal( SmokeColor )
	elseif Mat == 68 or Mat == 79 then -- Dirt
		SmokeColor = Vector(100,80,50)
		self:Dirt( SmokeColor )	
	elseif Mat == 78 then -- Sand
		SmokeColor = Vector(100,80,50)
		self:Sand( SmokeColor )
	else -- Nonspecific
		SmokeColor = Vector(90,90,90)
		self:Concrete( SmokeColor )
	end
	
	if Ground.HitWorld then
		self:Shockwave( Ground, SmokeColor )
	end

end   

--particle\muzzleflash\noisecloud1.vmt -- Upward Blast
--particle\fire_particle_2\fire_particle_2.vmt --Center Blast
--particle\smoke1\smoke1.vmt --New Smoke

--[[
function EFFECT:Core()
	
	if self.Radius*self.ParticleMul > 4 then
		for i=0, 0.5*self.Radius*self.ParticleMul do
			local Cookoff = EffectData()				
				Cookoff:SetOrigin( self.Origin )
				Cookoff:SetScale( self.Radius/6 )
			util.Effect( "ACF_Cookoff", Cookoff )
		end
	end
--	sound.Play( "ambient/explosions/explode_"..math.random(1,9)..".wav", self.Origin , math.Clamp(self.Radius*10,75,165), math.Clamp(300 - self.Radius*12,15,255))
	sound.Play( "acf_other/explosions/cookOff"..math.random(1,4)..".wav", self.Origin , math.Clamp(self.Radius*10,75,165), math.Clamp(300 - self.Radius*25,15,255))
end
]]--

--particle\muzzleflash\noisecloud1.vmt -- Upward Blast
--particle\fire_particle_2\fire_particle_2.vmt --Center Blast
--particle\smoke1\smoke1.vmt --New Smoke

function EFFECT:Core()
	
--	local AirBurst = self.Emitter:Add( "ACF_Explosion", self.Origin )

local Radius = self.Radius
local PMul = self.ParticleMul

if (Radius*PMul)/2 > 10 then --Smoke Embers
	for i=0, (0.5*Radius*PMul)^0.7 do	
--		ParticleEffect( "ACF_BlastEmber", self.Origin+Vector(math.Rand(-Radius*5,Radius*5),math.Rand(-Radius*5,Radius*5),20+Radius), Angle(math.Rand(-10,10),0,math.Rand(-10,10))) --self.DirVec:Angle()
		ParticleEffect( "ACF_BlastEmber", self.Origin+Vector(0,0,5+Radius*5), Angle(math.Rand(-45,45),0,math.Rand(-45,45))) --self.DirVec:Angle()
	end
end

local RandColor = 0

for i=0, 1*Radius*PMul do --Explosion Core
	 
	local Flame = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Origin)
	if (Flame) then
		Flame:SetVelocity( VectorRand() * math.random(50,150*Radius) )
		Flame:SetLifeTime( 0 )
		Flame:SetDieTime( 0.5 )
		Flame:SetStartAlpha( math.Rand( 50, 255 ) )
		Flame:SetEndAlpha( 0 )
		Flame:SetStartSize( 0.5*Radius )
		Flame:SetEndSize( 15*Radius )
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
		Debris:SetVelocity ( VectorRand() * math.random(150*Radius,250*Radius) )
		Debris:SetLifeTime( 0 )
		Debris:SetDieTime( math.Rand( 1.5 , 3 )*Radius/3 )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( 1*Radius )
		Debris:SetEndSize( 1*Radius )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-3, 3) )			
		Debris:SetAirResistance( 10 ) 			 
		Debris:SetGravity( Vector( 0, 0, -650 ) ) 			
		Debris:SetColor( 120,120,120 )
		RandColor = 80-math.random( 0 , 50 )
		Debris:SetColor( RandColor,RandColor,RandColor )
	end
end

for i=0, 2*Radius*PMul do
	local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Whisp) then
			Whisp:SetVelocity(VectorRand() * math.random( 50,150*Radius) )
			Whisp:SetLifeTime( 0 )
			Whisp:SetDieTime( math.Rand( 3 , 5 )*Radius/3  )
			Whisp:SetStartAlpha( math.Rand( 100, 150 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 10*Radius )
			Whisp:SetEndSize( 80*Radius )
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Whisp:SetAirResistance( 100 ) 			 
			Whisp:SetGravity( Vector( math.random(-5,5)*Radius, math.random(-5,5)*Radius, 0 ) ) 	
			RandColor = 100-math.random( 0 , 75 )
			Whisp:SetColor( RandColor,RandColor,RandColor )		
		end
end


		--[[
	if self.Radius*self.ParticleMul > 4 then
--		for i=0, 0.5*self.Radius*self.ParticleMul do
			local Cookoff = EffectData()				
				Cookoff:SetOrigin( self.Origin )
				Cookoff:SetScale( self.Radius*3 )
			util.Effect( "ACF_Explosion", Cookoff )
--		end
	end
]]--


	sound.Play( "ambient/explosions/explode_"..math.random(1,9)..".wav", self.Origin , math.Clamp(self.Radius*10,75,165), math.Clamp(300 - self.Radius*12,15,255))
	sound.Play( "acf_other/explosions/cookOff"..math.random(1,4)..".wav", self.Origin , math.Clamp(self.Radius*10,75,165), math.Clamp(300 - self.Radius*25,15,255))
end

-----
-----
-----
-----
-----
-----



function EFFECT:Shockwave( Ground, SmokeColor )

	local Mat = Ground.MatType
	local Radius = (1-Ground.Fraction)*self.Radius
	local Density = 15*Radius
	local Angle = Ground.HitNormal:Angle()
	for i=0, Density*self.ParticleMul do	
--		particle\smoke1\smoke1
		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), Ground.HitPos )
		if (Smoke) then
			Smoke:SetVelocity( ShootVector * math.Rand(5,200*Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*Radius /3 )
			Smoke:SetStartAlpha( math.Rand( 50, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 4*Radius )
			Smoke:SetEndSize( 15*Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 200 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( 10 , 100 ) ) )			
			local SMKColor = math.random( 0 , 50 )
			Smoke:SetColor( SmokeColor.x-SMKColor,SmokeColor.y-SMKColor,SmokeColor.z-SMKColor )
		end	
	
	end

end

function EFFECT:Metal( SmokeColor )

	self:Core()
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

	self:Core()
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
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
]]--	
end

function EFFECT:Dirt( SmokeColor )
	
	self:Core()
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
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
]]--		
end

function EFFECT:Sand( SmokeColor )
	
	self:Core()

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
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
]]--

end

function EFFECT:Airburst( SmokeColor )

	self:Core()
	local Radius = self.Radius
	for i=0, 0.5*Radius*self.ParticleMul do --Flying Debris
	
		local Debris = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( VectorRand() * math.random(150*Radius,450*Radius) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 0.2 , 0.4 )*Radius/3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 2*Radius )
			Debris:SetEndSize( 2*Radius )
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

 
