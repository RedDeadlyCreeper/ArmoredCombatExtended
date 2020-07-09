AddCSLuaFile("shared.lua")
SWEP.Base = "ace_basewep"

if (CLIENT) then
SWEP.PrintName		= "Anti Tank Rifle"
SWEP.Slot		    = 3
SWEP.SlotPos		= 1			
end

SWEP.Spawnable		= true	

--Visual
SWEP.ViewModelFlip 	= false
SWEP.ViewModel		= "models/weapons/v_sniper.mdl"	
SWEP.WorldModel		= "models/weapons/w_sniper.mdl"	
SWEP.ReloadSound	= "Weapon_Pistol.Reload"	
SWEP.HoldType		= "ar2"		
SWEP.CSMuzzleFlashes	= true


-- Other settings
SWEP.Weight			= 10						
SWEP.ZoomAccuracyImprovement = 0.95 -- 0.3 means 0.7 the inaccuracy
SWEP.ZoomRecoilImprovement = 0.6 -- 0.3 means 0.7 the recoil movement 

SWEP.CrouchAccuracyImprovement = 0.85 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement = 0.8 -- 0.3 means 0.7 the recoil movement

-- Weapon info		
SWEP.Purpose		= "Oversized Tank Sniper"	
SWEP.Instructions	= "Crouch when aiming, Left mouse to shoot"		

-- Primary fire settings
SWEP.Primary.Sound			= "acf_extra/tankfx/gnomefather/40mm4.wav"	
SWEP.Primary.NumShots		= 1	
SWEP.Primary.Recoil			= 1	
SWEP.Primary.RecoilAngle	= 1		
SWEP.Primary.Cone			= 0.025		
SWEP.Primary.Delay			= 5
SWEP.Primary.ClipSize		= 1		
SWEP.Primary.DefaultClip	= 1			
SWEP.Primary.Force			= 1	
SWEP.Primary.Automatic		= 1	
SWEP.Primary.Ammo		= "XBowBolt"	

SWEP.Secondary.Ammo		= "none"	
SWEP.Secondary.ClipSize		= -1		
SWEP.Secondary.DefaultClip	= -1

SWEP.ReloadSoundEnabled = 1

SWEP.Category 			= "ACE Sweps - Sp"

SWEP.AimOffset = Vector(0,0,0)
SWEP.InaccuracyAccumulation = 0
SWEP.lastFire=CurTime()

SWEP.MaxInaccuracyMult = 5
SWEP.InaccuracyAccumulationRate = 0.3
SWEP.InaccuracyDecayRate = 1

SWEP.HasScope = true
SWEP.ZoomFOV = 5

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -15, 2.98)
SWEP.ZoomPos = Vector(2,-2,2)
SWEP.IronSightsAng = Angle(0.45, 0, 0)
SWEP.ZoomFOV = 20

SWEP.CrouchAccuracyImprovement = 0.8 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement = 0.5 -- 0.3 means 0.7 the recoil movement
--

function SWEP:InitBulletData()
	
	self.BulletData = {}

		self.BulletData.Id = "20mmMG"
		self.BulletData.Type = "HVAP"
		self.BulletData.Id = 1
		self.BulletData.Caliber = 2.0
		self.BulletData.PropLength = 10 --Volume of the case as a cylinder * Powder density converted from g to kg		
		self.BulletData.ProjLength = 12 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		self.BulletData.Data5 = 0.2  --He Filler or Flechette count or subcaliber modifier
		self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
		self.BulletData.Data7 = 0
		self.BulletData.Data8 = 0
		self.BulletData.Data9 = 0
		self.BulletData.Data10 = 1 -- Tracer
		self.BulletData.Colour = Color(0, 255, 0)
		--
		self.BulletData.Data13 = 0 --THEAT ConeAng2
		self.BulletData.Data14 = 0 --THEAT HE Allocation
		self.BulletData.Data15 = 0
	
		self.BulletData.AmmoType  = self.BulletData.Type
		self.BulletData.FrAera    = 3.1416 * (self.BulletData.Caliber/2)^2
		self.BulletData.SubFrAera = self.BulletData.FrAera * self.BulletData.Data5
		self.BulletData.PenAera = (1.2*self.BulletData.SubFrAera)^ACF.PenAreaMod	
		self.BulletData.ProjMass = (self.BulletData.SubFrAera * (self.BulletData.ProjLength*7.9/1000) * 1.5 + (self.BulletData.FrAera - self.BulletData.SubFrAera) * (self.BulletData.ProjLength*7.9/10000)) --(Tungsten Core Mass + Sabot Exterior Mass) * Mass modifier used for bad aerodynamics


		self.BulletData.PropMass  = self.BulletData.FrAera * (self.BulletData.PropLength*ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
--		self.BulletData.DragCoef  = 0 --Alternatively manually set it
		self.BulletData.DragCoef  = ((self.BulletData.FrAera/10000)/self.BulletData.ProjMass)	

		--Don't touch below here
		self.BulletData.MuzzleVel = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber )		
		self.BulletData.ShovePower = 0.2
		self.BulletData.KETransfert = 0.3
		self.BulletData.Pos = Vector(0 , 0 , 0)
		self.BulletData.LimitVel = 900	
		self.BulletData.Ricochet = 60
		self.BulletData.Flight = Vector(0 , 0 , 0)
		self.BulletData.BoomPower = self.BulletData.PropMass
		
		--For Fake Crate
		self.Type = self.BulletData.Type
		self.BulletData.Tracer = self.BulletData.Data10
		self.Tracer = self.BulletData.Tracer
		self.Caliber = self.BulletData.Caliber
		self.ProjMass = self.BulletData.ProjMass
		self.FillerMass = self.BulletData.Data5
		self.DragCoef = self.BulletData.DragCoef
		self.Colour = self.BulletData.Colour
		
end	
		
function SWEP:PrimaryAttack()		
	if ( !self:CanPrimaryAttack() ) then return end		

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	
	self.Weapon:EmitSound(Sound(self.Primary.Sound), 100, 100, 1, CHAN_WEAPON )		

	if CLIENT then 
		return 
		end
	
	self.BulletData.Owner = self.Owner
	self.BulletData.Gun = self	
	self.InaccuracyAccumulation = math.Clamp(self.InaccuracyAccumulation + self.InaccuracyAccumulationRate - self.InaccuracyDecayRate*(CurTime()-self.lastFire),1,self.MaxInaccuracyMult)
	
	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( true )
	end

	self:ACEFireBullet()
	
	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( false )
	end
	
	self.lastFire=CurTime()
--	print("Inaccuracy: "..self.InaccuracyAccumulation)
	
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )							
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			
	self.Owner:ViewPunch(Angle( -self.Primary.Recoil + math.Rand(-self.Primary.RecoilAngleVer,self.Primary.RecoilAngleVer), math.Rand(-self.Primary.RecoilAngleHor,self.Primary.RecoilAngleHor), 0 )*(1+self.InaccuracyAccumulation))	
	if (self.Primary.TakeAmmoPerBullet) then			
		self:TakePrimaryAmmo(self.Primary.NumShots)
	else
		self:TakePrimaryAmmo(1)
	end
end

function SWEP:Reload()	

	if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 and self.ReloadSoundEnabled == 1 then
	self.Weapon:EmitSound(Sound(self.ReloadSound))
	end
	self:DefaultReload(ACT_VM_RELOAD)
	
--player.GetByID( 1 ):GiveAmmo( 30-self:Clip1(), "AR2", true )
	self:Think()
	return true
end



