AddCSLuaFile("shared.lua")
SWEP.Base = "ace_basewep"

if (CLIENT) then
SWEP.PrintName		= "XM25"
SWEP.Slot		    = 4
SWEP.SlotPos		= 1			
end

SWEP.Spawnable		= true	

--Visual
SWEP.ViewModelFlip 	= false
SWEP.ViewModel		= "models/weapons/v_xm25.mdl"	
SWEP.WorldModel		= "models/weapons/w_xm25.mdl"	
SWEP.ReloadSound	= "weapons/amr/sniper_reload.wav"	
SWEP.HoldType		= "ar2"		
SWEP.CSMuzzleFlashes	= false


-- Other settings
SWEP.Weight			= 10						
 
-- Weapon info		
SWEP.Purpose		= "Lob HE behind cover."	
SWEP.Instructions	= "LMB to shoot, RMB to adjust range"		

-- Primary fire settings
SWEP.Primary.Sound			= "acf_extra/tankfx/gnomefather/mortar1.wav"	
SWEP.Primary.NumShots		= 1	
SWEP.Primary.Recoil			= 0.25	
SWEP.Primary.RecoilAngleVer	= 0.15	
SWEP.Primary.RecoilAngleHor	= 0.1		
SWEP.Primary.Cone			= 0.0175		
SWEP.Primary.Delay			= 0.75
SWEP.Primary.ClipSize		= 5		
SWEP.Primary.DefaultClip	= 5			
SWEP.Primary.Force			= 1	
SWEP.Primary.Automatic		= 0	
SWEP.Primary.Ammo		= "SMG1"	

SWEP.Secondary.Ammo		= "none"	
SWEP.Secondary.ClipSize		= -1		
SWEP.Secondary.DefaultClip	= -1

SWEP.ReloadSoundEnabled = 1

SWEP.Category 			= "ACE Sweps - Sp"

SWEP.AimOffset = Vector(32, 8, -1)
SWEP.InaccuracyAccumulation = 0
SWEP.lastFire=CurTime()

SWEP.MaxInaccuracyMult = 2
SWEP.InaccuracyAccumulationRate = 0.15
SWEP.InaccuracyDecayRate = 1
SWEP.CarrySpeedMul = 0.6 --WalkSpeedMult when carrying the weapon


SWEP.fuseDelay = 0 -- Detonation Delay of weapon
--

function SWEP:InitBulletData()
	
	self.BulletData = {}

		self.BulletData.Id = "20mmGL"
		self.BulletData.Type = "HE"
		self.BulletData.Id = 3
		self.BulletData.Caliber = 2.5
		self.BulletData.PropLength = 7 --Volume of the case as a cylinder * Powder density converted from g to kg		
		self.BulletData.ProjLength = 100 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		self.BulletData.Data5 = 25  --He Filler or Flechette count
		self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
		self.BulletData.Data7 = 0
		self.BulletData.Data8 = 0
		self.BulletData.Data9 = 0
		self.BulletData.Data10 = 1 -- Tracer
		self.BulletData.Colour = Color(255, 100, 100)
		--
		self.BulletData.Data13 = 0 --THEAT ConeAng2
		self.BulletData.Data14 = 0 --THEAT HE Allocation
		self.BulletData.Data15 = 0
	
		self.BulletData.AmmoType  = self.BulletData.Type
		self.BulletData.FrAera    = 3.1416 * (self.BulletData.Caliber/2)^2
		self.BulletData.ProjMass  = self.BulletData.FrAera * (self.BulletData.ProjLength*7.9/1000)
		self.BulletData.PropMass  = self.BulletData.FrAera * (self.BulletData.PropLength*ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
		self.BulletData.FillerVol = self.BulletData.Data5
		self.BulletData.FillerMass = self.BulletData.FillerVol * ACF.HEDensity/1000
				self.BulletData.DragCoef  = 0 --Alternatively manually set it
		--self.BulletData.DragCoef  = ((self.BulletData.FrAera/10000)/self.BulletData.ProjMass)	

		--Don't touch below here
		self.BulletData.MuzzleVel = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber )		
		self.BulletData.ShovePower = 0.2
		self.BulletData.KETransfert = 0.3
		self.BulletData.PenAera = self.BulletData.FrAera^ACF.PenAreaMod
		self.BulletData.Pos = Vector(0 , 0 , 0)
		self.BulletData.LimitVel = 800	
		self.BulletData.Ricochet = 60
		self.BulletData.Flight = Vector(0 , 0 , 0)
		self.BulletData.BoomPower = self.BulletData.PropMass
		
		--For Fake Crate
		self.Type = self.BulletData.Type
		self.BulletData.Tracer = self.BulletData.Data10
		self.Tracer = self.BulletData.Tracer
		self.Caliber = self.BulletData.Caliber
		self.ProjMass = self.BulletData.ProjMass
		self.FillerMass = self.BulletData.FillerMass
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
	self.BulletData.FuseLength = self.fuseDelay

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

function SWEP:SecondaryAttack()

	if CLIENT then 
	return 
	end

	local RangeTrace = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 50000, { self.Owner } )
	
	if RangeTrace.Hit then
	self.fuseDelay = ((self.Owner:GetShootPos()-RangeTrace.HitPos):Length()/39.37+1)/172
	end

	self.Owner:SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 2)", "Fuse Delay: "..math.Round(self.fuseDelay*172).." m"))
	
	
	return 
	
end

