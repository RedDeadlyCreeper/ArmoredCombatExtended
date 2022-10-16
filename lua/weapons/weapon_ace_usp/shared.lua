SWEP.PrintName = "USP"
SWEP.Base = "weapon_ace_base"
SWEP.Spawnable = true
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Pistols"

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.HoldType = "pistol"
SWEP.CSMuzzleFlashes = true

SWEP.FireRate = 8

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/usp_multi.mp3"
SWEP.Primary.Automatic = false

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP.HasScope = false
SWEP.ZoomFOV = 60

SWEP.ViewPunchAmount = 0.5
SWEP.HeatPerShot = 4
SWEP.HeatMax = 16
SWEP.HeatReductionRate = 75
SWEP.BaseSpread = 0.07
SWEP.MaxSpread = 3.5
SWEP.RecoilSideBias = -0.1

function SWEP:InitBulletData()
    self.BulletData = {}
    self.BulletData.Id = "7.62mmMG"
    self.BulletData.Type = "AP"
    self.BulletData.Id = 1
    self.BulletData.Caliber = 0.9
    self.BulletData.PropLength = 2.2 --Volume of the case as a cylinder * Powder density converted from g to kg		
    self.BulletData.ProjLength = 1.3 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
    self.BulletData.Data5 = 0 --He Filler or Flechette count
    self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
    self.BulletData.Data7 = 0
    self.BulletData.Data8 = 0
    self.BulletData.Data9 = 0
    self.BulletData.Data10 = 1 -- Tracer
    self.BulletData.Colour = Color(255, 0, 0)
    --
    self.BulletData.Data13 = 0 --THEAT ConeAng2
    self.BulletData.Data14 = 0 --THEAT HE Allocation
    self.BulletData.Data15 = 0
    self.BulletData.AmmoType = self.BulletData.Type
    self.BulletData.FrArea = 3.1416 * (self.BulletData.Caliber / 2) ^ 2
    self.BulletData.ProjMass = self.BulletData.FrArea * (self.BulletData.ProjLength * 7.9 / 1000)
    self.BulletData.PropMass = self.BulletData.FrArea * (self.BulletData.PropLength * ACF.PDensity / 1000) --Volume of the case as a cylinder * Powder density converted from g to kg
    self.BulletData.DragCoef = 0.01 --Alternatively manually set it
    --		self.BulletData.DragCoef  = ((self.BulletData.FrArea/10000)/self.BulletData.ProjMass)	
    --Don't touch below here
    self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
    self.BulletData.ShovePower = 0.2
    self.BulletData.KETransfert = 0.3
    self.BulletData.PenArea = self.BulletData.FrArea ^ ACF.PenAreaMod * 0.6
    self.BulletData.Pos = Vector(0, 0, 0)
    self.BulletData.LimitVel = 800
    self.BulletData.Ricochet = 60
    self.BulletData.Flight = Vector(0, 0, 0)
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