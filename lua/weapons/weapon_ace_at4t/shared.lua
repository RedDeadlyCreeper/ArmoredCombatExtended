SWEP.PrintName = "AT-4 Proto"
SWEP.Base = "weapon_ace_base"
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Special"
SWEP.Purpose = "Clear Backblast!"
SWEP.Spawnable = true
SWEP.Slot = 4 --Which inventory column the weapon appears in
SWEP.SlotPos = 3 --Priority in which the weapon appears, 1 tries to put it at the top


--Main settings--
SWEP.FireRate = 0.15 --Rounds per second

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/at4p_multi.mp3"
SWEP.Primary.LightScale = 200 --Muzzleflash light radius
SWEP.Primary.BulletCount = 1 --Number of bullets to fire each shot, used for shotguns

SWEP.ReloadSound = "Weapon_Pistol.Reload" --Sound other players hear when you reload - this is NOT your first-person sound
										--Most models have a built-in first-person reload sound

SWEP.ZoomFOV = 60
SWEP.HasScope = false --True if the weapon has a sniper-style scope


--Recoil (crosshair movement) settings--
--"Heat" is a number that represents how long you've been firing, affecting how quickly your crosshair moves upwards
SWEP.HeatReductionRate = 75 --Heat loss per second when not firing
SWEP.HeatReductionDelay = 0.3 --Delay after firing before beginning to reduce heat
SWEP.HeatPerShot = 20 --Heat generated per shot
SWEP.HeatMax = 25 --Maximum heat - determines max rate at which recoil is applied to eye angles
				--Also determines point at which random spread is at its highest intensity
				--HeatMax divided by HeatPerShot gives you how many shots until you reach MaxSpread

SWEP.RecoilSideBias = 0.1 --How much the recoil is biased to one side proportional to vertical recoil
						--Positive numbers bias to the right, negative to the left

SWEP.ZoomRecoilBonus = 0.5 --Reduce recoil by this amount when zoomed or scoped
SWEP.CrouchRecoilBonus = 0.5 --Reduce recoil by this amount when crouching
SWEP.ViewPunchAmount = 10 --Degrees to punch the view upwards each shot - does not actually move crosshair, just a visual effect


--Spread (aimcone) settings--
SWEP.BaseSpread = 0.75 --First-shot random spread, in degrees
SWEP.MaxSpread = 0 --Maximum added random spread from heat value, in degrees
					--If HeatMax is 0 this will be ignored and only BaseSpread will be taken into account (AT4 for example)
SWEP.MovementSpread = 10 --Increase aimcone to this many degrees when sprinting at full speed
SWEP.UnscopedSpread = 8 --Spread, in degrees, when unscoped with a scoped weapon

SWEP.CarrySpeedMul			= 0.5

--Model settings--
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_RPG.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType = "rpg"
SWEP.DeployDelay = 2 --Time before you can fire after deploying the weapon
SWEP.CSMuzzleFlashes = false


function SWEP:InitBulletData()
	self.BulletData = {}
	self.BulletData.Id = "75mmHW"
	self.BulletData.Type = "THEAT"
	self.BulletData.Id = 2
	self.BulletData.Caliber = 12.0
	self.BulletData.PropLength = 2 --Volume of the case as a cylinder * Powder density converted from g to kg
	self.BulletData.ProjLength = 60 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
	self.BulletData.Data5 = 12000 --He Filler or Flechette count
	self.BulletData.Data6 = 60 --HEAT ConeAng or Flechette Spread
	self.BulletData.Data7 = 0
	self.BulletData.Data8 = 0
	self.BulletData.Data9 = 0
	self.BulletData.Data10 = 1 -- Tracer
	self.BulletData.Colour = Color(255, 110, 0)
	--
	self.BulletData.Data13 = 57 --THEAT ConeAng2
	self.BulletData.Data14 = 0.85 --THEAT HE Allocation
	self.BulletData.Data15 = 0
	self.BulletData.AmmoType = self.BulletData.Type
	self.BulletData.FrArea = 3.1416 * (self.BulletData.Caliber / 2) ^ 2
	self.BulletData.ProjMass = self.BulletData.FrArea * (self.BulletData.ProjLength * 7.9 / 1000)
	self.BulletData.PropMass = self.BulletData.FrArea * (self.BulletData.PropLength * ACF.PDensity / 1000) --Volume of the case as a cylinder * Powder density converted from g to kg
	self.BulletData.FillerVol = self.BulletData.Data5
	self.BulletData.FillerMass = self.BulletData.FillerVol * ACF.HEDensity / 1000
	self.BulletData.BoomFillerMass = self.BulletData.FillerMass / 250
	local ConeArea = 3.1416 * self.BulletData.Caliber / 2 * ((self.BulletData.Caliber / 2) ^ 2 + self.BulletData.ProjLength ^ 2) ^ 0.5
	local ConeThick = self.BulletData.Caliber / 50
	local ConeVol = ConeArea * ConeThick
	self.BulletData.SlugMass = ConeVol * 7.9 / 1000
	self.BulletData.SlugMass2 = ConeVol * 7.9 / 1000
	local Rad = math.rad(self.BulletData.Data6 / 2)
	self.BulletData.HEAllocation = self.BulletData.Data14
	self.BulletData.SlugCaliber = self.BulletData.Caliber - self.BulletData.Caliber * (math.sin(Rad) * 0.5 + math.cos(Rad) * 1.5) / 2
	self.BulletData.SlugMV = (self.BulletData.FillerMass / 2 * (1 - self.BulletData.HEAllocation) * ACF.HEPower * math.sin(math.rad(10 + self.BulletData.Data6) / 2) / self.BulletData.SlugMass) ^ ACF.HEATMVScale
	self.BulletData.SlugCaliber2 = self.BulletData.Caliber - self.BulletData.Caliber * (math.sin(Rad) * 0.5 + math.cos(Rad) * 1.5) / 2
	self.BulletData.SlugMV2 = (self.BulletData.FillerMass / 2 * self.BulletData.HEAllocation * ACF.HEPower * math.sin(math.rad(10 + self.BulletData.Data6) / 2) / self.BulletData.SlugMass) ^ ACF.HEATMVScale
	--		print("SlugMV: " .. self.BulletData.SlugMV)
	--		print("SlugMV2: " .. self.BulletData.SlugMV2)
	self.BulletData.Detonated = 0
	local SlugFrArea = 3.1416 * (self.BulletData.SlugCaliber / 2) ^ 2
	local SlugFrArea2 = 3.1416 * (self.BulletData.SlugCaliber2 / 2) ^ 2
	self.BulletData.SlugPenArea = SlugFrArea ^ ACF.PenAreaMod
	self.BulletData.SlugPenArea2 = SlugFrArea ^ ACF.PenAreaMod
	self.BulletData.SlugDragCoef = ((SlugFrArea / 10000) / self.BulletData.SlugMass) * 1000
	self.BulletData.SlugDragCoef2 = ((SlugFrArea2 / 10000) / self.BulletData.SlugMass2) * 1000
	self.BulletData.SlugRicochet = 500 --Base ricochet angle (The HEAT slug shouldn't ricochet at all)
	self.BulletData.SlugRicochet2 = 500 --Base ricochet angle (The HEAT slug shouldn't ricochet at all)
	self.BulletData.CasingMass = self.BulletData.ProjMass - self.BulletData.FillerMass - ConeVol * 7.9 / 1000
	self.BulletData.Fragments = math.max(math.floor((self.BulletData.BoomFillerMass / self.BulletData.CasingMass) * ACF.HEFrag), 2)
	self.BulletData.FragMass = self.BulletData.CasingMass / self.BulletData.Fragments
	--		self.BulletData.DragCoef  = 0 --Alternatively manually set it
	self.BulletData.DragCoef = (self.BulletData.FrArea / 10000) / self.BulletData.ProjMass
	--Don't touch below here
	self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
	self.BulletData.ShovePower = 0.2
	self.BulletData.KETransfert = 0.3
	self.BulletData.PenArea = self.BulletData.FrArea ^ ACF.PenAreaMod
	self.BulletData.Pos = Vector(0, 0, 0)
	self.BulletData.LimitVel = 800
	self.BulletData.Ricochet = 999
	self.BulletData.Flight = Vector(0, 0, 0)
	self.BulletData.BoomPower = self.BulletData.PropMass + self.BulletData.FillerMass
	--		local SlugEnergy = ACF_Kinetic( self.BulletData.MuzzleVel * 39.37 + self.BulletData.SlugMV * 39.37 , self.BulletData.SlugMass, 999999 )
	local SlugEnergy = ACF_Kinetic(self.BulletData.SlugMV * 39.37, self.BulletData.SlugMass, 999999)
	self.BulletData.MaxPen = (SlugEnergy.Penetration / self.BulletData.SlugPenArea) * ACF.KEtoRHA
	--		print("SlugPen: " .. self.BulletData.MaxPen)
	local SlugEnergy = ACF_Kinetic(self.BulletData.SlugMV2 * 39.37, self.BulletData.SlugMass2, 999999)
	self.BulletData.MaxPen = (SlugEnergy.Penetration / self.BulletData.SlugPenArea2) * ACF.KEtoRHA
	--		print("SlugPen2: " .. self.BulletData.MaxPen)
	--For Fake Crate
	self.BoomFillerMass = self.BulletData.BoomFillerMass
	self.Type = self.BulletData.Type
	self.BulletData.Tracer = self.BulletData.Data10
	self.Tracer = self.BulletData.Tracer
	self.Caliber = self.BulletData.Caliber
	self.ProjMass = self.BulletData.ProjMass
	self.FillerMass = self.BulletData.FillerMass
	self.DragCoef = self.BulletData.DragCoef
	self.Colour = self.BulletData.Colour
	self.DetonatorAngle = 80
end
