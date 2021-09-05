
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal() 
	self.Velocity = data:GetScale() --Velocity of the projectile in gmod units
	self.Mass = data:GetMagnitude() --Mass of the projectile in kg
	self.Emitter = ParticleEmitter( self.Origin )
	
	self.Scale = math.max(self.Mass * (self.Velocity/39.37)/100,1)^0.3

	--self.Entity:EmitSound( "ambient/explosions/explode_1.wav" , 100 + self.Radius*10, 200 - self.Radius*10 )
	
	local BulletEffect = {}
		BulletEffect.Num = 1
		BulletEffect.Src = self.Origin - self.DirVec
		BulletEffect.Dir = self.DirVec
		BulletEffect.Spread = Vector(0,0,0)
		BulletEffect.Tracer = 0
		BulletEffect.Force = 0
		BulletEffect.Damage = 0	 
	LocalPlayer():FireBullets(BulletEffect) 

	local soundlvl = self.Mass*2.6
	--print('rico sound level: '..soundlvl)

	--how i love the sound level.....
	--TODO: Other sounds for small weapons, since the current is for >100mm cannons
	sound.Play(  "/acf_other/ricochets/richo"..math.random(1,7)..".wav", self.Origin, math.Clamp(soundlvl, 80,150), math.Clamp(self.Velocity*0.01,25,125), 1)

	util.Decal("ExplosiveGunshot", self.Origin + self.DirVec*10, self.Origin - self.DirVec*10)
	
	if self.Emitter then self.Emitter:Finish() end
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

 