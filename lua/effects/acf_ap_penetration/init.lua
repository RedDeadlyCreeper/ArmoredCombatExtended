local ACFEnts = list.Get("ACFEnts")
local GunTable = ACFEnts.Guns
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	self.Ent = data:GetEntity()
	self.Caliber = self.Ent:GetNWFloat( "Caliber", 10 )
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal() 
	self.Velocity = data:GetScale() --Mass of the projectile in kg
	self.Mass = data:GetMagnitude() --Velocity of the projectile in gmod units
	self.Emitter = ParticleEmitter( self.Origin )
	self.ParticleMul = math.Max( tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 0, 0)
	
	self.Scale = math.max(self.Mass * (self.Velocity/39.37)/100,1)^0.3

	local ImpactTr = { }
		ImpactTr.start = self.Origin - self.DirVec*20
		ImpactTr.endpos = self.Origin + self.DirVec*100
	local Impact = util.TraceLine(ImpactTr)					--Trace to see if it will hit anything
	self.Normal = Impact.HitNormal

	if IsValid(Impact.Entity) then
		debugoverlay.Text(self.Origin - self.DirVec*20, Impact.Entity:GetClass(), 5)
	end
	debugoverlay.Line(self.Origin - self.DirVec*20, Impact.HitPos , 5, Color(0,255,255))

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

	--local Mat = Impact.MatType
	--print(Mat)

	self:Prop()

	ACE_SPen( self.Origin, self.Velocity, self.Mass )

	if IsValid(self.Emitter) then self.Emitter:Finish() end
 end   

function EFFECT:Prop()
  
	util.Decal("Impact.Concrete", self.Origin - self.DirVec*50, self.Origin + self.DirVec*50, self.Ent )

	for i=0, self.Scale*self.ParticleMul do
	
		local Debris = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( self.Normal * math.random( 20,140*self.Scale) + VectorRand() * math.random( 25,150*self.Scale) )
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 1.5 , 3 )*self.Scale/3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 1*self.Scale )
			Debris:SetEndSize( 1*self.Scale )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )			
			Debris:SetAirResistance( 100 ) 			 
			Debris:SetGravity( Vector( 0, 0, -650 ) ) 			
			Debris:SetColor( 120,120,120 )
		end
	end
	
	for i=0, self.Scale*self.ParticleMul do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 20,40*self.Scale) + VectorRand() * math.random( 25,50*self.Scale) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*self.Scale/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 1*self.Scale )
			Smoke:SetEndSize( 2*self.Scale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 200 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*self.Scale, math.random(-5,5)*self.Scale, -50 ) ) 			
			Smoke:SetColor( 90,90,90 )
		end
	
	end
	
	for i=0, self.Scale*self.ParticleMul do
	
		local Embers = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Origin )
		if (Embers) then
			Embers:SetVelocity ( (self.Normal - VectorRand()) * math.random(30*self.Scale,80*self.Scale) )
			Embers:SetLifeTime( 0 )
			Embers:SetDieTime( math.Rand( 0.3 , 1 )*self.Scale/5 )
			Embers:SetStartAlpha( 255 )
			Embers:SetEndAlpha( 0 )
			Embers:SetStartSize( 10*self.Scale )
			Embers:SetEndSize( 0*self.Scale )
			Embers:SetStartLength( 5*self.Scale )
			Embers:SetEndLength ( 0*self.Scale )
			Embers:SetRoll( math.Rand(0, 360) )
			Embers:SetRollDelta( math.Rand(-0.2, 0.2) )	
			Embers:SetAirResistance( 20 ) 			 
			Embers:SetGravity( VectorRand()*10 ) 			
			Embers:SetColor( 200,200,200 )
		end
	end

	local Sparks = EffectData()
		Sparks:SetOrigin( self.Origin )
		Sparks:SetNormal( self.Normal+VectorRand()*1.5)
		Sparks:SetMagnitude( self.Scale )
		Sparks:SetScale( self.Scale )
		Sparks:SetRadius( self.Scale )
	util.Effect( "sparks", Sparks )

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end

 