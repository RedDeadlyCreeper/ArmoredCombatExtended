
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	self.Ent = data:GetEntity()
	self.Id = self.Ent:GetNWString( "AmmoType", "AP" )
	self.Caliber = self.Ent:GetNWFloat( "Caliber", 10 )
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal() 
	self.Velocity = data:GetScale() --Mass of the projectile in kg
	self.Mass = data:GetMagnitude() --Velocity of the projectile in gmod units
	self.Emitter = ParticleEmitter( self.Origin )
	
	self.Scale = math.max(self.Mass * (self.Velocity/39.37)/100,1)^0.3

	local Tr = {}
	Tr.start = self.Origin - self.DirVec*10
	Tr.endpos = self.Origin + self.DirVec*10
	local SurfaceTr = util.TraceLine( Tr )

	util.Decal("Impact.Concrete", SurfaceTr.StartPos, self.Origin + self.DirVec*10 )

	--debugoverlay.Cross( SurfaceTr.StartPos, 10, 3, Color(math.random(100,255),0,0) )
	--debugoverlay.Line( SurfaceTr.StartPos, self.Origin + self.DirVec*10, 2 , Color(math.random(100,255),0,0) )

	--this is crucial for subcaliber, this will boost the dust's size.
	self.SubCalBoost = {
		APDS = true,
		APDSS = true,
		APFSDS = true,
		APFSDSS = true,
		APCR = true,
		HVAP = true
	}

	--the dust is for non-explosive rounds, so lets skip this
	self.TypeIgnore = {
		APHE = true,
		APHECBC = true,
		HE = true,
		HEFS = true,
		HESH = true,
		HEAT = true,
		HEATFS = true,
		THEAT = true,
		THEATFS = true
	}

	self.Ignore = {
		npc = true,
		player =true
	}

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

 	--do this if we are dealing with non-explosive rounds. nil types are being created by HEAT, so skip it too
	if not self.TypeIgnore[self.Id] and self.Id ~= nil then

		if SurfaceTr.HitWorld or (IsValid(SurfaceTr.Entity) and self.Ignore[SurfaceTr.Entity:GetClass()]) then

			local Mat = SurfaceTr.MatType --print(Mat)

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
				self:Metal( SmokeColor )
			end
		end
	end

	local BulletEffect = {}
		BulletEffect.Num = 1
		BulletEffect.Src = self.Origin - self.DirVec
		BulletEffect.Dir = self.DirVec
		BulletEffect.Spread = Vector(0,0,0)
		BulletEffect.Tracer = 0
		BulletEffect.Force = 0
		BulletEffect.Damage = 0	 
	LocalPlayer():FireBullets(BulletEffect) 
	
	if self.Emitter then self.Emitter:Finish() end
 end   


--Sounds for impacts are coming soon
function EFFECT:Dust( SmokeColor )

	local PMul = self.ParticleMul
	local Vel = self.Velocity/2500
	local Mass = self.Mass

	--this is the size boost fo subcaliber rounds
	local Boost = ( self.SubCalBoost[self.Id] and 3) or 1

	--KE main formula
	local Energy = math.max(((Mass*(Vel^2))/2)*0.005 * Boost ,3)

	for i=0, math.max(self.Caliber/3,1) do

		local Dust = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin - self.DirVec*5 )
		if (Dust) then
			Dust:SetVelocity(VectorRand() * math.random( 25,35*Energy) )
			Dust:SetLifeTime( 0 )
			Dust:SetDieTime( math.Rand( 0.1 , 4 )*math.max(Energy,2)/3  )
			Dust:SetStartAlpha( math.Rand( math.max(SmokeColor.a-25,10), SmokeColor.a ) )
			Dust:SetEndAlpha( 0 )
			Dust:SetStartSize( 20*Energy )
			Dust:SetEndSize( 30*Energy )
			Dust:SetRoll( math.Rand(150, 360) )
			Dust:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Dust:SetAirResistance( 100 ) 			 
			Dust:SetGravity( Vector( math.random(-5,5)*Energy, math.random(-5,5)*Energy, -70 ) )

			Dust:SetColor( SmokeColor.r,SmokeColor.g,SmokeColor.b )		
		end
	end

end

function EFFECT:Metal( SmokeColor )

	SmokeColor.a = SmokeColor.a*0.5

	local PMul = self.ParticleMul
	local Vel = self.Velocity/2500
	local Mass = self.Mass

	--this is the size boost fo subcaliber rounds
	local Boost = ( self.SubCalBoost[self.Id] and 2) or 1

	--KE main formula
	local Energy = math.max(((Mass*(Vel^2))/2)*0.005 * Boost ,2)

	for i=0, math.max(self.Caliber/3,1) do

		local Dust = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin - self.DirVec*5 )
		if (Dust) then
			Dust:SetVelocity(VectorRand() * math.random( 25,35*Energy) )
			Dust:SetLifeTime( 0 )
			Dust:SetDieTime( math.Rand( 0.1 , 4 )*math.max(Energy,2)/3  )
			Dust:SetStartAlpha( math.Rand( math.max(SmokeColor.a-25,10), SmokeColor.a ) )
			Dust:SetEndAlpha( 0 )
			Dust:SetStartSize( 5*Energy )
			Dust:SetEndSize( 15*Energy )
			Dust:SetRoll( math.Rand(150, 360) )
			Dust:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Dust:SetAirResistance( 100 ) 			 
			Dust:SetGravity( Vector( math.random(-5,5)*Energy, math.random(-5,5)*Energy, -70 ) )

			Dust:SetColor( SmokeColor.r,SmokeColor.g,SmokeColor.b )		
		end
	end

	local Sparks = EffectData()
		Sparks:SetOrigin( self.Origin )
		Sparks:SetNormal( self.DirVec+VectorRand()*1.5)
		Sparks:SetMagnitude( self.Scale/1.75 )
		Sparks:SetScale( self.Scale/1.75 )
		Sparks:SetRadius( self.Scale/1.75 )
	util.Effect( "Sparks", Sparks )

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

 